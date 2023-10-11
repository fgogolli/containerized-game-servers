FROM public.ecr.aws/docker/library/python:slim

RUN apt-get update -y --fix-missing && \
    apt-get install -y \
        vim \
        net-tools \
        telnet \
        iproute2 \
        jq \
        unzip \
        curl \
        net-tools \
        subversion \
        sqlite3 \
        iptables \
        kmod \
        ulogd2 \
        gcc \
        wget \
        libpq-dev && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN /usr/local/bin/python -m pip install --upgrade --no-cache-dir pip && \
    pip install --no-cache-dir requests \
        boto3 \
        psycopg2-binary \
        urllib3 \
        wheel \
        Cmake \
        pyenet \
        ec2-metadata \
        awscli && \
    mkdir /root/.aws

#Install game build tools
RUN apt-get update -y --fix-missing && \
    apt-get install -y \
        build-essential \
        cmake \
        libbluetooth-dev \
        libsdl2-dev \
        libcurl4-openssl-dev \
        libenet-dev \
        libfreetype6-dev \
        libharfbuzz-dev \
        libjpeg-dev libogg-dev \
        libopenal-dev \
        libpng-dev \
        libssl-dev \
        libvorbis-dev \
        libmbedtls-dev \
        pkg-config \
        zlib1g-dev \
        git \
        sqlite3 \
        subversion && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY config /root/.aws

#Install kubectl for the simulator pod scaler
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --fix-missing -y postgresql && \
    apt-get install -y apt-transport-https ca-certificates curl && \
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl
