#!/bin/bash

#-------------- check sudo/root

if [ "$EUID" -ne 0 ]
  then echo -e "\033[0;31m Please run as root."
  exit
fi

#-------------- end


#-------------- tools
function check {
  test=$($1 2> /dev/null || echo "false" )
  if [[ $test != "false" ]]; then
    echo -e "$2:\033[0;32m true \033[0m"
  else
    echo -e "$2:\033[0;31m false \033[0m"
  fi
}

function checkv {
  test=$($1 2> /dev/null || echo "false" )
  if [[ $test != "false" ]]; then
    echo -e "$2:\033[0;32m true\033[0m --> $test"
  else
    error=$($1 2>&1 >/dev/null)
    echo -e "$2:\033[0;31m false\033[0m --> $error"
  fi
}

#-------------- end


#-------------- start test
echo -e "\033[0;34m"
echo "------START TEST------"

echo -e "\033[0;33m"
echo "system:"
echo -e "\033[0m"
case $(uname -m) in
  armv6*)  processor="armv6l" ;;
  armv7*)  processor="armv7l" ;;
  armv8*)  processor="arm64" ;;
  *)       [[ $(getconf LONG_BIT) = "64" ]] && processor="x64" || processor="x86" ;;
esac
lsb_release -a
echo "Architecture:   $processor"
echo ""
uname -a

echo -e "\033[0;33m"
echo "browsers:"
echo -e "\033[0m"
checkv "google-chrome --version" "google-chrome"
checkv "firefox -v" "firefox"

echo -e "\033[0;33m"
echo -e "dependencies:"
echo -e "\033[0m"

#iconfig=$(ifconfig 2> /dev/null || echo "false" )
#unzip=$(unzip 2> /dev/null || echo "false" )
#xz=$(xz -h 2> /dev/null || echo "false" )

check "ifconfig" "net-tools"
check "unzip" "unzip"
check "xz -h" "xz-utils"
echo ""
checkv "/opt/intrahouse-c/node/bin/node -v" "nodejs (local)"
checkv "/opt/intrahouse-c/node/bin/node /opt/intrahouse-c/node/bin/npm -v" "npm (local)"
echo ""
checkv "node -v" "nodejs (system)"
checkv "npm -v" "npm (system)"

echo -e "\033[0;34m"
echo "------END TEST------"
#-------------- end
