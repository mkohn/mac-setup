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

## Needs to be run as root user section
sudo -s <<EOS
#Disable Zscaler
grep "zscalertwo" /etc/hosts > /dev/null
ZHOSTSFILE=$?
if [[ $ZHOSTSFILE -eq 0 ]]; then
	echo "Zscaler entries already present"
else 
	echo "Adding needed entries to hostsfile"
	cat <<EOT >> /etc/hosts
127.0.0.1 pac.zscalertwo.net
127.0.0.1 gateway.zscalertwo.net
EOT
fi

grep '104.129.192.0/20' /etc/pf.conf > /dev/null
ZRULES=$?
if [[  $ZRULES -eq 0 ]]; then
	echo "Zscaler entry already present"
else
	echo "Blocking proxy traffic"
	echo "block drop from any to 104.129.192.0/20" >> /etc/pf.comf
	pfctl -f /etc/pf.conf 2> /dev/null
	pfctl -E 2> /dev/null
fi	
EOS
