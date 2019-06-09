import pandas as pd
import numpy as np 
import json

def checkMissingAgDistrict(crop_data):
    """Check whether any agriculture districts have missing data from 1997 - 2017

    - Saves a log of all the missing values
    - Saves the imputed data 


    Input:

        crop_data: data containing crop yields

    Output:

        None
    """

    # create log file containing missing values
    logFile = open("../logs/checkMissingAgDistrict.txt", "w")
    logFile.write("FILE BEGINNING \n \n")

    # verify that each year has complete data for each Agriculture district
    years = set(crop_data.Year)
    states = set(crop_data.State)
    # for each year check whether there is crop yield information for each county
    num_missing = {year:0 for year in years}

    print("Imputing missing entry with 0 yield when necessary \n")
    for state in states:

        stateData = crop_data[crop_data["State"] == state]
        stateUSPS = stateData.USPS_Code.values[0]
        stateDistricts = set(stateData["Ag_District"])

        for year in years:
            
            stateYearData = stateData[stateData["Year"] == year]
            
            for agDistrict in stateDistricts:

                yearAgDistrict = set(stateYearData["Ag_District"])

                if not agDistrict in yearAgDistrict:
                    num_missing[year] += 1
                    missingMessage = "Yield missing in year {} from district {} in state {} \n ".format(year, agDistrict, state)
                    # define imputation
                    imputation = pd.DataFrame(
                        [[state, year, agDistrict, 0, stateUSPS]],
                        columns=list(crop_data.columns)
                    )
                    
                    # impute data
                    crop_data = pd.concat([crop_data, imputation])

                    logFile.write(missingMessage)

                    print(missingMessage)

    crop_data.to_csv("../data/corn_data/ag_district_corn_imputed.csv")
    logFile.write("\n \n Summary. Imputed with 0s \n \n")
    logFile.write(json.dumps(num_missing))
    logFile.write("\n FILE END \n \n")
    # close log
    logFile.close()
    print("Summary: {}".format(num_missing))
    print("Log written to ../logs/checkMissingAgDistrict.txt")
    print("Imputation written to ../data/corn_data/ag_district_corn_imputed.csv")

    return 

# capitalise a string and uncapitalise non-beginning letters 
capitalize_func = lambda string: string.upper()

def capitalize_entries(string):
    """Capitalise the whole string

    e.g. Kent County -> KENT COUNTY

    Input:

        string: string of words

    Output:

        capitalisedString: processed string
    """


    capitalisedString = " ".join( map(capitalize_func, string.split(" ")) )

    return capitalisedString

def stateToCountyMapping(coordinates):
    """create state to county mapping dictionary

    Input:

        coordinates: file containing coordinates of each state in America

    Output:

        stateToCounty: dictionary containing hash mapping from state name to county names
    """
    # generate dictionary of state to county mapping

    stateToCounty = {}

    states = set(coordinates.State)

    for state in states:
        stateGeoInfo = coordinates[coordinates.State == state]
        stateCounties = stateGeoInfo["County"].values
        stateToCounty[state] = stateCounties

    return stateToCounty

#def computeCentroid(ag_district_county_mapping, coordinates, stateToCounty):
#    """Compute the centroids corresponding to the coordinates of each agriculture district.
#    This corresponds to averaging the longitude and latitude of the coordinates of each county within
#    each agriculture district.
#
#    Input:
#
#        ag_district_county_mapping: data containing yields with USPS code column
#        coordinates: file containing coordinates of each state in America
#        stateToCounty: dictionary containing hash mapping from state name to county names
#
#    Output:
#
#        agDistrictCentroids: data containing coordinates to agriculture district centroids
#
#    """
#
#    # create dataframe of 
#    agDistrictCentroids = pd.DataFrame(
#        columns = ["USPS_Code",
#                "Ag_District",
#                "Ag_District_Centroid_Longitude",
#                "Ag_District_Centroid_Latitude",
#                ]
#    )
#
#    # for crop_data, obtain for each state, it's agriculture districts
#    # then identify the counties within the agriculture districts THAT EXISTS in stateToCounty dictionary
#
#    for state in set(ag_district_county_mapping["USPS_Code"]):
#      print("State {}".format(state))
#
#      # put the agriculture and district mapping into a dictionary
#      districtsToCounty = {}
#      # obtain agriculture districts
#      agDistricts = set(ag_district_county_mapping[ag_district_county_mapping["USPS_Code"] == state]["Ag District"])
#      stateCounties = stateToCounty[state]
#    
#      for agDistrict in agDistricts:
#        print("Agriculture District {} ".format(agDistrict))
#
#        # put the counties corresponding to each agriculture district into a list
#        # then insert into the dictionary districtsToCounty
#
#        countiesInagDistrict = set(ag_district_county_mapping[ag_district_county_mapping["Ag District"] == agDistrict].County)
#
#        districtsToCounty[agDistrict] = []
#
#        for county in stateCounties:
#        
#          if county in countiesInagDistrict:
#          
#            districtsToCounty[agDistrict].append(county)
#
#        # now obtain the coordinates of the counties within each agriculture district
#        # and compute the centroid
#
#        # obtain coordinates from coordinates
#        stateCoordinates = coordinates[coordinates["State"] == state]
#
#        countyCoordinates = []
#        for county in districtsToCounty[agDistrict]:
#        
#          countyInfo = stateCoordinates[stateCoordinates["County"] == county] 
#
#          latitude, longitude = countyInfo.Latitude.values[0], countyInfo.Longitude.values[0]
#          latitude, longitude = float(latitude[1:-1]), float(longitude[1:-1])
#
#          print(np.array([latitude, longitude]))
#          countyCoordinates.append(np.array([latitude, longitude]))
#
#
#        agDistrictCentroid = sum(countyCoordinates) / len(countyCoordinates)
#
#        agDistrictCentroids = pd.concat(
#            [agDistrictCentroids,
#              pd.DataFrame(
#                {
#                "USPS_Code": state,
#                "Ag_District" : agDistrict,
#                "Ag_District_Centroid_Longitude" : -agDistrictCentroid[1],
#                "Ag_District_Centroid_Latitude" : agDistrictCentroid[0]
#                },
#                  index=[state]
#              )
#            ]
#        )
#
#    print("Complete centroid computation")
#
#    return agDistrictCentroids

#if __name__ == "__main__":
#
#    # read in yield data
#    crop_data = pd.read_csv("../data/")
#    checkMissingAgDistrict(crop_data)
#    stateToCounty = stateToCountyMapping(coordinates)
#    agDistrictCentroids = computeCentroid(crop_data, coordinates, stateToCounty)
#
#    agDistrictCentroids.to_csv("../../data/centroids.csv")
