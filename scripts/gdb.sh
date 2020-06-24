#!/usr/bin/env bash
WHERE=$(dirname $0)
source $WHERE/openocd_server.sh
start_oocd
arm-none-eabi-gdb --eval-command="target remote localhost:3333" $1
