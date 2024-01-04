{
  description = "Environment for synthesizing and simulating the ibex-demo-system.";

  inputs = {
    lowrisc-nix.url = "github:lowRISC/lowrisc-nix";

    nixpkgs.follows = "lowrisc-nix/nixpkgs";
    flake-utils.follows = "lowrisc-nix/flake-utils";
    poetry2nix.follows = "lowrisc-nix/poetry2nix";

    deps = {
      url = "path:./dependencies";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    lowrisc-nix,
    nixpkgs,
    flake-utils,
    deps,
    ...
  }: let
    all_system_outputs = flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {allowUnfree = true;};
        overlays = [
          # Add extra packages we might need
          # Currently this contains spike
          deps.overlay_pkgs
        ];
      };

      pythonEnv = let
        poetry2nix = inputs.poetry2nix.lib.mkPoetry2Nix {inherit pkgs;};
        poetryOverrides = lowrisc-nix.lib.poetryOverrides {inherit pkgs;};
      in
        poetry2nix.mkPoetryEnv {
          projectDir = ./.;
          overrides = [
            poetryOverrides
            poetry2nix.defaultPoetryOverrides
          ];
        };
    in {
      devShells.default = pkgs.mkShellNoCC {
        name = "labenv";
        buildInputs = with pkgs; [
          # Needed in DPI code
          libelf
          # Needed when running verilator with FST support
          zlib
        ];
        nativeBuildInputs = with pkgs; [
          pythonEnv

          cmake
          openocd
          screen
          verilator

          # Currently we don't build the riscv-toolchain from src, we use a github release
          # See https://github.com/lowRISC/lowrisc-nix/blob/main/pkgs/lowrisc-toolchain-gcc-rv32imcb.nix

          # riscv-toolchain (built from src) # BROKEN
          # riscv-gcc-toolchain-lowrisc-src = pkgs.callPackage \
          #   ./dependencies/riscv_gcc.nix {
          #     riscv-arch = "rv32imc";
          #   };
          lowrisc-nix.packages.${system}.lowrisc-toolchain-gcc-rv32imcb

          gtkwave
          srecord
          openfpgaloader
          # vivado

          # Poetry tool not required, add for convience in case update is needed
          poetry

          # By default mkShell adds non-interactive bash to PATH
          bashInteractive
        ];
        shellHook = ''
          # FIXME This works on Ubuntu, may not on other distros. FIXME
          export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive

          if [ -z "$DIRENV_IN_ENVRC" ]; then
            export PS1='labenv(HiPEAC) (ibex-demo-system) \$ '

            echo
            echo
            cat ./data/lowrisc.art
          fi

          echo "---------------------------------------------------"
          echo "Welcome to the 'ibex-demo-system' nix environment!"
          echo "---------------------------------------------------"

          helpme(){ cat <<'EOF'

          Build ibex software :
              mkdir sw/c/build && pushd sw/c/build && cmake ../ && make && popd
          Build ibex simulation verilator model :
              fusesoc --cores-root=. run --target=sim --tool=verilator --setup --build lowrisc:ibex:demo_system
          Run ibex simulator verilator model :
              ./build/lowrisc_ibex_demo_system_0/sim-verilator/Vibex_demo_system -t \
                --meminit=ram,sw/c/build/demo/hello_world/demo
          Build ibex-demo-system FPGA bitstream for Arty-A7 :
              fusesoc --cores-root=. run --target=synth --setup --build lowrisc:ibex:demo_system
          Program Arty-A7 FPGA with bitstream :
              openFPGALoader -b arty_a7_35t build/lowrisc_ibex_demo_system_0/synth-vivado/lowrisc_ibex_demo_system_0.bit
          Load ibex software to the programmed FPGA :
              ./util/load_demo_system.sh run ./sw/c/build/demo/lcd_st7735/lcd_st7735
          Start an OpenOCD instance, connected to the Arty-A7 ibex
              openocd -f util/arty-a7-openocd-cfg.tcl
          Connect gdb to a running program on the FPGA (In a different terminal to the OpenOCD instance):
              riscv32-unknown-elf-gdb -ex "target extended-remote localhost:3333" ./sw/c/build/demo/hello_world/demo

          EOF

            if [ -z "$DIRENV_IN_ENVRC" ]; then
              cat <<'EOF'
          To leave the environment:
              exit

          EOF
            fi
          }

          helpme

          if [ -z "$DIRENV_IN_ENVRC" ]; then
            echo
            echo "Run 'helpme' in your shell to see this message again."
            echo
          fi
        '';
      };
      formatter = pkgs.alejandra;
    });
  in
    all_system_outputs;
}
