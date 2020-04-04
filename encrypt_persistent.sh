#! /bin/bash

# ignore CTRL-C press in this script ---------
trap '' INT
# ignore CTRL-C press in this script ---------

dmesg -D 2> /dev/null

# wait for other boot messages to dissapear
sleep 5

echo ""
echo ""
echo ""
echo ""

echo "==========================================================="
echo "kernel command line:"
cat /proc/cmdline
echo "==========================================================="

echo 'v4l2-ctl -d /dev/video0 --set-parm=30 --set-fmt-video=width=640,height=480,pixelformat="Y16 " --stream-mmap --stream-count=240 --stream-to=video.raw' > /v.sh
chmod a+rwx /v.sh

if [[ $(cat /proc/cmdline 2>/dev/null) =~ 'tbw_hw=1' ]]; then
    cp -av /home/pi/ToxBlinkenwall/toxblinkenwall/toxblinkenwall_hw_nvidia /home/pi/ToxBlinkenwall/toxblinkenwall/toxblinkenwall
    chown pi:pi /home/pi/ToxBlinkenwall/toxblinkenwall/toxblinkenwall_hw_nvidia > /dev/null 2> /dev/null
    echo ""
    echo ""
    echo "--- using NVIDIA HW ACCEL ---"
    echo ""
    echo ""

    # echo 0 > /sys/class/vtconsole/vtcon1/bind
    rmmod -fv nouveau
    # /etc/init.d/consolefont restart
    # rmmod ttm
    # rmmod drm_kms_helper
    # rmmod drm

    # apt-get install -y --force-yes -o "Dpkg::Options::=--force-confdef" nvidia-kernel-dmks
    # apt-get install -y --force-yes -o "Dpkg::Options::=--force-confdef" nvidia-modprobe
    apt-get install -y --force-yes -o "Dpkg::Options::=--force-confdef" libnvidia-encode1 
    apt-get install -y --force-yes -o "Dpkg::Options::=--force-confdef" libnvcuvid1
    depmod -a
    modprobe nvidia
    modprobe nvidia-current
    modprobe nvidia-current-drm
    modprobe nvidia-current-uvm
    modprobe nvidia-current-modeset
    modprobe nvidia
    modprobe nvidia-current
    echo ""
    echo ""

    # test if ffmpeg h264_nvenc is working
    echo './ffmpeg -y -f lavfi -i testsrc=duration=10:size=1280x720:rate=30 -vcodec h264_nvenc test.mkv # -v 56' > /m.sh
    chmod a+rwx /m.sh

    echo '-/ffmpeg -y -c:v h264_cuvid -i test.mkv t2.mkv' > /d.sh
    chmod a+rwx /d.sh

    sleep 3

    echo ""
    echo ""
    nvidia-smi
    echo ""
    echo ""

    sleep 5
fi

echo ""
echo ""
echo ""

# find correct device name
# and change to partition number 3 on the boot device
device_=$(lsblk -nP -o name,mountpoint 2>/dev/null | grep '"/lib/live/mount/medium"' 2>/dev/null | awk '{ print $1 }' 2>/dev/null | awk -F'=' '{ print $2 }' 2>/dev/null | tr -d '"' 2>/dev/null | sed 's/1$/3/' 2>/dev/null )
echo "####################################"
echo ""
echo "found USB boot device: /dev/""$device_"
echo ""

non_persistent=0

if [ "$device_""x" == "x" ]; then
    device_="/dev/"'XXXXXXXXXYYYYYYYZZZZZZ'
    byuuid_device_='AAAAAAAAAAAABBBBBBBBBBCCCCCCCDDDDDDDDDDDDDD'
    lsblk -nP -o name,mountpoint
    # error!!
    echo '!!DEVICE ERROR D-001 !!'
    sleep 10
    non_persistent=1
else
    # get full device path by some magick above
    device_="/dev/""$device_"
    # get full device path by uuid
    byuuid_device_=$(readlink -f "/dev/disk/by-uuid/ffdbdad1-431e-426d-b1f9-2be903c83a48")
fi

if [ ! -e "/dev/disk/by-uuid/ffdbdad1-431e-426d-b1f9-2be903c83a48" ]; then
    echo "UUID device NOT found"
    echo '!!DEVICE ERROR D-004 !!'
    echo '** using non-persistent mode **'
    sleep 10
    non_persistent=1
else
    echo "found UUID device: ""$byuuid_device_"
    echo ""

    # compare if the result is the same
    if [ "$device_""x" != "$byuuid_device_""x" ]; then
        # error!!
        echo '!!DEVICE ERROR D-002 !!'
        echo '** using non-persistent mode **'
        sleep 10
        non_persistent=1
    fi
fi

mkdir -p /home/pi/ToxBlinkenwall/toxblinkenwall/db >/dev/null 2> /dev/null
chown -R pi:pi /home/pi/ToxBlinkenwall/toxblinkenwall/db/ >/dev/null 2> /dev/null
chmod u+rwx /home/pi/ToxBlinkenwall/toxblinkenwall/db/ >/dev/null 2> /dev/null

