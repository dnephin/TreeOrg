while true; do
	coffee --join ./www_root/js/main.js --compile coffee-src/*.coffee || sleep 5
	sleep 2
	clear
done
