# m4r_project: Source code for M4R Project

The minimal working example (MWE) is provided below.

## Requirements

- Google Colab access or GPU-enabled machines
- Python 3.7 or above
- R 3.5.1 or above

## Sweden Crop Yield Forecast

Simply run the following commands from the root `m4r_project` folder:

```bash
cd sweden_bart/R
./run_monthly.sh
```
This will produce plots and saved models in the `sweden_bart/saved/` folder. Then open `notebooks/sweden.ipynb` and configure to run the XGB-GP models and full analysis.

## USA Crop Yield Forecast

Simply run the following commands from the root `m4r_project` folder:

```bash
cd usa_bart/R
./run_monthly.sh
```
This will produce plots and saved models in the `sweden_bart/saved/` folder. Then open `notebooks/usa.ipynb` and configure to run the XGB-GP models and full analysis.


## Other code

`src/` contains code used for data engineering and collection.

