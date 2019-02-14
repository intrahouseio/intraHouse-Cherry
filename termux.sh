echo -e "\033[0;34m"
cat <<\EOF
######################################
#             INTRAHOUSE             #
#  Software for Automation Systems   #
######################################
EOF

#-------------- options

repo_name="intraHouse-Cherry"
name_service="intrahouse-c"
project_name=project_$(date +%s)
port=8088

root="$(pwd)/$name_service"
core="$(pwd)/$name_service/core"
project="$root/varlib/"
project_path="$root/varlib/$name_service/projects/$project_name"

file="https://github.com/intrahouseio/intraHouse-Cherry/releases/download/v4.4.15/intrahouse-lite.zip"

case "$1" in
  "ru")   lang=$1;;
  "en")   lang=$1;;
     *)   lang="en";;
esac
echo $lang
#-------------- end

#-------------- creation of structures

rm -fr $core

mkdir -p $root
mkdir -p $core
mkdir -p $project_path

cd $core

#-------------- end

#-------------- check dependencies
echo -e "\033[0;33m"
echo -e "Check dependencies:"
echo -e "\033[0m"

pkg install -y zip unzip rsync nodejs

#-------------- end

#-------------- download files
echo -e "\033[0;33m"
echo -e "Download:"
echo -e "\033[0m"

echo "search $name_service"
echo -e "latest found: \033[0;32m $file \033[0m"

echo -e "\033[0m"
echo -e "get $name_service \033[0;34m"
wget $file -q --show-progress

#-------------- end

#-------------- deploy
echo -e "\033[0;33m"
echo -e "Deploy:"
echo -e "\033[0m"

unzip ./intrahouse-lite.zip > /dev/null

cd ./backend

npm i --only=prod
npm i --only=prod pm2 -g

cd ..

cp -fr ./project_$lang/* $project_path

rm -fr ./project_*
rm -fr ./intrahouse-lite.zip

#-------------- end

#-------------- generate config

 cat > $core/config.json <<EOF
 {
   "port":$port,
   "project":"$project_name",
   "name_service":"$name_service",
   "node":"node",
   "npm":"npm",
   "lang":"$lang",
   "vardir":"$project"
 }
EOF

chmod 744 $core/config.json

#-------------- end

#-------------- register service
echo -e "\033[0;36m"
echo -e "...register service \033[0m"
echo ""
pm2 stop intrahouse-c > /dev/null
pm2 start ./backend/app.js -- prod --name "intrahouse-c"

cat > ~/.bashrc <<EOF
cd ./intrahouse-c/core/ && pm2 start ./backend/app.js -- prod --name "intrahouse-c"
EOF

#-------------- end

#-------------- get ip address server

 myip=""
 while IFS=$': \t' read -a line ;do
     [ -z "${line%inet}" ] && ip=${line[${#line[1]}>4?1:2]} &&
         [ "${ip#127.0.0.1}" ] && myip="http://$ip:$port/pm/ $myip"
 done< <(LANG=C ifconfig)

#-------------- end

#-------------- display info complete

echo -e "\033[0;34m"
echo "-----------------------------------------------------------------------------------"
echo ""
echo -e "\033[0;36m Web interface:\033[0;35m $myip"
echo -e "\033[0;36m Complete! Thank you."
echo -e "\033[0m"

#-------------- end
