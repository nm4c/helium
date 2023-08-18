#!/bin/ash

echo "Checking latest gateway-rs version..."
latestver=$(curl https://github.com/helium/gateway-rs/releases/latest --verbose 2>&1 | grep -Eo 'v[0-9]\.[0-9]\.[0-9]' | cut -b 2-)

echo "Latest version is v$latestver... Downloading..."

curl -Ls https://github.com/helium/gateway-rs/releases/download/v$latestver/helium-gateway-$latestver-aarch64-unknown-linux-musl.tar.gz | tar xvzf - -C /root/ helium_gateway
chown root.root /root/helium_gateway
instver=$(/root/helium_gateway -V)
oldver=$(/usr/bin/helium_gateway -V)

echo "$instver binary downloaded. Current version is $oldver"

while true
do
    read -p 'Install now? ' choice
    case "$choice" in
      n|N) exit;;
      y|Y) go=1 break;;
      *) echo 'Invalid choice';;
    esac
done
if [ $go = 1 ]; then
   echo "Stopping old helium_gateway process..."
   /etc/init.d/helium_gateway stop
   mv /usr/bin/helium_gateway /usr/bin/helium_gateway.old
   echo "Installing helium_gateway..."
   mv /root/helium_gateway /usr/bin/
   newver=$(/usr/bin/helium_gateway -V)
   echo "Starting $newver ..."
   /etc/init.d/helium_gateway start
   echo "Install completed, old $oldver saved at /usr/bin/helium_gateway.old"
   echo "*** If Helium auto-update is enabled this update will be overwritten on the next update cycle ***"
fi
