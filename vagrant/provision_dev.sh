#!/usr/bin/env bash

. /vagrant/provision_base.sh

ProvisionDev()
{
    Msg " ==== ProvisionDev ==== "
    SetHostname rackendev
    CloneGitRepo /home/vagrant/devel/elisp/enfors-lib/ \
		 https://github.com/enfors/enfors-lib
    ConfigureUser vagrant
    InstallEmacs25
    InstallPythonLibs
    installPython36
    InstallElpySupport
    InstallX
    InstallIntelliJ
}

FixDB()
{
    Msg " == Fixing database..."
    Cmd /usr/share/debconf/fix_db.pl
}

InstallEmacs25()
{
    Msg " == Preparing for installing emacs25..."
    add-apt-repository -y ppa:kelleyk/emacs >>$VAGRANT_LOG
    apt-get update >>$VAGRANT_LOG
    if [ ! -d "/home/vagrant/.emacs.d/plugins/yasnippet" ]; then
	Msg " = Installing yasnippet..."	
	MkDir /home/vagrant/.emacs.d/plugins 750 vagrant vagrant
	Cmd git clone --recursive https://github.com/joaotavora/yasnippet \
	    /home/vagrant/.emacs.d/plugins/yasnippet >/dev/null
    fi
    #InstallDeb emacs25
}

InstallPythonLibs()
{
    Msg " == Installing Python libraries..."
    # As per https://askubuntu.com/questions/538905/cannot-install-scikit-learn-in-python-3-4-in-ubuntu-14-04:

    InstallDeb build-essential python3-dev python3-setuptools python3-numpy \
	python3-scipy python3-pip libatlas-dev libatlas3gf-base \
	python3-matplotlib python3-pandas
    Msg " = Installing pip3 packages scikit-learn, jupyter and seaborn..."
    pip3 install --upgrade scikit-learn jupyter seaborn >>$VAGRANT_LOG

    update-alternatives --set libblas.so.3 \
        /usr/lib/atlas-base/atlas/libblas.so.3
    update-alternatives --set liblapack.so.3 \
			/usr/lib/atlas-base/atlas/liblapack.so.3
    Msg " = Installing misc pip3 packages..."
    pip3 install --upgrade telepot tweepy flask twine

    # Msg " = Installing ImageMagick for Pillow..."
    # InstallDeb imagemagick
}

InstallPython36()
{
    add-apt-repository --yes ppa:deadsnakes/ppa
    apt-get update
    InstallDeb python3.6
}

InstallElpySupport()
{
    Msg " == Installing Elpy support..."

    pip3 install --upgrade flake8 jedi >>$VAGRANT_LOG
}

InstallX()
{
    Msg " == Installing X Window System..."
    InstallDeb xfce4 firefox xfonts-terminus
}

InstallIntelliJ()
{
    Msg " == Preparing for installation of IntelliJ IDE..."
    Msg " = Adding repository..."
    add-apt-repository ppa:ubuntu-desktop/ubuntu-make >>$VAGRANT_LOG
    apt-get update >>$VAGRANT_LOG
    unset SUDO_UID
    unset SUDO_GID
    InstallDeb ubuntu-make
    #Msg " = Installing IntelliJ package..."
    #echo | umake ide idea >>$VAGRANT_LOG
}

InstallOpenCV()
{
    Msg " == Preparing for installation of OpenCV..."
    Msg " = Downloading installation script from GitHub..."

    MkDir $HOME/build 750 vagrant vagrant
    
    CloneGitRepo https://github.com/milq/milq.git $HOME/build/milq >/dev/null
}

ConfigureUser()
{
    for user in $*; do
	Msg " == Configuring user $user..."
    
	SetXFCEKeyboard $user

	for file in \
	    /vagrant/home/$user/.bashrc \
		/vagrant/home/$user/.emacs \
		/vagrant/home/$user/.emacs.d \
		/vagrant/home/$user/.gitconfig \
		/vagrant/home/$user/.tmux.conf \
		/vagrant/home/$user/.Xresources \
		/vagrant/home/$user/README.txt
	do
	    Msg "  Copying $file"
	    Cmd cp -rp $file /home/$user
	done

	MkDir /vagrant/home/devel/python 750 vagrant vagrant
	
	Cmd chown -R $user:$user /home/$user
    done
}

SetXFCEKeyboard()
{
    user=$1
    base_dir=/home/$user
    target_dir=$base_dir/.config/xfce4/xfconf/xfce-perchannel-xml
    target_file=$target_dir/keyboard-layout.xml

    Msg "  Enabling Swedish keyboard in xfce..."
    
    MkDir $base_dir/.config                                  700 $user $user
    MkDir $base_dir/.config/xfce4                            775 $user $user
    MkDir $base_dir/.config/xfce4/xfconf                     775 $user $user
    MkDir $base_dir/.config/xfce4/xfconf/xfce-perchannel-xml 700 $user $user

    Cmd cp /vagrant/keyboard-layout.xml $target_file
    Cmd chown $user:$user $target_file
}

Main()
{
    ProvisionBase
    ProvisionDev
    Msg " ==== Provisioning completed. ==== "
}

Main
