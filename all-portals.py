import json

with open('rc.json', 'r') as file:
    dataset = json.load(file)
    
data = dataset['rc']

portals = set()

for entry in data:
    if 'published_in' in entry:
        for item in entry['published_in']:
            if 'name' in item:
                portals.add(item['name'])

    if 'connected_to' in entry:
        for item in entry['connected_to']:
            if 'name' in item:
                print(item['name'])
                portals.add(item['name'])

portals_list = list(portals)

with open('all_portals.json', 'w') as outfile:
    json.dump(portals_list, outfile)

print(len(portals)) #42