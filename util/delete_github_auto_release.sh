#!/bin/sh

echo "deleteing release"
gh release list | tail -n +2 | awk '{if ($1 ~ /^release\.[a-zA-Z0-9]*$/) {print $1}}' | while read -r line; do gh release delete -y "$line"; done

echo "deleteing tags"
gh release list | tail -n +2 | awk '{if ($1 ~ /^release\.[a-zA-Z0-9]*$/) {print $2}}' | while read -r line; do git push origin --delete  "$line"; done

echo "kept:"
gh release list

