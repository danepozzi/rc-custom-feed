#!/bin/sh
elm make src/Main.elm --output build/elm.js
elm make src/Generate.elm --output generate/elm.js
