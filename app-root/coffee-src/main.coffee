
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
		events["click " + viewId + " .removeme"] = 'delete'
		events["mouseover " + viewId] = 'showButtons'
		events["mouseout " + viewId] = 'hideButtons'
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

	delete: (e) ->
		console.log("remove[#{@model.get('value')}]")
		@state.delete(e)

	showButtons: (e) ->
		@state.showButtons(e)

	hideButtons: (e) ->
		@state.hideButtons(e)


class NodeController

	loadRoot: () ->
		node = new Node
		nodeView =  new NodeView model: node, state: NodeState.open
		$('#container').append(nodeView.el)
		# TODO: query param to set depth
		node.fetch( data: {depth: 3} )


window.nodeController = new NodeController

$(document).ready( ->
	# Load the root node
	nodeController.loadRoot()
)
