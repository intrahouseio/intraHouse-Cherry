#!/bin/bash

repo_name="Doc"

echo "Installing IntraHouse-system ..."
echo "check latest"

file=$(curl -s https://api.github.com/repos/intrahouseio/$repo_name/releases/latest | grep browser_download_url | cut -d '"' -f 4)

echo "latest found:$file"
echo "get latest ..."
curl -sL -o intrahouse-lite.zip $file

echo
echo "Install complete!!!"
echo
