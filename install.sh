#!/bin/bash

repo_name="Doc"

echo -e "\033[0;34m"
cat << "EOF"
 ______          __                   __  __
/\__  _\        /\ \__               /\ \/\ \
\/_/\ \/    ___\ \ ,_\  _ __    __  \ \ \_\ \    ___   __  __    ____     __
  \ \ \   /' _ `\ \ \/ /\`'__\/'__`\ \ \  _  \  / __`\/\ \/\ \  /',__\  /'__`\
   \_\ \__/\ \/\ \ \ \_\ \ \//\ \L\.\_\ \ \ \ \/\ \L\ \ \ \_\ \/\__, `\/\  __/
   /\_____\ \_\ \_\ \__\\ \_\\ \__/.\_\\ \_\ \_\ \____/\ \____/\/\____/\ \____\
   \/_____/\/_/\/_/\/__/ \/_/ \/__/\/_/ \/_/\/_/\/___/  \/___/  \/___/  \/____/

----------------------------------------------------------------------------------

EOF
echo -e "\033[0;36m"

echo -e "...installing \033[0m"
echo ""

echo "check latest"

file=$(curl -s https://api.github.com/repos/intrahouseio/$repo_name/releases/latest | grep browser_download_url | cut -d '"' -f 4)

echo -e "latest found: \033[0;32m $file \033[0m"
echo "get latest"

curl -sL -o intrahouse-lite.zip $file

echo -e "\033[0;36m"
echo "Install complete!!!"
echo -e "\033[0m"
