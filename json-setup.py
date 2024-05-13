import os

url = "https://www.researchcatalogue.net/portal/search-result?fulltext=&title=&autocomplete=&keyword=&portal=&statusprogress=0&statusprogress=1&statuspublished=0&statuspublished=1&includelimited=0&includelimited=1&includeprivate=0&type_research=research&resulttype=research&format=json&limit=250&page="

def getPage(num):
    if num == 0:
        get = 'curl -X GET \"'+ url + str(num) +  '\" > rc.json'
    else:
        get = 'curl -X GET \"'+ url + str(num) +  '\" >> rc.json'
    os.system(get)
    
for i in range(18):
    getPage(i)

with open("rc.json", "r") as f:
    contents = f.readlines()

contents.insert(1,"}")
contents.insert(0,"{\"rc\":")

with open("rc.json", "w") as f:
    contents = "".join(contents)
    contents = contents.replace("}][{", "},{")
    f.write(contents)
    
os.system("npx json-server --watch rc.json -p 2019 &")
