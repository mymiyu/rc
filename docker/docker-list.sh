#!/usr/bin/env zsh

autoload -Uz getRepos getTags
autoload -Uz coloredText

registry="http://129.254.171.230:5050"

print ""
print "[] DOCKER-LIST : list docker images on registry server"

while IFS= read -r repo; do
    print "   @" $(coloredText $repo 'bold' 'white')
    while IFS= read -r tag; do
        if [[ "$tag" = "null" ]]; then
            print "         :" $(coloredText "(empty)" 'normal' 'white')
        else
            print "         :" $(coloredText $tag 'normal' 'white')
        fi
    done <<< $(getTags $registry $repo)
done <<< $(getRepos $registry)

