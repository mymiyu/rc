#!/usr/bin/env zsh

autoload -Uz coloredText

registry="http://129.254.171.230:5050"

img=$1

if [[ "$img" == "" ]]; then
    echo "$0 <image to delete>"
    exit 0
fi

repo=$(echo $img | cut -f1 -d:)
tag=$(echo $img | cut -f2 -d:)

header="Accept: application/vnd.docker.distribution.manifest.v2+json"
response=$(curl -vsH $header $registry/v2/$repo/manifests/$tag 2>&1)
digest=$(echo "$response" | grep -i "< docker-content-digest:" | awk '{print $3}')
digest=${digest//[$'\t\r\n']}
result=$(curl -w "%{http_code}" -sH $header -X DELETE $registry/v2/$repo/manifests/$digest)

print ""
print "[] DOCKER-DELETE : delete image from registry server"

if [[ "$result" = "202" ]]; then
    print "   @" $(coloredText 'deleted:' 'bold' 'white') $repo:$tag
else
    print "   @" $(coloredText 'failed:' 'bold' 'white') $result
fi

