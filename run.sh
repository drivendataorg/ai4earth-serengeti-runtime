#!/bin/bash
set -e

# load .env vars
cat .env | while read a; do export $a; done

# prepare example submission
mkdir -p submission
cd inference; zip -r ../submission/submission.zip ./*; cd ..


# test configuration
if [ $(which nvidia-smi) ]
then
    docker build --build-arg CPU_GPU=gpu -t ai-for-earth-serengeti/inference .
    docker run --env-file .env \
           --gpus all \
           --network none \
           --mount type=bind,source=$(pwd)/image-files,target=/inference/data,readonly \
           --mount type=bind,source=$(pwd)/submission,target=/inference/submission \
           ai-for-earth-serengeti/inference
else
    docker build --build-arg CPU_GPU=cpu -t ai-for-earth-serengeti/inference .
    docker run --env-file .env \
            --network none \
            --mount type=bind,source=$(pwd)/image-files,target=/inference/data,readonly \
            --mount type=bind,source=$(pwd)/submission,target=/inference/submission \
            ai-for-earth-serengeti/inference
fi
