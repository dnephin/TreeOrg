import web
from web.utils import storage
from web.webapi import debug, ctx

from google.appengine.api import users
from google.appengine.ext import db

from treeorg.web import json
from treeorg.web import models 
from treeorg.web import url

render = web.template.render('templates/', base='base')


class ServletType(type):
	"""Servlet metaclass. Registers the servlets url."""
	def __init__(cls, *args, **kwargs):
		if hasattr(cls, 'GET') or hasattr(cls, 'POST'):
			url.register(cls.url(), cls)
		super(ServletType, cls).__init__(*args, **kwargs)

class Servlet(object):
	"""Base class for all servlets."""
	__metaclass__ = ServletType

	url_base = None
	action = None
	extra = []

	@classmethod
	def url(cls):
		parts = [p for p in [cls.url_base, cls.action] + cls.extra if p]
		return '/%s' % ('/'.join(parts))

	def context(self):
		return storage(
			user=users.get_current_user()
		)

	def loginurl(self):
		return users.create_login_url('/tree')
		

class Main(Servlet):
	"""Main index page."""
	url_base = ''

	def GET(self):
		user = users.get_current_user()
		if user:
			return web.seeother('/tree')
		raise web.seeother(self.loginurl())

class About(Servlet):
	"""About the site page."""
	url_base = 'about'

	def GET(self):
		context = self.context()
		context.loginurl = self.loginurl()
		debug(context)
		return render.about(context)

class Tree(Servlet):
	"""Full page which loads javascript app."""
	url_base = 'tree'

	def GET(self):
		return render.tree(self.context())

class NodeServlet(Servlet):
	url_base = 'node'
	action = '([^/]*)'

	# TODO: filter reserved kwargs (key_name, id, parent, etc)

	def PUT(self, key):
		user = users.get_current_user()
		# TODO: handle errors?
		new_node = json.dec(web.data())
		# Check old node belongs to this user
		old_node = models.Node.get(new_node.key())
		assert old_node.user == user
		new_node.put()
		return json.enc(new_node)

	def GET(self, key):
		user = users.get_current_user()
		# TODO: validate input
		input = web.input()
		depth = int(input.get('depth') or 0)
		if not key:
			node = models.Node.get_root_for_user(user, load_depth=depth)

			# TODO: write on GET
			# First visit
			if not node:
				node = models.Node.new_for_user(user, value='root', root_node=True)
				node.put()
		else:
			node = models.Node.get_with_children(key)
			if not node or node.user != user:
				raise web.notfound()

		return json.enc(node)

	def POST(self, key):
		assert not key
		user = users.get_current_user()
		# TODO: handle errors?
		node_data = json.dec(web.data())
		debug(node_data)
		assert not node_data.get('key')

		new_node = models.Node.new_for_user(user, **node_data)
		new_node.put()
		return json.enc(new_node)

	def DELETE(self, key):
		user = users.get_current_user()
		node = models.Node.get(key)
		assert node.user == user
		assert not node.root_node
		node.active = False
		node.put()
		

class NodeChildrenServlet(Servlet):
	url_base = 'children'
	action = '([^/]*)'

	def GET(self, key):
		user = users.get_current_user()
		children = models.Node.get_children([db.Key(key)])
		for child in children:
			assert child.user == user
		return json.enc(children)



