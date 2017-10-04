#!/bin/bash

#-------------- check sudo/root

if [ "$EUID" -ne 0 ]
  then echo -e "\033[0;31m Please run as root."
  exit
fi

#-------------- end

#-------------- options

repo_name="Doc"
name_service="intrahouse-c"

port=8088
root=/opt/$name_service
project_path=/var/lib/$name_service

#-------------- end

#-------------- logo

echo -e "\033[0;34m"
cat <<\EOF
   ______          __                   __  __
  /\__  _\        /\ \__               /\ \/\ \
  \/_/\ \/    ___\ \ ,_\  _ __    __  \ \ \_\ \    ___   __  __    ____     __
    \ \ \   /' _ `\ \ \/ /\`'__\/'__`\ \ \  _  \  / __`\/\ \/\ \  /',__\  /'__`\
     \_\ \__/\ \/\ \ \ \_\ \ \//\ \L\.\_\ \ \ \ \/\ \L\ \ \ \_\ \/\__, `\/\  __/
     /\_____\ \_\ \_\ \__\\ \_\\ \__/.\_\\ \_\ \_\ \____/\ \____/\/\____/\ \____\
     \/_____/\/_/\/_/\/__/ \/_/ \/__/\/_/ \/_/\/_/\/___/  \/___/  \/___/  \/____/

                          Software for Automation Systems

-----------------------------------------------------------------------------------

EOF

#-------------- end

#-------------- install start

rm -fr $root
mkdir -p $root

function getLinuxUrl {
  check=$(apt-get 2> /dev/null || echo "false" )
  if [[ $check != "false" ]]; then
      url="https://raw.githubusercontent.com/intrahouseio/Doc/master/install_linux_deb.sh"
  else
      url="https://raw.githubusercontent.com/intrahouseio/Doc/master/install_linux_red.sh"
  fi
}

case "$OSTYPE" in
  solaris*) echo -e "\033[0;33m Error:\033[0;31m Installation is not supported\033[0;35m $OSTYPE!" && exit ;; #SOLARIS
  darwin*)  url="https://raw.githubusercontent.com/intrahouseio/Doc/master/install_darwin.sh" ;; #OSX
  linux*)   getLinuxUrl ;; #LINUX
  bsd*)     echo -e "\033[0;33m Error:\033[0;31m Installation is not supported\033[0;35m $OSTYPE!" && exit ;; #BSD
  msys*)    echo -e "\033[0;33m Error:\033[0;31m Installation is not supported\033[0;35m $OSTYPE!" && exit ;; #WINDOWS
  *)        echo -e "\033[0;33m Error:\033[0;31m Unknown operating system\033[0;35m $OSTYPE\033[0;31m, installation aborted!" && exit ;; #UNKNOWN
esac


 curl -sL -o $root/install.sh $url
 . $root/install.sh

#-------------- end

#-------------- generate config

 cat > $root/config.json <<EOF
 {
   "port":$port,
   "project":"$project_path/lite",
 }
EOF

#-------------- end

#-------------- get ip address server

 myip=""
 while IFS=$': \t' read -a line ;do
     [ -z "${line%inet}" ] && ip=${line[${#line[1]}>4?1:2]} &&
         [ "${ip#127.0.0.1}" ] && myip="http://$ip:$port/pm/ $myip"
 done< <(LANG=C /sbin/ifconfig)

#-------------- end

#-------------- display info complete

echo -e "\033[0;34m"
echo "-----------------------------------------------------------------------------------"
echo ""
echo -e "\033[0;36m Server start:\033[0;35m $myip"
echo -e "\033[0;36m Complete! Thank you."
echo -e "\033[0m"

#-------------- end
