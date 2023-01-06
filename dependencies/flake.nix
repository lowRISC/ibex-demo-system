{
  description = "ibex simple_system dependencies";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    lowrisc_fusesoc_src = { url = "github:lowRISC/fusesoc?ref=ot-0.2"; flake = false; };
    lowrisc_edalize_src = { url = "github:lowRISC/edalize?ref=ot-0.2"; flake = false; };
  };

  outputs = {self, nixpkgs,
              lowrisc_fusesoc_src, lowrisc_edalize_src,
  }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };

      lowRISC_python_overrides = pfinal: pprev: {
        fusesoc = pprev.fusesoc.overridePythonAttrs (oldAttrs: {
          version = "0.3.3.dev";
          src = lowrisc_fusesoc_src;
        });
        edalize = pprev.edalize.overridePythonAttrs (oldAttrs: {
          version = "0.3.3.dev";
          src = lowrisc_edalize_src;
        });
      };

      lowRISC_spike_override = final: prev: {
        riscv-isa-sim = prev.riscv-isa-sim.overrideAttrs (oldAttrs: rec {
          version = "ibex-cosim-v0.3";
          src = pkgs.fetchFromGitHub {
            owner = "lowrisc";
            repo = oldAttrs.pname;
            rev = version;
            sha256 = "sha256-pKuOpzybOI8UqWV1TSFq4hqTHf7Bft/3WL19fRpwmfU=";
          };
        });
      };

      # Using requireFile prevents rehashing each time.
      # This saves much seconds during rebuilds.
      vivado_bundled_installer_src = pkgs.requireFile rec {
        name = "vivado_bundled.tar.gz";
        sha256 = "1yxx6crvawhzvary9js0m8bzm35vv6pzfqdkv095r84lb13fyp7b";
        # Print the following message if the name / hash are not
        # found in the store.
        message = ''
          requireFile :
          file/dir not found in /nix/store
          file = ${name}
          hash = ${sha256}

          This nix expression requires that ${name} is already part of the store.
          - Login to xilinx.com
          - Download Unified Installer from https://www.xilinx.com/support/download.html,
          - Run installer, specify a 'Download Image (Install Seperately)'
          - Gzip the bundled installed image directory
          - Rename the file to ${name}
          - Add it to the nix store with
              nix-prefetch-url --type sha256 file:/path/to/${name}
          - Change the sha256 key above to $HASH
        '';
      };

      vivado = pkgs.callPackage (import ./vivado.nix) {
        # We need to prepare the pre-downloaded installer to
        # execute within a nix build. Make use of the included java deps,
        # but we still need to do a little patching to make it work.
        vivado-src = pkgs.stdenv.mkDerivation rec {
          pname = "vivado_src";
          version = "2022.2";
          src = vivado_bundled_installer_src;
          postPatch = ''
            patchShebangs .
            patchelf \
              --set-interpreter $(cat ${pkgs.stdenv.cc}/nix-support/dynamic-linker) \
              tps/lnx64/jre*/bin/java
          '';
          dontBuild = true; dontFixup = true;
          installPhase = ''
            mkdir -p $out
            cp -R * $out
          '';
        };
      };

    in
      {
        overlay_pkgs = pkgs.lib.composeManyExtensions [
          (import ./overlay.nix)
          lowRISC_spike_override
          (final: prev: {
            inherit vivado;
          })
        ];
        overlay_python = pkgs.lib.composeManyExtensions [
          (import ./python-overlay.nix)
          lowRISC_python_overrides
        ];
      };
}
