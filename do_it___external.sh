#! /bin/bash



echo "starting ..."

START_TIME=$SECONDS

## ----------------------
numcpus_=$(nproc)
quiet_=1
full="1"
download_full="0"
## ----------------------


echo "++++++++++++++++++++++++++"
id -a
pwd
df -h
sleep 1
echo "++++++++++++++++++++++++++"


# _HOME2_=$(dirname $0)
_HOME2_="/workspace"
export WRKSPACEDIR="/workspace/"
mkdir -p "$WRKSPACEDIR"
export CIRCLE_ARTIFACTS="/artefacts/"

export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_

export qqq=""

if [ "$quiet_""x" == "1x" ]; then
	export qqq=" -qq "
fi


redirect_cmd() {
    if [ "$quiet_""x" == "1x" ]; then
        "$@" > /dev/null 2>&1
    else
        "$@"
    fi
}


echo "installing system packages ..."

export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
redirect_cmd apt-get update $qqq

redirect_cmd apt-get install $qqq -y --force-yes --no-install-recommends lsb-release
system__=$(lsb_release -i|cut -d ':' -f2|sed -e 's#\s##g')
version__=$(lsb_release -r|cut -d ':' -f2|sed -e 's#\s##g')
echo "compiling on: $system__ $version__"

echo "installing more system packages ..."

pkgs="
    git
    curl
    wget
    bc
    xz-utils
    python-software-properties
    software-properties-common
    unzip
    zip
    check
    checkinstall
    pkg-config
    rsync
    libostree-dev
    debootstrap
    systemd-container
    squashfs-tools
    xorriso
    grub-pc-bin
    grub-efi-amd64-bin
    mtools
    sudo
    dosfstools
"

for i in $pkgs ; do
    redirect_cmd apt-get install $qqq -y --force-yes --no-install-recommends $i
done






#### build ###############################################

deb_release="buster"

echo $_HOME_
mkdir -p $_HOME_/LIVE_BOOT

echo "running debootstrap (debian:""$deb_release"") ..."
debootstrap \
    --arch=amd64 \
    --variant=minbase \
    $deb_release \
    $_HOME_/LIVE_BOOT/chroot \
    http://ftp.debian.org/debian/ > /dev/null


cat << EOF | chroot $_HOME_/LIVE_BOOT/chroot

pwd
id -a
echo "debian:$deb_release"

echo "portabletbw" > /etc/hostname

export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical

echo "###########################"
touch /etc/apt/apt.conf
cp -av /etc/apt/apt.conf /etc/apt/apt.conf_BACKUP
cat /etc/apt/apt.conf
echo "###########################"

echo '
APT::Get::Assume-Yes "true";
APT::Get::force-yes "true";
' >> /etc/apt/apt.conf

# -----------------
cat /etc/apt/sources.list
sleep 2
# -----------------
#sed -i -e 's#main#main contrib non-free#' /etc/apt/sources.list
echo 'deb http://ftp.debian.org/debian buster main contrib non-free
deb http://security.debian.org/debian-security/ buster/updates main contrib non-free
deb http://deb.debian.org/debian buster-backports main contrib non-free
' > /etc/apt/sources.list
# -----------------
cat /etc/apt/sources.list
sleep 2
# -----------------

# turn off console bell globally
echo '
setterm -blength 0
' >> /etc/profile


apt-get update

echo "11xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
apt-cache search linux-image
echo "22xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
apt-cache search live-boot
echo "33xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
apt-cache search systemd-sysv
echo "44xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# apt-cache search firmware
# echo "55xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"


apt-get install -y --force-yes linux-image-amd64
apt-get install -y --force-yes systemd-sysv

apt-get install -y --force-yes ca-certificates
apt-get install -y --force-yes coreutils
apt-get install -y --force-yes locales
apt-get install -y --force-yes --no-install-recommends git
apt-get install -y --force-yes --no-install-recommends network-manager
apt-get install -y --force-yes --no-install-recommends net-tools
apt-get install -y --force-yes --no-install-recommends wireless-tools
# apt-get install -y --force-yes --no-install-recommends wpagui
apt-get install -y --force-yes --no-install-recommends curl
apt-get install -y --force-yes --no-install-recommends openssh-client
# apt-get install -y --force-yes --no-install-recommends blackbox
apt-get install -y --force-yes --no-install-recommends nano
apt-get install -y --force-yes ifupdown
apt-get install -y --force-yes isc-dhcp-client
apt-get install -y --force-yes alsa-utils
apt-get install -y --force-yes libasound-dev
apt-get install -y --force-yes v4l-utils

