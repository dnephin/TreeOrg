while true; do
#	python web/template.py --compile templates/ && \
	coffee --join ./www_root/js/main.js --compile coffee-src/*.coffee || sleep 2
	clear
done
