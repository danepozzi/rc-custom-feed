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

## TODO
[ ] filter by exposition ID
[ ] Scrollbars in certain browsers, I think it is more likely with less elements
     - Where are they?
     - In the generated CSS
[ ] At least include a link to the readme from the generate page, its nice if the special CSS rule is include on the page.
[ ] Internal portal fetching (how do we deal with this?)
[ ] Search options

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

# Deploying to a server

* Create a deploy key, clone the repo from GitHub (or clone using https)
* Make a new deploy script to copy to the right sub dir in /var/www/html/rcfeed instead of the main html directory
*￼You are probably going to run this as a subdomain in another domain, for example rcfeed.example.com
Add a new config file in /etc/apache2/sites-available
*￼ServerName rcfeed.rcdata.org
*￼ServerAdmin webmaster@localhost
*￼DocumentRoot /var/www/html/rcfeed
*￼the go proxy = <Location /rcproxy>

                ProxyPass http://localhost:3000
                ProxyPassReverse http://localhost:3000

                Order allow,deny
                Allow from all
        </Location>
￼This go proxy also should be added in the https config file of apache2

* Run the certbot
￼sudo certbot --apache -d subdomain.example.com
￼This will also add the redirect rule
* don't forget to restart apache service

### Running:
Run deploy script to copy files (you may have to create some dirs like build and generate)
Run the go server in a linux "screen". 



