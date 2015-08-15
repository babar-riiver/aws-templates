#!/usr/bin/env sh
TEMPLATES="one.template.txt
two.template.txt
three.template.txt"

TOKENS="VAR_ONE:Enter a value for VAR_ONE
VAR_TWO:Enter a value for VAR_TWO"

IFS=$(echo "\n\b")

for line in $TOKENS; do
    var=$(echo "$line" | cut -f 1 -d :)
    prompt=$(echo "$line" | cut -f 2- -d :)
    echo -n "$var - $prompt: "
    read $var
done

for filename in $TEMPLATES; do
    dest=$(echo $filename | sed 's/\.template//g')
    content=$(eval "echo \"$(cat $filename)\"")
    echo $content > $dest
done
