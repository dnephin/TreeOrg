import web
import treeorg.web.servlet
from treeorg.web.url import urls, class_map

app = web.application(urls, class_map)
web.debug(urls)
web.debug(class_map)

if __name__ == "__main__":
	app.cgirun()
