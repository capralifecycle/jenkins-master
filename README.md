# Jenkins master

This repository contains the Docker image for Jenkins master used with
our Jenkins setup.

Details about our setup is available on https://confluence.capraconsulting.no/x/uALGBQ

## Build and verify

```bash
npm ci
npm run test
```

## Troubleshooting
If you need to trigger a release of a Docker image to ECR (e.g., in case of CI of an earlier commit failing), visit https://jenkins.capra.tv/job/buildtools/job/jenkins-master/job/master/build, check `docker_skip_cache` and click **Build**.
