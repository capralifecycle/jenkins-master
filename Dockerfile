# see https://github.com/jenkinsci/docker
FROM jenkins/jenkins:lts-alpine

RUN /usr/local/bin/install-plugins.sh \

  # https://wiki.jenkins-ci.org/display/JENKINS/AnsiColor+Plugin
  ansicolor \

  # https://wiki.jenkins-ci.org/display/JENKINS/Authorize+Project+plugin
  authorize-project \

  # https://wiki.jenkins-ci.org/display/JENKINS/Blue+Ocean+Plugin
  blueocean \

  # https://wiki.jenkins-ci.org/display/JENKINS/Credentials+Binding+Plugin
  credentials-binding \

  # https://wiki.jenkins-ci.org/display/JENKINS/CloudBees+Docker+Pipeline+Plugin
  docker-workflow \

  # https://wiki.jenkins-ci.org/display/JENKINS/Email-ext+plugin
  email-ext \

  # https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin
  git \

  # https://wiki.jenkins-ci.org/display/JENKINS/GitHub+Plugin
  github \

  # https://wiki.jenkins-ci.org/display/JENKINS/HTML+Publisher+Plugin
  htmlpublisher \

  # https://wiki.jenkins-ci.org/display/JENKINS/Wall+Display+Plugin
  jenkinswalldisplay \

  # https://wiki.jenkins.io/display/JENKINS/Job+DSL+Plugin
  job-dsl \

  # https://wiki.jenkins-ci.org/display/JENKINS/Lockable+Resources+Plugin
  lockable-resources \

  # https://wiki.jenkins-ci.org/display/JENKINS/Mailer
  mailer \

  # https://wiki.jenkins-ci.org/display/JENKINS/Matrix+Authorization+Strategy+Plugin
  matrix-auth \

  # https://wiki.jenkins-ci.org/display/JENKINS/Pipeline+Stage+View+Plugin
  pipeline-stage-view \

  # https://wiki.jenkins-ci.org/display/JENKINS/Slack+Plugin
  slack \

  # https://wiki.jenkins-ci.org/display/JENKINS/SSH+Agent+Plugin
  ssh-agent \

  # https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin
  swarm \

  # https://wiki.jenkins-ci.org/display/JENKINS/Timestamper
  timestamper \

  # https://wiki.jenkins-ci.org/display/JENKINS/Pipeline+Plugin
  workflow-aggregator \

  # https://wiki.jenkins-ci.org/display/JENKINS/Workspace+Cleanup+Plugin
  ws-cleanup

# Try to force plugins to be updated with newer version from this image
# when running against an existing installation
ENV TRY_UPGRADE_IF_NO_MARKER=true
