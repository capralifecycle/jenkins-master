# see https://github.com/jenkinsci/docker
# and https://hub.docker.com/r/jenkins/jenkins/tags/
FROM jenkins/jenkins:2.128-alpine

RUN /usr/local/bin/install-plugins.sh \

  # https://wiki.jenkins.io/display/JENKINS/AnsiColor+Plugin
  ansicolor \

  # https://wiki.jenkins.io/display/JENKINS/Authorize+Project+plugin
  authorize-project \

  # https://wiki.jenkins.io/display/JENKINS/Blue+Ocean+Plugin
  blueocean \

  # https://wiki.jenkins.io/display/JENKINS/Config+File+Provider+Plugin
  config-file-provider \

  # https://wiki.jenkins.io/display/JENKINS/Credentials+Binding+Plugin
  credentials-binding \

  # https://wiki.jenkins.io/display/JENKINS/CloudBees+Docker+Pipeline+Plugin
  docker-workflow \

  # https://wiki.jenkins.io/display/JENKINS/Email-ext+plugin
  email-ext \

  # https://wiki.jenkins.io/display/JENKINS/Git+Plugin
  git \

  # https://wiki.jenkins.io/display/JENKINS/GitHub+Plugin
  github \

  # https://wiki.jenkins.io/display/JENKINS/GitHub+OAuth+Plugin
  github-oauth \

  # https://wiki.jenkins.io/display/JENKINS/HTML+Publisher+Plugin
  htmlpublisher \

  # https://wiki.jenkins.io/display/JENKINS/Wall+Display+Plugin
  jenkinswalldisplay \

  # https://wiki.jenkins.io/display/JENKINS/Job+DSL+Plugin
  job-dsl \

  # https://wiki.jenkins.io/display/JENKINS/Lockable+Resources+Plugin
  lockable-resources \

  # https://wiki.jenkins.io/display/JENKINS/Mailer
  mailer \

  # https://wiki.jenkins.io/display/JENKINS/Matrix+Authorization+Strategy+Plugin
  matrix-auth \

  # https://wiki.jenkins.io/display/JENKINS/Maven+Project+Plugin
  maven-plugin \

  # https://wiki.jenkins.io/display/JENKINS/Pipeline+Stage+View+Plugin
  pipeline-stage-view \

  # https://wiki.jenkins.io/display/JENKINS/Slack+Plugin
  slack \

  # https://wiki.jenkins.io/display/JENKINS/SonarQube+plugin?focusedCommentId=37748932
  sonar \

  # https://wiki.jenkins.io/display/JENKINS/SSH+Agent+Plugin
  ssh-agent \

  # https://wiki.jenkins.io/display/JENKINS/Swarm+Plugin
  swarm \

  # https://wiki.jenkins.io/display/JENKINS/Timestamper
  timestamper \

  # https://wiki.jenkins.io/display/JENKINS/Pipeline+Plugin
  workflow-aggregator \

  # https://wiki.jenkins.io/display/JENKINS/Workspace+Cleanup+Plugin
  ws-cleanup

# Try to force plugins to be updated with newer version from this image
# when running against an existing installation
ENV TRY_UPGRADE_IF_NO_MARKER=true

# Remove banner prompting to install additional plugins when run against
# a fresh installation
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
