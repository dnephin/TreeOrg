import datetime
import time
import web
try:
	from google.appengine.ext import db
	from google.appengine.api import users
except:
	pass

try:
	import simplejson as _json
except:
	import json as _json

from treeorg.web import models


class GaeJsonEncoder(_json.JSONEncoder):

	def __init__(self, filter=None, **kwargs):
		self.filter = set(filter or [])
		super(GaeJsonEncoder, self).__init__(**kwargs)

	def default(self, obj):

		if hasattr(obj, '____'):
			return obj.____()

		if isinstance(obj, db.GqlQuery):
			return list(obj)

		if isinstance(obj, db.Model):
			for f in self.filter:
				if isinstance(obj, f):
					return None

			properties = obj.properties().iteritems()
			output = {
				'key': self.default(obj.key()),
				'__type': 'db.Model',
				'__model_type': obj.kind()
			}
			for field, value in properties:
				output[field] = self.default(getattr(obj, field))
			return output

		if isinstance(obj, db.Key):
			if db.Key in self.filter:
				return
			return {'__type': 'db.Key', 'key': str(obj)}

		if isinstance(obj, datetime.datetime):
			output = {
				'__type': 'datetime.datetime'
			}
			fields = ['day', 'hour', 'microsecond', 'minute', 'month', 'second', 'year']
			methods = ['ctime', 'isocalendar', 'isoformat', 'isoweekday', 'timetuple']
			for field in fields:
				output[field] = getattr(obj, field)
			for method in methods:
				output[method] = getattr(obj, method)()
			output['epoch'] = time.mktime(obj.timetuple())
			return output

		if isinstance(obj, time.struct_time):
			return list(obj)

		if isinstance(obj, users.User):
			if users.User in self.filter:
				return
			output = {
				'__type': 'user.User'
			}
			methods = ['nickname', 'email', 'auth_domain']
			for method in methods:
				output[method] = getattr(obj, method)()
			return output

		return obj


__model_module=models

def decode_object_hook(obj):

	obj_type = obj.get('__type')

	if obj_type == 'db.Model':
		model_type = obj['__model_type']
		cls = getattr(models, model_type)
		del obj['__type']
		del obj['__model_type']
		# Fix for unicode kwargs
		if hasattr(cls, 'from_dict'):
			return cls.from_dict(obj)
		return cls(**obj)

	if obj_type == 'datetime.datetime':
		dt = datetime.datettime.fromtimestamp(tuple(obj['epoch']))
		dt.microsecond = obj['microsecond']
		return dt

	if obj_type == 'user.User':
		return None

	if obj_type == 'db.Key':
		return db.Key(obj['key'])
	
	return obj

__gae__encoder_filtered = GaeJsonEncoder(filter=[users.User])
__gae__encoder_raw = GaeJsonEncoder()
__gae__decoder = _json.JSONDecoder(object_hook=decode_object_hook)
__gae__decoder_raw = _json.JSONDecoder()


def enc(obj, filter_user=True):
	"""Encode an object as a  string. Supports Google App Engine objects
	and users.
	"""
	if not filter_user:
		return __gae__encoder_raw.encode(obj)
	return __gae__encoder_filtered.encode(obj)

def dec(s, build_objects=True):
	"""Decode a JSON string and build Google App engine model objects."""
	if not build_objects:
		return __gae__decoder_raw.decode(s)
	return __gae__decoder.decode(s)



