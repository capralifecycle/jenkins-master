#!/bin/sh
# Test the build
set -e

if [ -z "$1" ]; then
  echo "Syntax: $0 <jenkins-image-id>"
  exit 1
fi

image_id="$1"

# Use unix time to simulate a random value, /dev/urandom is unstable in Jenkins slave
run_id=$(date +%s | base64 | tr -dc 'a-zA-Z0-9' | fold -w 16)
network_name="jenkins-test-$run_id"
echo "Docker network name: $network_name"

network_id=$(docker network create $network_name)
container_id=$(docker run -d --rm --network-alias=jenkins --network $network_id "$image_id")

cleanup() {
  echo "Cleaning up resources"
  docker stop $container_id || :
  docker network rm $network_name || :
}

trap cleanup EXIT

max_wait=30
wait_interval=2
echo "Polling for Jenkins to be up.. Trying for $max_wait iterations of $wait_interval sec"

ok=0
start=$(date +%s)
for x in $(seq 1 $max_wait); do
  if docker run -i --rm --network $network_id byrnedo/alpine-curl -fsS jenkins:8080/login >/dev/null; then
    ok=1
    break
  fi
  sleep $wait_interval
done

if [ $ok -eq 0 ]; then
  echo "Waiting for Jenkins to boot failed"
  cleanup
  exit 1
fi

end=$(date +%s)
echo "Took $(echo "$end - $start" | bc) seconds for Jenkins to boot up"

jenkins_pass=$(docker cp $container_id:/var/jenkins_home/secrets/initialAdminPassword - | tar -xOf -)

plugins=$(
  docker run -i --rm --network $network_id byrnedo/alpine-curl -fsS -u "admin:$jenkins_pass" "jenkins:8080/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins" \
    | docker run -i --rm perl perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g' \
    | sed 's/ /:/' \
    | sort
)

if ! echo "$plugins" | grep -q blueocean; then
  echo "Failed to extract plugin list - will dump output"
  echo "$plugins"
  exit 1
fi

echo "$plugins" >plugin-history/plugin-list-clean-build.txt
echo "Plugins extracted"
