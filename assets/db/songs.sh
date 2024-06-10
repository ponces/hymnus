#!/bin/bash

set -e

if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "Usage: $0 <folder>"
    exit 1
fi

id=0

echo "{\"songs\":[" > songs.json
for file in "$1"/*.txt; do
    filename=$(basename "$file")
    title=$(echo ${filename%.*} | sed "s/'/\'/g")
    echo "Adding \"$title\""
    if [[ "$title" == "CC"* ]]; then
        type="CC"
    elif [[ "$title" == "HCC"* ]]; then
        type="HCC"
    else
        type="Other"
    fi
    lyrics=$(cat "$file" | sed "s/\"/\\\\\"/g" | tr -d '\t' | tr -d '\r' | sed -z "s/\n/\\\n/g;s/\\\n\\\n\\\n/\\\n\\\n/g" )
    echo "{\"id\":$id,\"title\":\"$title\",\"type\":\"$type\",\"lyrics\":\"$lyrics\"}," >> songs.json
    id=$((id+1))
done
sed -i "$ s/,$//" songs.json
echo "]}" >> songs.json

cat songs.json | jq . > songs.json.tmp
mv songs.json.tmp songs.json
