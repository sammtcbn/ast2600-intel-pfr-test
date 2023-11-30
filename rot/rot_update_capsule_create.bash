#!/bin/bash
TOPPATH=$(cd "$(dirname "$1")"; pwd)

function failed()
{
    echo "$*" >&2
    exit 1
}

ROT_UPDATE_XML="rot_update_capsule_secp384r1.xml"
ROT_UNSIGNED="zephyr.bin"
OUTPUT="zephyr_signed.bin"

[ -f "${ROT_UNSIGNED}" ] || failed "${ROT_UNSIGNED} not found"

intel-pfr-signing-utility -c $ROT_UPDATE_XML -o $OUTPUT $ROT_UNSIGNED -v
