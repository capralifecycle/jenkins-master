# see https://github.com/jenkinsci/docker
# and https://hub.docker.com/r/jenkins/jenkins/tags/
FROM jenkins/jenkins:2.133-alpine

RUN /usr/local/bin/install-plugins.sh \
  \
  # https://wiki.jenkins.io/display/JENKINS/AnsiColor+Plugin
  ansicolor \
  \
  # https://wiki.jenkins.io/display/JENKINS/Authorize+Project+plugin
  authorize-project \
  \
  # https://wiki.jenkins.io/display/JENKINS/Blue+Ocean+Plugin
  blueocean \
  \
  # https://wiki.jenkins.io/display/JENKINS/Build+Monitor+Plugin
  build-monitor-plugin \
  \
  # https://wiki.jenkins.io/display/JENKINS/Config+File+Provider+Plugin
  config-file-provider \
  \
  # https://wiki.jenkins.io/display/JENKINS/Credentials+Binding+Plugin
  credentials-binding \
  \
  # https://wiki.jenkins.io/display/JENKINS/CloudBees+Docker+Pipeline+Plugin
  docker-workflow \
  \
  # https://wiki.jenkins.io/display/JENKINS/Embeddable+Build+Status+Plugin
  embeddable-build-status \
  \
  # https://wiki.jenkins.io/display/JENKINS/Email-ext+plugin
  email-ext \
  \
  # https://wiki.jenkins.io/display/JENKINS/EnvInject+Plugin
  # Needed for mavenJob { environmentVariables } in job DSL
  envinject \
  \
  # https://wiki.jenkins.io/display/JENKINS/FindBugs+Plugin
  findbugs \
  \
  # https://wiki.jenkins.io/display/JENKINS/GitHub+pull+request+builder+plugin
  # Used with githubPullRequest job DSL step
  ghprb \
  \
  # https://wiki.jenkins.io/display/JENKINS/Git+Plugin
  git \
  \
  # https://wiki.jenkins-ci.org/display/JENKINS/Git+Parameter+Plugin
  # Needed for parameters { gitParam } in job DSL
  git-parameter \
  \
  # https://wiki.jenkins.io/display/JENKINS/GitHub+Plugin
  github \
  \
  # https://wiki.jenkins.io/display/JENKINS/GitHub+OAuth+Plugin
  github-oauth \
  \
  # https://plugins.jenkins.io/github-scm-trait-notification-context
  # Needed for custom notification context in GitHub
  # https://github.com/capralifecycle/jenkins-job-seeder-v2/blob/293b981481464e64c86521d75948b0da9efd1809/jobs.groovy#L1958-L1968
  github-scm-trait-notification-context \
  \
  # https://wiki.jenkins.io/display/JENKINS/HTML+Publisher+Plugin
  htmlpublisher \
  \
  # https://wiki.jenkins.io/display/JENKINS/Job+DSL+Plugin
  job-dsl \
  \
  # https://wiki.jenkins.io/display/JENKINS/Lockable+Resources+Plugin
  lockable-resources \
  \
  # https://wiki.jenkins.io/display/JENKINS/M2+Release+Plugin
  m2release \
  \
  # https://wiki.jenkins.io/display/JENKINS/Mailer
  mailer \
  \
  # https://wiki.jenkins.io/display/JENKINS/Matrix+Authorization+Strategy+Plugin
  matrix-auth \
  \
  # https://wiki.jenkins.io/display/JENKINS/Maven+Project+Plugin
  maven-plugin \
  \
  # https://wiki.jenkins.io/display/JENKINS/Parameterized+Trigger+Plugin
  parameterized-trigger \
  \
  # https://wiki.jenkins.io/display/JENKINS/Pipeline+Stage+View+Plugin
  pipeline-stage-view \
  \
  # https://wiki.jenkins.io/display/JENKINS/Pipeline+Utility+Steps+Plugin
  # Provides readMavenPom()
  pipeline-utility-steps \
  \
  # https://wiki.jenkins.io/display/JENKINS/Slack+Plugin
  slack \
  \
  # https://wiki.jenkins.io/display/JENKINS/SonarQube+plugin?focusedCommentId=37748932
  sonar \
  \
  # https://wiki.jenkins.io/display/JENKINS/SSH+Agent+Plugin
  ssh-agent \
  \
  # https://wiki.jenkins.io/display/JENKINS/Swarm+Plugin
  swarm \
  \
  # https://wiki.jenkins.io/display/JENKINS/Timestamper
  timestamper \
  \
  # https://wiki.jenkins.io/display/JENKINS/Pipeline+Plugin
  workflow-aggregator \
  \
  # https://wiki.jenkins.io/display/JENKINS/Workspace+Cleanup+Plugin
  ws-cleanup

# Try to force plugins to be updated with newer version from this image
# when running against an existing installation
ENV TRY_UPGRADE_IF_NO_MARKER=true

# Remove banner prompting to install additional plugins when run against
# a fresh installation
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
