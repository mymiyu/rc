#!/usr/bin/env zsh

autoload -Uz coloredText

registry_prefix=129.254.171.230:5050

img=$1
imgas=$img

if [[ -z $img ]]; then
    echo "$0 <server image to pull> <local image name>"
    exit 0
elif [[ -n $2 ]]; then
    imgas=$2
fi

docker pull $registry_prefix/$img
docker tag $registry_prefix/$img $imgas
docker rmi $registry_prefix/$img

print ""
print "[] DOCKER-PULL : pull docker image from registry server"

print "   @" $(coloredText 'pulled:' 'bold' 'white') $img
if [[ "$img" != "$imgas" ]]; then
    print "   @" $(coloredText 'as name:' 'bold' 'white') $imgas
else
fi
