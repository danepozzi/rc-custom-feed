import os

keyword = "kcpedia"
get = 'curl -X GET "https://www.researchcatalogue.net/portal/search-result?fulltext=&title=&autocomplete=&keyword=kcpedia&portal=&statusprogress=0&statusprogress=1&statuspublished=0&statuspublished=1&includelimited=0&includeprivate=0&type_research=research&resulttype=research&modifiedafter=&modifiedbefore=&format=json&limit=50&page=0" > kcpedia.json'

os.system(get)

with open("kcpedia.json", "r") as f:
    contents = f.readlines()

contents.insert(1,"}")
contents.insert(0,"{\"kcpedia\":")

with open("kcpedia.json", "w") as f:
    contents = "".join(contents)
    f.write(contents)
    
os.system("npx json-server --watch kcpedia.json -p 2019 &")
