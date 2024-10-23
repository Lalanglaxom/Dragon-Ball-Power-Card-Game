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

# Path to the JSON file
json_data_file_path = "card/battle/battle_database.json"
json_collection_file_path = "card/battle/battle_collection.json"

# Read data from the CSV file
header_row, csv_data = read_csv(csv_file_path)


# Write the modified data back to the CSV file
with open(csv_file_path, "w", newline="", encoding="utf-8") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(header_row)
    writer.writerows(csv_data)


# # Prepare the JSON data
json_data = []
json_collection = []
for index, row in enumerate(csv_data):
    nice_name = row[1]
    texture_path = row[2]
    mini_image = row[3]
    power = int(row[4])  # Assuming power is an integer
    effect = row[5]  # Assuming power is an integer

    card_data = {
        "nice_name": nice_name,
        "front_mini_path": mini_image,
        "back_mini_path": "res://card/battle/image/160x240/back.png",
        "front_image_path": texture_path,
        "back_image_path": "res://card/battle/image/742x1122/back.png",
        "resource_script_path": "res://card/battle/battle_data.gd",
        "power": power,
        "effect": effect,
    }

    json_data.append(card_data)
    json_collection.append(nice_name)

# Write JSON data to the file
with open(json_data_file_path, "w", encoding="utf-8") as jsonfile:
    json.dump(json_data, jsonfile, ensure_ascii=False, indent=2)

with open(json_collection_file_path, "w", encoding="utf-8") as jsonfile:
    json.dump(json_collection, jsonfile, indent=2)

print("JSON data has been written to", json_data_file_path)
