#!/bin/bash
# This script is revised basing on openbmc/meta-aspeed-sdk/meta-ast2600-pfr/classes/intel-pfr-signing-image.bbclass
TOPPATH=$(cd "$(dirname "$1")"; pwd)

function failed()
{
    echo "$*" >&2
    exit 1
}

IMAGE_NAME=obmc-phosphor-image-ast2600-dcscm
IMGDEPLOYDIR=${TOPPATH}/images

# PFR settings , copy from openbmc/meta-aspeed-sdk/meta-ast2600-pfr/conf/machine/ast2600-dcscm.conf
PFR_IMAGE_SIZE="262144"
# 0x000E0000
PFM_OFFSET_PAGE="896"
# 0x04220000
RC_IMAGE_PAGE="67712"
PFR_MANIFEST="pfr_manifest_ast2600_dcscm.json"
# 1 = SHA256
# 2 = SHA384
PFR_SHA="2"

# function copy from openbmc/meta-phosphor/classes/image_types_phosphor.bbclass
function mk_empty_image() {
    image_dst="$1"
    image_size_kb=$2
    dd if=/dev/zero bs=1k count=$image_size_kb | tr '\000' '\377' > $image_dst || exit 1
}

# function copy from openbmc/meta-phosphor/classes/image_types_phosphor.bbclass
function mk_empty_image_zeros() {
    image_dst="$1"
    image_size_kb=$2
    dd if=/dev/zero of=$image_dst bs=1k count=$image_size_kb || exit 1
}

# PFR images directory
PFR_IMAGES_DIR="${TOPPATH}/pfr_images"

# PFR image generation script directory
PFR_SCRIPT_DIR="${TOPPATH}"

# PFR image config directory
PFR_CFG_DIR="${TOPPATH}/pfrconfig"

# Temporary hardcode
PFR_PLATFORM="obmc"
PFR_SVN="1"
PFR_BKC_VER="1"
PFR_BUILD_VER_MAJ="1"
PFR_BUILD_VER_MIN="0"
PFR_BUILD_NUM="565566"
# 1 = SHA256
# 2 = SHA384
PFR_SHA="2"

function do_generate_signed_pfr_image()
{
    local manifest_json=${PFR_MANIFEST}
    local pfmconfig_xml=""
    local bmcconfig_xml=""
    local pfm_signed_bin="pfm_signed.bin"
    local signed_cap_bin="bmc_signed_cap.bin"
    local unsigned_cap_bin="bmc_unsigned_cap.bin"
    local unsigned_cap_align_bin="bmc_unsigned_cap.bin_aligned"
    local output_bin="image-mtd-pfr"
    #local SIGN_UTILITY=${PFR_SCRIPT_DIR}/intel-pfr-signing-utility
    local SIGN_UTILITY=intel-pfr-signing-utility

    if [ "${PFR_SHA}" == "1" ]; then
        pfmconfig_xml="pfm_config.xml"
        bmcconfig_xml="bmc_config.xml"
    else
        pfmconfig_xml="pfm_config_secp384r1.xml"
        bmcconfig_xml="bmc_config_secp384r1.xml"
    fi

    rm -rf ${PFR_IMAGES_DIR}
    mkdir -p ${PFR_IMAGES_DIR}
    cd ${PFR_IMAGES_DIR}

    # Assemble the flash image
    mk_empty_image ${PFR_IMAGES_DIR}/image-mtd ${PFR_IMAGE_SIZE}

    dd bs=1k conv=notrunc seek=0 \
        if=${IMGDEPLOYDIR}/${IMAGE_NAME}.static.mtd \
        of=${PFR_IMAGES_DIR}/image-mtd || exit 1

    python3 ${PFR_SCRIPT_DIR}/pfr_image.py -m ${PFR_CFG_DIR}/${manifest_json} \
        -p ${PFR_PLATFORM} \
        -i ${PFR_IMAGES_DIR}/image-mtd \
        -j ${PFR_BUILD_VER_MAJ} \
        -n ${PFR_BUILD_VER_MIN} \
        -b ${PFR_BUILD_NUM} \
        -v ${PFR_BKC_VER} \
        -s ${PFR_SVN} \
        -a ${PFR_SHA} \
        -o ${output_bin} || exit 1

    # sign the PFM region
    ${SIGN_UTILITY} -c ${PFR_CFG_DIR}/${pfmconfig_xml} -o ${PFR_IMAGES_DIR}/${pfm_signed_bin} ${PFR_IMAGES_DIR}/obmc-pfm.bin -v || exit 1

    # Parsing and Verifying the PFM
    echo "Parsing and Verifying the PFM"
    ${SIGN_UTILITY} -p ${PFR_IMAGES_DIR}/${pfm_signed_bin} -c ${PFR_CFG_DIR}/${pfmconfig_xml}
    if [ $(${SIGN_UTILITY} -p ${PFR_IMAGES_DIR}/${pfm_signed_bin} -c ${PFR_CFG_DIR}/${pfmconfig_xml} 2>&1 | grep "ERR" | wc -c) -gt 0 ]; then
        failed "Verify the PFM failed."
    fi

    # Add the signed PFM to rom image
    dd bs=1k conv=notrunc seek=${PFM_OFFSET_PAGE} \
        if=${PFR_IMAGES_DIR}/${pfm_signed_bin} \
        of=${PFR_IMAGES_DIR}/${output_bin} || exit 1

    # Create unsigned BMC update capsule - append with 1. pfm_signed, 2. pbc, 3. bmc compressed
    dd if=${PFR_IMAGES_DIR}/${pfm_signed_bin} bs=1k >> ${PFR_IMAGES_DIR}/${unsigned_cap_bin} || exit 1

    dd if=${PFR_IMAGES_DIR}/obmc-pbc.bin bs=1k >> ${PFR_IMAGES_DIR}/${unsigned_cap_bin} || exit 1

    dd if=${PFR_IMAGES_DIR}/obmc-bmc_compressed.bin bs=1k >> ${PFR_IMAGES_DIR}/${unsigned_cap_bin} || exit 1

    # Sign the BMC update capsule
    ${SIGN_UTILITY} -c ${PFR_CFG_DIR}/${bmcconfig_xml} -o ${PFR_IMAGES_DIR}/${signed_cap_bin} ${PFR_IMAGES_DIR}/${unsigned_cap_bin} -v || exit 1

    # Parsing and Verifying the BMC update capsule
    echo "Parsing and Verifying the BMC update capsule"
    ${SIGN_UTILITY} -p ${PFR_IMAGES_DIR}/${signed_cap_bin} -c ${PFR_CFG_DIR}/${bmcconfig_xml}
    if [ $(${SIGN_UTILITY} -p ${PFR_IMAGES_DIR}/${signed_cap_bin} -c ${PFR_CFG_DIR}/${bmcconfig_xml} 2>&1 | grep "ERR" | wc -c) -gt 0 ]; then
        failed "Verify the BMC update capsule failed."
    fi

    # Add the signed bmc update capsule to full rom image
    dd bs=1k conv=notrunc seek=${RC_IMAGE_PAGE} \
        if=${PFR_IMAGES_DIR}/${signed_cap_bin} \
        of=${PFR_IMAGES_DIR}/${output_bin} || exit 1
}

do_generate_signed_pfr_image
echo "done"
