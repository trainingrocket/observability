FROM gcr.io/cloud-builders/kubectl

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends curl groff jq gnupg && \
    apt-get -y clean && apt-get -y autoclean && apt-get -y autoremove && \
    curl -Lso aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.12.7/2019-03-27/bin/linux/amd64/aws-iam-authenticator && \
    chmod +x ./aws-iam-authenticator && \
    mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH && \
    echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc && \
    aws-iam-authenticator help && \
    curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-18.06.1-ce.tgz && \
    tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 \
                   -C /usr/local/bin docker/docker && \
    rm docker-${DOCKERVERSION}.tgz && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --upgrade pip && \
    pip install setuptools awscli \
    aws help

COPY "entrypoint.sh" "/entrypoint.sh"
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["help"]