from datetime import datetime
import logging
import multiprocessing
from pathlib import Path

import cv2
import numpy as np
from PIL import ImageFile
import pandas as pd
from tensorflow.keras.applications import nasnet
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.image import ImageDataGenerator

# We get to see the log output for our execution, so log away!
logging.basicConfig(level=logging.INFO)

# This must be set to load some imags using PIL, which Keras uses.
ImageFile.LOAD_TRUNCATED_IMAGES = True

ASSET_PATH = Path(__file__).resolve().parents[0] / "assets"
MODEL_PATH = ASSET_PATH / "my_awesome_model.h5"

# the images will live in a folder called 'data' in the container
TEST_PATH = Path("/databig/processed/test_images")


### SEQ DROP BLOCK ###
seq_drop_path = Path(__file__).resolve().parents[2] / "data/interim/seqs_to_drop.csv"
seqs_to_drop = pd.read_csv(str(seq_drop_path), index_col=0, squeeze=True)


def perform_inference():
    """This is the main function executed at runtime in the cloud environment. """
    logging.info("Loading model.")
    model = load_model(MODEL_PATH)

    logging.info("Loading and processing metadata.")

    # our preprocessing selects the first image for each sequence
    test_metadata = pd.read_csv(ASSET_PATH / "test_metadata.csv", index_col="seq_id")
    test_metadata = (
        test_metadata.sort_values("file_name").groupby("seq_id").first().reset_index()
    )

    # prepend the path to our filename since our data lives in a separate folder
    test_metadata["full_path"] = test_metadata.file_name.map(
        lambda x: str(TEST_PATH / x)
    )

    ### SEQ DROP BLOCK ###
    logging.info(f"Dropping {seqs_to_drop.shape[0]} sequences:")
    test_metadata = test_metadata.set_index("seq_id").drop(seqs_to_drop).reset_index()

    logging.info("Starting inference.")

    # Preallocate prediction output
    num_labels = 54
    output = np.zeros((test_metadata.shape[0], num_labels))

    # Instantiate test data generator
    datagen = ImageDataGenerator(preprocessing_function=nasnet.preprocess_input)

    batch_size = 256
    test_datagen = datagen.flow_from_dataframe(
        dataframe=test_metadata,
        x_col="full_path",
        y_col=None,
        class_mode=None,
        target_size=(224, 224),
        batch_size=batch_size,
        shuffle=False,
    )

    # Perform (and time) inference
    steps = np.ceil(test_metadata.shape[0] / batch_size)
    inference_start = datetime.now()
    preds = model.predict_generator(
        test_datagen, steps=steps, verbose=1, workers=12, use_multiprocessing=False
    )
    inference_stop = datetime.now()
    logging.info(f"Inference complete. Took {inference_stop - inference_start}.")

    logging.info("Creating submission.")

    # Load the submission format so we can match it exactly
    submission_format = pd.read_csv(ASSET_PATH / "submission_format.csv", index_col=0)

    ### SEQ DROP BLOCK ###
    submission_format = submission_format.drop(seqs_to_drop)

    # Check our predictions are in the same order as the submission format
    assert np.all(
        test_metadata.seq_id.unique().tolist() == submission_format.index.to_list()
    )

    output[: preds.shape[0], :] = preds[: output.shape[0], :]
    my_submission = pd.DataFrame(
        np.stack(output),
        # remember that we are predicting at the sequence, not image level
        index=test_metadata.seq_id,
        columns=submission_format.columns,
    )

    # We want to ensure all of our data are floats, not integers
    my_submission = my_submission.astype(np.float)

    # Save out submission to root of directory
    my_submission.to_csv("submission.csv", index=True)
    logging.info(f"Submission saved.")


if __name__ == "__main__":
    perform_inference()
