# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Directory listing
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Shortcuts
alias c='clear'
alias h='history'
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'

# Show PATH entries one per line
alias path='echo $PATH | tr ":" "\n"'

# Reload shell config
alias reload='source ~/.bashrc 2>/dev/null || source ~/.zshrc 2>/dev/null'
