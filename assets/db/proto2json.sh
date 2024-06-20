#!/bin/bash

set -e

if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "Usage: $0 <folder>"
    exit 1
fi

CURDIR=$(pwd)
TMPDIR="/tmp/proto2json"
SINGLE=$(echo -ne '\u00B4\u2018\u2019')
DOUBLE=$(echo -ne '\u201C\u201D')

rm -rf "$TMPDIR"
mkdir -p "$TMPDIR/json"
git clone -q https://github.com/greyshirtguy/ProPresenter7-Proto --depth 1 "$TMPDIR/templates"
curl -sSL "https://github.com/bufbuild/buf/releases/download/v1.33.0/buf-$(uname -s)-$(uname -m)" -o "$TMPDIR/buf" && chmod +x "$TMPDIR/buf"
curl -sSL "https://github.com/jgm/pandoc/releases/download/3.2/pandoc-3.2-linux-amd64.tar.gz" -o "$TMPDIR/pandoc.tar.gz" && tar -xzf "$TMPDIR/pandoc.tar.gz" -C "$TMPDIR" && mv "$TMPDIR/pandoc-3.2/bin/pandoc" "$TMPDIR/pandoc" && chmod +x "$TMPDIR/pandoc"
pushd "$TMPDIR/templates/Proto7.16.2" >/dev/null

total=$(ls "$1"/*.pro | wc -l)
id=1
count=0
echo "{\"songs\":[" > "$CURDIR/songs.json"
for file in "$1"/*.pro; do
    count=$((count+1))
    filename=$(basename "$file")
    jsonFile="$TMPDIR/json/${filename%.*}.json"
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
    "$TMPDIR/buf" convert presentation.proto --type=rv.data.Presentation --from "$file#format=binpb" --to "-#format=json" | \
        jq ".cues[].actions[].slide.presentation.baseSlide.elements[].element.text.rtfData |= @base64d" | \
        jq ".cues[].actions[].slide.presentation.notes.rtfData |= @base64d" > "$jsonFile"
    cat "$jsonFile" | jq -cr ".cueGroups[]" | while read -r group; do
        name=$(echo "$group" | jq -r ".group.name")
        echo -n "{\"name\":\"$name\",\"data\":\"" >> "$CURDIR/songs.json"
        echo "$group" | jq -cr ".cueIdentifiers[].string" | while read -r slideid; do
            data=$(cat "$jsonFile" | \
                   jq -cr ".cues[] | select(.uuid.string==\"$slideid\") | .actions[].slide.presentation.baseSlide.elements[].element.text.rtfData" | \
                   "$TMPDIR/pandoc" --from=rtf --to=plain | \
                   sed -z "s/\\n\\n/\\n/g;s/\\n/\\\\n/g;s/\\\"/\\\\\"/g")
            if grep -q "Refrão" "$jsonFile"; then
                echo -n "$data" >> "$CURDIR/songs.json"
            else
                echo -n "$data\n" >> "$CURDIR/songs.json"
            fi
        done
        echo "\"}," >> "$CURDIR/songs.json"
    done
    echo "]}," >> "$CURDIR/songs.json"
    id=$((id+1))
done
echo "]}" >> "$CURDIR/songs.json"

sed -z "s/[$SINGLE]/'/g;s/[$DOUBLE]/\\\\\"/g;s/\\\\n\\\\n\"/\"/g;s/\\\\n\"/\"/g;s/\"},\n]}/\"}\n]}/g;s/]},\n]}/]}\n]}/g" "$CURDIR/songs.json" > "$CURDIR/songs.json.tmp"

cat "$CURDIR/songs.json.tmp" | jq . > "$CURDIR/songs.json"
rm -f "$CURDIR/songs.json.tmp"

popd >/dev/null
