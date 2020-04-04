#! /bin/bash

# ignore CTRL-C press in this script ---------
trap '' INT
# ignore CTRL-C press in this script ---------

dmesg -D 2> /dev/null


# tell network manager to NOT manage these network interfaces!!
mkdir -p /etc/network 2> /dev/null

echo '
auto lo
iface lo inet loopback

# allow-hotplug eth0
# iface eth0 inet dhcp

auto wlan0
iface wlan0 inet dhcp
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

' > /etc/network/interfaces 2> /dev/null

function set_wlan_values
{
    export mount_dir="/tmp/"

    if [ -e "$mount_dir""/""wlan_ssid.txt" ]; then

        wpa_net_country="AT" # TODO: also make this a parameter?
        wpa_net_id_rand=$(( ( RANDOM % 100000 )  + 1 ))

        ########-------------------------------------

        wpa_conf_file_location="/etc/wpa_supplicant/wpa_supplicant.conf"
        wpa_conf_file_mode="600"
        wpa_conf_file_content_001='country=@NETCOUNTRY@
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
    ssid="'

        wpa_conf_file_content_002='"
    scan_ssid=1
    psk="'

        wpa_conf_file_content_003='"
    key_mgmt=WPA-PSK
    mode=0
    proto=WPA2
    pairwise=CCMP
    group=CCMP
    auth_alg=OPEN
    id_str="ToxPhone@RAND@"
    priority=1
}
'

        wpa_conf_file_content_openwlan='
network={
    key_mgmt=NONE
    priority=-999
}
'

        ########-------------------------------------

        rm -f "/tmp/abc.txt"

        rm -f "/tmp/abc001.txt"

        echo -n "$wpa_conf_file_content_001" \
          | sed -e 's#@NETCOUNTRY@#'"$wpa_net_country"'#' \
          > "/tmp/abc001.txt"

        chmod og-rwx "/tmp/abc001.txt"

        rm -f "/tmp/abc003.txt"

        echo -n "$wpa_conf_file_content_003" \
          | sed -e 's#@RAND@#'"$wpa_net_id_rand"'#' \
          > "/tmp/abc003.txt"

        chmod og-rwx "/tmp/abc003.txt"

        cat "/tmp/abc001.txt" > "/tmp/abc.txt"
        cat "$mount_dir""/""wlan_ssid.txt"|head -1|tr -d '\r'|tr -d '\n' >> "/tmp/abc.txt"
        echo -n "$wpa_conf_file_content_002" >> "/tmp/abc.txt"
        cat "$mount_dir""/""wlan_pass.txt"|head -1|tr -d '\r'|tr -d '\n' >> "/tmp/abc.txt"
        cat "/tmp/abc003.txt" >> "/tmp/abc.txt"

        rm -f "/tmp/abc001.txt" "/tmp/abc003.txt"

        if [ -e "$mount_dir""/""wlan_public.txt" ]; then
            echo "$wpa_conf_file_content_openwlan" >> "/tmp/abc.txt"
        fi

        chmod $wpa_conf_file_mode "/tmp/abc.txt"

        mv -v "/tmp/abc.txt" "$wpa_conf_file_location"
        rm -f "/tmp/abc.txt" # just to be safe

    fi

    return 0
}







echo ""
echo ""
echo ""
echo ""

echo "####################################"
echo ""
echo ' press "A" to enter your screename'
echo ' press "N" to setup WIFI'
echo ' press "F" to setup Public Free WIFI'
echo "        or wait 6 seconds"
echo ""

screen_name=''
name_set=0
what=0

echo -n 'press "A" or "N" or "F" ';
for _ in {1..6}; do
    read -rs -n1 -t1 name1 > /dev/null 2>&1
    ret=$?
    if [ $ret -eq 0 ]; then
        if [ "$name1""x" == "ax" ]; then
            echo ""
            read -p 'New Screenname : ' -t60 -r -e screen_name
            name_set=1
            what=0
            break
        elif [ "$name1""x" == "nx" ]; then
            echo ""
            echo " WIFI Networks in the area:"
            echo ""
            nmcli device wifi list
            echo ""
            echo ""
            sleep 2

            read -p 'WIFI SSID : ' -t60 -r -e wifi_ssid
            read -p 'WIFI PASS : ' -t60 -r -e wifi_pass
            name_set=1
            what=1
            break
        elif [ "$name1""x" == "fx" ]; then
            echo ""
            echo " WIFI Networks in the area:"
            echo ""
            nmcli device wifi list
            echo ""
            echo ""
            sleep 2

            wifi_ssid="_PUBLIC_FREE_"
            wifi_pass="xxyy12_PUBLIC_FREE_213213123"
            name_set=1
            what=1
            break
        else
            echo -n '.'
        fi
    else
        echo -n '.'
    fi
done

echo ""

# restore toxname from persistent storage
cp -av /home/pi/ToxBlinkenwall/toxblinkenwall/db/toxname.txt /home/pi/ToxBlinkenwall/toxblinkenwall/toxname.txt > /dev/null 2> /dev/null
chown pi:pi /home/pi/ToxBlinkenwall/toxblinkenwall/toxname.txt > /dev/null 2> /dev/null

# set values from user input
if [ $name_set -eq 1 ]; then
    if [ "$what""x" == "0x" ]; then
        if [ "$screen_name""x" != "x" ]; then
            echo ""
            echo ""
            echo "Screenname will be : ""$screen_name"
            echo "$screen_name" > /home/pi/ToxBlinkenwall/toxblinkenwall/toxname.txt 2> /dev/null
            chown pi:pi /home/pi/ToxBlinkenwall/toxblinkenwall/toxname.txt > /dev/null 2> /dev/null
            echo ""
            echo ""
            sleep 5
        fi
    elif [ "$what""x" == "1x" ]; then
        if [ "$wifi_ssid""x" != "x" ]; then
            if [ "$wifi_pass""x" != "x" ]; then
                echo ""
                echo ""
                echo "Connecting to WIFI ""$wifi_ssid"" ..."

                echo "$wifi_ssid" > /tmp/wlan_ssid.txt
                echo "$wifi_pass" > /tmp/wlan_pass.txt
                echo ""           > /tmp/wlan_public.txt
                set_wlan_values   > /dev/null 2>&1

                sleep 5
            fi
        fi
    fi
fi

dmesg -E 2> /dev/null

