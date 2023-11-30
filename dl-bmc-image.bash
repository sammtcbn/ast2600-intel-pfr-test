#!/bin/bash
TOPPATH=$(cd "$(dirname "$1")"; pwd)

OPENBMC_TAG=v08.06
TARFN=ast2600-dcscm-obmc.tar.gz
URL=https://github.com/AspeedTech-BMC/openbmc/releases/download/${OPENBMC_TAG}/${TARFN}

rm -f ${TARFN} || exit 1

echo "downloading ${URL}"
curl -k -fSL ${URL} --progress-bar -o ${TARFN} || exit 1

tar zxfv ${TARFN} || exit 1

mkdir -p images || exit 1
cp -f ast2600-dcscm/obmc-phosphor-image-ast2600-dcscm.static.mtd images || exit 1
rm -rf ${TARFN} ast2600-dcscm/ || exit 1

echo done
