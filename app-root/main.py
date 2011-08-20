import web
from web.utils import storage
from web.webapi import debug, ctx
from google.appengine.api import users
from google.appengine.ext import db

import data
import util

urls = (
	'/',				'Main',
	'/tree',			'Tree',

	'/node/save',		'NodeSave',
	'/node/get',		'NodeGet',
	'/node/delete',		'NodeDelete',
)

render = web.template.render('templates/', base='base')
app = web.application(urls, globals())


class Main(object):
	"""Main index page."""
	def GET(self):
		user = users.get_current_user()
		if user:
			return render.index(storage(user=user))
		raise web.seeother(users.create_login_url(ctx.path))

class Tree(object):
	"""Full page which loads javascript app."""

	# TODO: logged in decorator
	def GET(self):
		user = users.get_current_user()
		return render.tree(storage(user=user))

class NodeServlet(object):
	pass

class NodeSave(NodeServlet):

	# TODO: filter reserved kwargs (key_name, id, parent, etc)

	# TODO: logged in decorator
	def POST(self):
		user = users.get_current_user()
		# TODO: handle errors?
		new_node = util.json_dec(web.data())
		# Check old node belongs to this user
		old_node = data.Node.get(new_node.key())
		assert old_node.user == user
		new_node.put()
		return util.json_enc(new_node)

class NodeGet(NodeServlet):

	# TODO: logged in decorator
	def GET(self):
		user = users.get_current_user()
		params = web.input(node=None)

		if not params.node:
			query = data.Node.all()
			query.filter('user =', user)
			query.filter('root_node =', True)
			node = query.fetch(limit=1)

			# First visit
			if not node:
				node = data.Node.for_user(user, value='root', root_node=True)
				node.put()
			else:
				node = node[0]
		else:
			node = data.Node.get(params.node)
			if not node or node.user != user:
				raise web.notfound()

		return util.json_enc(node)

NodeUpdate = NodeDelete = NodeGet


if __name__ == "__main__":
	app.cgirun()
