

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
		for child_view in @build_children()
			$(@el).after(child_view.render())
		return @el

	build_children: ->
		@children = []
		for child_node in @model.get('children')
			@children.push(new ChildNodeView
				model: new Node child_node
			)

		@children.push(new EmptyNodeView parent_view: this)
		return @children


class EmptyNodeView extends NodeView

	initialize: (options) ->
		@model = new Node(
			parent_node: options.parent_view.model.get('key')
		)
		super options

class ChildNodeView extends NodeView

	className: 'node child_display'


class Node extends Backbone.Model

	urlRoot: '/node/'

	fetch: (options) ->
		options || (options = {})
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
