import csv
import json
import os
import re


# Function to read data from the CSV file
def read_csv(file_path):
    data = []
    with open(file_path, encoding="utf-8", errors="ignore") as csvfile:
        reader = csv.reader(csvfile)
        header_row = next(reader)

        for row in reader:
            data.append(row)
    return header_row, data


# Path to the CSV file
csv_file_path = "Power Card Game - Digital - Battle.csv"


# Read data from the CSV file
header_row, csv_data = read_csv(csv_file_path)


# Function to update the file paths with a new folder file path
def update_image_file_paths(csv_data, new_folder_path, big_image_path):
    for row in csv_data:
        # Loop through each file in the folder
        for filename in os.listdir(big_image_path):
            # Get the full path of the file
            file_path = os.path.join(big_image_path, filename)
            
            
            # Check if it's a file and doesn't contain "import" in its name
            if (
                os.path.isfile(file_path)
                and "import" not in filename
                and row[2] in filename
            ):
                print(file_path)
                resource_path = file_path.replace(
                    "D:/Godot Game/Dragon-Ball-Power-Card-Game/", "res://"
                )
                row[5] = (resource_path.replace("\\", "/"))
                # print(row[5])
                
        for filename in os.listdir(new_folder_path):
            # Get the full path of the file
            file_path = os.path.join(new_folder_path, filename)

            # Check if it's a file and doesn't contain "import" in its name
            if (
                os.path.isfile(file_path)
                and "import" not in filename
                and row[2] in filename
            ):
                # Perform your action on the file
                # print(f"Processing file: {file_path}")
                # Find the index of the first "_" character and the last "." character
                resource_path = file_path.replace(
                    "D:/Godot Game/Dragon-Ball-Power-Card-Game/", "res://"
                )
                row[6] = resource_path.replace("\\", "/")
                # print(row[6])



# Update the file paths with the new folder file path
update_image_file_paths(
    csv_data,
    r"D:/Godot Game/Dragon-Ball-Power-Card-Game/card/battle/image/160x240/",
    r"D:/Godot Game/Dragon-Ball-Power-Card-Game/card/battle/image/742x1122/",
)

# Write the modified data back to the CSV file
with open(csv_file_path, "w", newline="", encoding="utf-8") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(header_row)
    writer.writerows(csv_data)

