
class NodeStateBase
	###
	 Base class for all NodeStates
	###

	constructor: (@view, @parentView) ->
		@model = @view.model
		@el = @view.el

	render: =>
		cc = @buildChildContainer()
		div = $(@view.make('div', class: 'disp', id: @view.cid))
		div.append(@buildValue())
		div.append(@buildFocusButton())
		$(@el).html(div)
		$(@el).append(cc)
		return $(@el)

	update: ->
		@model.set 'value': @select('value').val()
		@model.save()

	focus: (e) ->
		if e
			e.preventDefault()

	buildValue: ->
		$('<input type="text">').addClass('value').val(@model.get('value'))

	buildFocusButton: ->
		$('<a href="#">v</a>').addClass('focusme')

	buildChildContainer: ->
		if @select('child_container').length
			childContainer = @select('child_container')
		else
			childContainer = $('<div>').addClass('child_container')
		return childContainer

	select: (ele) ->
		switch ele
			when 'value' then @view.$(' > .disp > .value')
			when 'focus' then @view.$(' > .disp > .focusme')
			when 'child_container' then @view.$(' > .child_container')


class NodeStateOpen extends NodeStateBase
	###
	 A parent node that has been opened already.
	###

	addChildToDom: (child) ->
		@select('child_container').append(child)

	focus: (e) ->
		super e
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


class NodeStateOpening extends NodeStateOpen

	render: (e) ->
		super e
		@buildChildren()
		@buildEmptyNode()
		@view.changeState(NodeState.open)
		return $(@el)

	buildChildren: ->
		for childNode in @model.getChildren()
			# Don't display the empty if it's already included in children
			continue if childNode.isNew()

			childView = new NodeView(
				model: childNode
				parentView: @view
			)
			@addChildToDom(childView.render())


class NodeStateClosed extends NodeStateBase
	###
	 A parent node in closed state.
	###

	focus: (e) ->
		super e
		# TODO: This needs to be atomic, is it ?
		@view.changeState NodeState.opening
		@view.state.render()

	buildChildContainer: ->
		return ''

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


### 
	Map of name to state class which implements the
	behavior for the node while in that state.
###
window.NodeState =
	
	open: NodeStateOpen			# opening state
	opening: NodeStateOpening
	closed: NodeStateClosed		# closed state
	empty: NodeStateEmpty		# empty state


class NodeView extends Backbone.View

	tagName: 'div'

	className: 'node default_display'

	initialize: (options) =>
		# select Impl for state
		if options.state
			@state = new options.state(this, options.parentView)
		else
			@setDefaultState(@model)

		@model.bind('change', @render)
		@model.view = this
		@isChanging = false
		super options
	
	setDefaultState: (model) ->
		if model.childrenLoaded and model.getChildren().length
			@state = new NodeState.opening this
		else
			@state = new NodeState.closed this

	changeState: (state) ->
		@state = new state(this)

	events: ->
		viewId = '#' + @cid
		events = {}
		events["change " + viewId + " .value"] = 'update'
		events["click " + viewId + " .focusme"] = 'focus'
		return events

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

#	renderChildren: ->
#		for node in @model.getChildren()
#			node.view.render()


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
		if not @childrenLoaded
			children = @fetchChildren()
			@set({children: @loadChildren children})
			
		if not @get('children')
			@set({children: []}, {silent: true})

		for child in @get('children')
			if not child.isNew()
				child

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
		nodeView =  new NodeView model: node, state: NodeState.opening
		$('body').append(nodeView.el)
		node.fetch( data: {depth: 2} )
		window.node = node


window.nodeController = new NodeController

$(document).ready( ->
	# Load the root node
	nodeController.loadRoot()
)
