import csv
import json
import os
import re

# Function to read data from the CSV file
def read_csv(file_path):
    data = []
    with open(file_path, encoding='utf-8', errors='ignore') as csvfile:
        reader = csv.reader(csvfile)
        header_row = next(reader)

        for row in reader:
            data.append(row)
    return header_row, data

# Path to the CSV file
csv_file_path = 'DBP - Character.csv'

# Path to the JSON file
json_data_file_path = 'card/battle/battle_database.json'
json_collection_file_path = 'card/battle/battle_collection.json'

# Read data from the CSV file
header_row, csv_data = read_csv(csv_file_path)

# Function to update the file paths with a new folder file path
def update_image_file_paths(csv_data, new_folder_path, big_image_path):
    for row in csv_data:
        # Loop through each file in the folder
        for filename in os.listdir(new_folder_path):
            # Get the full path of the file
            file_path = os.path.join(new_folder_path, filename)
            
            # Check if it's a file and doesn't contain "import" in its name
            if os.path.isfile(file_path) and "import" not in filename and row[1] in filename:
                # Perform your action on the file
                # print(f"Processing file: {file_path}")
                # Find the index of the first "_" character and the last "." character
                resource_path = file_path.replace("E:\\Zame\\Godot Game\\Bai Suc Manh\\", "res://")
                row[2] = resource_path.replace("\\","/")
                # print(row[2])

        for filename in os.listdir(big_image_path):
            # Get the full path of the file
            file_path = os.path.join(big_image_path, filename)
            
            # Check if it's a file and doesn't contain "import" in its name
            if os.path.isfile(file_path) and "import" not in filename and row[1] in filename:
                # Perform your action on the file
                # print(f"Processing file: {file_path}")
                # Find the index of the first "_" character and the last "." character
                resource_path = file_path.replace("E:\\Zame\\Godot Game\\Bai Suc Manh\\", "res://")
                row.append(resource_path.replace("\\", "/"))
                print(row[6])


# Update the file paths with the new folder file path
update_image_file_paths(csv_data, r'E:\Zame\Godot Game\Bai Suc Manh\card\battle\image', r'E:\Zame\Godot Game\Bai Suc Manh\card\battle\image\742x1122')

# Write the modified data back to the CSV file
with open(csv_file_path, 'w', newline='', encoding='utf-8') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(header_row)
    writer.writerows(csv_data)


# # Prepare the JSON data
json_data = []
json_collection = []
for index, row in enumerate(csv_data):
    nice_name = row[1]
    texture_path = row[2]
    power = int(row[3])  # Assuming power is an integer
    effect = row[4]  # Assuming power is an integer
    description = row[5] # Assuming power is an integer
    big_image = row[6]

    card_data = {
        "nice_name": nice_name,
        "texture_path": texture_path,
        "backface_texture_path": "res://card/battle/image/back.png",
        "resource_script_path": "res://card/battle/battle_data.gd",
        "power": power,
        "effect": effect,
        "description": description,
        "big_image": big_image
    }

    json_data.append(card_data)
    json_collection.append(nice_name)

# Write JSON data to the file
with open(json_data_file_path, 'w', encoding='utf-8') as jsonfile:
    json.dump(json_data, jsonfile, ensure_ascii=False, indent=2)

with open(json_collection_file_path, 'w', encoding='utf-8') as jsonfile:
    json.dump(json_collection, jsonfile, indent=2)

print("JSON data has been written to", json_data_file_path)
