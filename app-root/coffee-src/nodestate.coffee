
class NodeStateBase
	###
	 Base class for all NodeStates
	###
	
	className: ''
	allStateClassNames: 'node_open node_closed node_empty'
	removeButtonClass: 'ui-icon-close'
	toggleButtonClass: 'ui-icon-arrowthick-1-se'
	
	
	constructor: (@view, @parentView) ->
		@model = @view.model
		@el = @view.el

	render: ->
		cc = @buildChildContainer()
		div = $(@view.make('div', class: 'disp clearfix', id: @view.cid))
			.removeClass(@allStateClassNames).addClass(@className)
			.append(@buildValue())
			.append(@buildOptionButton())
		$(@el).html(div)
		$(@el).append(cc)
		return $(@el)

	update: (callback) ->
		@model.set {'value': @select('value').val()},{silent: true}
		options = {}
		options.success = callback if callback
		@model.save({}, options)

	toggle: (e) ->
		e.preventDefault() if e

	delete: (e) ->
		e.preventDefault() if e
		@model.destroy()
		@view.remove()

	hoverOver: (e) ->
		@select('disp').addClass('active')
		@select('option').show()

	hoverOut: (e) ->
		# TODO: better selector
		rel = $(e.relatedTarget)
		if rel.parent().hasClass('node') and rel.prev().attr('id') == @view.cid
			return
		@select('disp').removeClass('active')
		@select('option').hide()
		# TODO: this breaks because mouseoff the button triegers hoverOut
		#@select('options').remove()

	showOptions: (e) ->
		# toggle display
		@select('options').remove().length or
			@select('disp').after(@buildOptionsBar())

	buildOptionButton: ->
		@buildButton('ui-icon-gear')
			.attr('title', 'options')
			.addClass('options-button')
			.hide()

	buildButton: (type) ->
		makeButton(
			$(@view.make('a', class: 'ui-state-default ui-corner-all', href: '#'))
			.append(@view.make('span', class: "ui-icon #{type}"))
		)

	buildOptionsBar: ->
		removeButton = @buildButton(@removeButtonClass)
			.click( (e) => @delete(e) )
		toggleButton = @buildButton(@toggleButtonClass)
			.click( (e) => @toggle(e) )
		$(@view.make('div', class: 'options-bar'))
			.append(toggleButton)
			.append(removeButton)
			.mouseleave( => @select('options').remove() )

	buildValue: ->
		$('<input type="text">').addClass('value').val(@model.get('value'))

	buildChildContainer: -> ''

	select: (ele) ->
		switch ele
			when 'value' then @view.$(' > .disp > .value')
			when 'child_container' then @view.$(' > .child_container')
			when 'disp' then @view.$(' > .disp')
			when 'option' then @view.$(' > .disp > .options-button')
			when 'options' then @view.$(' > .options-bar')


class NodeStateOpen extends NodeStateBase
	###
	 A parent node that has been opened already.
	###

	className: 'node_open'
	toggleButtonClass: 'ui-icon-arrowthick-1-nw'

	addChildToDom: (child) ->
		@select('child_container').append(child)

	toggle: (e) ->
		super e
		@view.changeState NodeState.closed
		@view.render()

	render: (e) ->
		super e
		@buildChildren()
		@buildEmptyNode()
		return $(@el)


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
		$('<div>').addClass('child_container clearfix')


class NodeStateClosed extends NodeStateBase
	###
	 A parent node in closed state.
	###

	className: 'node_closed'

	toggle: (e) ->
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

	buildOptionButton: ->

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


