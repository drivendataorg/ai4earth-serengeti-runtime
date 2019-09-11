FROM nvidia/cuda:10.1-cudnn7-runtime-ubuntu18.04

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && \
    apt-get install wget software-properties-common pkg-config build-essential unzip git -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install miniconda as system python
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda

ENV PATH /opt/conda/bin:$PATH

RUN mkdir /envs
COPY *.yml /envs/

# base environments
ENV PATH /opt/conda/bin:$PATH
RUN conda update -n base -c defaults conda
RUN conda env create -f /envs/py-cpu.yml
RUN conda env create -f /envs/py-gpu.yml
RUN conda env create -f /envs/r-cpu.yml
RUN conda env create -f /envs/r-gpu.yml

# post-environment installs for R
COPY ./package_installs*.R /envs/
RUN apt-get install libglu1-mesa
RUN /opt/conda/envs/r-cpu/bin/R -f /envs/package_installs_cpu.R
RUN /opt/conda/envs/r-gpu/bin/R -f /envs/package_installs_gpu.R

RUN mkdir /inference
COPY ./entrypoint.sh /inference/entrypoint.sh
WORKDIR /inference
RUN chmod +x ./entrypoint.sh

# Execute the entrypoint.sh script inside the container when we do docker run
CMD ["/bin/bash", "/inference/entrypoint.sh"]