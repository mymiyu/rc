#!/usr/bin/env zsh

print ""
print "[] DOCKER-CLEAN : delete dangling images"

docker rmi -f $(docker images --filter "dangling=true" --quiet)
#docker rmi -f $(docker images --filter "dangling=true" --quiet --no-trunc)
