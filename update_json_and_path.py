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
battle_file_path = "Power Card Game - Digital - Battle.csv"
faux_file_path = "Power Card Game - Digital - Faux.csv"


##################################################################### BATTLE JSON ############################################################################
# Read data from the CSV file
header_row, csv_data = read_csv(battle_file_path)


# Function to update the file paths with a new folder file path
def update_battle_file_paths(csv_data, new_folder_path, big_image_path):
    for row in csv_data:
        # Loop through each file in the folder
        for filename in os.listdir(big_image_path):
            # Get the full path of the file
            file_path = os.path.join(big_image_path, filename)
            
            
            # Check if it's a file and doesn't contain "import" in its name
            if (
                os.path.isfile(file_path)
                and "import" not in filename
                and row[2].strip() in filename
            ):
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
                and row[2].strip() in filename
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
update_battle_file_paths(
    csv_data,
    r"D:/Godot Game/Dragon-Ball-Power-Card-Game/card/battle/image/160x240/",
    r"D:/Godot Game/Dragon-Ball-Power-Card-Game/card/battle/image/742x1122/",
)

# Write the modified data back to the CSV file
with open(battle_file_path, "w", newline="", encoding="utf-8") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(header_row)
    writer.writerows(csv_data)

##################################################################### FAUX JSON ############################################################################

# Read data from the CSV file
header_row, csv_data = read_csv(faux_file_path)

# Function to update the file paths with a new folder file path
def update_faux_file_paths(csv_data, new_folder_path, big_image_path):
    for row in csv_data:
        # Loop through each file in the folder
        for filename in os.listdir(big_image_path):
            # Get the full path of the file
            file_path = os.path.join(big_image_path, filename)
            
            
            # Check if it's a file and doesn't contain "import" in its name
            if (
                os.path.isfile(file_path)
                and "import" not in filename
                and row[2].strip() == filename.replace(".png","")
            ):
                print(file_path)
                resource_path = file_path.replace(
                    "D:/Godot Game/Dragon-Ball-Power-Card-Game/", "res://"
                )
                row[4] = (resource_path.replace("\\", "/"))
                # print(row[5])
                
        for filename in os.listdir(new_folder_path):
            # Get the full path of the file
            file_path = os.path.join(new_folder_path, filename)

            # Check if it's a file and doesn't contain "import" in its name
            if (
                os.path.isfile(file_path)
                and "import" not in filename
                and row[2].strip() == filename.replace(".png","")
            ):
                # Perform your action on the file
                # print(f"Processing file: {file_path}")
                # Find the index of the first "_" character and the last "." character
                resource_path = file_path.replace(
                    "D:/Godot Game/Dragon-Ball-Power-Card-Game/", "res://"
                )
                row[5] = resource_path.replace("\\", "/")
                print(row[5])


# Update the file paths with the new folder file path
update_faux_file_paths(
    csv_data,
    r"D:/Godot Game/Dragon-Ball-Power-Card-Game/card/faux/image/160x240/",
    r"D:/Godot Game/Dragon-Ball-Power-Card-Game/card/faux/image/742x1122/",
)


# Write the modified data back to the CSV file
with open(faux_file_path, "w", newline="", encoding="utf-8") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(header_row)
    writer.writerows(csv_data)

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
battle_file_path = "Power Card Game - Digital - Battle.csv"
faux_file_path = "Power Card Game - Digital - Faux.csv"

# Path to the JSON file
json_data_battle_path = "card/battle/battle_database.json"
json_collection_battle_path = "card/battle/battle_collection.json"
json_data_faux_path = "card/faux/faux_database.json"
json_collection_faux_path = "card/faux/faux_collection.json"




##################################################################### BATTLE JSON ############################################################################

# Read data from the CSV file
header_row, csv_data = read_csv(battle_file_path)


# Write the modified data back to the CSV file
with open(battle_file_path, "w", newline="", encoding="utf-8") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(header_row)
    writer.writerows(csv_data)


# # Prepare the JSON data
json_data = []
json_collection = []
for index, row in enumerate(csv_data):
    id = row[1]
    nice_name = row[2]
    power = int(row[3])  # Assuming power is an integer
    effect = row[4]  # Assuming power is an integer
    texture_path = row[5]
    mini_image = row[6]

    card_data = {
        "id" : id,
        "nice_name": nice_name.strip(),
        "power": power,
        "effect": effect.strip(),
        "front_mini_path": mini_image.strip(),
        "back_mini_path": "res://card/battle/image/160x240/back.png",
        "front_image_path": texture_path.strip(),
        "back_image_path": "res://card/battle/image/742x1122/back.png",
        "resource_script_path": "res://card/script/battle_data.gd",
    }

    json_data.append(card_data)
    json_collection.append(nice_name.strip())

# Write JSON data to the file
with open(json_data_battle_path, "w", encoding="utf-8") as jsonfile:
    json.dump(json_data, jsonfile, ensure_ascii=False, indent=2)

with open(json_collection_battle_path, "w", encoding="utf-8") as jsonfile:
    json.dump(json_collection, jsonfile, indent=2)

print("JSON data has been written to", json_data_battle_path)


##################################################################### FAUX JSON ############################################################################

# Read data from the CSV file
header_row, csv_data = read_csv(faux_file_path)


# Write the modified data back to the CSV file
with open(faux_file_path, "w", newline="", encoding="utf-8") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(header_row)
    writer.writerows(csv_data)


# # Prepare the JSON data
json_data = []
json_collection = []
for index, row in enumerate(csv_data):
    id = row[1]
    nice_name = row[2]
    effect = row[3] 
    texture_path = row[4]
    mini_image = row[5]

    card_data = {
        "id" : id,
        "nice_name": nice_name.strip(),
        "effect": effect.strip(),
        "front_mini_path": mini_image.strip(),
        "back_mini_path": "res://card/battle/image/160x240/back.png",
        "front_image_path": texture_path.strip(),
        "back_image_path": "res://card/battle/image/742x1122/back.png",
        "resource_script_path": "res://card/script/faux_data.gd",
    }

    json_data.append(card_data)
    json_collection.append(nice_name.strip())

# Write JSON data to the file
with open(json_data_faux_path, "w", encoding="utf-8") as jsonfile:
    json.dump(json_data, jsonfile, ensure_ascii=False, indent=2)

with open(json_collection_faux_path, "w", encoding="utf-8") as jsonfile:
    json.dump(json_collection, jsonfile, indent=2)

print("JSON data has been written to", json_data_faux_path)