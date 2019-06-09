import pandas as pd
import os

print("First make sure the data is stored in ../../data/{}/")
print("please indicate the folder name")
response = input()
for root, dirs, files in os.walk("../../data/{}/".format(response), topdown=False):
    for name in files:
        file_dir = os.path.join(root, name)
        print("On file:", file_dir)
        data = pd.read_csv(file_dir)
        data = data.drop(columns=["system:index","AFFGEOID", "GEOID", "ALAND", "AWATER", "LSAD", "description", ".geo", "name"])
        data[["COUNTYFP", "COUNTYNS", "STATEFP"]] = data[["COUNTYFP", "COUNTYNS", "STATEFP"]].astype(int)

        data.to_csv(file_dir)


print("finished processing data. Please check:", file_dir)


