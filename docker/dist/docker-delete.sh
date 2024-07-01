#!/usr/bin/env zsh

function coloredText() {
    ESC='\e['

    declare -A code_style code_fgcolor code_bgcolor

    code_style=([reset]=0 [bold]=1 [normal]=2 [underline]=4 [blink]=5 [inverse]=7)
    code_fgcolor=([black]=30 [red]=31 [green]=32 [yellow]=33 [blue]=34 [magenta]=35 [cyan]=36 [white]=37)
    code_bgcolor=([black]=40 [red]=41 [green]=42 [yellow]=43 [blue]=44 [magenta]=45 [cyan]=46 [white]=47)

    text=$1
    style=${code_style[$2]}
    fgcolor=${code_fgcolor[$3]}

    if [[ -z "$4" ]]; then
        coloredtext="${ESC}${style};${fgcolor}m${text}${ESC}0m"
    else
        bgcolor=${code_bgcolor[$4]}
        coloredtext="${ESC}${style};${fgcolor};${bgcolor}m${text}${ESC}0m"
    fi

    echo -e -n $coloredtext
}

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

