#!/bin/bash
function failed()
{
    echo "$*" >&2
    exit 1
}

# PFR Image
echo "generage PFR Image ..."
docker run --name intel-pfr-signing-utility --rm -it -v $(pwd):/home/intel/workspace --workdir="/home/intel/workspace" sammtcbn/intel-pfr-signing-utility ./pfr-image-create.bash || failed "Failed to generate PFR Image "
echo "done"

# Decommission Capsule
echo "generate Decommission Capsule ..."
docker run --name intel-pfr-signing-utility --rm -it -v $(pwd)/rot:/home/intel/workspace/rot --workdir="/home/intel/workspace/rot" sammtcbn/intel-pfr-signing-utility ./rot_decommission_capsule_create.bash || failed "Failed to generate Decommission Capsule"
echo "done"

# RoT Update Capsule
echo "generate RoT Update Capsule ..."
docker run --name intel-pfr-signing-utility --rm -it -v $(pwd)/rot:/home/intel/workspace/rot --workdir="/home/intel/workspace/rot" sammtcbn/intel-pfr-signing-utility ./rot_update_capsule_create.bash || failed "Failed to generate Update Capsule"
echo "done"
