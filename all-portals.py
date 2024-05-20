import json

with open('rc.json', 'r') as file:
    dataset = json.load(file)
    
data = dataset['rc']

portals = {}

for entry in data:
    if 'published_in' in entry:
        for item in entry['published_in']:
            if 'name' in item:
                portals[item['name']] = item['id']

    if 'connected_to' in entry:
        for item in entry['connected_to']:
            if 'name' in item:
                portals[item['name']] = item['id']

with open('all_portals.json', 'w') as outfile:
    json.dump(portals, outfile)

print(len(portals)) #42