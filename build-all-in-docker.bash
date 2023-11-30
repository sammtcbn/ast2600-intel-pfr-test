#!/bin/bash
docker run --name intel-pfr-signing-utility --rm -it -v $(pwd):/home/intel/workspace --workdir="/home/intel/workspace" sammtcbn/intel-pfr-signing-utility ./pfr-image-create.bash
