# see https://github.com/jenkinsci/docker
# and https://hub.docker.com/r/jenkins/jenkins/tags/

FROM jenkins/jenkins:lts-alpine@sha256:ce408da48fdfdab4e55854b35965f9f0065cc3c8a47bbc74382b909966636a42

# For information about a plugin, go to:
# https://plugins.jenkins.io/NAMEOFPLUGIN

RUN jenkins-plugin-cli --verbose --plugins \
  ansicolor \
  authorize-project \
  blueocean \
  build-monitor-plugin \
  config-file-provider \
  credentials-binding \
  docker-workflow \
  embeddable-build-status \
  email-ext \
  # Needed for mavenJob { environmentVariables } in job DSL
  envinject \
  git \
  # Needed for parameters { gitParam } in job DSL
  git-parameter \
  github \
  github-oauth \
  # Needed for custom notification context in GitHub
  # https://github.com/capralifecycle/jenkins-job-seeder-v2/blob/293b981481464e64c86521d75948b0da9efd1809/jobs.groovy#L1958-L1968
  github-scm-trait-notification-context \
  htmlpublisher \
  job-dsl \
  lockable-resources \
  m2release \
  mailer \
  matrix-auth \
  maven-plugin \
  parameterized-trigger \
  pipeline-stage-view \
  # Provides readMavenPom()
  pipeline-utility-steps \
  plot \
  role-strategy \
  slack \
  sonar \
  ssh-agent \
  swarm \
  timestamper \
  view-job-filters \
  workflow-aggregator \
  ws-cleanup

# Try to force plugins to be updated with newer version from this image
# when running against an existing installation
ENV TRY_UPGRADE_IF_NO_MARKER=true
