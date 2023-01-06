{
  description = "Environment for synthesizing and simulating the ibex-demo-system.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    deps = {
      url = "path:./dependencies";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = all@{ self, nixpkgs, flake-utils, deps, ... }:

    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
          overlays =
            [ # Add extra packages we might need
              # Currently this contains the lowrisc riscv-toolchain, and spike
              deps.overlay_pkgs
              # Add all the python packages we need that aren't in nixpkgs
              # (See the ./dependencies folder for more info)
              (final: prev: {
                python3 = prev.python3.override {
                  packageOverrides = deps.overlay_python;
                };
              })
              # Add some missing dependencies to nixpkgs#verilator
              (final: prev: {
                verilator = prev.verilator.overrideAttrs ( oldAttrs : {
                  propagatedBuildInputs = [ final.zlib final.libelf ];
                });
              })
            ];
        };


        # Currently we don't build the riscv-toolchain from src, we use a github release
        # (See ./dependencies/riscv-gcc-toolchain-lowrisc.nix)

        # riscv-toolchain (built from src) # BROKEN
        # riscv-gcc-toolchain-lowrisc-src = pkgs.callPackage \
        #   ./dependencies/riscv_gcc.nix {
        #     riscv-arch = "rv32imc";
        #   };

        pythonEnv = pkgs.python3.withPackages(ps:
          with ps; [ pip fusesoc edalize pyyaml Mako ]
        );

        # This is the final list of dependencies we need to build the project.
        project_deps = [
          pythonEnv
        ] ++ (with pkgs; [
          cmake
          openocd
          screen
          verilator
          riscv-gcc-toolchain-lowrisc
          gtkwave
          srecord
          openfpgaloader
          # vivado
        ]);

      in {
        packages.dockertest = pkgs.dockerTools.buildImage {
          name = "hello-docker";
          copyToRoot = pkgs.buildEnv {
            name = "image-root";
            paths = [ pkgs.coreutils
                      pkgs.sl ];
          };
          config = {
            Cmd = [ "${pkgs.sl}/bin/sl" ];
          };
        };
        devShells.default = pkgs.mkShell {
          name = "labenv";
          buildInputs = project_deps;
          shellHook = ''
            # FIXME This works on Ubuntu, may not on other distros. FIXME
            export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive

            # HACK fixup some paths to use our sandboxed python environment
            # Currently, fusesoc tries to invoke the program 'python3' from the
            # PATH, which when running under a nix python environment, resolves
            # to the raw python binary, not wrapped and not including the
            # environment's packages. Hence, the first time an import is evaluated
            # we will error out.
            sed -i -- \
              's|interpreter:.*|interpreter: ${pythonEnv}/bin/python3|g' \
              vendor/lowrisc_ibex/vendor/lowrisc_ip/dv/tools/ralgen/ralgen.core
            sed -i -- \
              's|interpreter:.*|interpreter: ${pythonEnv}/bin/python3|g' \
              vendor/lowrisc_ibex/vendor/lowrisc_ip/ip/prim/primgen.core

            export PS1='labenv(HiPEAC) (ibex-demo-system) \$ '

            echo
            echo
            cat ./data/lowrisc.art
            echo "---------------------------------------------------"
            echo "Welcome to the 'ibex-demo-system' nix environment!"
            echo "---------------------------------------------------"

            helpstr=$(cat <<'EOF'

            Build ibex software :
                mkdir sw/build && pushd sw/build && cmake ../ && make && popd
            Build ibex simulation verilator model :
                fusesoc --cores-root=. run --target=sim --tool=verilator --setup --build lowrisc:ibex:demo_system
            Run ibex simulator verilator model :
                ./build/lowrisc_ibex_demo_system_0/sim-verilator/Vibex_demo_system -t \
                  --meminit=ram,sw/build/demo/hello_world/demo
            Build ibex-demo-system FPGA bitstream for Arty-A7 :
                fusesoc --cores-root=. run --target=synth --setup --build lowrisc:ibex:demo_system
            Program Arty-A7 FPGA with bitstream :
                openFPGALoader -b arty_a7_35t build/lowrisc_ibex_demo_system_0/synth-vivado/lowrisc_ibex_demo_system_0.bit
            Load ibex software to the programmed FPGA :
                ./util/load_demo_system.sh run ./sw/build/demo/lcd_st7735/lcd_st7735
            Start an OpenOCD instance, connected to the Arty-A7 ibex
                openocd -f util/arty-a7-openocd-cfg.tcl
            Connect gdb to a running program on the FPGA (In a different terminal to the OpenOCD instance):
                riscv32-unknown-elf-gdb -ex "target extended-remote localhost:3333" ./sw/build/demo/hello_world/demo

            To leave the environment:
                exit

            EOF
            )
            helpme(){ echo "$helpstr"; }
            helpme

            echo
            echo "Run 'helpme' in your shell to see this message again."
            echo
          '';
        };
      })
    ) // {

      overlay = final: prev: { };
      overlays = { exampleOverlay = self.overlay; };

    # Utilized by `nix run .#<name>`
    # apps.x86_64-linux.hello = {
    #   type = "app";
    #   program = c-hello.packages.x86_64-linux.hello;
    # };

    # Utilized by `nix run . -- <args?>`
    # defaultApp.x86_64-linux = self.apps.x86_64-linux.hello;
  };
}
