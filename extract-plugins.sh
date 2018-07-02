#!/bin/sh
set -e

if [ -z "$JENKINS_USERNAME" ] || [ -z "$JENKINS_PASSWORD" ]; then
  echo "Missing authentication variables"
  exit 1
fi

plugins=$(
  curl -fsS -u "$JENKINS_USERNAME:$JENKINS_PASSWORD" "https://jenkins.capra.tv/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins" \
    | perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g' \
    | sed 's/ /:/' \
    | sort
)

if ! echo "$plugins" | grep -q blueocean; then
  echo "Failed to extract plugin list - will dump output"
  echo "$plugins"
  exit 1
fi

echo "$plugins" >plugin-history/plugin-list.txt
echo "Plugins extracted"
