#!/bin/bash
echo "Starte Suche nach: $2"
grep -r "$2" ~/zemala-core/ | grep -v "node_modules"
