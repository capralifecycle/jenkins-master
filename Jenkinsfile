#!/usr/bin/env groovy

// See https://github.com/capralifecycle/jenkins-pipeline-library
@Library('cals') _

def dockerImageName = '923402097046.dkr.ecr.eu-central-1.amazonaws.com/buildtools/service/jenkins-master'
def dockerBuildImageName = '923402097046.dkr.ecr.eu-central-1.amazonaws.com/buildtools/service/jenkins-master-builder'

def jobProperties = [
  parameters([
    // Add parameter so we can build without using cached image layers.
    // This forces plugins to be reinstalled to their latest version.
    booleanParam(
      defaultValue: false,
      description: 'Force build without Docker cache',
      name: 'docker_skip_cache'
    ),
  ]),
]

if (env.BRANCH_NAME == 'master') {
  jobProperties << pipelineTriggers([
    // Build a new version every night so we keep up to date with upstream changes
    cron('H H(2-6) * * *'),
  ])
}

buildConfig([
  jobProperties: jobProperties,
  slack: [
    channel: '#cals-dev-info',
    teamDomain: 'cals-capra',
  ],
]) {
  dockerNode {
    stage('Checkout source') {
      checkout scm
    }

    if (previousRecentCommitIsJenkins() && !isManualTriggered()) {
      println 'Last commit was made by Jenkins - skipping'
    } else {
      def buildImg = prepareBuildImage(dockerBuildImageName)

      def img
      def lastImageId = dockerPullCacheImage(dockerImageName)

      stage('Build Docker image') {
        def args = ""
        if (params.docker_skip_cache) {
          args = " --no-cache"
        }
        img = docker.build(dockerImageName, "--cache-from $lastImageId$args --pull .")
      }

      def isSameImage = dockerPushCacheImage(img, lastImageId)

      stage('Verify build and extract list of installed plugins') {
        insideToolImage("node:14") {
          sh "npm ci"
          sh "npm run test-image -- ${img.id}"
        }
      }

      stage('Extract plugins from running instance') {
        // Allow to fail without failing the job
        try {
          withCredentials([
            usernamePassword(
              credentialsId: 'jenkins-admin-token',
              passwordVariable: 'JENKINS_PASSWORD',
              usernameVariable: 'JENKINS_USERNAME',
            )
          ]) {
            buildImg.inside {
              sh './ci/extract-plugins-from-prod.sh'
            }
          }
        } catch (e) {
          println 'Failed to extract plugins - will mark job as UNSTABLE'
          println e
          currentBuild.result = 'UNSTABLE'
        }
      }

      // Use a milestone so that two commits have less chance of getting the
      // wrong order.
      milestone 1

      stage('Diff between plugin versions') {
        buildImg.inside {
          sh './ci/generate-plugin-diff.sh'
        }
      }

      // Do not commit anything on branches belonging to renovate, as it
      // will cause two bots to force-push over each other.
      // Also exclude PR builds since we cannot push back.
      if (!env.BRANCH_NAME.startsWith('renovate/') && !env.CHANGE_ID) {
        stage('Commit and push any plugin changes') {
          if (currentBuild.result == 'UNSTABLE') {
            println 'Build is unstable - skipping'
          } else {
            buildImg.inside {
              withGitConfig {
                withGitTokenCredentials {
                  sh './ci/commit-and-push-plugin-changes.sh'
                }
              }
            }
          }
        }
      }

      if (env.BRANCH_NAME == 'master' && !isSameImage) {
        stage('Push Docker image') {
          milestone 2

          def tagName = sh([
            returnStdout: true,
            script: 'date +%Y%m%d-%H%M'
          ]).trim() + '-' + env.BUILD_NUMBER

          img.push(tagName)
          img.push('latest')

          slackNotify message: "New Docker image available: $dockerImageName:$tagName"
        }
      }
    }
  }
}

def previousRecentCommitIsJenkins() {
  def res = false
  withGitConfig {
    def configName = sh([
      returnStdout: true,
      script: 'git config user.name'
    ]).trim()

    def commitName = sh([
      returnStdout: true,
      script: 'git log --since="10 minutes" --format="%an" -n1'
    ]).trim()

    if (configName == commitName) {
      res = true
    }
  }

  return res
}

def isManualTriggered() {
  return currentBuild.rawBuild.getCauses()[0].toString().contains('UserIdCause')
}

def prepareBuildImage(dockerBuildImageName) {
  def buildImg
  def lastBuildImageId = dockerPullCacheImage(dockerBuildImageName)

  stage('Build Docker image (for build)') {
    buildImg = docker.build(dockerBuildImageName, "--cache-from $lastBuildImageId --pull -f builder.Dockerfile .")
  }

  dockerPushCacheImage(buildImg, lastBuildImageId)
  return buildImg
}
