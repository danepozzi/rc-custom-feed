#!/bin/sh
npx elm-watch hot &
python json-setup.py &
http-server --port 8080 -P "http://localhost:8080?" &
