"""Servlets register their urls for routing."""

urls = []
class_map = {}


def register(url, cls):
	urls.append(url)
	urls.append(cls.__name__)
	class_map[cls.__name__] = cls
