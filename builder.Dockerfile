FROM debian:stretch-slim

ENV DOCKER_VERSION=18.03.1-ce

RUN set -eux; \
    apt-get update; \
    apt-get install -y \
        curl \
        git \
        perl \
        wdiff \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    # Install docker so we can provision Jenkins for testing in the scripts
    curl -fSL https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION.tgz \
      | tar -zxvOf - docker/docker > /usr/bin/docker; \
    chmod +x /usr/bin/docker; \
    docker -v; \
    # Dont check host keys when connecting with ssh (Git) from the docker container
    sed -i 's/#   StrictHostKeyChecking .*/    StrictHostKeyChecking no/' /etc/ssh/ssh_config; \
    # Add the user that jenkins runs this as to avoid error "No user exists for uid 1000"
    # when commiting with Git.
    useradd -u 1000 jenkins
