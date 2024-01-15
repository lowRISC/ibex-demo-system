#!/bin/sh
# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

if [ $# -ne 2 ] && [ $# -ne 3 ]; then
  echo "Usage $0 run|halt elf_file [tcl_file]"
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

SCRIPT_DIR="$(dirname "$(readlink -e "$0")")"
TCL_FILE=$SCRIPT_DIR/arty-a7-openocd-cfg.tcl

if [ $# -eq 3 ]; then
  if [ ! -f $3 ]; then
    echo "$3 does not exist"
    exit 1
  fi
  TCL_FILE=$3
fi

EXIT_CMD=''

if [ $1 = "run" ]; then
  EXIT_CMD='-c "exit"'
fi

openocd -f $TCL_FILE -c "load_image $2 0x0" \
 -c "verify_image $2 0x0" \
 -c "echo \"Doing reset\"" \
 -c "reset $1" \
 $EXIT_CMD
