case $OSTYPE in
    darwin*)
        alias ls='ls -G'
        ;;
    linux*)
        alias ls='ls --color=auto'
        ;;    
esac
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -AlF'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
# alias emacs='vim' # religious war trigger

