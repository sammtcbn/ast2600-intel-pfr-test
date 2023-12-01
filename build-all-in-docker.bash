#!/bin/bash
docker run --name intel-pfr-signing-utility --rm -it -v $(pwd):/home/intel/workspace --workdir="/home/intel/workspace" sammtcbn/intel-pfr-signing-utility ./pfr-image-create.bash

# Decommission Capsule
docker run --name intel-pfr-signing-utility --rm -it -v $(pwd)/rot:/home/intel/workspace/rot --workdir="/home/intel/workspace/rot" sammtcbn/intel-pfr-signing-utility ./rot_decommission_capsule_create.bash
