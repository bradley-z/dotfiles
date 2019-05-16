# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/bradleyzhou/.oh-my-zsh"

ZSH_THEME="oxide"

# Uncomment the following line to use hyphen-insensitive completion.
HYPHEN_INSENSITIVE="true"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    osx
    colored-man-pages
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# improve autosuggestions
bindkey '^ ' autosuggest-accept

# LSCOLORS that I might change at some point
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# use neovim instead of vim
alias vim='nvim'
alias vi='nvim'

# aliases for faster commands
# aliases for faster navigation up directories
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# make ls colorized, add a forward slash after each directory,
# and use unit suffixes when displaying file sizes
alias ls="ls -GFh"

# improve use of list
alias ll="ls -l"
alias lo="ls -o"
alias lh="ls -lh"
alias lla="ls -la"
alias la="ls -a"
alias sl="ls"
alias s="ls"
alias c="clear"

# abbreviations for programs
alias py="python"
alias st="sublime"

# random ones
alias h="function hdi(){ howdoi $* -a -c -n 5; }; hdi"
alias sml="rlwrap sml"
alias gll="git log --graph --oneline --abbrev-commit --decorate --all"
alias reload="source ~/.zshrc"
alias vimrc="vim ~/.config/nvim/init.vim"

# cd and ls in one
function cd() {
    new_directory="$*";
    if [ $# -eq 0 ]; then
        new_directory=${HOME};
    fi;
    builtin cd "${new_directory}" && ls
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
