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
