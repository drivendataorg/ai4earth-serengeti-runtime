#!/bin/bash
set -vex

processor="gpu"

{
    cd /inference

    # check for gpu with nvidia-smi
    if [ $(nvidia-smi 2> /dev/null) ]
    then
        :
    else
        echo "GPU unavailable; falling back to CPU."
        processor="cpu"
    fi

    echo "Unpacking submission ($SUBMISSION_ID) for $COMPETITION_OWNER"
    echo "TaskID: $TASK_ID"
    unzip ./submission/submission.zip -d .

    if [ -f "main.py" ]
    then
        source activate py-$processor
        echo "Running submission ($SUBMISSION_ID) in Python for $COMPETITION_OWNER"
        python main.py
    elif [ -f "main.R" ]
    then
        source activate r-$processor
        echo "Running submission ($SUBMISSION_ID) in R for $COMPETITION_OWNER"
        R -f main.R
    else
        echo "Could not find main.py or main.R in submission ($SUBMISSION_ID) for $COMPETITION_OWNER"
        exit 1
    fi

    echo "Exporting submission ($SUBMISSION_ID) result for $COMPETITION_OWNER"

    # Valid scripts must create a "submission.csv" file within the same directory as main
    if [ -f "submission.csv" ]
    then
        echo "Script completed its run."
        cp submission.csv ./submission/submission.csv
    else
        echo "ERROR: Script did not produce a submission.csv file in the main directory."
        exit 1
    fi

    echo "Completed submission ($SUBMISSION_ID) for $COMPETITION_OWNER"
    exit 0
} |& tee "/inference/submission/log.txt"

# copy for additional log uses
cp /inference/submission/log.txt /tmp/log