apt-get -t buster-backports install -y -o "Dpkg::Options::=--force-confdef" --force-yes "v4l-conf"

apt-get install -y --force-yes libv4l-dev
apt-get install -y --force-yes libv4lconvert0
apt-get install -y --force-yes --no-install-recommends adduser
apt-get install -y --force-yes --no-install-recommends sudo
apt-get install -y --force-yes kmod
apt-get install -y --force-yes --no-install-recommends net-tools
apt-get install -y --force-yes fbset
apt-get install -y --force-yes --no-install-recommends htop
apt-get install -y --force-yes --no-install-recommends nano
apt-get install -y --force-yes --no-install-recommends vim
apt-get install -y --force-yes firmware-linux
# ----- more firmware -----
apt-get install -y --force-yes firmware-linux-nonfree
apt-get install -y --force-yes firmware-misc-nonfree
apt-get install -y --force-yes alsa-firmware-loaders
apt-get install -y --force-yes firmware-realtek
apt-get install -y --force-yes firmware-amd-graphics
apt-get install -y --force-yes atmel-firmware
apt-get install -y --force-yes firmware-atheros
apt-get install -y --force-yes firmware-brcm80211
apt-get install -y --force-yes firmware-intel-sound
apt-get install -y --force-yes firmware-intelwimax
apt-get install -y --force-yes firmware-ipw2x00
apt-get install -y --force-yes firmware-iwlwifi
apt-get install -y --force-yes firmware-libertas
apt-get install -y --force-yes firmware-myricom
apt-get install -y --force-yes firmware-qcom-media
apt-get install -y --force-yes firmware-ralink
apt-get install -y --force-yes firmware-zd1211
apt-get install -y --force-yes intel-microcode
apt-get install -y --force-yes amd64-microcode
# ----- more firmware -----

# apt-get install -y --force-yes --no-install-recommends -o "Dpkg::Options::=--force-confdef" kbd keyboard-configuration
# apt-get install -y --force-yes --no-install-recommends -o "Dpkg::Options::=--force-confdef" console-setup-linux
# apt-get install -y --force-yes --no-install-recommends -o "Dpkg::Options::=--force-confdef" console-setup
apt-get install -y --force-yes --no-install-recommends -o "Dpkg::Options::=--force-confdef" console-data

echo "####### cryptsetup #######"
echo "####### cryptsetup #######"
#ls -al /proc/mounts
#mkdir -p /usr/share/initramfs-tools/conf-hooks.d/
#echo 'export CRYPTSETUP=y' >> /usr/share/initramfs-tools/conf-hooks.d/forcecryptsetup
#mkdir -p /etc/cryptsetup-initramfs/
#echo 'CRYPTSETUP=y' >> /etc/cryptsetup-initramfs/conf-hook
#mkdir -p /etc/initramfs-tools/conf.d
#echo 'export CRYPTSETUP=y' >> /etc/initramfs-tools/conf.d/cryptsetup
#
apt-get install -y --force-yes -o "Dpkg::Options::=--force-confdef" cryptsetup
echo "####### cryptsetup #######"
echo "####### cryptsetup #######"


apt-get install -y --force-yes -o "Dpkg::Options::=--force-confdef" \
    libopenal-dev libcurl4-gnutls-dev libncursesw5-dev || exit 1

# reset
# tput reset
# stty sane
# echo -e "\033c"

apt-get install -y --force-yes live-boot

# ------ pulse audio for alsa ------
apt-get install -y --force-yes pulseaudio pulseaudio-utils
# ------ pulse audio for alsa ------

# ------ more packages ------
apt-get install -y -o "Dpkg::Options::=--force-confdef" --force-yes \
apt-transport-https \
coreutils \
build-essential \
libjpeg-dev libpng-dev imagemagick \
htop mc fbset cmake qrencode \
libqrencode-dev vim nano \
wget curl git make \
autotools-dev libtool bc \
libv4l-dev \
libv4lconvert0 v4l-utils \
pkg-config libjpeg-dev \
libpulse-dev libconfig-dev \
automake \
check yasm \
libasound2-dev \
libasound2-plugins \
bc htop speedometer \
ntp ntpstat \
python-setuptools \
python3-setuptools \
dnsutils \
ifmetric \
sysstat \
iproute2 \
pciutils \
libc-bin \
dpkg \
v86d \
iputils-ping \
hostname \
gdb \
dialog \
zbar-tools

