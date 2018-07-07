#!/bin/sh
set -e

diff_file=plugin-history/plugin-list-prod.diff

echo "build-from-source                                                  jenkins.capra.tv" >$diff_file
(diff -ty plugin-history/plugin-list-prod.txt plugin-history/plugin-list-build.txt || :) >>$diff_file

echo "Plugin diff:"
cat $diff_file
