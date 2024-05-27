#!/bin/sh
echo "copying index.html and build/elm.js to /var/www/html/ and a json"
cp index.html /var/www/html/index.html
cp build/elm.js /var/www/html/build/elm.js
cp kcpedia.json /var/www/html/kcpedia.json
cp proxy.go ../rcproxy/proxy.go
rm -r /var/www/html/generate
cp -r generate/ /var/www/html/generate/