apt-get install -y -o "Dpkg::Options::=--force-confdef" --force-yes \
libmagick-dev \
gettext \
libticonv-dev

apt-get install -y -o "Dpkg::Options::=--force-confdef" --force-yes util-linux


apt-get -t buster-backports install -y -o "Dpkg::Options::=--force-confdef" --force-yes "checkinstall"

apt-get purge -y --force-yes exim
apt-get purge -y --force-yes exim4
apt-get purge -y --force-yes exim4-base
apt-get purge -y --force-yes exim4-config
apt-get purge -y --force-yes mailutils
apt-get purge -y --force-yes mysql-common

dpkg -l | grep exim
dpkg -l | grep mail


# ------ more packages ------


apt-get clean

# ------------------------------------

echo "
root    ALL=(ALL:ALL) ALL
%admin  ALL=(ALL) ALL
%sudo   ALL=(ALL) NOPASSWD: ALL
" > /etc/sudoers

cat /etc/sudoers

# ------------------------------------

echo 'export PATH=$PATH:/sbin' >> /root/.bashrc

# ------------------------------------

echo "--------------"
cat /etc/adduser.conf|grep -v '^#'|grep -v '^$'
echo "--------------"

echo "I: create user pi"
adduser --disabled-login --gecos "tbw" --add_extra_groups pi

usermod -a -G sudo,input pi

echo "I: set user password"
echo "pi:pass" | chpasswd

echo "--------------"
cat /etc/group
echo "--------------"
cat /etc/passwd
echo "--------------"
cat /etc/shadow
echo "--------------"

# ------------------------------------
echo "m1--------------"
ls -al /etc/machine-id
echo "m2--------------"
truncate -s0 "/etc/machine-id"
echo "m3--------------"
ls -al /etc/machine-id
echo "m4--------------"
# ------------------------------------

echo "de_AT.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_AT ISO-8859-1" >> /etc/locale.gen
echo "de_AT@euro ISO-8859-15" >> /etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_DE ISO-8859-1" >> /etc/locale.gen
echo "de_DE@euro ISO-8859-15" >> /etc/locale.gen
locale-gen
locale -a

# https://github.com/cdown/tzupdate
# util to autodetect timezone from IP address
# pip install -U tzupdate || pip install -U tzupdate || pip install -U tzupdate || pip install -U tzupdate || pip install -U tzupdate || pip install -U tzupdate

# install module used by "ext_keys_evdev.py" script to get keyboard input events
# python3 -m pip install evdev || python3 -m pip install evdev || python3 -m pip install evdev || python3 -m pip install evdev || python3 -m pip install evdev || python3 -m pip install evdev
apt-get install -y --force-yes --no-install-recommends -o "Dpkg::Options::=--force-confdef" python3-evdev || exit 1
apt-get install -y --force-yes --no-install-recommends -o "Dpkg::Options::=--force-confdef" python3-libevdev || exit 1

  rm -f /etc/cron.daily/apt-compat
  rm -f /etc/cron.daily/aptitude
  rm -f /etc/cron.daily/man-db
  rm -f /etc/cron.weekly/man-db
  
systemctl disable syslog
systemctl stop syslog || echo "ERROR"

systemctl disable syslog.socket
systemctl stop syslog.socket || echo "ERROR"

systemctl disable cron
systemctl stop cron || echo "ERROR"

    rm -f /usr/lib/apt/apt.systemd.daily
    rm -f /lib/systemd/system/apt-daily-upgrade.timer
    rm -f /var/lib/systemd/deb-systemd-helper-enabled/timers.target.wants/apt-daily-upgrade.timer
    rm -f /etc/systemd/system/timers.target.wants/apt-daily-upgrade.timer
    systemctl stop apt-daily.timer || echo "ERROR"
    systemctl disable apt-daily.timer || echo "ERROR"
    systemctl mask apt-daily.service || echo "ERROR"
    systemctl daemon-reload || echo "ERROR"
    
sed -i -e 's#debian\.pool#pool#g' /etc/ntp.conf


# configure rc.local
echo "configure rc.local"

## sed -i -e 's#exit 0##' /etc/rc.local

