
class NodeStateBase
	###
	 Base class for all NodeStates
	###
	
	className: ''

	allStateClassNames: 'node_open node_closed node_empty'
	
	constructor: (@view, @parentView) ->
		@model = @view.model
		@el = @view.el

	render: ->
		cc = @buildChildContainer()
		div = $(@view.make('div', class: 'disp', id: @view.cid))
			.removeClass(@allStateClassNames).addClass(@className)
			.append(@buildValue())
			.append(@buildFocusButton())
			.append(@buildRemoveButton())
		$(@el).html(div)
		$(@el).append(cc)
		return $(@el)

	update: (callback) ->
		@model.set {'value': @select('value').val()},{silent: true}
		options = {}
		options.success = callback if callback
		@model.save({}, options)

	focus: (e) ->
		e.preventDefault() if e

	delete: (e) ->
		e.preventDefault() if e
		@model.destroy()
		@view.remove()

	showButtons: (e) ->
		@select('focus').show()
		# TODO: does with this in keyboard refactor
#		@select('remove').show()
		@view.$('> .disp').addClass('active')

	hideButtons: (e) ->
		@select('focus').clearQueue().hide()
		@select('remove').clearQueue().hide()
		@view.$('> .disp').removeClass('active')

	buildValue: ->
		$('<input type="text">').addClass('value').val(@model.get('value'))

	buildFocusButton: ->
		el = @select('focus')
		disp = if el.length then el else $('<a href="#">').hide()
		disp.html('-&gt;&gt;').addClass('focusme button').removeClass('flip_text')

	buildRemoveButton: ->
		if @model.get('root_node')
			''
		else
			$('<a href="#">x</a>').addClass('removeme button')

	buildChildContainer: -> ''

	select: (ele) ->
		switch ele
			when 'value' then @view.$(' > .disp > .value')
			when 'focus' then @view.$(' > .disp > .focusme')
			when 'remove' then @view.$(' > .disp > .removeme')
			when 'child_container' then @view.$(' > .child_container')


class NodeStateOpen extends NodeStateBase
	###
	 A parent node that has been opened already.
	###

	className: 'node_open'

	addChildToDom: (child) ->
		@select('child_container').append(child)

	focus: (e) ->
		super e
		@view.changeState NodeState.closed
		@view.render()

	render: (e) ->
		super e
		@buildChildren()
		@buildEmptyNode()
		return $(@el)

	buildFocusButton: ->
		super().html('&lt;&lt;-').addClass('flip_text')

	buildEmptyNode: ->
		emptyNode = new NodeView(
			state: NodeState.empty
			parentView: @view
		)
		@addChildToDom(emptyNode.render())
		emptyNode.state.select('value').focus()

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

	className: 'node_closed'

	focus: (e) ->
		super e
		@view.changeState NodeState.open
		@view.state.render()


class NodeStateEmpty extends NodeStateBase
	###
	 An empty node that will become a new node when a value is set.
	###
	
	className: 'node_empty'

	constructor: ->
		super
		@model = @parentView.model.getEmptyChild()
		@view.model = @model

	update: ->
		@view.changeState NodeState.closed
		# Wait for save to complete to build the new empty
		super =>
			@parentView.state.buildEmptyNode()

	delete: (e) ->

	# Empty node does not have a focus or remove  button
	buildFocusButton: ->
	buildRemoveButton: ->

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


