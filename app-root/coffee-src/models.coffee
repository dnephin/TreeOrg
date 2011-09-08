
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
		options =
			type: 'GET'
			dataType: 'json'
			contentType: 'application/json'
			url: @childrenUrl()
			async: false
			success: (data, textStatus, xhr) ->
				children = data

		@_wrapAjax(options)
		$.ajax(options)
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

	destroy: (options) ->
		super options
		# TODO: this should be handled by success callback, but it is not firing
		@collection.remove(this)

	_wrapAjax: (options) ->
		window.status_bar.working() if window.status_bar

		# Add success message
		success = options.success
		options.success = (data, textStatus, xhr) ->
			if window.status_bar
				window.status_bar.done()
			success(data, textStatus, xhr) if success

		# Add error message
		error = options.error
		options.error = (xhr, textStatus, err) ->
			if window.status_bar
				window.status_bar.error()
			error(xhr, textStatus, err) if error

	sync: (method, model, options) ->
		options or= {}
		@_wrapAjax(options)
		Backbone.sync(method, model, options)


class NodeCollection extends Backbone.Collection

	model: Node

