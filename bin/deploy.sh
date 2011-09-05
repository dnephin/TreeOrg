#!/bin/bash
# Deploy to prod

if [ ! -f app.yaml ]; then
	echo "Run from app root directory."
	exit -1
fi

COFFEEJS=www_root/js/main.js

echo "Building coffee scripts."
coffee --join $COFFEEJS --compile coffee-src/*.coffee || exit -1

# echo "Building less scripts."

echo "Syncing to dist..."
rsync --delete -av  \
	--exclude=.git \
	--exclude=\*.pyc \
	--exclude=.*.sw? \
	--exclude=TODO \
	--exclude=tests \
	--exclude=jinja2/testsuite \
	--exclude=coffee-src \
	. ../dist || exit -2

pushd ../dist

echo "Minifying..."
uglifyjs --overwrite $COFFEEJS || exit -1

echo "Deploying..."
appcfg.py update .