if [ $non_persistent == 0 ]; then

    sleep 2

    # check if its the first boot ---------
    mount -t ext4 "/dev/disk/by-uuid/ffdbdad1-431e-426d-b1f9-2be903c83a48" /mnt > /dev/null 2> /dev/null
    err=$?
    # check if its the first boot ---------

    if [ $err -eq 0 ]; then

        # check if its really really the correct filesystem/partition
        # since we are going to fully overwrite it
        if [ ! -f "/mnt/__tbw_persist_part__" ]; then
            # error!! block forever
            while [ 1 == 1 ]; do
                echo '!!DEVICE ERROR D-003 !!'
                sleep 10
            done
        fi

        echo "####################################"
        echo "####################################"
        echo "####################################"
        echo "####################################"
        echo "####################################"
        echo "####################################"
        echo ""
        echo "------- SETUP data encryption -------"
        echo "------- pick a strong password ------"
        echo ""

        # unmount and encrypt
        umount -f "/dev/disk/by-uuid/ffdbdad1-431e-426d-b1f9-2be903c83a48" >/dev/null 2> /dev/null
        cryptsetup -y -q luksFormat --uuid "ffdbdad1-431e-426d-b1f9-2be903c83a48" "$device_" #"/dev/disk/by-uuid/ffdbdad1-431e-426d-b1f9-2be903c83a48"
        err2=$?
        if [ $err2 -eq 0 ]; then
            echo ""
            echo "------ UNLOCK data encryption ------"
            echo "---- ENTER your password again -----"
            echo ""

            cryptsetup luksOpen "/dev/disk/by-uuid/ffdbdad1-431e-426d-b1f9-2be903c83a48" tbwdb
            err3=$?
            mkfs.ext4 -e panic -U "039dbad8-1784-4068-9500-33a440117cde" /dev/mapper/tbwdb >/dev/null 2> /dev/null
            if [ $err3 -eq 0 ]; then
                mkdir -p /home/pi/ToxBlinkenwall/toxblinkenwall/db >/dev/null 2> /dev/null
                mount -o "rw,noatime,nodiratime,sync,data=ordered" /dev/mapper/tbwdb /home/pi/ToxBlinkenwall/toxblinkenwall/db >/dev/null 2> /dev/null
                err4=$?
                if [ $err4 -eq 0 ]; then
                    chown -R pi:pi /home/pi/ToxBlinkenwall/toxblinkenwall/db/ >/dev/null 2> /dev/null
                    chmod u+rwx /home/pi/ToxBlinkenwall/toxblinkenwall/db/ >/dev/null 2> /dev/null

                    echo ""
                    echo ""
                    echo "         ++ LUKS init OK ++"
                    echo ""
                    echo ""
                    sleep 5
                else
                    # error!! block forever
                    while [ 1 == 1 ]; do
                        echo '!!LUKS ERROR 003 !!'
                        sleep 10
                    done
                fi
            else
                # error!! block forever
                while [ 1 == 1 ]; do
                    echo '!!LUKS ERROR 002 !!'
                    sleep 10
                done
            fi
        else
            # error!!
            echo '!!LUKS ERROR 001 !!'
            sleep 10
            non_persistent=1
            chown -R pi:pi /home/pi/ToxBlinkenwall/toxblinkenwall/db/ >/dev/null 2> /dev/null
            chmod u+rwx /home/pi/ToxBlinkenwall/toxblinkenwall/db/ >/dev/null 2> /dev/null
        fi
    else
        echo "####################################"
        echo "####################################"
        echo "####################################"
        echo "####################################"
        echo "####################################"
        echo "####################################"
        echo ""
        echo "------ UNLOCK data encryption ------"
        echo "------- ENTER your password --------"
        echo ""

        # try to unlock and mount
        cryptsetup luksOpen "/dev/disk/by-uuid/ffdbdad1-431e-426d-b1f9-2be903c83a48" tbwdb
        err3=$?
        if [ $err3 -eq 0 ]; then
            mkdir -p /home/pi/ToxBlinkenwall/toxblinkenwall/db >/dev/null 2> /dev/null
            mount -o "rw,noatime,nodiratime,sync,data=ordered" /dev/mapper/tbwdb /home/pi/ToxBlinkenwall/toxblinkenwall/db >/dev/null 2> /dev/null
            err4=$?
            if [ $err4 -eq 0 ]; then
                chown -R pi:pi /home/pi/ToxBlinkenwall/toxblinkenwall/db/ >/dev/null 2> /dev/null
                chmod u+rwx /home/pi/ToxBlinkenwall/toxblinkenwall/db/ >/dev/null 2> /dev/null
                echo ""
                echo ""
                echo "         ## LUKS open OK ##"
                echo ""
                echo ""
                sleep 5
            else
                # error!! block forever
                while [ 1 == 1 ]; do
                    echo '!!LUKS ERROR 005 !!'
                    sleep 10
                done
            fi
        else
            # error!! block forever
            while [ 1 == 1 ]; do
                echo '!!LUKS ERROR 004 !!'
                sleep 10
            done
        fi
    fi

    # copy phone book entries from persistent storage to actual usage dir
    cp -f /home/pi/ToxBlinkenwall/toxblinkenwall/db/book_entry_*.txt /home/pi/ToxBlinkenwall/toxblinkenwall/ >/dev/null 2> /dev/null
    chown pi:pi /home/pi/ToxBlinkenwall/toxblinkenwall/book_entry_*.txt >/dev/null 2> /dev/null

    # copy phone custom bootstrap nodes file from persistent storage to actual usage dir
    cp -f /home/pi/ToxBlinkenwall/toxblinkenwall/db/custom_bootstrap_nodes.dat /home/pi/ToxBlinkenwall/toxblinkenwall/ >/dev/null 2> /dev/null
    chown pi:pi /home/pi/ToxBlinkenwall/toxblinkenwall/custom_bootstrap_nodes.dat >/dev/null 2> /dev/null

fi


dmesg -E 2> /dev/null
