#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo -e "\033[0;31m Please run as root."
  exit
fi

echo -e "\033[0;34m"
cat << "EOF"
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

repo_name="Doc"
root=/opt/intrahouse

mkdir -p $root

case "$OSTYPE" in
  solaris*) echo -e "\033[0;33m Error:\033[0;31m Installation is not supported\033[0;35m $OSTYPE!" && exit ;; #SOLARIS
  darwin*)  url="http://192.168.0.111:3000/api/install_darwin.sh" ;; #OSX
  linux*)   url="http://192.168.0.111:3000/api/install_linux.sh" ;; #LINUX
  bsd*)     echo -e "\033[0;33m Error:\033[0;31m Installation is not supported\033[0;35m $OSTYPE!" && exit ;; #BSD
  msys*)    echo -e "\033[0;33m Error:\033[0;31m Installation is not supported\033[0;35m $OSTYPE!" && exit ;; #WINDOWS
  *)        echo -e "\033[0;33m Error:\033[0;31m Unknown operating system\033[0;35m $OSTYPE\033[0;31m, installation aborted!" && exit ;; #UNKNOWN
esac

echo $MACHINE_TYPE
curl -sL -o $root/install.sh $url
. $root/install.sh
