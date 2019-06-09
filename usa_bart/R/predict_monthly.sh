#!/bin/bash

usa_results="../usa_results"
if [ ! -d "$usa_results" ]
then
    mkdir ../usa_results/
    mkdir ../usa_results/predictions/
    Rscript setup.R
fi


# run predictions for 2019
#Rscript bart_train_week_main.R "2019" 2 30
Rscript bart_test_month_main.R 2 4
