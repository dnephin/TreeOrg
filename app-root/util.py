import datetime
import time
from google.appengine.ext import db
from google.appengine.api import users

try:
	import simplejson as json
except:
	import json


class GaeJsonEncoder(json.JSONEncoder):

	def default(self, obj):

		if hasattr(obj, '__json__'):
			return obj.__json__()

		if isinstance(obj, db.GqlQuery):
			return list(obj)

		if isinstance(obj, db.Model):
			properties = obj.properties().iteritems()
			output = {
				'key': str(obj.key()),
				'__type': 'db.Model',
				'__model_type': obj.kind()
			}
			for field, value in properties:
				output[field] = self.default(getattr(obj, field))
			return output

		if isinstance(obj, datetime.datetime):
			output = {
				'__type': 'datetime.datetime'
			}
			fields = ['day', 'hour', 'microsecond', 'minute', 'month', 'second', 'year']
			methods = ['ctime', 'isocalendar', 'isoformat', 'isoweekday']
			for field in fields:
				output[field] = getattr(obj, field)
			for method in methods:
				output[method] = getattr(obj, method)()
			output['epoch'] = time.mktime(obj.timetuple())
			return output

		if isinstance(obj, time.struct_time):
			return list(obj)

		if isinstance(obj, users.User):
			output = {
				'__type': 'db.User'
			}
			methods = ['nickname', 'email', 'auth_domain']
			for method in methods:
				output[method] = getattr(obj, method)()
			return output

		return obj

json_encoder = GaeJsonEncoder()
