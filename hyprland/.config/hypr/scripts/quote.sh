#!/usr/bin/env bash

cache_file="/tmp/quote"

# Check if we need to fetch a new quote (older than 60 seconds or missing)
if [[ ! -f "$cache_file" || $(find "$cache_file" -mmin +1) ]]; then
	quotes=$(curl -s "https://zenquotes.io/api/quotes")
	quote=$(echo "$quotes" | jq -r '.[0]')
	echo "$quote" >"$cache_file"
fi

# Read cached quote
quote=$(<"$cache_file")
body=$(echo "$quote" | jq -r '.q')
author=$(echo "$quote" | jq -r '.a')

case "$1" in
--quote | -q)
	echo "$body"
	;;
--author | -a)
	echo "$author"
	;;
--full | "" | -f)
	echo "'$body' - $author"
	;;
--help | -h)
	echo "Usage:
    $0 --quote     | -q   # Show quote only
    $0 --author    | -a   # Show author only
    $0 --full      | -f   # Show full quote (default)
    $0 --help      | -h   # Show this help message"
	;;
*)
	echo "Unknown option: $1"
	echo "Run '$0 --help' to see usage."
	exit 1
	;;
esac
