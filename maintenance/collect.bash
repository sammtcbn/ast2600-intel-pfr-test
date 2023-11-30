#!/bin/bash
TOPPATH=$(cd "$(dirname "$1")/.."; pwd)

# -----------------------------------------------

#INTEL_SIGN_UTIL_COMMIT=2c6f15434db57e5f51e3b1a4817f0e621a5bad25

OPENBMC_TAG=v08.05
ZEPHYR_TAG=v01.05

#output=./output
output=${TOPPATH}

# -----------------------------------------------

mkdir -p ${output} || exit 1

#INTEL_SIGN_UTIL_PATH=${TOPPATH}/intel-pfr-signing-utility
OPENBMC_PATH=${TOPPATH}/openbmc

ZEPHYR_PATH=${TOPPATH}/aspeed-zephyr-project

#function aspeed-intelpfr-tools-dl()
#{
#  cd ${TOPPATH} || exit 1
#  git clone https://github.com/Intel-BMC/intel-pfr-signing-utility.git || exit 1
#  cd intel-pfr-signing-utility || exit 1
#  git checkout ${INTEL_SIGN_UTIL_COMMIT} || exit 1
#}

function aspeed-openbmc-dl()
{
  cd ${TOPPATH} || exit 1
  rm -rf openbmc || exit 1
  git clone https://github.com/AspeedTech-BMC/openbmc.git || exit 1
  cd openbmc || exit 1
  git checkout ${OPENBMC_TAG} || exit 1
}

function aspeed-zephyr-dl()
{
  cd ${TOPPATH} || exit 1
  rm -rf aspeed-zephyr-project || exit 1
  git clone https://github.com/AspeedTech-BMC/aspeed-zephyr-project.git || exit 1
  cd aspeed-zephyr-project || exit 1
  git checkout ${ZEPHYR_TAG} || exit 1
}

function collect ()
{
  mv ${OPENBMC_PATH}/meta-aspeed-sdk/meta-ast2600-pfr/recipes-intel/pfr/files/pfr_image.py ${TOPPATH} || exit 1
  mkdir -p ${TOPPATH}/pfrconfig || exit 1
  mv ${OPENBMC_PATH}/meta-aspeed-sdk/meta-ast2600-pfr/recipes-intel/pfr/files/* ${TOPPATH}/pfrconfig || exit 1
}

function copy_output()
{
  echo
}

function zephyr_collect()
{
  cd ${TOPPATH} || exit 1
  mkdir -p ${TOPPATH}/rot || exit 1
  mv ${ZEPHYR_PATH}/apps/aspeed-pfr/tools/intel/* ${TOPPATH}/rot || exit 1
}

function clean_metafile()
{
#  rm -rf ${INTEL_SIGN_UTIL_PATH} || exit 1
  rm -rf ${OPENBMC_PATH} || exit 1
  rm -rf ${ZEPHYR_PATH}  || exit 1
}

#aspeed-intelpfr-tools-dl
aspeed-openbmc-dl
collect
copy_output

aspeed-zephyr-dl
zephyr_collect

clean_metafile

echo done
