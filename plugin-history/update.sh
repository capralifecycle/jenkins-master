#!/bin/sh

curl -sSL -u capraadmin "https://jenkins.capra.tv/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins" \
  | perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g' \
  | sed 's/ /:/' \
  | sort >plugin-list.txt
