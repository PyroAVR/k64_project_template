#!/usr/bin/env bash
WHERE=$(dirname $0)
PRJ_ROOT=$(pwd)

start_oocd() {
    if [ ! -e $PRJ_ROOT/openocd.pid ]; then
        openocd -f $PRJ_ROOT/k64_files/frdm-k64f.cfg &
        echo $! > $PRJ_ROOT/openocd.pid
    fi
}

stop_oocd() {
    if [ -e $PRJ_ROOT/openocd.pid ]; then
        (echo "shutdown"; sleep 1; echo "quit") | telnet localhost 4444 > /dev/null 2>&1
        rm $PRJ_ROOT/openocd.pid
    fi
}

_main() {
    case $1 in
        "start")
            start_oocd
        ;;

        "stop")
            stop_oocd
        ;;

        *)
            echo "Usage: $0 start|stop"
        ;;
    esac
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    _main "$@"
fi
