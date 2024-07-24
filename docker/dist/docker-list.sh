#!/usr/bin/env zsh

function coloredText() {
    ESC='\e['

    declare -A code_style code_fgcolor code_bgcolor

    code_style=([reset]=0 [bold]=1 [normal]=2 [underline]=4 [blink]=5 [inverse]=7)
    code_fgcolor=([black]=30 [red]=31 [green]=32 [yellow]=33 [blue]=34 [magenta]=35 [cyan]=36 [white]=37)
    code_bgcolor=([black]=40 [red]=41 [green]=42 [yellow]=43 [blue]=44 [magenta]=45 [cyan]=46 [white]=47)

    text="$1"
    style=${code_style[$2]}
    fgcolor=${code_fgcolor[$3]}

    if [[ -z $4 ]]; then
        coloredtext="${ESC}${style};${fgcolor}m${text}${ESC}0m"
    else
        bgcolor=${code_bgcolor[$4]}
        coloredtext="${ESC}${style};${fgcolor};${bgcolor}m${text}${ESC}0m"
    fi

    echo -e -n $coloredtext
}

function getRegRepos {
    registry=$1

    curl -s $registry/v2/_catalog | jq -r '.["repositories"][]'
}

function getRegTags {
    registry=$1
    repository=$2

    taglist=$(curl -s $registry/v2/$repository/tags/list)
    nulltag=$(echo $taglist | jq -r '.["tags"]')

    if [[ "$nulltag" == "null" ]]
    then
        echo "null"
    else
        echo $taglist | jq -r '.["tags"][]'
    fi
}

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
    done <<< $(getRegTags $registry $repo)
done <<< $(getRegRepos $registry)

