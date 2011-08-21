


class Display
	constructor: (@data, @parent) ->

	render: () ->
		ele = $("<div> #{@data.value} </div>")
		ele.addClass('node default_display')
		@parent.append(ele)


class Node
	constructor: (@parent) ->

	
	load: (key) ->
		target = if key then "?node=#key" else ""
		$.get(
			"/node/get#target",
			(data) => 
				@data = data
				@display()
			,
			'json'
		)

	save: ->
		$.post(
			"/node/save",
			JSON.stringify(@data),
			(data) => @data = data,
			'json'
		)

	display: () ->
		display = new Display @data, @parent
		display.render()


$(document).ready( ->
	# Load the root node
	root_node = new Node $('body')
	root_node.load()
)
