FROM debian:stretch-slim@sha256:d8566545bd3750e270b8aaf703d0a048fda080cd287a249823a5a11b7c95adbf

RUN set -eux; \
    apt-get update; \
    apt-get install -y \
        curl \
        git \
        perl \
        wdiff \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    # Dont check host keys when connecting with ssh (Git) from the docker container
    sed -i 's/#   StrictHostKeyChecking .*/    StrictHostKeyChecking no/' /etc/ssh/ssh_config; \
    # Add the user that jenkins runs this as to avoid error "No user exists for uid 1000"
    # when commiting with Git.
    useradd -u 1000 jenkins
