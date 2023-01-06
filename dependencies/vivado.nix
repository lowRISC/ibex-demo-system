{ stdenv, lib, breakpointHook
, fetchurl, patchelf, makeWrapper
, vivado-src
, coreutils
, procps
, zlib
, ncurses5
, libxcrypt
, libuuid
, libSM
, libICE
, libX11
, libXrender
, libxcb
, libXext
, libXtst
, libXi
, glib
, gtk2
, freetype
}:

stdenv.mkDerivation rec {
  pname = "vivado";
  version = "2022.2";

  # src = vivado-src;

  nativeBuildInputs = [
    vivado-src
    makeWrapper
    breakpointHook
  ];

  buildInputs = [
    procps
    ncurses5
    libxcrypt
  ];

  dontUnpack = true;
  dontBuild = true;
  dontStrip = true;

  libPath = lib.makeLibraryPath [
    stdenv.cc.cc
    ncurses5 zlib libxcrypt
    libuuid libSM libICE libX11 libXrender libxcb libXext libXtst libXi
    glib gtk2 freetype
  ];

  installPhase = ''
    cat <<EOF > install_config.txt
    Edition=Vivado ML Standard
    Product=Vivado
    Destination=$out/opt
    Modules=Spartan-7:1,Virtex-7:1,Artix-7:1
    InstallOptions=
    CreateProgramGroupShortcuts=0
    ProgramGroupFolder=Xilinx Design Tools
    CreateShortcutsForAllUsers=0
    CreateDesktopShortcuts=0
    CreateFileAssociation=0
    EOF

    mkdir -p $out/opt
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${libPath}"
    export HOME=$out/userhome

    # The installer will be killed as soon as it says that post install tasks have failed.
    # This is required because it tries to run the unpatched scripts to check if the installation
    # has succeeded. However, these scripts will fail because they have not been patched yet,
    # and the installer will proceed to delete the installation if not killed.
    (${vivado-src}/xsetup \
      --agree XilinxEULA,3rdPartyEULA \
      --batch Install \
      --config install_config.txt || true) | while read line
    do
        [[ "''${line}" == *"Execution of Pre/Post Installation Tasks Failed"* ]] \
          && echo "killing installer!" \
          && ((pkill -9 -f "tps/lnx64/jre/bin/java") || true)

        echo ''${line}
    done
  '';


  preFixup = ''
    echo "Patch installed scripts"
    patchShebangs $out/opt/Vivado/${version}/bin || true

    echo "Hack around lack of libtinfo in NixOS"
    ln -s ${ncurses5}/lib/libncursesw.so.6 $out/opt/Vivado/${version}/lib/lnx64.o/libtinfo.so.5 || true

    echo "Patch ELFs"
    for f in $out/opt/Vivado/${version}/bin/unwrapped/lnx64.o/* \
             $out/opt/Vitis_HLS/${version}/bin/unwrapped/lnx64.o/*
    do
      patchelf --set-interpreter "$(cat ${stdenv.cc}/nix-support/dynamic-linker)" $f || true
    done

    echo "Wrapping binaries"
    for f in $out/opt/Vivado/${version}/bin/vivado \
             $out/opt/Vitis_HLS/${version}/bin/vitis_hls
    do
      wrapProgram $f --prefix LD_LIBRARY_PATH : "${libPath}" || true
    done

    # 'wrapProgram' on its own does not work
    # - This is because of the way the Vivado script runs ./loader
    # - Therefore, we need ---Even More Patches...---
    echo "Even More Patches..."
    sed -i -- 's|`basename "\$0"`|vivado|g' $out/opt/Vivado/$version/bin/.vivado-wrapped

    echo "Adding to bin"
    mkdir $out/bin
    ln -s $out/opt/Vivado/${version}/bin/vivado $out/bin/vivado || true
  '';

  meta = with lib; {
    description = "Xilinx Vivado";
    homepage = "https://www.xilinx.com/products/design-tools/vivado.html";
    license = licenses.unfree;
  };
}

