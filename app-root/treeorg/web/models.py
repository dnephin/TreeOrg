from google.appengine.ext import db


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
	# time created
	# time updated
	
	#display = db.ReferenceProperty()

#	@classmethod
#	def key(cls, name=None):
#		return db.Key.from_path(cls.__name__, name or 'Unknown')

	@classmethod
	def new_for_user(cls, user, **kwargs):
		return cls(user=user, **kwargs)

	@classmethod
	def get_with_children(cls, key):
		node = cls.get(key)
		node.children = cls.get_children(node.key())
		for child in node.children:
			assert child.user == node.user
		return node

	@classmethod
	def get_root_for_user(cls, user):
		query = cls.all()
		query.filter('user =', user)
		query.filter('root_node =', True)
		node = query.get()
		if not node:
			return

		node.children = cls.get_children(node.key())
		return node

	@classmethod
	def get_children(cls, key):
		query = cls.all()
		query.filter('parentNode =', key)
		return list(query)

