#!/bin/bash

alias   accounts='cd ~/Code/aws-account-management-platform && git fetch && git pull && cd ~/Code/PublicCloud-Utilities && src/make_profile_list.py -o ~/.aws/config -f'	
alias 	mkpasswd='openssl rand -base64 8'
alias   vib="vi ~/.bash_profile"
alias   vif="vi ~/.bash_functions"
alias   refresh="source ~/.bash_profile;source ~/.bash_functions"
alias   code='cd ~/Code'
alias   accts='PREVDIR=`pwd`;cd ~/Code/aws-account-management-platform &&  bundle exec rake list_accounts; cd $PREVDIR'
alias   cflaunch='~/Code/rlucas_scripts/cf_deploystack.sh'
alias 	rake='bundle exec rake'
alias	findacct='aws organizations describe-account --profile em-master-prod --account-id'
alias	tf='terraform'

HISTFILE=~/.bash_history
HISTSIZE=5000
HISTFILESIZE=10000

export DATE=`date +%Y%m%d_%H%M%S`

test -e "~/.iterm2_shell_integration.bash" && source "~/.iterm2_shell_integration.bash"

# guzzi specific 
if [[ `hostname` == "guzzi" ]];then
    eval "$(rbenv init -)"
    source ~/.evident
    source ~/.artifactory
fi

source ~/.bash_functions


# Copies profile and anything else in briefcase to remote hosts
BRIEFCASE=~/.briefcase

# Check to see whether we have ssh.
SSH=`type -path ssh`
if [[ -n $SSH  ]]; then
    HAVE_SSH=yes
    __SSH=$SSH
else
    unset HAVE_SSH;
fi

if [ -n "$HAVE_SSH" ]; then
    function ssh()
    {
    # First: Determine the hostname argument.

    # Skip all the command line arguments using getopts (shell builtin).  
    # This will set $OPTIND to the index of the first non-option argument,
    # which should be the hostname argument to ssh, if provided. 

    # N.B.: This option list is current as of OpenSSH 4.5p1, and may need
    # to be updated as newer versions are released.

    sshargs="$@" 

    while getopts ':1246AaCfgkMNnqsTtVvXxYb:c:D:e:F:i:L:l:m:O:o:p:R:S:w:' \
    Option
    do
        # If connecting to the remote host under a different user ID:
        # don't copy the briefcase files! 
        case $Option in
        "l") SSH_SKIP_COPY=1 
        ;;
        esac
    done
    shift $(($OPTIND - 1))
    # We have to reset OPTIND, otherwise future invocations of this
    # function will fail to properly parse the command line.
    OPTIND=1

    # $1 should now be either the hostname or empty
    if [ -n "$SSH_SKIP_COPY" ];then
    # No hostname specified, or connecting to the remote host under a different user ID:
    # Run ssh as specified.
        $__SSH $sshargs
    else
    # Copy our environment to the target host ($1)'s home directory.
    # We run rsync with -u so that any newer files on the target
    # host are preserved.  All files to be synced to the target host
    # should be listed, one per line, in $HOME/.briefcase.
        rsync -uptgo -e $__SSH --files-from=$BRIEFCASE \
        "$HOME"  "$1":~/ || echo "Briefcase sync failed: $!" >&2

        # Now run ssh, with the command line intact. 
        $__SSH $sshargs
    fi
    unset SSH_SKIP_COPY
    unset ssh
    }  
fi

# This should do pretty things to git prompt
parse_git_branch ()
{
    local GITDIR=`git rev-parse --show-toplevel 2>&1` # Get root directory of git repo
    if [[ "$GITDIR" != '/root' ]] # Don't show status of home directory repo
    then
        # Figure out the current branch, wrap in brackets and return it
        local BRANCH=`git branch --no-color 2>/dev/null | sed -n '/^\*/s/^\* //p'`
        if [ -n "$BRANCH" ]; then
            echo -e "[$BRANCH]"
        fi
    else
        echo ""
    fi
}

function git_color ()
{
    # Get the status of the repo and chose a color accordingly
    local STATUS=`git status 2>&1`
    if [[ "$STATUS" == *'Not a git repository'* ]]
    then
        echo ""
    else
        if [[ "$STATUS" != *'working directory clean'* ]]
        then
            # red if need to commit
            echo -e '\033[0;31m'
        else
            if [[ "$STATUS" == *'Your branch is ahead'* ]]
            then
                # yellow if need to push
                echo -e '\033[0;33m'
            else
                # else cyan
                echo -e '\033[0;36m'
            fi
        fi
    fi
}

  # Call the above functions inside the PS1 declaration
PS1='\[$(git_color)\]$(parse_git_branch)\[\033[01;32m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \$ '
