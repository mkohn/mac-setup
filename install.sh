#!/bin/bash
echo "Installing Homebrew"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
echo "Installing bundle"
brew tap Homebrew/bundle
echo "Installing Brewfile dependencies"
brew bundle