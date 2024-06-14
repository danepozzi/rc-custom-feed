# RC Portal Feed

This is a collection of tools to support the design of a Research Catalogue portal homepage. It is specifically aimed at generating exposition feeds that can be embedded in a block page to display the portal research activities. A feed looks like this:

<div style="position: relative;overflow: hidden;width: 100%;padding-top: 43.75%;"><iframe src="https://rcdata.org/?keyword=theater&elements=4&order=recent&portal=&issue=" style="position: absolute;top: 0;left: 0;bottom: 0;right: 0;width: 100%;height: 100%;"></div>

## Feed Generation

Exposition feeds can be generated using a dedicated [feed generator](http://rcfeed.rcdata.org/generate/).


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