printf '#!/bin/bash\n' > /etc/rc.local
printf '\n' >> /etc/rc.local
printf '\n' >> /etc/rc.local
printf 'openvt -s -w /encrypt_persistent.sh\n' >> /etc/rc.local
printf '\n' >> /etc/rc.local
printf 'openvt -s -w /enter_screen_name.sh\n' >> /etc/rc.local
printf '\n' >> /etc/rc.local
printf 'systemctl stop "getty@tty1.service"\n' >> /etc/rc.local
printf 'echo "" > "/home/pi/ToxBlinkenwall/toxblinkenwall/ext_keys_scripts/ext_keys.py"\n' >> /etc/rc.local
printf '\n' >> /etc/rc.local
### printf 'cat /etc/network/interfaces\n' >> /etc/rc.local
printf 'sleep 1\n' >> /etc/rc.local
printf 'systemctl restart NetworkManager\n' >> /etc/rc.local
printf 'sleep 3\n' >> /etc/rc.local
printf 'nmcli radio wifi on\n' >> /etc/rc.local
printf 'pkill -f wpa_supplicant\n' >> /etc/rc.local
printf 'timeout -k 6 4 ifdown wlan0\n' >> /etc/rc.local
printf 'timeout -k 100 98 ifup wlan0\n' >> /etc/rc.local
printf 'set +e\n' >> /etc/rc.local
printf 'touch /_boot_\n' >> /etc/rc.local
printf 'systemctl disable cron\n' >> /etc/rc.local
printf 'systemctl stop cron || echo "ERROR"\n' >> /etc/rc.local
printf 'export PATH=$PATH:/sbin\n' >> /etc/rc.local
printf 'echo xxxxxxxxxx\n' >> /etc/rc.local
printf 'echo xxxxxxxxxx\n' >> /etc/rc.local
printf 'echo xxxxxxxxxx\n' >> /etc/rc.local
printf 'cat /proc/asound/cards\n' >> /etc/rc.local
printf '\n' >> /etc/rc.local
printf 'echo -n eth0:\n' >> /etc/rc.local
printf 'ip -4 addr show eth0|grep inet|awk "{print \\\$2}"\n' >> /etc/rc.local
printf 'echo -n wlan0:\n' >> /etc/rc.local
printf 'ip -4 addr show wlan0|grep inet|awk "{print \\\$2}"\n' >> /etc/rc.local
printf 'echo -n IP:\n' >> /etc/rc.local
printf 'hostname -I\n' >> /etc/rc.local
printf 'echo -n hostname:\n' >> /etc/rc.local
printf 'hostname\n' >> /etc/rc.local
printf 'echo xxxxxxxxxx\n' >> /etc/rc.local
printf 'echo xxxxxxxxxx\n' >> /etc/rc.local
printf 'echo xxxxxxxxxx\n' >> /etc/rc.local
printf 'sleep 10\n' >> /etc/rc.local
printf 'if [ ! -e /dev/fb0 ]; then modprobe uvesafb ; fi\n' >> /etc/rc.local
printf 'sleep 1\n' >> /etc/rc.local
printf 'if [ ! -e /dev/fb0 ]; then modprobe vga16fb ; fi\n' >> /etc/rc.local
printf '\n' >> /etc/rc.local
printf 'openvt -f -s -- bash /home/pi/ToxBlinkenwall/toxblinkenwall/start_toxic.sh &\n' >> /etc/rc.local
printf '\n' >> /etc/rc.local
printf 'exit 0\n' >> /etc/rc.local

# systemctl enable rc-local.service || echo "ERROR"
chmod a+x /etc/rc.local

echo "view /etc/rc.local ================================="
cat /etc/rc.local
echo "view /etc/rc.local ================================="

exit

EOF

cp -av /artefacts/encrypt_persistent.sh $_HOME_/LIVE_BOOT/chroot/encrypt_persistent.sh
chmod a+rx $_HOME_/LIVE_BOOT/chroot/encrypt_persistent.sh
ls -al $_HOME_/LIVE_BOOT/chroot/

cp -av /artefacts/enter_screen_name.sh $_HOME_/LIVE_BOOT/chroot/enter_screen_name.sh
chmod a+rx $_HOME_/LIVE_BOOT/chroot/enter_screen_name.sh
ls -al $_HOME_/LIVE_BOOT/chroot/

