
class Node extends Backbone.Model
	###
	 Node Model
	###

	urlRoot: '/node/'

	initialize: (data) ->
		@childrenLoaded = false
		if data.key
			@id = data.key.key

	parse: (resp, xhr) ->
		@id = resp.key.key
		if resp.children
			resp.children = @loadChildren resp.children
				
		return resp

	save: (attrs, options) ->
		# Set id to pending if this is a new object
		# TODO: This may be super broken
		super attrs, options
		if @isNew()
			@id = 'pending'

	url: ->
		base = @urlRoot
		return base if @isNew()
		return base + encodeURIComponent(@id)

	childrenUrl: ->
		'/children/' + encodeURIComponent(@id)

	loadChildren: (children) ->
		@childrenLoaded = true
		for child in children
			node = new Node child
			cchildren = node.get('children')
			if cchildren
				cnodes = node.loadChildren(cchildren)
				node.set({'children': cnodes}, silent: true)
			node
	
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
		 Return all existing children (not empty) and load them if neessary.
		###
		if not @childrenLoaded
			children = @fetchChildren()
			@set({children: @loadChildren children}, silent: true)
			
		for child in @get('children')
			if not child.isNew()
				child

	getEmptyChild: ->
		last = _.last(@getChildren())
		if last and last.isNew()
			return last
		new_child = new Node pNode: @get('key')
		@getChildren().push(new_child)
		return new_child


