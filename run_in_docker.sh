#! /bin/bash

system_to_build_for="ubuntu:18.04"

cd $_HOME_/
docker run -ti --privileged --rm \
  -v /artefacts:/artefacts \
  -v /data:/data \
  -e DISPLAY=$DISPLAY \
  --net=host \
  "$system_to_build_for" \
  /bin/bash /artefacts/runme.sh

