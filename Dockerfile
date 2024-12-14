FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04 AS builder

ARG PYTHON_VERSION=3.11.5
ENV HOME=/root

SHELL ["/bin/bash", "-c"]

COPY ./requirements_build.txt ${HOME}
COPY ./requirements_pip.txt ${HOME}

RUN apt-get update \
	&& apt-get -y upgrade \
	&& apt-get -y install \
	git \
	curl \
	build-essential \
	libbz2-dev libreadline-dev libssl-dev zlib1g-dev \
	libsqlite3-dev libncurses5-dev liblzma-dev \
	libffi-dev libdb-dev \
	&& curl https://pyenv.run | /bin/bash

ENV PYENV_ROOT="${HOME}/.pyenv"
ENV PATH="${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:$PATH"

RUN  echo 'export PYENV_ROOT="${HOME}/.pyenv"' >> ~/.bashrc \
	&& echo 'export PATH="${PYENV_ROOT}/bin:${PATH}"' >> ~/.bashrc \
	&& echo 'eval "$(pyenv init -)"' >> ~/.bashrc \
	&& echo 'eval "$(pyenv init --path)"' >> ~/.bashrc \
	&& . ~/.bashrc \
	&& pyenv install $PYTHON_VERSION \
	&& pyenv global $PYTHON_VERSION

RUN pip install --upgrade pip \
	&& pip install -r ~/requirements.txt


# 本番環境
FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

ENV PYENV_ROOT=/root/.pyenv
ENV PATH="${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:$PATH"

WORKDIR /workdir
ENV HOME=/workdir

SHELL ["/bin/bash", "-c"]

COPY --from=builder /root/.pyenv /root/.pyenv
COPY --from=builder /root/.bashrc /root/.bashrc

RUN apt-get update \
	&& apt-get -y upgrade \
	&& apt-get -y install vim curl git openssh-client \
	&& . /root/.bashrc

ENTRYPOINT ["/bin/bash"]
