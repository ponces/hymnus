#!/bin/bash

set -e

if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "Usage: $0 <folder>"
    exit 1
fi

CURDIR=$(pwd)
SINGLE=$(echo -ne '\u00B4\u2018\u2019')
DOUBLE=$(echo -ne '\u201C\u201D')

total=$(ls "$1"/*.txt | wc -l)
id=1
count=0
echo "{\"songs\":[" > "$CURDIR/songs.json"
for file in "$1"/*.txt; do
    count=$((count+1))
    filename=$(basename "$file")
    title=$(echo ${filename%.*} | sed "s/'/\'/g;s/6_/6:/g;s/_/?/g;s/^hcc/HCC/g;s/^cc/CC/g")
    if [[ "$title" == *"(ARC)"* ]] || [[ "$title" == "https"* ]] || [[ "$title" == *"+"* ]] || [[ "$title" == *"medley"* ]]; then
        echo "[$count/$total] Skipping \"$title\"..."
        continue
    fi
    echo "[$count/$total] Adding \"$title\"..."
    if [[ "$title" == "CC"* ]]; then
        type="CC"
    elif [[ "$title" == "HCC"* ]]; then
        type="HCC"
    else
        type="Other"
    fi
    echo "{\"id\":$id,\"title\":\"$title\",\"type\":\"$type\",\"lyrics\":[" >> "$CURDIR/songs.json"
    name="Grupo"
    echo -n "{\"name\":\"$name\",\"data\":\"" >> "$CURDIR/songs.json"
    data=$(cat "$file" | tail -n +3 | tr -d '\r' | \
        sed -z "s/\\n/\\\n/g;s/\\\n\\\n\\\n/\\\n\\\n/g" | \
        sed -z "s/\\n\\n/\\n/g;s/\\n/\\\\n/g;s/\\\"/\\\\\"/g")
    echo -n "$data\n" >> "$CURDIR/songs.json"
    echo "\"}," >> "$CURDIR/songs.json"
    echo "]}," >> "$CURDIR/songs.json"
    id=$((id+1))
done
echo "]}" >> "$CURDIR/songs.json"

sed -z "s/[$SINGLE]/'/g;s/[$DOUBLE]/\\\\\"/g;s/\\\\n\\\\n\"/\"/g;s/\\\\n\"/\"/g;s/\"},\n]}/\"}\n]}/g;s/]},\n]}/]}\n]}/g" "$CURDIR/songs.json" > "$CURDIR/songs.json.tmp"

cat "$CURDIR/songs.json.tmp" | jq . > "$CURDIR/songs.json"
rm -f "$CURDIR/songs.json.tmp"
