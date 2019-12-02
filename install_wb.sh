#!/bin/bash

#-------------- check sudo/root

if [ "$EUID" -ne 0 ]
  then echo -e "\033[0;31m Please run as root."
  exit
fi

#-------------- end

#-------------- options

repo_name="intraHouse-Cherry"
name_service="intrahouse-c"
project_name=project_$(date +%s)
port=8088

root=/mnt/data/opt/$name_service
project_root=/mnt/data/var/lib/
project_path=/mnt/data/var/lib/$name_service/projects/$project_name

case "$1" in
  "ru")   lang=$1;;
  "en")   lang=$1;;
     *)   lang="en";;
esac

#-------------- end

#-------------- logo

echo -e "\033[0;34m"
cat <<\EOF
   ______          __                   __  __
  /\__  _\        /\ \__               /\ \/\ \
  \/_/\ \/     ___\ \ ,_\  _ __    __  \ \ \_\ \    ___   __  __    ____     __
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

url="https://raw.githubusercontent.com/intrahouseio/intraHouse-Cherry/master/install_linux_deb_wb.sh"


curl -sL -o $root/install.sh $url
. $root/install.sh

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
echo -e "\033[0;36m Web interface:\033[0;35m $myip"
echo -e "\033[0;36m Complete! Thank you."
echo -e "\033[0m"

#-------------- end
