

from collections import defaultdict 
from operator import attrgetter

def build_map_lists(seq, key_func=attrgetter('key')):
	m = defaultdict(list)
	for item in seq:
		m[key_func(item)].append(item)
	return m
	




