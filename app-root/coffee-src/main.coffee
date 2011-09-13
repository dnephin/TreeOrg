
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
		events["mouseover " + viewId] = 'hoverOver'
		events["mouseout " + viewId] = 'hoverOut'
		events["click " + viewId + ' .options-button'] = 'showOptions'
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

	hoverOver: (e) ->
		@state.hoverOver(e)

	hoverOut: (e) ->
		@state.hoverOut(e)

	showOptions: (e) ->
		@state.showOptions(e)


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

setupButtons = (container) ->
	container or= $('body')
	makeButton(container.find('.ui-state-default'))
	$('#menu_bar A[refresh]').click( (e) ->
		e.preventDefault()
		nodeController.nodeView.remove()
		nodeController.loadRoot()
	)

makeButton = (selector) ->
	selector.hover(
		-> $(this).addClass('ui-state-hover')
		-> $(this).removeClass('ui-state-hover').removeClass('ui-state-active')
	)
	.mousedown( -> $(this).addClass('ui-state-active'))
	.mouseup( -> $(this).removeClass('ui-state-active'))


$(document).ready( ->
	window.nodeController = new NodeController
	# Load the root node
	nodeController.loadRoot()
	# Create the status bar
	window.status_bar = new StatusBar().attach()
	
	setupButtons()
)
