
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


class StatusBar extends Backbone.View

	allClasses: 'working done error'

	render: =>
		$(@el).attr('id', 'status_bar').hide()

	action: (text, addClassName) ->
		$(@el)
			.stop(true, true)
			.html(text)
			.removeClass(@allClasses)
			.addClass(addClassName)
			.show()

	working: ->
		@action('working...', 'working')

	done: ->
		@action('done', 'done').delay(800).fadeOut(1000)

	error: ->
		@action('error!', 'error')

	attach: (parent) ->
		parent or= $('body')
		parent.append(@render())
		return this
		

class NodeController

	loadRoot: () ->
		node = new Node
		@nodeView =  new NodeView model: node, state: NodeState.open
		$('#container').append(@nodeView.el)
		depth = parseUrlSearch().depth or 3
		node.fetch( data: {depth: depth} )


parseUrlSearch = ->
	query = document.location.search.substring(1)
	params = {}
	for pair in query.split('&')
		parts = pair.split('=')
		params[parts[0]] = parts[1]
	return params

setupButtons = ->
	$('.ui-state-default').hover(
		-> $(this).addClass('ui-state-hover')
		-> $(this).removeClass('ui-state-hover').removeClass('ui-state-active')
	)
	.mousedown( -> $(this).addClass('ui-state-active'))
	.mouseup( -> $(this).removeClass('ui-state-active'))

	$('#menu_bar A[refresh]').click( (e) ->
		e.preventDefault()
		nodeController.nodeView.remove()
		nodeController.loadRoot()
	)

$(document).ready( ->
	window.nodeController = new NodeController
	# Load the root node
	nodeController.loadRoot()
	# Create the status bar
	window.status_bar = new StatusBar().attach()
	
	setupButtons()
)
