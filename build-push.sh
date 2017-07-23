#!/bin/bash

tag=923402097046.dkr.ecr.eu-central-1.amazonaws.com/jenkins2/master

docker build -t $tag .
docker push $tag
