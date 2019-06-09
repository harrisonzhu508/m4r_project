#!/bin/bash

results="../saved"
if [ ! -d "$results" ]
then
    mkdir ../saved/
    mkdir ../saved/spring_barley
    mkdir ../saved/winter_wheat
    mkdir ../saved/spring_barley/plots
    mkdir ../saved/winter_wheat/plots
    mkdir ./predictions
    Rscript setup.R
fi


# run predictions for 2019
#Rscript bart_train_week_main.R "2019" 2 30
Rscript bart_test_month_main.R 2 4
