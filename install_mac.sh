#!/bin/bash

source ./settings.sh

# Create default folder to store binaries if needed.
#
# Note: I don't use /usr/bin or /usr/local/bin due to potential permissions
# issues, it is much easier to keep my own private bin directory for work
# environments where I may not have superuser access.
if [ ! -d "$DEFAULT_BIN_PATH" ]; then
    mkdir "$DEFAULT_BIN_PATH"
fi

##############################################################################
#                              Install Homebrew                              #
##############################################################################

# Install Homebrew
if ! type "$brew" > /dev/null; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

##############################################################################
#                              Install cli tools                             #
##############################################################################

# install htop, bat, and fzf
brew install htop bat fzf

##############################################################################
#                               Install NeoVim                               #
##############################################################################

if [ "$INSTALL_NEOVIM" = true ]; then
    echo "Installing NeoVim..."
    brew install neovim python3
    pip3 install pynvim jedi flake8

    # add the binary directory to our PATH variable
    echo "export \"PATH=${DEFAULT_BIN_PATH}:$PATH\"" >> ~/.zshrc

    # download the Plug package manager for NeoVim
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    # create a ~/.config directory if needed
    if [ ! -d ~/.config ]; then
        mkdir ~/.config
    fi

    # create a ~/.config/nvim directory if needed
    if [ ! -d ~/.config/nvim ]; then
        mkdir ~/.config/nvim
    fi

    # copy our neovim settings into init.vim
    cat ./init.vim > ~/.config/nvim/init.vim
fi

##############################################################################
#                         Install Git Configurations                         #
##############################################################################

# if requested, install icdiff and copy my gitconfig into ~/.gitconfig
if [ "$INSTALL_GITCONFIG" = true ]; then
    echo "Installing git configurations..."
    curl -s https://raw.githubusercontent.com/jeffkaufman/icdiff/release-1.9.2/icdiff \
        | sudo tee /usr/local/bin/icdiff > /dev/null \
        && sudo chmod ugo+rx /usr/local/bin/icdiff
    cat ./gitconfig > ~/.gitconfig
fi

##############################################################################
#                            Install Zsh Settings                            #
##############################################################################

# if requested, install zsh, oh-my-zsh, and associated plugins
if [ "$INSTALL_ZSH" = true ]; then
    echo "Installing zsh..."
    brew install zsh

    # change default shell
    if [ -d "/usr/local/bin/zsh" ]
    then
      chsh -s /usr/local/bin/zsh
    else
      chsh -s /bin/zsh
    fi

    echo "Installing oh-my-zsh..."
    # install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    # install Oxide oh-my-zsh theme
    wget -O $HOME/.oh-my-zsh/custom/themes/oxide.zsh-theme https://raw.githubusercontent.com/dikiaap/dotfiles/master/.oh-my-zsh/themes/oxide.zsh-theme

    # install zsh plugins
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    cat ./zshrc > ~/.zshrc

    # run the ~/.zshrc to reflect any new changes
    source ~/.zshrc
fi

##############################################################################
#                                Install tmux                                #
##############################################################################

# if requested, install tmux and copy my tmux.conf into ~/.tmux.conf
if [ "$INSTALL_TMUX" = true ]; then
    echo "Installing tmux..."
    brew install tmux
    cat ./tmux.conf > ~/.tmux.conf
fi

# success!
echo "Done!"
