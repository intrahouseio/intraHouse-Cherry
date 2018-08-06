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

#-------------- generate config

 cat > $root/config.json <<EOF
 {
   "port":$port,
   "project":"$project_name",
   "name_service":"$name_service",
   "lang":"$lang"
 }
EOF

chmod 744 $root/config.json

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

echo "search $name_service"
file=$(curl -s https://api.github.com/repos/intrahouseio/$repo_name/releases/latest | grep browser_download_url | cut -d '"' -f 4)
echo -e "latest found: \033[0;32m $file \033[0m"

echo -e "\033[0m"
echo -e "get $name_service \033[0;34m"
curl --progress-bar -L -o intrahouse-lite.zip $file

echo -e "\033[0m"
echo -e "get nodeJS \033[0;34"
curl --progress-bar -L -o node.tar.xz "https://nodejs.org/dist/v8.7.0/node-v8.7.0-darwin-x64.tar.gz"


#-------------- end


#-------------- deploy

echo -e "\033[0;33m"
echo -e "Deploy:"
echo -e "\033[0m"

unzip ./intrahouse-lite.zip > /dev/null

if [ -d "./project_$lang" ]; then
  rm -fr $project_path
  mkdir -p $project_path
  cp -fr ./project_$lang/* $project_path
  rm -fr ./project_*
fi

mkdir -p node
cd ./node
tar xf ./../node.tar.xz --strip 1
cd ./../

rm -frd ./intrahouse-lite.zip
rm -frd ./node.tar.xz

cd ./backend
#export PATH=$PATH:$root/node/bin
$root/node/bin/node $root/node/bin/npm i --only=prod

#-------------- end


#-------------- register service

echo -e "\033[0;36m"
echo -e "...register service \033[0m"
echo ""

path_service=/Library/LaunchAgents/$name_service.plist

sudo rm -frd $path_service

cat > $path_service <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>

  <key>Label</key>
    <string>$name_service</string>

  <key>WorkingDirectory</key>
    <string>/opt/$name_service</string>

  <key>ProgramArguments</key>
  <array>
    <string>/opt/$name_service/node/bin/node</string>
    <string>/opt/$name_service/backend/app.js</string>
    <string>prod</string>
  </array>

  <key>RunAtLoad</key>
    <true/>

  <key>KeepAlive</key>
    <true/>

  <key>StandardOutPath</key>
    <string>/opt/$name_service/launchdOutput.log</string>

  <key>StandardErrorPath</key>
    <string>/opt/$name_service/launchdErrors.log</string>


</dict>
</plist>
EOF

sudo launchctl stop $name_service
sudo launchctl remove $name_service

sudo chown root /Library/LaunchAgents/$name_service.plist
sudo chmod 644 /Library/LaunchAgents/$name_service.plist
sudo launchctl load /Library/LaunchAgents/$name_service.plist

sudo launchctl start $name_service

sudo launchctl list | grep $name_service

#-------------- end
