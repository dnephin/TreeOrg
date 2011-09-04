from google.appengine.ext import db
from treeorg.web import util 
from operator import attrgetter

# Replace with logging
from web import debug


class TransientProperty(db.Property):

	data_type = None

	def get_value_for_datastore(self, model_instance):
		return None

	def make_value_from_datastore(self, value):
		return None 


class Node(db.Expando):
	"""A node in the organization tree."""

	user = db.UserProperty(auto_current_user=True)
	root_node = db.BooleanProperty(default=False)
	value = db.StringProperty()
	children = TransientProperty()
	pNode = db.SelfReferenceProperty()
	active = db.BooleanProperty(default=True)
	# time created
	# time updated
	
	#display = db.ReferenceProperty()

#	@classmethod
#	def key(cls, name=None):
#		return db.Key.from_path(cls.__name__, name or 'Unknown')

	@classmethod
	def new_for_user(cls, user, **kwargs):
		"""Create a new node for the user."""
		return cls(user=user, **kwargs)

	@classmethod
	def get_with_children(cls, key):
		"""Get a node with its immediate children."""
		node = cls.get(key)
		assert node.active
		node.children = cls.get_children(node.key())
		for child in node.children:
			assert child.user == node.user
		return node

	@classmethod
	def get_root_for_user(cls, user, load_depth=1):
		"""Get the root node for a user, with children to load_depth."""
		query = cls.all()
		query.filter('user =', user)
		query.filter('root_node =', True)
		node = query.get()
		if not node:
			return

		parents = {node.key(): node}
		for _ in range(load_depth):
			children = cls.get_children(parents.keys())
			map_pkey_to_children = util.build_map_lists(
				children, 
				lambda a: str(a.pNode.key())
			)
			for key, parent in parents.iteritems():
				parent.children = map_pkey_to_children[str(key)]
			parents = dict((cnode.key(), cnode) for cnode in children)

		return node

	@classmethod
	def get_children(cls, keys):
		"""Get the children for a list of parent keys."""
		if not keys:
			return []
		query = cls.all()
		query.filter('active =', True)
		query.filter('pNode IN', keys)
		return list(query)

