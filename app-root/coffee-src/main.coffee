

class NodeView extends Backbone.View

	tagName: 'div'

	className: 'node default_display'

	initialize: (options) ->
		@model.bind('change', @render)
		@model.view = this
		super options

	events:
		'change .value': "update",

	render: =>
		$(@el).html(@build_value())

	build_value: ->
		$("""<input type="text">""")
			.addClass('value')
			.val(@model.get('value'))

	update: ->
		@model.set 'value': $(@el).children('.value').val()
		@model.save()


class ParentNodeView extends NodeView

	render: =>
		$(@el).html(@build_value())
		@build_children()
		@build_empty_node()
		return @el

	build_children: ->
		for child_node in @model.get('children')
			child_view = new ChildNodeView model: new Node child_node
			@add_child_to_dom(child_view.render())
			child_view

	build_empty_node: ->
		empty_node = new EmptyNodeView parent_view: this
		@add_child_to_dom(empty_node.render())
		empty_node

	add_child_to_dom: (child) ->
		$(@el).parent().append(child)


class EmptyNodeView extends NodeView

	initialize: (options) ->
		@model = new Node(
			parent_node: options.parent_view.model.get('key')
		)
		super options

	# TODO: replace with ChildNode after save

class ChildNodeView extends NodeView

	className: 'node child_display'


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
		node_view = new ParentNodeView model: node
		$('body').append(node_view.el)
		node.fetch()


window.node_controller = new NodeController

$(document).ready( ->
	# Load the root node
	node_controller.load_root()
)
