#we use the debian stable slim base image
FROM public.ecr.aws/debian/debian:stable-slim as debian_base

#we install dependencies
RUN apt-get update -y && \
    apt-get install -y \
        build-essential \
        cmake \
        libbluetooth-dev \
        libsdl2-dev \
        libcurl4-openssl-dev \
        libenet-dev \
        libfreetype6-dev \
        libharfbuzz-dev \
        libjpeg-dev \
        libogg-dev \
        libopenal-dev \
        libpng-dev \
        libssl-dev \
        libvorbis-dev \
        libmbedtls-dev \
        pkg-config \
        zlib1g-dev \
        git \
        sqlite3 \
        subversion \
        python3-pip \
        python3-enet \
        curl \
        vim \
        unzip \
        jq && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip && \
    rm -fr ./aws/ && \
    mkdir /root/.aws

COPY config /root/.aws

#we install kubectl to run commands against EKS
#Install kubectl for the simulator pod scaler
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --fix-missing -y postgresql && \
    apt-get install -y apt-transport-https ca-certificates curl && \
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl && \
    kubectl version --client

#we use the debian base image to create a build_art stage where game assets are retrieved from svn
FROM debian_base AS build_art
RUN svn co https://svn.code.sf.net/p/supertuxkart/code/stk-assets stk-assets

#we reuse the debian base to create a build_code stage where custom game engine code is compiled
FROM debian_base AS build_code

COPY --from=1 /stk-assets /stk-assets

RUN apt-get install git -y
# This is where you can modify the game to clone a different version of the code
# You can fork the code in github and make changes to stk-code to build different flavours of supertuxkart
RUN git clone https://github.com/supertuxkart/stk-code stk-code && \
    cd stk-code && \
    mkdir cmake_build && \
    cmake ../stk-code -B ./cmake_build -DSERVER_ONLY=ON && \
    cd cmake_build && make -j$(nproc) -f ./Makefile install

COPY . /stk-code/
COPY *.py /

RUN chmod +x /stk-code/*.sh /*.py
