#!/bin/bash

echo -e "\033[0;36m"
echo -e "...installing \033[0m"


#-------------- creation of structures

cd /mnt/data

rm -fr $root/install.sh
rm -fr $root
mkdir -p $root
cd $root

#-------------- end

#-------------- generate config

 cat > $root/config.json <<EOF
 {
   "port":$port,
   "project":"$project_name",
   "name_service":"$name_service",
   "lang":"$lang",
   "vardir":"$project_root",
   "node":"$root/node/bin/node",
   "npm":"$root/node/bin/node $root/node/bin/npm"
 }
EOF

chmod 744 $root/config.json

#-------------- end

#-------------- check dependencies

echo -e "\033[0;33m"
echo -e "Check dependencies:"
echo -e "\033[0m"

check_iconfig=$(ifconfig 2> /dev/null || echo "false" )
check_zip=$(zip -L 2> /dev/null || echo "false" )
check_unzip=$(unzip 2> /dev/null || echo "false" )
check_xz=$(xz -h 2> /dev/null || echo "false" )
check_rsync=$(rsync --version 2> /dev/null || echo "false" )

if [[ $check_zip != "false" ]]; then
  echo -e "\033[0;35m zip:\033[0;32m true \033[0m"
else
  echo -e "\033[0;35m zip:\033[0;31m false \033[0m --> will be installed"

   apt-get update > /dev/null
   apt-get install -y zip > /dev/null
fi

if [[ $check_unzip != "false" ]]; then
  echo -e "\033[0;35m unzip:\033[0;32m true \033[0m"
else
  echo -e "\033[0;35m unzip:\033[0;31m false \033[0m --> will be installed"

   apt-get update > /dev/null
   apt-get install -y unzip > /dev/null
fi

if [[ $check_xz != "false" ]]; then
  echo -e "\033[0;35m xz-utils:\033[0;32m true \033[0m"
else
  echo -e "\033[0;35m xz-utils:\033[0;31m false \033[0m --> will be installed"

   apt-get update > /dev/null
   apt-get install -y xz-utils > /dev/null
fi

if [[ $check_iconfig != "false" ]]; then
  echo -e "\033[0;35m net-tools:\033[0;32m true \033[0m"
else
  echo -e "\033[0;35m net-tools:\033[0;31m false \033[0m --> will be installed"

   apt-get update > /dev/null
   apt-get install -y net-tools > /dev/null
fi

if [[ $check_rsync != "false" ]]; then
  echo -e "\033[0;35m rsync:\033[0;32m true \033[0m"
else
  echo -e "\033[0;35m rsync:\033[0;31m false \033[0m --> will be installed"

   apt-get update > /dev/null
   apt-get install -y rsync > /dev/null
fi

#-------------- end


#-------------- download files
echo -e "\033[0;33m"
echo -e "Download:"
echo -e "\033[0m"

case $(uname -m) in
  armv6*)  processor="armv6l" ;;
  armv7*)  processor="armv7l" ;;
  armv8*)  processor="arm64" ;;
  aarch64*)  processor="arm64" ;;
  *)       [[ $(getconf LONG_BIT) = "64" ]] && processor="x64" || processor="x86" ;;
esac

echo "search $name_service"
file=$(curl -s https://api.github.com/repos/intrahouseio/$repo_name/releases/latest | grep browser_download_url | cut -d '"' -f 4)
echo -e "latest found: \033[0;32m $file \033[0m"

echo -e "\033[0m"
echo -e "get $name_service \033[0;34m"
curl --progress-bar -L -o intrahouse-lite.zip $file

echo -e "\033[0m"
echo -e "get nodeJS \033[0;34m"
curl --progress-bar -L -o node.tar.xz "https://nodejs.org/dist/v8.17.0/node-v8.17.0-linux-$processor.tar.xz"


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

rm -fr ./intrahouse-lite.zip
rm -fr ./node.tar.xz

cd ./backend
#export PATH=$root/node/bin:$PATH
$root/node/bin/node $root/node/bin/npm i --only=prod --scripts-prepend-node-path=auto
#cp -Rf $root/deps/core-js $root/backend/node_modules
#$root/node/bin/node $root/node/bin/npm i pdfmake@0.1.37 --only=prod

mkdir -p /opt/intrahouse-c/node/bin

 ln -s $root/node/bin/node /opt/intrahouse-c/node/bin/node
 ln -s $root/node/bin/npm /opt/intrahouse-c/node/bin/npm

#-------------- end


#-------------- register service

echo -e "\033[0;36m"
echo -e "...register service \033[0m"
echo ""

distro=$(lsb_release -c -s 2> /dev/null) || distro=$(cat /etc/os-release | grep -oP "VERSION=\".*\(\K(.*)\)") && distro=${distro%?}

case "$distro" in
  xenia*)  type_service="systemd" ;; # ubuntu 16
  trust*)  type_service="upstart" ;; # ubuntu 14
  precis*) type_service="upstart" ;; # ubuntu 12
  jessi*)  type_service="systemd" ;; # debian 8
  wheez*)  type_service="sysv" ;; # debian 7
  *)        type_service="systemd" ;;
