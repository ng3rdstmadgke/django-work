# https://hub.docker.com/_/microsoft-devcontainers
FROM mcr.microsoft.com/devcontainers/python:3.12-bookworm

RUN apt-get update && \
    apt-get install -y \
      default-mysql-client \
      bash-completion \
      procps \
      net-tools \
      iputils-ping \
      net-tools \
      locales \
      make \
      jq \
      fzf \
      vim \
      curl \
      wget \
      git \
      groff \
      less \
      sudo \
      gcc \
      tmux \
      unzip

# ロケール設定
RUN echo 'ja_JP.UTF-8 UTF-8' >> /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=ja_JP.UTF-8
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# aws cli インストール
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

# Jupyter Labインストール
RUN pip install --upgrade pip && \
    pip install jupyterlab

# pip インストール
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip & \
    pip install -r /tmp/requirements.txt