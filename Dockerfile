FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04 AS builder

ARG PYTHON_VERSION=3.11.5
ENV HOME=/root

SHELL ["/bin/bash", "-c"]

COPY ./bash/.bashrc $HOME
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

RUN cd ${HOME} \
	&& git clone https://github.com/vim/vim.git \
	&& cd ${HOME}/vim \
	&& git pull \
	&& cd ${HOME}/vim/src \
	&& make \
	&& make install 

# 本番環境
FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

ENV PYENV_ROOT=/root/.pyenv
ENV PATH="${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:$PATH"

WORKDIR /workdir
ENV HOME=/workdir

SHELL ["/bin/bash", "-c"]

# local環境から
COPY ./requirements_runtime.txt ${HOME}
COPY ./tmux/.tmux.conf ${HOME}
COPY ./vim ${HOME}/.vim

# build環境から
COPY --from=builder /root/.bashrc ${HOME}/.bashrc
COPY --from=builder /root/.pyenv /root/.pyenv
COPY --from=builder /usr/local/bin/vim /usr/local/bin/vim
COPY --from=builder /usr/local/share/vim /usr/local/share/vim
COPY --from=builder /usr/local/man /usr/local/man

RUN apt-get update \
	&& apt-get -y upgrade \
	&& cat ${HOME}/requirements_runtime.txt | xargs apt-get -y install \
	&& source /root/.bashrc \
	&& curl -fLo ${HOME}/.vim/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim --create-dirs https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim \
	&& mkdir ${HOME}/repos

ENTRYPOINT ["/bin/bash"]
