import web
from web.utils import storage
from web.webapi import debug, ctx

from google.appengine.api import users
from google.appengine.ext import db

from treeorg.web import util
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
		

class Main(Servlet):
	"""Main index page."""
	url_base = ''

	def GET(self):
		user = users.get_current_user()
		if user:
			return render.index(storage(user=user))
		raise web.seeother(users.create_login_url(ctx.path))

class Tree(Servlet):
	"""Full page which loads javascript app."""
	url_base = 'tree'

	# TODO: logged in decorator
	def GET(self):
		user = users.get_current_user()
		return render.tree(storage(user=user))

class NodeServlet(Servlet):
	url_base = 'node'

class NodeSave(NodeServlet):
	action = 'save'

	# TODO: filter reserved kwargs (key_name, id, parent, etc)

	# TODO: logged in decorator
	def POST(self):
		user = users.get_current_user()
		# TODO: handle errors?
		new_node = util.json_dec(web.data())
		# Check old node belongs to this user
		old_node = models.Node.get(new_node.key())
		assert old_node.user == user
		new_node.put()
		return util.json_enc(new_node)

class NodeGet(NodeServlet):
	action = 'get'

	# TODO: logged in decorator
	def GET(self):
		user = users.get_current_user()
		params = web.input(node=None)

		if not params.node:
			query = models.Node.all()
			query.filter('user =', user)
			query.filter('root_node =', True)
			node = query.fetch(limit=1)

			# First visit
			if not node:
				node = models.Node.for_user(user, value='root', root_node=True)
				node.put()
			else:
				node = node[0]
		else:
			node = models.Node.get(params.node)
			if not node or node.user != user:
				raise web.notfound()

		return util.json_enc(node)

class NodeDelete(NodeServlet):
	action = 'delete'

	def POST(self):
		pass


