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

#source '/Users/harrisonzhu/Desktop/PhD/ds-google-earth-engine/cervest_GEE/bin/activate.fish'
#python /Users/harrisonzhu/Desktop/PhD/ds-google-earth-engine/data-processing/test/lantmannen_regional_predictions_preprocessing.py

# run predictions for 2019
#Rscript bart_train_week_main.R "2019" 2 30
Rscript bart_test_week_main.R 2 18
