
class NodeStateBase
	###
	 Base class for all NodeStates
	###
	
	className: ''

	allStateClassNames: 'node_open node_closed node_empty'
	
	constructor: (@view, @parentView) ->
		@model = @view.model
		@el = @view.el

#	render: =>
#		@preRender()
#		@_render()
#		@postRender()

	preRender: ->
		
		
	postRender: ->
		if @_is_first_render
			@is_first_render = false
		#	@initCss()

	render: ->
		cc = @buildChildContainer()
		div = $(@view.make('div', class: 'disp', id: @view.cid))
		#	.removeClass(@allStateclasSNames).addClass(@className)
		div.append(@buildValue())
		div.append(@buildFocusButton())
		div.append(@buildRemoveButton())
		$(@el).html(div)
		$(@el).append(cc)
		return $(@el)
	update: ->
		@model.set 'value': @select('value').val()
		@model.save()

	focus: (e) ->
		e.preventDefault() if e

	delete: (e) ->
		e.preventDefault() if e
		@model.destroy()
		@view.remove()

#	_show: (el) ->
#		el.css('display', 'block-inline')

	initCss: (selector) ->
		cssDef =
			'focus': [[display, 'none']]

		for op in cssDef[selector] or []
			@select(selector).css(op[0], op[1])

	showButtons: (e) ->
		@select('focus').show()
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
		# TODO: This needs to be atomic, is it ?
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
		super
		# This is messy... and broken
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


