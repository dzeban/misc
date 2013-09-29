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

# ==============================================
#                   REPOS
# ==============================================

# Enable RPM Fusion repo
su -c 'yum localinstall --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm %http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm %-E %fedora).noarch.rpm'

# Enable Russian Fedora repo
su -c 'yum install --nogpgcheck http://mirror.yandex.ru/fedora/russianfedora/russianfedora/free/fedora/russianfedora-free-release-stable.noarch.rpm http://mirror.yandex.ru/fedora/russianfedora/russianfedora/nonfree/fedora/russianfedora-nonfree-release-stable.noarch.rpm'

# Enable infinality repo
rpm -Uvh http://www.infinality.net/fedora/linux/infinality-repo-1.0-1.noarch.rpm

# ==============================================
#                   SOFTWARE
# ==============================================

# Install software
yum -y install ${PKGS[*]}

# Dropbox 
cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -

# Install custom dwm from my github dwm mirror
cd ..
git clone https://github.com/dzeban/dwm.git
cd dwm
make clean install

# Install dmenu
cd ..
git clone http://git.suckless.org/dmenu
cd dmenu
make clean install

# ==============================================
#                CONFIGURATION
# ==============================================

# Set dwm as window manager for root and avd (What a nice double piping!)
echo "#!/bin/bash" >> ~/.xinitrc >> /home/avd/.xinitrc
echo "exec dwm"    >> ~/.xinitrc >> /home/avd/.xinitrc

# Set dwm as default session in SLIM config
sed -e 's/sessions.*/sessions	dwm/' /etc/slim.conf

# Make init 5 level as default
ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target

