# RC Custom Feed

This is a tool to help creating custom feeds for the Research Catalaogue portals. A "feed" is created in the RC by tagging a group of exposition with a unique keyword. This tool takes one feed and renders it to a carousel. I chose the carousel to keep it compact and with a fixed size, but there might be more clever layouts. The idea is then that portal admnins should be able to create custom landing pages (block pages) for the portals, in which carousels can be embedded with an iframe mirroring https://external.resource/keyword/

## To Test

__npx elm-watch hot__

python json-setup.py

http-server --port 8080 -P http://localhost:8080?



## TODO


- [d] test in a block page. testing here: https://www.researchcatalogue.net/view/2639908/2639909
- [c] scaling of the arrow
- [c] add feature for selecting single expositions in url
- [c] arrow size ?
- [d] arrow flash on hover
- [d] clever iframe height
- [d] filter for portal ID / in progress
- [d] font size static, variable ellipsis
- [d] interface for generating the iframe

## DONE

- [done] horizontal padding shall also be responsive to card size 
- [done] add a arrow to the left
- [done] add a new design
- [done] wire in the proxy
- [done] add keyd for force image load
- [done] check that the key is unique for keyed

- At the moment carousel displays one exposition per slide. This might be also customised in the url
- Alternative layouts?

## Design Considerations
To have a consistent image rendering, that also looks good:
- we shall not use screenshots (or keep it as a fallback). the main problem is ratio and scaling, which needs to be "curated"
- portal admins shall ensure that each featured exposition has a thumbnail. Ideally we shall ask for a specific aspect ratio (1:1?)
- [done] in feed image height shall be dependent on the number of columns + viewport, to keep the ratio consistent 
- [done] abstract is hidden / shown based on card scaling