cp -av /artefacts/build_tbw.sh $_HOME_/LIVE_BOOT/chroot/home/pi/build_tbw.sh
chmod a+rx $_HOME_/LIVE_BOOT/chroot/home/pi/build_tbw.sh
ls -al $_HOME_/LIVE_BOOT/chroot/home/pi

cat << EOF | chroot $_HOME_/LIVE_BOOT/chroot
  id -a
  res=0
  mkdir -p "/home/pi/inst/"
  chmod a+rwx "/home/pi/inst/"
  chown pi:pi -R "/home/pi/inst/"
  echo "build tbw ..."
  su - pi bash -c "/home/pi/build_tbw.sh || touch /home/pi/ERROR"
  if [ -e /home/pi/ERROR ]; then
    exit 1
  fi
EOF

res11=$?
if [ $res11 -ne 0 ]; then
    echo ""
    echo ""
    echo "******* ERROR building tbw *******"
    echo "******* ERROR building tbw *******"
    echo "******* ERROR building tbw *******"
    echo "******* ERROR building tbw *******"
    echo ""
    echo ""
    exit 1
fi

cat << EOF | chroot $_HOME_/LIVE_BOOT/chroot
  id -a
  res=0
  mkdir -p "/home/pi/zbar/"
  chmod a+rwx "/home/pi/zbar/"
  chown pi:pi -R "/home/pi/zbar/"
  echo "build zbar ..."
  su - pi bash -c "cd /home/pi/zbar/; git clone https://github.com/zoff99/ZBar_deb || touch /home/pi/ERROR2"
  su - pi bash -c "cd /home/pi/zbar/ZBar_deb/; bash do_it.sh || touch /home/pi/ERROR2"
  if [ -e /home/pi/ERROR2 ]; then
    exit 1
  fi
EOF

res12=$?
if [ $res12 -ne 0 ]; then
    echo ""
    echo ""
    echo "******* ERROR building zbar *******"
    echo "******* ERROR building zbar *******"
    echo "******* ERROR building zbar *******"
    echo "******* ERROR building zbar *******"
    echo ""
    echo ""
    exit 1
fi

echo "create debug fixup script"
cat << EOF | chroot $_HOME_/LIVE_BOOT/chroot
    echo '#! /bin/bash
setterm -cursor on
sudo loadkeys de
export PATH=$PATH:/sbin:/usr/sbin
' > "/f.sh"

    chmod a+rwx "/f.sh"
EOF

echo "enable predictable network interface names" # does NOT work for some reason, only the kernel boot param does
cat << EOF | chroot $_HOME_/LIVE_BOOT/chroot
    rm -f /etc/systemd/network/99-default.link
    ln -sf /dev/null /etc/systemd/network/99-default.link
    ls -al /etc/systemd/network/99-default.link
EOF

echo "configure interfaces without network-manager" # -> stupid network manager changes this file on boot!?!
cat << EOF | chroot $_HOME_/LIVE_BOOT/chroot

    mkdir -p /etc/network

    echo '
auto lo
iface lo inet loopback

allow-hotplug eth0
iface eth0 inet dhcp

auto wlan0
iface wlan0 inet dhcp
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

' > /etc/network/interfaces_tbw

EOF

# echo "remove unused packages to make image smaller"
# cat << EOF | chroot $_HOME_/LIVE_BOOT/chroot
# dpkg -P --force-all cmake cpp gcc g++ libtool build-essential mc x11-common libice6 libxtst6 cron
# dpkg -P --force-all git
# EOF

echo "reset apt options to default again"
cat << EOF | chroot $_HOME_/LIVE_BOOT/chroot
mv -v /etc/apt/apt.conf_BACKUP /etc/apt/apt.conf
EOF


# --------------------------------------------


mkdir -p $_HOME_/LIVE_BOOT/{scratch,image/live}

sudo mksquashfs \
    $_HOME_/LIVE_BOOT/chroot \
    $_HOME_/LIVE_BOOT/image/live/filesystem.squashfs \
    -e boot

ls -al $_HOME_/LIVE_BOOT/chroot/boot/

cp $_HOME_/LIVE_BOOT/chroot/boot/vmlinuz-* \
    $_HOME_/LIVE_BOOT/image/vmlinuz && \
cp $_HOME_/LIVE_BOOT/chroot/boot/initrd.img-* \
    $_HOME_/LIVE_BOOT/image/initrd


# grub config, with predictable network interface names!
cat <<'EOF' >$_HOME_/LIVE_BOOT/scratch/grub.cfg

