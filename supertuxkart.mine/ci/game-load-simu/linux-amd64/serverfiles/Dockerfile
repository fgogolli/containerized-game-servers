FROM public.ecr.aws/debian/debian:stable-slim 

RUN apt -y --fix-missing update && \
    apt install -y \
        gnupg \
        curl \
        vim \
        unzip \
        jq && \
    DEBIAN_FRONTEND=noninteractive apt-get install --fix-missing -y postgresql

#Install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip && \
    rm -fr ./aws/ && \
    mkdir /root/.aws

#Install kubectl for the simulator pod scaler
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --fix-missing -y postgresql && \
    apt-get install -y apt-transport-https ca-certificates curl && \
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl && \
    kubectl version --client

COPY appsimulator.sh /appsimulator.sh

RUN chmod +x /appsimulator.sh
