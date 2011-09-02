
class NodeStateBase
	###
	 Base class for all NodeStates
	###

	constructor: (@view, @parentView) ->
		@model = @view.model
		@el = @view.el

	render: =>
		$(@el)
			.html(@buildValue())
			.append(@buildFocusButton())

	update: ->
		@model.set 'value': @select('value').val()
		@model.save()

	focus: (e) ->
		if e
			e.preventDefault()

	buildValue: ->
		$('<input type="text">')
			.addClass('value')
			.val(@model.get('value'))

	buildFocusButton: ->
		$('<a href="#">v</a>').addClass('focusme')

	select: (ele) ->
		switch ele
			when 'value' then $(@el).children('.value')
			when 'focus' then $(@el).children('.focusme')
			when 'child_container' then $(@el).next('.child_container')


class NodeStateParent extends NodeStateBase
	###
	 A parent node that has been opened already.
	###

	addChildToDom: (child) ->
		@select('child_container').append(child)

	focus: (e) ->
		super e
		@select('child_container').remove()
		@view.changeState NodeState.closed
		@view.render()

	buildFocusButton: ->
		$('<a href="#">^</a>').addClass('focusme')

	buildEmptyNode: ->
		emptyNode = new NodeView(
			state: NodeState.empty
			parentView: @view
		)
		@addChildToDom(emptyNode.render())
		emptyNode.state.select('value').focus()

class NodeStateOpen extends NodeStateParent
	###
	 A parent node opening.
	###

	render: (e) ->
		super e
		$(@el).after($('<div>').addClass('child_container'))
		@buildChildren()
		@buildEmptyNode()
		@view.changeState NodeState.parent

	buildChildren: ->
		for childNode in @model.getChildren()
			continue if childNode.isNew()
			childView = new NodeView(
				model: childNode
				state: NodeState.closed
				parentView: @view
			)
			@addChildToDom(childView.render())


class NodeStateClosed extends NodeStateBase
	###
	 A parent node in closed state.
	###

	focus: (e) ->
		super e
		@view.changeState NodeState.open
		@view.render()


class NodeStateEmpty extends NodeStateBase
	###
	 An empty node that will become a new node when a value is set.
	###

	constructor: ->
		super
		@model = @parentView.model.getEmptyChild()
		@view.model = @model

	update: ->
		@view.changeState NodeState.closed
		super
		# This is messy... and broken
		@parentView.state.buildEmptyNode()

	# Empty node does not have a focus button
	buildFocusButton: ->

	buildValue: ->
		$('<input type="text">').addClass('value')


window.NodeState =
	# Enumeration of states taken by a NodeView
	
	open: NodeStateOpen
	parent: NodeStateParent
	closed: NodeStateClosed
	empty: NodeStateEmpty


class NodeView extends Backbone.View

	tagName: 'div'

	className: 'node default_display'

	initialize: (options) =>
		# select Impl for state
		options.state or= NodeState.open
		@state = new options.state(this, options.parentView)

		@model.bind('change', @render)
		@model.view = this
		@isChanging = false
		super options

	changeState: (state) ->
		@state = new state(this)

	events:
		'change .value': 'update',
		'click .focusme': 'focus',

	update: (e) ->
		# isChanging deals with a problem where hitting <enter> causes the
		# change event to fire twice.  This limits the event to firing once.
		if @isChanging
			return
		@isChanging = true
		@state.update(e)
		@isChanging = false

	render: (e) =>
		@state.render(e)

	focus: (e) ->
		@state.focus(e)


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
		# This may be super broken
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
			new Node child

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
		if not @childrenLoaded
			children = @fetchChildren()
			@set({children: @loadChildren children}, {silent: true})
			
		if not @get('children')
			@set({children: []}, {silent: true})

		return @get('children')

	getEmptyChild: ->
		last = _.last(@getChildren())
		if last and last.isNew()
			return last
		new_child = new Node parentNode: @get('key')
		@getChildren().push(new_child)
		return new_child


class NodeController

	loadRoot: () ->
		node = new Node
		nodeView = new NodeView model: node
		$('body').append(nodeView.el)
		node.fetch()


window.nodeController = new NodeController

$(document).ready( ->
	# Load the root node
	nodeController.loadRoot()
)
