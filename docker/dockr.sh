#!/usr/bin/env zsh

autoload -Uz getRegRepos getRegTags
autoload -Uz coloredText

g_registry_host=cafe-famille.net
g_registry_port=5050

function print_msg() {
    local cmd=$1
    local msg=$2

    print -n $(coloredText " DOCKR " 'bold' 'white' 'red')
    print -n $(coloredText " $cmd " 'normal' 'red' 'white')
    print $(coloredText " $msg" 'bold' 'green')
}

function print_help() {
    print_msg 'help' 'DOCKR <command> <arg>'
    print "\
   commands for local
     imgs    : list docker images
     vols    : list docker volumes
     cons    : list docker containers
     clear   : delete dangling images
     rm      : delete local images
     rename  <image to rename> <new name>

   commands for registry
     list    : list docker images on registry server
     delete  <image to delete>
     push    <image to push> (new name)
     pull    <image to pull> (new name)
"
}

function check_img() {
    local img=$1

    print "$(docker images -q $img 2> /dev/null)"
}

function parse_args() {
    local n_args=$#

    if [[ $n_args -lt 1 ]]; then
        print_help
        exit -1
    fi

    g_cmd=$1
    shift
    g_arg=($@)
}

function do_docker_list() {
    local registry="http://${g_registry_host}:$g_registry_port"

    print_msg 'list' "docker images on $registry"

    while IFS= read -r repo; do
        if [[ -z $repo ]]; then
            continue
        fi
        print "   @" $(coloredText $repo 'bold' 'white')
        while IFS= read -r tag; do
            if [[ -z $tag ]]; then
                continue
            fi
            if [[ "$tag" = "null" ]]; then
                print "         :" $(coloredText "(null)" 'normal' 'white')
            else
                print "         :" $(coloredText $tag 'normal' 'white')
            fi
        done <<< $(getRegTags $registry $repo)
    done <<< $(getRegRepos $registry)

    print ''
}

function do_docker_clear() {
    local dangling_list=$(docker images --filter "dangling=true" --quiet)

    if [[ -z $dangling_list ]]; then
        print_msg 'clean' 'no dangling image to delete'
    else
        print_msg 'clean' 'deleting dangling images'
        docker rmi -f $(docker images --filter "dangling=true" --quiet)
    fi
    print ''
}

function do_docker_delete() {
    if [[ -z $1 ]]; then
        print_msg 'delete' 'DOCKR delete <image to delete>'
        print ''
        exit -1
    fi

    local registry="http://${g_registry_host}:$g_registry_port"
    local repo=$(echo $1 | cut -f1 -d:)
    local tag=$(echo $1 | cut -f2 -d:)

    if [[ -z $tag ]]; then tag='latest'; fi

    local header="Accept: application/vnd.docker.distribution.manifest.v2+json"
    local response=$(curl -vsH $header $registry/v2/$repo/manifests/$tag 2>&1)
    local digest=$(echo "$response" | grep -i "< docker-content-digest:" | awk '{print $3}')
    local digest=${digest//[$'\t\r\n']}
    local result=$(curl -w "%{http_code}" -sH $header -X DELETE $registry/v2/$repo/manifests/$digest)

    if [[ "$result" = "202" ]]; then
        print_msg 'delete' "deleted $1 from $registry"
    else
        print_msg 'delete' "no such image on $registry"
    fi
    print ''
}

function do_docker_rename() {
    if [[ -z $2 ]]; then
        print_msg 'rename' 'DOCKR rename <image to rename> <new name>'
        print ''
        exit -1
    fi

    img=$1
    imgas=$2

    if [[ -z $(check_img $img) ]]; then
        print_msg 'rename' "$img : no such image"
    elif [[ -n $(check_img $imgas) ]]; then
        print_msg 'rename' "$imgas : already exists"
    else
        docker tag $img $imgas
        docker rmi $img
        print_msg 'rename' "renamed : $img --> $imgas"
    fi

    print ''
}

function do_docker_rm() {
    if [[ -z $1 ]]; then
        print_msg 'rm' 'DOCKR rm <images to delete>'
        print ''
        exit -1
    fi

    imgs=($@)
    for img in $imgs; do
        if [[ -z $(check_img $img) ]]; then
            print_msg 'rm' "$img : no such image"
        else
            docker rmi -f $img
            print_msg 'rm' "deleted : $img"
        fi
    done
}

function do_docker_push() {
    if [[ -z $1 ]]; then
        print_msg 'push' 'DOCKR push <image to push> (new name)'
        print ''
        exit -1
    fi

    local registry_prefix="${g_registry_host}:$g_registry_port"
    local img=$1
    local imgas=$1

    if [[ -n $2 ]]; then
        imgas=$2
    fi

    if [[ -z $(check_img $img) ]]; then
        print_msg 'push' "$img : no such image"
        print ''
        exit -1
    fi

    docker tag $img $registry_prefix/$imgas
    docker push $registry_prefix/$imgas
    docker rmi $registry_prefix/$imgas

    print_msg 'push' "pushed : $img --> $imgas"
    print ''
}

function do_docker_pull() {
    if [[ -z $1 ]]; then
        print_msg 'pull' 'DOCKR pull <image to pull> (new name)'
        print ''
        exit -1
    fi

    local registry_prefix="${g_registry_host}:$g_registry_port"
    local img=$1
    local imgas=$1

    if [[ -n $2 ]]; then
        imgas=$2
    fi

    docker pull $registry_prefix/$img
    docker tag $registry_prefix/$img $imgas
    docker rmi $registry_prefix/$img

    print_msg 'pull' "pulled : $imgas <-- $img"
    print ''
}

function do_docker_imgs() {
    print_msg 'imgs' 'docker images on local system'
    docker image ls
    print ''
}

function do_docker_vols() {
    print_msg 'vols' 'docker volumes on local system'
    docker volume ls
    print ''
}

function do_docker_cons() {
    print_msg 'cons' 'docker containers on local system'
    docker container ls
    print ''
}

function do_main() {
    parse_args $@

    if [[ $g_cmd == "imgs"   ]]; then do_docker_imgs; fi
    if [[ $g_cmd == "vols"   ]]; then do_docker_vols; fi
    if [[ $g_cmd == "cons"   ]]; then do_docker_cons; fi
    if [[ $g_cmd == "rm"     ]]; then do_docker_rm $g_arg; fi

    if [[ $g_cmd == "clear"  ]]; then do_docker_clear; fi
    if [[ $g_cmd == "clean"  ]]; then do_docker_clear; fi
    if [[ $g_cmd == "clr"    ]]; then do_docker_clear; fi

    if [[ $g_cmd == "ren"    ]]; then do_docker_rename $g_arg; fi
    if [[ $g_cmd == "rename" ]]; then do_docker_rename $g_arg; fi

    if [[ $g_cmd == "list"   ]]; then do_docker_list; fi
    if [[ $g_cmd == "push"   ]]; then do_docker_push $g_arg; fi
    if [[ $g_cmd == "pull"   ]]; then do_docker_pull $g_arg; fi
    if [[ $g_cmd == "del"    ]]; then do_docker_delete $g_arg; fi
    if [[ $g_cmd == "delete" ]]; then do_docker_delete $g_arg; fi
}

do_main $@
