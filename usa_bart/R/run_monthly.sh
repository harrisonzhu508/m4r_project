#!/bin/bash

results="../saved"
if [ ! -d "$results" ]
then
    mkdir ../saved/
    mkdir ../saved/plots
    Rscript setup.R
fi


# run predictions for 2017
Rscript bart_train_month_main.R
Rscript bart_test_month_main.R


