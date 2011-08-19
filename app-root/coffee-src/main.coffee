


class Display
	constructor: () ->


class Node
	constructor: (@data) ->

	
	load: (key) ->
		$.get(
			"/node/get?node=#key",
			(data) => @data = data,
			'json'
		)

	save: ->
		$.post(
			"/node/save",
			JSON.stringify(@data),
			(data) => @data = data,
			'json'
		)


window.node = new Node {1:2}