esac

# if [[ $type_service == "sysv" ]]; then

#  service $name_service stop 2> /dev/null
  path_service="/etc/init.d/$name_service"

  rm -fr $path_service
  touch $path_service
  chmod 755 $path_service

  cat > $path_service <<EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:          $name_service
# Required-Start:    \$local_fs \$network \$remote_fs \$syslog \$named \$time
# Required-Stop:     \$local_fs \$network \$remote_fs \$syslog \$named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable service provided by daemon.
### END INIT INFO

dir="/mnt/data/opt/$name_service"
cmd="/mnt/data/opt/$name_service/node/bin/node /mnt/data/opt/$name_service/backend/app.js prod"
user=""

name=\`basename \$0\`
pid_file="/var/run/\$name.pid"
stdout_log="/var/log/\$name.log"
stderr_log="/var/log/\$name.err"

get_pid() {
    cat "\$pid_file"
}

is_running() {
    [ -f "\$pid_file" ] && ps -p \`get_pid\` > /dev/null 2>&1
}

case "\$1" in
    start)
    if is_running; then
        echo "Already started"
    else
        echo "Starting \$name"
        cd "\$dir"
        if [ -z "\$user" ]; then
             \$cmd >> "\$stdout_log" 2>> "\$stderr_log" &
        else
             -u "\$user" \$cmd >> "\$stdout_log" 2>> "\$stderr_log" &
        fi
        echo \$! > "\$pid_file"
        if ! is_running; then
            echo "Unable to start, see \$stdout_log and \$stderr_log"
            exit 1
        fi
    fi
    ;;
    stop)
    if is_running; then
        echo -n "Stopping \$name.."
        kill \`get_pid\`
        for i in 1 2 3 4 5 6 7 8 9 10
        # for i in \`seq 10\`
        do
            if ! is_running; then
                break
            fi

            echo -n "."
            sleep 1
        done
        echo

        if is_running; then
            echo "Not stopped; may still be shutting down or shutdown may have failed"
            exit 1
        else
            echo "Stopped"
            if [ -f "\$pid_file" ]; then
                rm "\$pid_file"
            fi
        fi
    else
        echo "Not running"
    fi
    ;;
    restart)
    \$0 stop
    if is_running; then
        echo "Unable to stop, will not attempt to start"
        exit 1
    fi
    \$0 start
    ;;
    status)
    if is_running; then
        echo "[\033[0;32m ok \033[0m] \$name is running."
    else
        echo "[\033[0;31m FAIL \033[0m] \$name is not running ... \033[0;31mfailed! \033[0m]"
        exit 1
    fi
    ;;
    *)
    echo "Usage: \$0 {start|stop|restart|status}"
    exit 1
    ;;
esac

exit 0
EOF

update-rc.d $name_service defaults

# fi

if [[ $type_service == "systemd" ]]; then

#  $(service $name_service stop 2> /dev/null)
  path_service="/etc/systemd/system/$name_service.service"

  rm -fr $path_service
  touch $path_service

  cat > $path_service <<EOF
  [Unit]
  Description=$name_service
  After=network.target mysql.service

  [Service]
  WorkingDirectory=/mnt/data/opt/$name_service
  ExecStart=/mnt/data/opt/$name_service/node/bin/node /mnt/data/opt/$name_service/backend/app.js prod
  Restart=always
  RestartSec=5
  StandardOutput=syslog
  StandardError=syslog
  SyslogIdentifier=$name_service

  [Install]
  WantedBy=multi-user.target mysql.service
EOF
  export SYSTEMD_PAGER=''
  chmod 755 $path_service

  systemctl daemon-reload
  systemctl enable $name_service

fi

if [[ $type_service == "upstart" ]]; then

#  $(service $name_service stop 2> /dev/null)
  path_service="/etc/init/$name_service.conf"

  rm -fr $path_service
  touch $path_service

  cat > $path_service <<EOF
  start on filesystem and started networking
  stop on shutdown
  respawn
  chdir /mnt/data/opt/$name_service
  env NODE_ENV=production

  exec /mnt/data/opt/$name_service/node/bin/node /mnt/data/opt/$name_service/backend/app.js prod
EOF

fi

service $name_service restart > /dev/null
service $name_service status

#-------------- end
