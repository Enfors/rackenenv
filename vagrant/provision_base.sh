#!/usr/bin/env bash

Msg()
{
    echo "$@"
}

Error()
{
    echo "Error: $@" >&2
}

Cmd()
{
    cmd=$@

    $cmd || {
	Error "Cmd: '$cmd' failed with exit code $?."
	exit 1
    }
}

Install()
{
    for pkg in $*; do
	dpkg -s $pkg &> /dev/null || {
	    Msg "Installing $pkg..."
	    apt-get install -y $pkg >/dev/null || {
		Error "Installation of $pkg failed. Aborting."
		exit 1
	    }
	}
    done
}

AddUser()
{
    for user in $*; do
	grep -q "^$user:" || {
	    echo "Adding user $user..."
	    useradd $user
	    for file in \
		/vagrant/home/$user/.bashrc \
		    /vagrant/home/$user/.emacs \
		    /vagrant/home/$user/.tmux.conf \
		; do
		echo "  Copying $file..."
		cp -rp $file /home/$user
	    done
	    chown -R $user:$user /home/$user
	}
    done
}

EnableSwedishKeyboard()
{
    echo "Enabling Swedish keyboard on the console... "
    grep -q "loadkeys" /etc/rc.local || {
	sed "s/^exit 0$/loadkeys se\nexit 0/g" -i /etc/rc.local
    }
    Cmd loadkeys se >/dev/null
}

MkDir()
{
    if [ $# -ne 4 ]; then
	Error "MkDir: Expected 4 args, got '$*'."
	exit 1
    fi
    
    dir=$1
    mode=$2
    owner=$3
    group=$4

    if [ ! -e $dir ]; then
	Cmd mkdir $dir -m $mode
    fi
    
    Cmd chown $owner:$group $dir 
}

ProvisionBase()
{
    apt-get update
    EnableSwedishKeyboard
    Install python3.4 python3-pip tmux git
    Install python-numpy python-sklearn # For AI course on Udacity

    echo "Installing Django..."
    pip3 install django==1.7 >/dev/null

    echo "Installing Selenium..."
    pip3 install --upgrade selenium >/dev/null
}
