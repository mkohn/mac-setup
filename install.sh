#!/bin/bash
echo "Installing Homebrew"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
echo "Installing bundle"
brew tap Homebrew/bundle
echo "Installing Brewfile dependencies"
brew bundle

echo "cflint() {
   #Run AWS Cloudformation Validate with Filename and Profile
   aws cloudformation validate-template --template-body file://./$1 --profile=$2
}

#-> listcreds [] list declared AWS credentials
function listcreds {
        cat  ~/.aws/credentials |  awk -F '[][]' '{print $2}' | sed '/^\s*$/d'
}
#-> usecreds [] use declared AWS creds
function usecreds {
        export AWS_PROFILE="$1"
}

# Update HomeBrew and Casks
brewup() {
	brew update && brew upgrade && brew cu -a && brew cleanup
}" >> ~/.bash_profile
