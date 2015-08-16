#!/usr/bin/env sh
TEMPLATE_DIR=./templates
OUTPUT_DIR=./output

TOKENS="
VAR_ONE:Enter a value for VAR_ONE
VAR_TWO:Enter a value for VAR_TWO
"

IFS=$(echo "\n\b")

stty -echo
for line in $TOKENS; do
    var=$(echo "$line" | cut -f 1 -d :)
    prompt=$(echo "$line" | cut -f 2- -d :)
    read -p "$var - $prompt: " $var
done
stty echo

rm -rf $OUTPUT_DIR
cp -r $TEMPLATE_DIR/ $OUTPUT_DIR

for filename in $(find $OUTPUT_DIR -type f); do
    content=$(eval "echo \"$(cat $filename)\"")
    echo $content > $filename
    echo "Created file at $filename"
done
