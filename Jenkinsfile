#!/usr/bin/env groovy

// See https://github.com/capralifecycle/jenkins-pipeline-library
@Library('cals') _

def dockerImageName = '923402097046.dkr.ecr.eu-central-1.amazonaws.com/jenkins2/master'
def dockerBuildImageName = '923402097046.dkr.ecr.eu-central-1.amazonaws.com/jenkins2/master-builder'

buildConfig([
  jobProperties: [
    pipelineTriggers([
      // Build a new version every night so we keep up to date with upstream changes
      cron('H H(2-6) * * *'),
    ]),
  ],
  slack: [
    channel: '#cals-dev-info',
    teamDomain: 'cals-capra',
  ],
]) {
  dockerNode {
    stage('Checkout source') {
      checkout scm
    }

    def commitByJenkins = false
    withGitConfig {
      def configName = sh([
        returnStdout: true,
        script: 'git config user.name'
      ]).trim()

      def commitName = sh([
        returnStdout: true,
        script: 'git log --format="%an" -n1'
      ]).trim()

      if (configName == commitName) {
        println 'Last commit was made by Jenkins - skipping'
        commitByJenkins = true
      }
    }

    if (!commitByJenkins || isManualTriggered()) {
      def buildImg = prepareBuildImage(dockerBuildImageName)

      def img
      def lastImageId = dockerPullCacheImage(dockerImageName)

      stage('Build Docker image') {
        img = docker.build(dockerImageName, "--cache-from $lastImageId --pull .")
      }

      def isSameImage = dockerPushCacheImage(img, lastImageId)

      stage('Verify build and extract list of installed plugins') {
        buildImg.inside {
          sh "./ci/test-and-extract-plugins.sh ${img.id}"
          echo 'Listing plugins that was bundled in the built container:'
          sh 'cat plugin-history/plugin-list-build.txt'
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
              sh 'cat plugin-history/plugin-list-prod.txt'
            }
          }
        } catch (e) {
          println 'Failed to extract plugins - will mark job as UNSTABLE'
          println e
          currentBuild.result = 'UNSTABLE'
        }
      }

      stage('Commit and push any plugin changes') {
        if (currentBuild.result == 'UNSTABLE') {
          println 'Build is unstable - skipping'
        } else {
          withGitConfig {
            buildImg.inside {
              sshagent(['github-calsci-sshkey']) {
                sh './ci/commit-and-push-plugin-changes.sh'
              }
            }
          }
        }
      }

      stage('Diff between plugin versions') {
        buildImg.inside {
          sh 'diff -ty plugin-history/plugin-list-prod.txt plugin-history/plugin-list-build.txt || :'
        }
      }

      if (env.BRANCH_NAME == 'master' && !isSameImage) {
        stage('Push Docker image') {
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