search --set=root --file /DEBIAN_CUSTOM

insmod all_video

set default="0"
set timeout=6

menuentry "TBW Portable" {
    linux /vmlinuz boot=live net.ifnames=0 quiet tbw_hw=0
    initrd /initrd
}

menuentry "TBW Portable - NVIDIA Hw Accel." {
    linux /vmlinuz boot=live net.ifnames=0 quiet modprobe.blacklist=nouveau rd.driver.blacklist=nouveau tbw_hw=1
    initrd /initrd
}

menuentry "TBW Portable - backlight" {
    linux /vmlinuz boot=live net.ifnames=0 acpi_backlight=vendor quiet tbw_hw=0
    initrd /initrd
}

menuentry "TBW Portable - compat." {
    linux /vmlinuz boot=live net.ifnames=0 quiet nomodeset tbw_hw=0
    initrd /initrd
}
EOF

touch $_HOME_/LIVE_BOOT/image/DEBIAN_CUSTOM

ls -al $_HOME_/LIVE_BOOT/image



grub-mkstandalone \
    --format=x86_64-efi \
    --output=$_HOME_/LIVE_BOOT/scratch/bootx64.efi \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=$_HOME_/LIVE_BOOT/scratch/grub.cfg"

cd $_HOME_/LIVE_BOOT/scratch && \
    dd if=/dev/zero of=efiboot.img bs=1M count=10 && \
    mkfs.vfat efiboot.img && \
    mmd -i efiboot.img efi efi/boot && \
    mcopy -i efiboot.img ./bootx64.efi ::efi/boot/

grub-mkstandalone \
    --format=i386-pc \
    --output=$_HOME_/LIVE_BOOT/scratch/core.img \
    --install-modules="linux normal iso9660 biosdisk memdisk search tar ls" \
    --modules="linux normal iso9660 biosdisk search" \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=$_HOME_/LIVE_BOOT/scratch/grub.cfg"

cat \
    /usr/lib/grub/i386-pc/cdboot.img \
    $_HOME_/LIVE_BOOT/scratch/core.img \
> $_HOME_/LIVE_BOOT/scratch/bios.img


# create 25MB ext4 partition image -----------
dd if=/dev/zero of=${_HOME_}/LIVE_BOOT/scratch/persist_ext4.img bs=4k count=6000
mkfs.ext4 -U "ffdbdad1-431e-426d-b1f9-2be903c83a48" -L tbwpersist ${_HOME_}/LIVE_BOOT/scratch/persist_ext4.img
mkdir -p ${_HOME_}/LIVE_BOOT/scratch/mnt_tmp/
mount -o loop ${_HOME_}/LIVE_BOOT/scratch/persist_ext4.img ${_HOME_}/LIVE_BOOT/scratch/mnt_tmp/
touch ${_HOME_}/LIVE_BOOT/scratch/mnt_tmp/__tbw_persist_part__
umount -f ${_HOME_}/LIVE_BOOT/scratch/mnt_tmp
rm -Rf ${_HOME_}/LIVE_BOOT/scratch/mnt_tmp/
# create 240MB ext4 partition image -----------


xorriso \
    -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "DEBIAN_CUSTOM" \
    -eltorito-boot \
        boot/grub/bios.img \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        --eltorito-catalog boot/grub/boot.cat \
    --grub2-boot-info \
    --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
    -eltorito-alt-boot \
        -e EFI/efiboot.img \
        -no-emul-boot \
    -append_partition 2 0xef ${_HOME_}/LIVE_BOOT/scratch/efiboot.img \
    -append_partition 3 Linux ${_HOME_}/LIVE_BOOT/scratch/persist_ext4.img \
    -output "${_HOME_}/LIVE_BOOT/debian-custom.iso" \
    -graft-points \
        "${_HOME_}/LIVE_BOOT/image" \
        /boot/grub/bios.img=$_HOME_/LIVE_BOOT/scratch/bios.img \
        /EFI/efiboot.img=$_HOME_/LIVE_BOOT/scratch/efiboot.img


ls -hal "${_HOME_}/LIVE_BOOT/debian-custom.iso"

cp -av "${_HOME_}/LIVE_BOOT/debian-custom.iso" /artefacts/


#### build ###############################################


pwd

ELAPSED_TIME=$(($SECONDS - $START_TIME))

echo "compile time: $(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"


# chmod -R a+rw /script/
chmod -R a+rw /artefacts/
