#!/bin/bash
which brew > /dev/null
if [ $? != 0 ]; then
	echo "Installing Homebrew"
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "brew already installed"
fi
brew help bundle > /dev/null
if [ $? -eq 0 ]; then
	echo "Installing bundle"
	brew tap -q Homebrew/bundle
fi
echo "Installing Brewfile dependencies"
brew bundle

# Setup profile
cp bash_functions ~/.bash_functions
cp bash_profile ~/.bash_profile
source ~/.bash_profile
cat <<EOT >> ~/.briefcase
.bash_functions
.bash_profile
.briefcase
EOT

# git setup
if [[ ! -f "~/.gitconfig" ]]; then
	cp git-config ~/.gitconfig
else
	echo "Git already has a config file"
fi

# Configure git Secrets
git secrets --register-aws --global
git secrets --install ~/.git-templates/git-secrets 2> /dev/null
git config --global init.templateDir ~/.git-templates/git-secrets

# Copy SSH config
cp ./ssh-config ~/.ssh/config

/usr/local/opt/fzf/install
