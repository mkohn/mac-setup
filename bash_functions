# Functions
#-> alias [regex] searches through alias in .bash_profile
function alias() { egrep "alias.*$1.*" ~/.bash_profile; }

#-> creds [] list declared AWS credentials
function creds {
	cat  ~/.aws/config |  awk -F '[][]' '{print $2}' | sed '/^\s*$/d'
	if [ ! -z $AWS_PROFILE ]; then
		echo "Currently using $AWS_PROFILE"
	else
		echo "No Profile currently defined"
	fi
}

#-> usecreds [] use declared AWS creds
function usecreds {
	export AWS_PROFILE="$1"
}

#-> listcreds [] list declared AWS credentials
function listcreds {
        cat  ~/.aws/credentials |  awk -F '[][]' '{print $2}' | sed '/^\s*$/d'
}

#-> cflint Run AWS Cloudformation Validate with Filename and Profile
cflint() {
   aws cloudformation validate-template --region us-west-2 --template-body file://./$1 --profile=$2
}

#-> hist [] search hist for last command
function hist {
	myarg=$1
	history | grep ${myarg}
}

#-> list [regex] searches through comments in .bash_functions
function list() { egrep "#->.*$1.*" ~/.bash_functions;
}

#-> rmkeys [regex] funtion that removes the lines in known_hosts file that match regex.
function rmkeys(){
                myIP=`host $1 | awk '{print$4}'`
		echo "Removing $1 amd $myIP"
		sed -i  -e "/$1/d" $HOME/.ssh/known_hosts
		echo "Removed $1"
		sed -i -e "/$myIP/d" $HOME/.ssh/known_hosts
                echo "Removed $myIP"
}

#-> myip [] display current IP address
function myip () {
	myip=`curl -s checkip.dyndns.org | awk -F '<' '{print$7}'`
	#myip=`echo $myip | awk -F '<' '{print$7}'`
	echo $myip | cut -d '>' -f 2
}

#-> time [File] converts epoch time into humantime
function time {
	cat $1 | perl -pe 's/\[(\d+)\]/localtime $1/e'
}

#-> ws [] remove spaces from a file
function ws () {
                myArg=$1
        cat ${myArg} |sed -e 's/\ //g' >> ${myArg}a && mv ${myArg}a ${myArg}
}

#-> wib [name] displays the block associated with the alias or function that matches name.
function wib()
{
        sed -ne "/function $1\(\)/,/}$/p" -ne "/alias $1/p" ~/.bash_functions
}
