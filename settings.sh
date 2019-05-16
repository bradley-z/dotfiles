# This is the default path where any binaries (such as NeoVim) will be
# installed on the new machine.
#
# Note: Though this could likely default to something like /usr/local/bin
# or some location like that, I frequenly find myself having to port my
# dev setup to machines where I do not have root access (i.e. shared clusters
# that I may use for work or school). In this case, I find it much easier to
# just keep a private $(HOME)/bin directory, which I can add to my system
# path, that contains all of my custom installed binaries.
# DEFAULT_BIN_PATH=~/bin
DEFAULT_BIN_PATH=/usr/local/bin

# If set to true, the install.sh script will cause NeoVim to be installed
# in the DEFAULT_BIN_PATH directory. It will also install Plug as a plugin
# manager, and import basic NeoVim configurations.
INSTALL_NEOVIM=true

# If set to true, the install.sh script will install zsh, oh-my-zsh, and
# associated plugins.
INSTALL_ZSH=true

# If set to true, the install.sh script will install icdiff and populate
# ~/.gitconfig with the settings contained in ./gitconfig.
INSTALL_GITCONFIG=true

# If set to true, the install.sh script will install tmux
INSTALL_TMUX=true
