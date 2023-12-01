#!/bin/bash
TOPPATH=$(cd "$(dirname "$1")"; pwd)

OPENBMC_TAG=v08.07
TARFN=ast2600-dcscm-obmc.tar.gz
URL=https://github.com/AspeedTech-BMC/openbmc/releases/download/${OPENBMC_TAG}/${TARFN}

rm -f ${TARFN} || exit 1

echo "downloading ${URL}"
curl -k -fSL ${URL} --progress-bar -o ${TARFN} || exit 1

tar zxfv ${TARFN} || exit 1

mkdir -p images || exit 1

if [ "$OPENBMC_TAG" = "v08.07" ]; then
  cp -f ast2600-dcscm/image-bmc images/obmc-phosphor-image-ast2600-dcscm.static.mtd || exit 1
else
  cp -f ast2600-dcscm/obmc-phosphor-image-ast2600-dcscm.static.mtd images || exit 1
fi
rm -rf ${TARFN} ast2600-dcscm/ || exit 1

echo done
