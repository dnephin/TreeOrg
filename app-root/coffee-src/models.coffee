
class Node extends Backbone.Model
	###
	 Node Model
	###

	urlRoot: '/node/'

	initialize: (data) ->
		@childrenLoaded = false
		@childCollection = new NodeCollection
		if data.key
			@id = data.key.key

	parse: (resp, xhr) ->
		@id = resp.key.key
		if resp.children
			@loadChildren resp.children
			resp.children = null
				
		return resp

	url: ->
		base = @urlRoot
		return base if @isNew()
		return base + encodeURIComponent(@id)

	childrenUrl: ->
		'/children/' + encodeURIComponent(@id)

	loadChildren: (children) ->
		@childrenLoaded = true
		@childCollection.add(children)
		@childCollection.each (node) ->
			cchildren = node.get('children')
			if cchildren
				node.loadChildren(cchildren)
	
	fetchChildren: ->
		children = null
		$.ajax(
			type: 'GET'
			dataType: 'json'
			contentType: 'application/json'
			url: @childrenUrl()
			async: false
			success: (data, textStatus, xhr) ->
				children = data
		)
		return children

	getChildren: ->
		###
		 Return all existing children (not empty) and load them if necessary.
		###
		if not @childrenLoaded
			children = @fetchChildren()
			@loadChildren(children)

		@childCollection.filter( (n) -> not n.isNew() )

	getEmptyChild: ->
		empty = @childCollection.find( (n) -> n.isNew() )
		if empty
			return empty

		new_child = new Node pNode: @get('key')
		@childCollection.add(new_child)
		return new_child

	save: (atrs, options) ->
		# This is a back to prevent new nodes from being overwritten 
		# because the response has not yet returned from the server.
		# TODO: Need a beter way to handle this.
		super atrs, options
		@id = 'pending' if @isNew

	destroy: (options) ->
		super options
		# TODO: this should be handled by success callback, but it is not firing
		@collection.remove(this)


class NodeCollection extends Backbone.Collection

	model: Node

