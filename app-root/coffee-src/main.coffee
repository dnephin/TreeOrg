
class NodeStateBase

	constructor: (@view, @parent_view) ->
		@model = @view.model
		@el = @view.el

	render: =>
		$(@el).html(@build_value())

	update: ->
		@model.set 'value': $(@el).children('.value').val()
		@model.save()

	focus: ->

	build_value: ->
		$("""<input type="text">""")
			.addClass('value')
			.val(@model.get('value'))


class NodeStateParent extends NodeStateBase

	render: =>
		super
		@build_children()
		@build_empty_node()
		return @el

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

	add_child_to_dom: (child) ->
		$(@el).parent().append(child)


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

class NodeStateChild extends NodeStateBase


window.NodeState =
	# Enumeration of states taken by a NodeView
	
	active: null
	parent: NodeStateParent
	child: NodeStateChild
	empty: NodeStateEmpty


class NodeView extends Backbone.View

	tagName: 'div'

	className: 'node default_display'

	initialize: (options) =>
		# select Impl for state
		options.state or= NodeState.parent
		@state = new options.state(this, options.parent_view)

		@model.bind('change', @render)
		@model.view = this
		super options

	events:
		'change .value': 'update',
		'focus': 'focus',

	update: ->
		@state.update()

	render: =>
		@state.render()

	focus: ->
		@state.focus()


class Node extends Backbone.Model

	urlRoot: '/node/'

	initialize: (options) ->
		if options.key
			@id = options.key.key

	fetch: (options) ->
		options or= {}
		options.success = => @id = @get('key').key
		super options

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
