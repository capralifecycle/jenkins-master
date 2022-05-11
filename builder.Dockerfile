FROM debian:stretch-slim@sha256:4581562d3a03f936e35670fa28063e83e6f7c1640402ce5e433724458244fd39

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
