# .zshenv

# umask
umask 022

# locale
export LANG=ko_KR.UTF-8
export LC_MESSAGES=en_US.UTF-8
export LC_NUMERIC=en_US.UTF-8
export LC_TIME=en_US.UTF-8

# path
typeset -U PATH

if [[ -d $HOME/bin        ]]; then PATH=$HOME/bin:$PATH; fi
if [[ -d $HOME/.local/bin ]]; then PATH=$HOME/.local/bin:$PATH; fi

export PATH

# functions
typeset -U FPATH

if [[ -d $HOME/.zsh_functions ]]; then
    fpath=( $HOME/.zsh_func/* "${fpath[@]}" )
#    export FPATH=$HOME/.zsh_func:$FPATH
#    autoload -Uz $HOME/.zsh_func/**/*
fi

