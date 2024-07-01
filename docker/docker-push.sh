#!/usr/bin/env zsh

autoload -Uz coloredText

registry_prefix=129.254.171.230:5050

img=$1
imgas=$img

if [[ -z $img ]]; then
    print "$0 <local image to push> <server image name>"
    exit -1
elif [[ -n $2 ]]; then
    imgas=$2
fi

docker tag $img $registry_prefix/$imgas
docker push $registry_prefix/$imgas
docker rmi $registry_prefix/$imgas

print ""
print "[] DOCKER-PUSH : push docker image to registry server"

print "   @" $(coloredText 'pushed:' 'bold' 'white') $img
if [[ "$img" != "$imgas" ]]; then
    print "   @" $(coloredText 'as name:' 'bold' 'white') $imgas
fi
