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

for i in {2000..2019}
do
    Rscript bart_train_week_main.R "$i"
    Rscript bart_validation_week_main.R "$i"
done

