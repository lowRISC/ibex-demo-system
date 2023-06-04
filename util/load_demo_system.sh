#!/bin/sh
# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

if [ $# -ne 3 ]; then
  echo "Usage $0 artya7|pynqz2 run|halt elf_file"
  exit 1
fi

if [ ! -f $3 ]; then
  echo "$3 does not exist"
  exit 1
fi

if [ $2 != "halt" ] && [ $2 != "run" ]; then
  echo "Second argument must be halt or run"
  exit 1
fi

if [ $1 != "artya7" ] && [ $1 != "pynqz2" ]; then
  echo "First argument must be artya7 or pynqz2"
  exit 1
fi

EXIT_CMD=''

if [ $2 = "run" ]; then
  EXIT_CMD='-c "exit"'
fi

SCRIPT_DIR="$(dirname "$(readlink -e "$0")")"

if [ $1 = "artya7" ]; then
  SCRIPT_FILENAME="arty-a7-openocd-cfg.tcl"
elif [ $1 = "pynqz2" ]; then
  SCRIPT_FILENAME="pynq-z2-openocd-cfg.tcl"
fi

openocd -f $SCRIPT_DIR/$SCRIPT_FILENAME -c "load_image $3 0x0" \
 -c "verify_image $3 0x0" \
 -c "echo \"Doing reset\"" \
 -c "reset $2" \
 $EXIT_CMD
