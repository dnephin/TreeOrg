import logging
import web
from web.utils import storage
from web.webapi import debug, ctx
from web.contrib.template import render_jinja

from google.appengine.api import users
from google.appengine.ext import db

from treeorg.web import json
from treeorg.web import models 
from treeorg.web import url

render = render_jinja('templates', encoding='utf-8')


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
			user=users.get_current_user(),
			loginurl=self.loginurl(),
			logouturl=users.create_logout_url('/')
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
		raise web.seeother('/about')

class About(Servlet):
	"""About the site page."""
	url_base = 'about'

	def GET(self):
		context = self.context()
		return render.about(**context)

class Tree(Servlet):
	"""Full page which loads javascript app."""
	url_base = 'tree'

	def GET(self):
		return render.tree(self.context())

class NodeServlet(Servlet):
	url_base = 'node'
	action = '([^/]*)'


	def PUT(self, key):
		"""PUT called to save an existing node."""
		user = users.get_current_user()
		# TODO: handle errors?
		new_node = json.dec(web.data())
		# Check old node belongs to this user
		old_node = models.Node.get(new_node.key())
		assert old_node.user == user
		new_node.put()
		# Remove reference to children since these should be transient
		# and sending them back after a save request confuses the 
		# client and causes duplicate child nodes.
		new_node.children = None 
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
				node = models.Node.new_for_user(user, 
					{'value':'root', 'root_node': True}
				)
				node.put()
		else:
			node = models.Node.get_with_children(key)
			if not node or node.user != user:
				raise web.notfound()

		return json.enc(node)

	def POST(self, key):
		"""POST called to create a new node."""
		assert not key
		user = users.get_current_user()
		# TODO: handle errors?
		node_data = json.dec(web.data())
		assert not node_data.get('key')

		logging.info("New Node: %r" % node_data)
		new_node = models.Node.new_for_user(user, node_data)
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



