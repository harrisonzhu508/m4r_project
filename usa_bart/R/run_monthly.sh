#!/bin/bash

results="../saved"
if [ ! -d "$results" ]
then
    mkdir ../saved/
    mkdir ../saved/
    Rscript setup.R
fi

# execute monthly training
# this is assuming you have the files
# 1. sweden_regional_yield_monthly_model_test.csv
# 2. sweden_regional_yield_monthly_model_train.csv
# 3. climatic_sweden_regional_yield_monthly_model_train.csv
# 4. climatic_sweden_regional_yield_monthly_model_test.csv

for i in {2000..2019}
do
    Rscript bart_train_month_main.R "$i"
    Rscript bart_validation_month_main.R "$i"
done

# run predictions for 2019
#Rscript bart_train_month_main.R "2019"
#Rscript bart_test_month_main.R


