#!/bin/bash

repo_name="Doc"
file=$(curl -s https://api.github.com/repos/intrahouseio/$repo_name/releases/latest | grep browser_download_url | cut -d '"' -f 4)

echo $file
curl -sL -o intrahouse-lite.zip $file
