#!/bin/bash

echo -e "\033[0;36m"
echo -e "...installing \033[0m"


#-------------- creation of structures

cd /opt

rm -frd $root/install.sh
rm -frd $root
mkdir -p $root
cd $root

#-------------- end

#-------------- check dependencies

# echo -e "\033[0;33m"
# echo -e "Check dependencies:"
# echo -e "\033[0m"

#-------------- end


#-------------- download files
echo -e "\033[0;33m"
echo -e "Download:"
echo -e "\033[0m"

echo "search latest"
# file=$(curl -s https://api.github.com/repos/intrahouseio/$repo_name/releases/latest | grep browser_download_url | cut -d '"' -f 4)
file="http://192.168.0.111:3000/api/intrahouse/intrahouse-lite.zip"
echo -e "latest found: \033[0;32m $file \033[0m"

echo "get latest"
curl -sL -o intrahouse-lite.zip $file

echo "get node"
curl -sL -o node.tar.xz "https://nodejs.org/dist/v8.6.0/node-v8.6.0-darwin-x64.tar.gz"


#-------------- end


#-------------- deploy

echo -e "\033[0;33m"
echo -e "Deploy:"
echo -e "\033[0m"

unzip ./intrahouse-lite.zip > /dev/null

mkdir -p node
cd ./node
tar xf ./../node.tar.xz --strip 1
cd ./../

rm -frd ./intrahouse-lite.zip
rm -frd ./node.tar.xz

cd ./backend
export PATH=$PATH:$root/node/bin
$root/node/bin/npm i

#-------------- end


#-------------- register service

echo -e "\033[0;36m"
echo -e "...register service \033[0m"
echo ""

path_service=/Library/LaunchAgents/intrahouse.plist

sudo rm -frd $path_service

cat > $path_service << "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>

  <key>Label</key>
    <string>intrahouse</string>

  <key>WorkingDirectory</key>
    <string>/opt/intrahouse/backend</string>

  <key>ProgramArguments</key>
  <array>
    <string>/opt/intrahouse/node/bin/node</string>
    <string>/opt/intrahouse/backend/app.js</string>
    <string>prod</string>
  </array>

  <key>RunAtLoad</key>
    <true/>

  <key>KeepAlive</key>
    <true/>

  <key>StandardOutPath</key>
    <string>/opt/intrahouse/launchdOutput.log</string>

  <key>StandardErrorPath</key>
    <string>/opt/intrahouse/launchdErrors.log</string>


</dict>
</plist>
EOF

sudo launchctl stop intrahouse
sudo launchctl remove intrahouse

sudo chown root /Library/LaunchAgents/intrahouse.plist
sudo chmod 644 /Library/LaunchAgents/intrahouse.plist
sudo launchctl load /Library/LaunchAgents/intrahouse.plist

sudo launchctl start intrahouse

sudo launchctl list | grep intrahouse

#-------------- end


echo -e "\033[0;36m"
echo "Complete! Thank you."
echo -e "\033[0m"
