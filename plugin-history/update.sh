#!/bin/sh
set -e

echo -n "GitHub username: "
read username

echo "You will now be asked for a password. Enter your GitHub Personal Access Token created for this use."

curl -sSL -u "$username" "https://jenkins.capra.tv/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins" \
  | perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g' \
  | sed 's/ /:/' \
  | sort >plugin-list.txt
