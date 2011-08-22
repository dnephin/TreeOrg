


class Display
	constructor: (@node, @parent) ->

	render: ->
		div = $('<div>').addClass('node default_display')
		div.append( @build_value() )
		div.after( @build_children() )
		return div

	build_value: ->
		ele = $("""<input type="text" value="#{@node.data.value}">""")
			.addClass('value')
		ele.change( (event) => 
				@node.data.value = ele.val()
				@node.save()
			)
		return ele

	build_children: ->
		children = for child in @node.data.children
				$("<div>")


class Node
	constructor: (@data, @child_depth=5) ->

	load: (key) ->
		target = if key then "?node=#key" else ""
		return $.get(
			"/node/get#target",
			(data) => 
				@data = data
				@post_load()
			,
			'json'
		)

	save: ->
		return $.post(
			"/node/save",
			JSON.stringify(@data),
			(data) => @data = data,
			'json'
		)

	post_load: () ->
		# TODO: recurse into children
		@display_impl = new Display this, @parent

	display: (parent) ->
		parent.append(@display_impl.render())


# Document ready deferred
drd = $.Deferred()

# Load the root node
root_node = new Node
def_load = root_node.load()

drd.done( -> 
	# Execute these on document.ready
	def_load.done( ->
		root_node.display($('body')) 
	)
)

$(document).ready( ->
	drd.resolve()
)
