# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#!/bin/sh

if [ $# -ne 2 ]; then
  echo "Usage $0 run|halt elf_file"
  exit 1
fi

if [ ! -f $2 ]; then
  echo "$2 does not exist"
  exit 1
fi

if [ $1 != "halt" ] && [ $1 != "run" ]; then
  echo "First argument must be halt or run"
  exit 1
fi

EXIT_CMD=''

if [ $1 = "run" ]; then
  EXIT_CMD='-c "exit"'
fi

SCRIPT_DIR="$(dirname "$(readlink -e "$BASH_SOURCE")")"

openocd -f $SCRIPT_DIR/arty-a7-openocd-cfg.tcl -c "load_image $2 0x0" \
 -c "verify_image $2 0x0" \
 -c "echo \"Doing reset\"" \
 -c "reset $1" \
 $EXIT_CMD
