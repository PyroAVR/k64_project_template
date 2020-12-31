#!/usr/bin/env bash
WHERE=$(dirname $0)
source $WHERE/openocd_server.sh
start_oocd
if [[ -n $1 ]]; then
    (echo "init;kinetis mdm mass_erase 0;reset halt;flash write_image $1 0 bin;reset run; exit"; sleep 1; echo "quit")| telnet localhost 4444
else
    (echo "init;kinetis mdm mass_erase 0;reset halt;flash write_image $(pwd)/build/main.bin 0 bin;reset run; exit"; sleep 1; echo "quit")| telnet localhost 4444
fi

