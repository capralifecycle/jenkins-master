#!/usr/bin/env groovy

// See https://github.com/capralifecycle/jenkins-pipeline-library
@Library('cals') _

properties([
  // Build a new version every night so we keep up to date with upstream changes
  pipelineTriggers([cron('H H(2-6) * * *')]),

  // Build when pushing to repo
  githubPush(),

  // "GitHub project"
  [
    $class: 'GithubProjectProperty',
    displayName: '',
    projectUrlStr: 'https://github.com/capralifecycle/jenkins-master/'
  ],
])

dockerNode {
  stage('Checkout source') {
    checkout scm
  }

  def img
  def tagName = sh([
    returnStdout: true,
    script: 'date +%Y%m%d-%H%M'
  ]).trim() + '-' + env.BUILD_NUMBER

  stage('Build Docker image') {
    img = docker.build('jenkins2/master', '--pull .')
  }

  stage('Push Docker image') {
    img.push(tagName)
    img.push('latest')
  }
}
