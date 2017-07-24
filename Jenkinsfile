#!/usr/bin/env groovy

// See https://github.com/capralifecycle/jenkins-pipeline-library
@Library('cals') _

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
    img = docker.build('jenkins2/master', '.')
  }

  stage('Push Docker image') {
    img.push(tagName)
    img.push('latest')
  }
}
