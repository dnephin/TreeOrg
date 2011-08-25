

class NodeView extends Backbone.View

	tagName: 'div'

	className: 'node default_display'

	initialize: (options) =>
		@model.bind('change', @render)
		@model.view = this

	events: 
		'change .value': "update",

	render: =>
		$(@el).html( @build_value() )
		@build_children()
		return this

	build_value: ->
		$("""<input type="text" value="#{@model.get('value')}">""")
			.addClass('value')

	build_children: ->
		for child in @model.get('children')
				$(@el).after $("<div>")

		$(@el).after $('<div>')

	update: ->
		@model.set 'value': $(@el).children('.value').val()
		@model.save()


class ChildNodeView extends Backbone.View

	tagName: 'div'

	className: 'node default_child_node'

	initialize: (options) =>
		@parent = options.parent
		@model.view = this
	
	render: =>
		$(el).html(@model.value)

class Node extends Backbone.Model

	urlRoot: '/node/'

	fetch: (options) ->
		options || (options = {});
		options.success = => @id = @get('key').key
		super options

	url: ->
		base = @urlRoot
		return base if @isNew() 
		return base + encodeURIComponent(@id)


class NodeCollection extends Backbone.Collection

	model: Node

	load: (key) ->
		data = if key then {id: key} else {}
		node = new @model data
		node_view = new NodeView model: node

		node.fetch()
		@add(node)
		# TODO: where to tack this onto the DOM
		$('body').append(node_view.el)



window.node = new Node {}
window.node_collection = new NodeCollection

$(document).ready( ->
	# Load the root node
	node_collection.load()
)
