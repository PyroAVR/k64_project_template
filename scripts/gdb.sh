#!/usr/bin/env bash
WHERE=$(dirname $0)
gdbarm=$(arm-none-eabi-gdb -version 2>/dev/null)
gdbmulti=$(gdb-multiarch -version 2>/dev/null)
source $WHERE/openocd_server.sh
start_oocd
if [ ! -z "$gdbarm" ]; then
    arm-none-eabi-gdb --eval-command="target remote localhost:3333" $1
elif [ ! -z "$gdbmulti" ]; then 
    gdb-multiarch --eval-command="set architecture armv6" --eval-command="target remote localhost:3333" $1
else
    echo "no suitable gdb found"
    stop_oocd
fi
