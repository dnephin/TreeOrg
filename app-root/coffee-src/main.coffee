
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

	buildChildContainer: -> ''
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

	render: (e) ->
		super e
		@buildChildren()
		@buildEmptyNode()
		return $(@el)

	buildChildren: ->
		for childNode in @model.getChildren()
			childView = new NodeView(
				model: childNode
				parentView: @view
			)
			@addChildToDom(childView.render())

	buildChildContainer: ->
		$('<div>').addClass('child_container')


class NodeStateClosed extends NodeStateBase
	###
	 A parent node in closed state.
	###

	focus: (e) ->
		super e
		# TODO: This needs to be atomic, is it ?
		@view.changeState NodeState.open
		@view.state.render()

	buildChildContainer: -> ''

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
			@state = new NodeState.open this
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
			console.log("update[#{@model.get('value')}] cancelled (already changing)")
			return
		console.log("update[#{@model.get('value')}]")
		@isChanging = true
		@state.update(e)
		@isChanging = false

	render: (e) =>
		console.log("render[#{@model.get('value')}]")
		@state.render(e)

	focus: (e) ->
		console.log("focus[#{@model.get('value')}]")
		@state.focus(e)


class NodeController

	loadRoot: () ->
		node = new Node
		nodeView =  new NodeView model: node, state: NodeState.open
		$('#container').append(nodeView.el)
		node.fetch( data: {depth: 4} )
		window.node = node


window.nodeController = new NodeController

$(document).ready( ->
	# Load the root node
	nodeController.loadRoot()
)
