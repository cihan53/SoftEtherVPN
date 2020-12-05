#!/bin/bash
set -x

SE_VERSION="4.34"
SE_REVISION="9745"

BASE_TAGS="latest centos debian alpine ubuntu"

for TAG in ${BASE_TAGS}; do
  docker pull cihan53/softethervpn:${TAG}
  VERSION_TAG=${SE_VERSION}-${TAG}
  REVISION_TAG=${SE_REVISION}-${TAG}
  docker tag cihan53/softethervpn:${TAG} cihan53/softethervpn:${VERSION_TAG%-latest}
  docker tag cihan53/softethervpn:${TAG} cihan53/softethervpn:${REVISION_TAG%-latest}
  docker push cihan53/softethervpn:${VERSION_TAG%-latest}
  docker push cihan53/softethervpn:${REVISION_TAG%-latest}
done
