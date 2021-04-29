# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# multi-stage arguments (repeat ARG NAME below)
ARG OPENMPI_VERSION=4.0.4
ARG ONNX_VERSION=1.7.0
ARG CONDA_VERSION=4.7.10

ARG OPENMPI_PATH=/opt/openmpi-${OPENMPI_VERSION}
ARG COMMIT=master

FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu18.04 as builder

WORKDIR /stage

RUN chmod 1777 /tmp

# install curl, git, ssh (required by MPI when running ORT tests)
RUN apt-get -y update &&\
    apt-get -y --no-install-recommends install \
        curl \
        git \
        unattended-upgrades

# update existing packages to minimize security vulnerabilities
RUN unattended-upgrade

# install miniconda 
ARG CONDA_VERSION
ARG CONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh
RUN cd /stage && curl -fSsL --insecure ${CONDA_URL} -o install-conda.sh &&\
/bin/bash ./install-conda.sh -b -p /opt/conda &&\
/opt/conda/bin/conda clean -ya

ENV PATH=/opt/conda/bin:${PATH}

RUN pip install --upgrade pip

# install onnxruntime and torch-ort dependencies
ARG ONNX_VERSION
RUN pip install \
       onnx=="${ONNX_VERSION}" \
       ninja

# install pytorch, onnxruntime and torch-ort
ARG PYTORCH_VERSION
RUN pip install torch==1.8.1 torchvision torchtext
RUN pip install --pre onnxruntime-training -f https://onnxruntimepackages.z14.web.core.windows.net/onnxruntime_nightly_cu111.html
RUN pip install torch-ort

WORKDIR /workspace
