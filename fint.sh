#!/bin/bash

PKGS=(
vim wget tar git mc        # Utils
gcc make                   # For building
lilyterm                   # Terminal
alsa-lib alsa-utils        # ALSA stuff
slim @base-x @core         # X needed
firefox skype geeqie gvim  # Apps
deadbeef ncmpcpp
libX11-devel libXinerama-devel libxcb-devel  # For dwm
freetype-infinality fontconfig-infinality    # Infinality patches
)

function usage
{
    cat << USAGE
    fint.sh - Fedora Installer script by avd.

    usage: $0 <options>

    OPTIONS:
    -h  Prints this nice message
    -r  Repositories setup
    -s  Install useful software
    -d  Install and configure dwm and dmenu
    -w  Configure window manager (adds exec in .xinitrc)
    -c  Do various system configs

    If no options are given - execute all operations.
USAGE
}

function repo_setup 
{
    # Enable RPM Fusion repo
    yum -y install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    # Enable Russian Fedora repo
    yum -y install http://mirror.yandex.ru/fedora/russianfedora/russianfedora/free/fedora/russianfedora-free-release-stable.noarch.rpm http://mirror.yandex.ru/fedora/russianfedora/russianfedora/nonfree/fedora/russianfedora-nonfree-release-stable.noarch.rpm

    # Enable infinality repo
    yum -y install http://www.infinality.net/fedora/linux/infinality-repo-1.0-1.noarch.rpm
}

function soft_install
{
    yum -y install ${PKGS[*]}
}

function dwm_install
{
    # Install custom dwm from my github dwm mirror
    cd ..
    git clone https://github.com/dzeban/dwm.git
    cd dwm
    make clean install

    cd ../misc # Return to original directory
}

function dmenu_install
{
    # Install dmenu
    cd ..
    git clone http://git.suckless.org/dmenu
    cd dmenu
    make clean install

    cd ../misc # Return to original directory
}

function wm_setup
{
    # Set dwm as window manager for root and avd (What a nice double piping!)
    echo "#!/bin/bash" >> ~/.xinitrc >> /home/avd/.xinitrc
    echo "exec dwm"    >> ~/.xinitrc >> /home/avd/.xinitrc
}

function dm_setup
{
    # Set dwm as default session in SLIM config
    sed -i 's/sessions.*/sessions	dwm/' /etc/slim.conf
}

function sys_config
{
    # Make init 5 level as default
    ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target
}

function run_all
{
    repo_setup
    soft_install
    dwm_install
    dmenu_install
    wm_setup
    dm_setup
    sys_config
}

# Exit on error in any script command
set -e

if [ $# -eq 0 ]; then
    run_all
fi

while getopts “hrsdmwc” OPTION
do
    case $OPTION in
        h) usage; exit 0;;
        r) repo_setup   ;;
        s) soft_install ;;
        d) dwm_install  ;;
        m) dwm_install  ;;
        w) wm_setup     ;;
        c) sys_config   ;;
        ?) usage; exit 1;;
    esac
done
