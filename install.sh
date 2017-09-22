#!/bin/bash
which brew > /dev/null
if [ $? !eq 0 ]; then
	echo "Installing Homebrew"
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "brew already installed"
fi
brew help bundle > /dev/null
if [ $? -eq 0 ]; then
	echo "Installing bundle"
	brew tap Homebrew/bundle
fi
echo "Installing Brewfile dependencies"
brew bundle
