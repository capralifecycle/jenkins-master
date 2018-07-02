#!/usr/bin/env groovy

// See https://github.com/capralifecycle/jenkins-pipeline-library
@Library('cals') _

def dockerImageName = '923402097046.dkr.ecr.eu-central-1.amazonaws.com/jenkins2/master'

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

    def img
    def lastImageId = dockerPullCacheImage(dockerImageName)

    stage('Build Docker image') {
      img = docker.build(dockerImageName, "--cache-from $lastImageId --pull .")
    }

    def isSameImage = dockerPushCacheImage(img, lastImageId)

    stage('Verify build and extract list of installed plugins') {
      sh "./test-and-extract-plugins.sh ${img.id}"
      echo 'Listing plugins that was bundled in the built container:'
      sh 'cat plugin-history/plugin-list-clean-build.txt'
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
          docker.image('perl').inside {
            sh './extract-plugins.sh'
            sh 'cat plugin-history/plugin-list.txt'
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
        sshagent(['github-calsci-sshkey']) {
          withGitConfig {
            withEnv(['GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"']) {
              sh './commit-and-push-plugin-changes.sh'
            }
          }
        }
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
