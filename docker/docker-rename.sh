#!/usr/bin/env zsh

autoload -Uz coloredText

argn=$#

if [[ $argn -ne 2 ]]
then
    echo "$0 <from> <to>"
    exit 0
fi

fromimg=$1
toimg=$2

docker tag $fromimg $toimg
docker rmi $fromimg

print ""
print "[] DOCKER-RENAME : rename docker image"
print "   @" $fromimg "->" $(coloredText $toimg 'bold' 'white')
