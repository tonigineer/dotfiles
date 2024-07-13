#!/usr/bin/env bash

case $1 in
--icon | -i)
    echo " "
    ;;
--layout | -l)
    echo $(cat /etc/vconsole.conf | grep = | cut -d "=" -f2)
    ;;
*)
    echo "Usage:
    $0 {-i|-l}
    $0 {--icon|--layout}"
    exit 1
    ;;
esac
