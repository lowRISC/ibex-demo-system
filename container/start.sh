#!/bin/bash
# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

vncserver -geometry=1920x1080 \
    -alwaysshared \
    -SecurityTypes None \
    -xstartup startxfce4

websockify --web=/usr/share/novnc/ \
    --cert=/novnc.pem 6080 localhost:5901
