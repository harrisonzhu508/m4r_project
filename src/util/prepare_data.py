import utils.data_cleaning_tools as dct
import pandas as pd



if __name__ == "__main__":

    # first read in the state county information and crop_data_information
    #state_county_info = pd.read_csv("../data/state_county_info/countyFIPS.csv")
    crop_data = pd.read_csv("../data/corn_data/ag_district_corn_imputed.csv")
    #ag_district_county_mapping = pd.read_csv("../data/state_county_info/ag_district_county_mapping.csv")

    # first check for missing values in agriculture districts
    dct.checkMissingAgDistrict(crop_data)






