#!/bin/sh
set -e

diff_file=plugin-history/plugin-list-prod.diff

echo "jenkins.capra.tv                                                   build-from-source" >$diff_file
echo "----------------                                                   -----------------" >>$diff_file
(diff -ty plugin-history/plugin-list-prod.txt plugin-history/plugin-list-build.txt || :) >>$diff_file

echo "Plugin diff:"
cat $diff_file
