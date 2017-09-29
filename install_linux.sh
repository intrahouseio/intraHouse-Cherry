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

echo -e "\033[0;33m"
echo -e "Check dependencies:"
echo -e "\033[0m"

check_unzip=$(unzip 2> /dev/null || echo "false" )
check_xz=$(xz -h 2> /dev/null || echo "false" )

if [[ $check_unzip != "false" ]]; then
  echo -e "\033[0;35m unzip:\033[0;32m true \033[0m"
else
  echo -e "\033[0;35m unzip:\033[0;31m false \033[0m --> will be installed"

  apt-get update > /dev/null
  apt-get install unzip > /dev/null
fi

if [[ $check_xz != "false" ]]; then
  echo -e "\033[0;35m xz-utils:\033[0;32m true \033[0m"
else
  echo -e "\033[0;35m xz-utils:\033[0;31m false \033[0m --> will be installed"

  apt-get update > /dev/null
  apt-get install xz-utils > /dev/null
fi

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
curl -sL -o node.tar.xz "https://nodejs.org/dist/v8.6.0/node-v8.6.0-linux-x64.tar.xz"


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

service intrahouse stop > /dev/null

path_service="/etc/systemd/system/intrahouse.service"

rm -frd $path_service
touch $path_service

cat > $path_service << "EOF"
cription=intrahouse

[Service]
WorkingDirectory=/opt/intrahouse/backend
ExecStart=/opt/intrahouse/node/bin/node /opt/intrahouse/backend/app.js prod
Restart=always
 RestartSec=5
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=intrahouse

[Install]
WantedBy=multi-user.target
EOF

chmod 755 $path_service

systemctl daemon-reload
systemctl enable

service intrahouse start
systemctl status intrahouse

#-------------- end


echo -e "\033[0;36m"
echo "Complete! Thank you."
echo -e "\033[0m"
