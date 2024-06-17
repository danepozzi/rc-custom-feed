# RC Portal Feed

This is a collection of tools to support the design of a Research Catalogue portal homepage. It is specifically aimed at generating *exposition feeds* that can be embedded in a block page to display the portal research activities. A feed represents a collection of expositions that is rendered as one single scrollable carousel. Feeds look like [this](https://www.researchcatalogue.net/view/2639908/2639909).

## Feed Generation

Exposition feeds can be generated using a dedicated [feed generator](https://rcfeed.rcdata.org/generate/). Here you find some controls to generate the feed, a preview section and a box with the generated HTML code. Copy the HTML code to an HTML element in your block exposition to embed the feed in the block page.

## Raw CSS
The following style needs to be copied over to the *raw css* section in the exposition editor. 

```
@media (max-width: 675px) {
     div.cont {
        padding-top: 125.00% !important;
    }
}
```

To enable full page view, also add these lines:

```
#content.device-desktop {
    max-width: unset;
}
```

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
