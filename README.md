# RC Custom Feed

This is a tool to help creating custom feeds for the Research Catalaogue portals. A "feed" is created in the RC by tagging a group of exposition with a unique keyword. This tool takes one feed and renders it to a carousel. I chose the carousel to keep it compact and with a fixed size, but there might be more clever layouts. The idea is then that portal admnins should be able to create custom landing pages (block pages) for the portals, in which carousels can be embedded with an iframe mirroring https://external.resource/keyword/

## To Test


__npx elm-watch hot__

python json-setup.py

http-server --port 8080 -P http://localhost:8080?



## TODO
- At the moment carousel displays one exposition per slide. This might be also customised in the url
- Alternative layouts?
