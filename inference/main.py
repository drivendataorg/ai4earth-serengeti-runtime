import json
import os
from pathlib import Path

from dotenv import load_dotenv, find_dotenv
import numpy as np
import pandas as pd
import tensorflow as tf
import torch

from tensorflow.keras import backend as K
from tensorflow.keras.applications.resnet50 import ResNet50
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.resnet50 import preprocess_input, decode_predictions


load_dotenv(find_dotenv())

DATA_PATH = Path("/inference/data")


def test_gpu_config():
    if tf.test.is_built_with_cuda():
        assert torch.cuda.is_available()
        assert tf.test.is_gpu_available()
    else:
        assert not tf.test.is_gpu_available()
        assert not torch.cuda.is_available()


def test_mounted_folders():
    # assuming non-empty implies successful binding
    data = list(DATA_PATH.glob("*"))
    assert data


def _get_label_name(preds):
    cls_index = np.argmax(preds)
    with open("assets/imagenet_class_index.json", "r") as f:
        labels = json.load(f)

    return labels[str(cls_index)][1]


def perform_inference():
    model = ResNet50(weights='assets/resnet50_weights_tf_dim_ordering_tf_kernels.h5')

    output = []

    extensions = ['*.png', '*.jpg']

    for img_path in [p for pattern in extensions for p in DATA_PATH.glob(pattern)]:
        img = image.load_img(img_path, target_size=(224, 224))
        x = image.img_to_array(img)
        x = np.expand_dims(x, axis=0)
        x = preprocess_input(x)

        preds = model.predict(x)
        pred = _get_label_name(preds)
        output.append((img_path.name, pred))

    df = pd.DataFrame(output, columns=['file', 'label'])
    df.to_csv('submission.csv', index=False)


def main():
    test_gpu_config()
    test_mounted_folders()
    perform_inference()


if __name__ == "__main__":
    main()
