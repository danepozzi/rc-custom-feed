# RC Portal Feed

This is a collection of tools to support the design of a Research Catalogue portal homepage. It is specifically aimed at generating exposition feeds that can be embedded in a block page to display the portal research activities. A feed looks like this:

## Feed Generation

Exposition feeds can be generated using a dedicated [feed generator](https://rcfeed.rcdata.org/generate/).


## Test and Development 

### To Test

__npx elm-watch hot__

python3 json-setup.py

http-server --port 8080 -P http://localhost:8080

### Make Generate Page

elm make src/Generate.elm --output generate/elm.js

### Find and Kill Json Server at Port 2019

sudo lsof -i :2019
kill -9 <PID>
