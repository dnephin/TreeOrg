while true; do
	python web/template.py --compile templates/ && \
	coffee --join ./www_root/js/main.js --compile coffee-src/*.coffee 2> /dev/null || sleep 2
done
