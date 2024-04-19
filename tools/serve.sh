#!/usr/bin/env bash
open http://localhost:8000
cd "`dirname $0`"
/usr/local/bin/python3 -m http.server -d ../docs/
