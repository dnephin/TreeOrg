from google.appengine.ext import db

class Node(db.Expando):
	"""A node in the organization tree."""

	user = db.UserProperty(auto_current_user=True)
	root_node = db.BooleanProperty(default=False)
	value = db.StringProperty()
	children = db.ListProperty(db.Key)
	parent_node = db.SelfReferenceProperty()

#	@classmethod
#	def key(cls, name=None):
#		return db.Key.from_path(cls.__name__, name or 'Unknown')

	@classmethod
	def for_user(cls, user, **kwargs):
		return cls(user=user, **kwargs)
