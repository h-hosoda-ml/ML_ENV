FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04 AS builder

ARG PYTHON_VERSION=3.11.5
ENV HOME=/root

SHELL ["/bin/bash", "-c"]

COPY ./.bashrc $HOME
COPY ./requirements_build.txt $HOME
COPY ./requirements_pip.txt $HOME

RUN apt-get update \
	&& apt-get -y upgrade \
	&& cat ${HOME}/requirements_build.txt | xargs apt-get -y install \
	&& curl https://pyenv.run | /bin/bash

ENV PYENV_ROOT="${HOME}/.pyenv"
ENV PATH="${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:$PATH"

RUN echo 'export PYENV_ROOT="/root/.pyenv"' >> ${HOME}/.bashrc \
	&& echo 'export PATH="/root/.pyenv/bin:/root/.pyenv/shims:${PATH}"' >> ${HOME}/.bashrc \
	&& echo 'eval "$(pyenv init -)"' >> ${HOME}/.bashrc \
	&& echo 'eval "$(pyenv init --path)"' >> ${HOME}/.bashrc \
	&& source ${HOME}/.bashrc \
	&& pyenv install ${PYTHON_VERSION} \
	&& pyenv global ${PYTHON_VERSION}

RUN pip install --upgrade pip \
	&& pip install -r ${HOME}/requirements_pip.txt


# 本番環境
FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

ENV PYENV_ROOT=/root/.pyenv
ENV PATH="${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:$PATH"

WORKDIR /workdir
ENV HOME=/workdir

SHELL ["/bin/bash", "-c"]

# local環境から
COPY ./requirements_runtime.txt /workdir

# build環境から
COPY --from=builder /root/.bashrc ${HOME}/.bashrc
COPY --from=builder /root/.pyenv /root/.pyenv

RUN apt-get update \
	&& apt-get -y upgrade \
	&& cat ${HOME}/requirements_runtime.txt | xargs apt-get -y install \
	&& source ${HOME}/.bashrc

ENTRYPOINT ["/bin/bash"]
