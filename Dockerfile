# FROM nvidia/cuda:10.1-cudnn7-runtime-ubuntu18.04
FROM nvidia/cuda:10.1-base-ubuntu18.04

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && \
    apt-get install --no-install-recommends \
    wget software-properties-common pkg-config build-essential unzip git \
    libglu1-mesa -y && \
    apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/local/src/*

# install miniconda as system python
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda

ENV PATH /opt/conda/bin:$PATH
RUN mkdir /envs
COPY *.yml /envs/

# base environments
ENV PATH /opt/conda/bin:$PATH
# RUN conda update -n base -c defaults conda

# create environments
RUN conda env create -f /envs/py-gpu.yml && \
    conda env create -f /envs/r-gpu.yml && \
    conda env create -f /envs/py-cpu.yml && \
    conda env create -f /envs/r-cpu.yml && \
    conda clean -i -l -t -y

# post-environment installs for R
COPY ./package_installs*.R /envs/
RUN /opt/conda/envs/r-cpu/bin/R -f /envs/package_installs_cpu.R
RUN /opt/conda/envs/r-gpu/bin/R -f /envs/package_installs_gpu.R

RUN mkdir /inference
COPY ./entrypoint.sh /inference/entrypoint.sh
WORKDIR /inference
RUN chmod +x ./entrypoint.sh

# Execute the entrypoint.sh script inside the container when we do docker run
CMD ["/bin/bash", "/inference/entrypoint.sh"]
