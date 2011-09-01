
class NodeStateBase

	constructor: (@view, @parent_view) ->
		@model = @view.model
		@el = @view.el

	render: =>
		$(@el)
			.html(@build_value())
			.append(@build_focus_button())

	update: ->
		@model.set 'value': @select('value').val()
		@model.save()

	focus: (e) ->
		if e
			e.preventDefault()

	build_value: ->
		$('<input type="text">')
			.addClass('value')
			.val(@model.get('value'))

	build_focus_button: ->
		$('<a href="#">v</a>').addClass('focusme')

	select: (ele) ->
		switch ele
			when 'value' then $(@el).children('.value')
			when 'focus' then $(@el).children('.focusme')
			when 'child_container' then $(@el).next('.child_container')


class NodeStateParent extends NodeStateBase

	focus: (e) ->
		super e
		@build_children()
		@build_empty_node()

	render: (e) ->
		super e
		$(@el).after($('<div>').addClass('child_container'))

	build_children: ->
		for child_node in @model.get('children')
			child_view = new NodeView(
				model: new Node(child_node)
				state: NodeState.child
				parent_view: @view
			)
			@add_child_to_dom(child_view.render())

	build_empty_node: ->
		empty_node = new NodeView(
			state: NodeState.empty
			parent_view: @view
		)
		@add_child_to_dom(empty_node.render())
		empty_node.state.select('value').focus()

	add_child_to_dom: (child) ->
		@select('child_container').append(child)


class NodeStateActive extends NodeStateParent

	render: (e) ->
		super e
		@focus()


class NodeStateEmpty extends NodeStateBase

	constructor: ->
		super
		@model = new Node(
			parent_node: @parent_view.model.get('key')
		)
		@view.model = @model

	update: ->
		super
		@view.state = new NodeState.child(@view)
		# This assumes a lot...
		@parent_view.state.build_empty_node()

	# Empty node does not have a focus button
	build_focus_button: ->

	build_value: ->
		$('<input type="text">')
			.addClass('value')

class NodeStateChild extends NodeStateBase


window.NodeState =
	# Enumeration of states taken by a NodeView
	
	active: NodeStateActive
	parent: NodeStateParent
	child: NodeStateChild
	empty: NodeStateEmpty


class NodeView extends Backbone.View

	tagName: 'div'

	className: 'node default_display'

	initialize: (options) =>
		# select Impl for state
		options.state or= NodeState.active
		@state = new options.state(this, options.parent_view)

		@model.bind('change', @render)
		@model.view = this
		@is_changing = false
		super options

	events:
		'change .value': 'update',
		'click .focusme': 'focus',

	update: (e) ->
		# is_changing deals with a problem where hitting <enter> causes the
		# change event to fire twice.  This limits the event to firing once.
		if @is_changing
			return
		@is_changing = true
		@state.update(e)
		@is_changing = false

	render: (e) =>
		@state.render(e)

	focus: (e) ->
		@state.focus(e)


class Node extends Backbone.Model

	# TODO: track if children are loaded, and load when it hasn't attmpted to

	urlRoot: '/node/'

	initialize: (data) ->
		if data.key
			@id = data.key.key

	parse: (resp, xhr) ->
		@id = resp.key.key
		return resp

	url: ->
		base = @urlRoot
		return base if @isNew()
		return base + encodeURIComponent(@id)


class NodeController

	load_root: () ->
		node = new Node
		node_view = new NodeView model: node
		$('body').append(node_view.el)
		node.fetch()


window.node_controller = new NodeController

$(document).ready( ->
	# Load the root node
	node_controller.load_root()
)
