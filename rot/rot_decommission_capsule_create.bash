#!/bin/bash
TOPPATH=$(cd "$(dirname "$1")"; pwd)

function failed()
{
    echo "$*" >&2
    exit 1
}

DECOMMISION_XML="dcc_secp384r1.xml"
EMPTY_IMG="dcc.bin"
OUTPUT="dcc_signed.bin"

dd if=/dev/zero of=$EMPTY_IMG count=128 bs=1

intel-pfr-signing-utility -c $DECOMMISION_XML -o $OUTPUT $EMPTY_IMG -v

