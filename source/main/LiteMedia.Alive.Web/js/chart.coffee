# global
root = exports ? this

# responsible for painting a chart
root.Chart = class Chart
	# create new instance of chart
	constructor: (@settings) ->
		@base_color = @settings.base_color
		@graph_colors = @settings.graph_colors

		# margin is not a setting because it could potentially break the chart
		@margin =  top: 10, right: 80, bottom: 10, left: 25

	# good enough log10 function
	log10: (val) -> Math.log(val) / Math.log(10)

	# get max value of graph, 100 is minimal
	# example: getMax [99] -> 100
	# example: getMax [251] -> 500
	# example: getMax [501] -> 1000
	getMax: (data) ->
		max = 100
		for n in data
			max = Math.max(max, n)
		ceil = Math.pow(10, Math.ceil(@log10(max)))
		if (ceil / 2) > max then ceil / 2 else ceil

	# Get the scaler of y
	yScaler: (size, max) -> (size.height - @margin.top - @margin.bottom) / max

	# Get number of pixels between discrete x
	xStep: (size, length) -> 
		if length > 0 then (size.width - @margin.left - @margin.right) / (length - 1) else 0

	# paint one graph on the canvas
	# todo, use quadratic curves?
	graph: (context, size, data, max, color) ->
		scaler = @yScaler size, max
		step = @xStep size, data.length
		x = @margin.left
		y = size.height - @margin.bottom - Math.round(data[0] * scaler)
		context.beginPath()
		context.moveTo(x, y) # start
		context.strokeStyle = color
		for item in data[1..data.length]
			x += step
			y = size.height - @margin.bottom - Math.round(item * scaler)
			context.lineTo(x, y)
		context.stroke()

	# paint grids
	gridLines: (context, size, max) ->
		context.fillStyle = @base_color
		context.strokeStyle = @base_color
		context.lineWidth = 1
		context.beginPath()
		context.moveTo(@margin.left, @margin.top)
		context.lineTo(@margin.left, size.height - @margin.bottom)
		context.lineTo(size.width - @margin.right, size.height - @margin.bottom)
		context.stroke()

		# Grid text
		context.font = '8.5pt Arial'
		context.textAlign = 'center'
		context.fillText('0', @margin.left / 2, size.height - (@margin.bottom / 2))
		context.fillText(max / 2, @margin.left / 2, size.height / 2)
		context.fillText(max, @margin.left / 2, 15)

	# top text
	gridTitle: (context, size, title) ->
		x = (size.width / 2) + (@margin.left - @margin.right)
		context.font = '12pt Arial'
		context.textAlign = 'center'
		context.fillText(title, x, @margin.top * 2)

	# paint the legends of data series with color
	gridLegends: (context, size, series) ->
		margin = 5
		width = 10
		x = size.width - @margin.right + margin
		y = (size.height / 2) - (series.length * (width + margin) / 2)
		

	# get the series, CPU, CPU #1, CPU #2
	dataSeries: (data) -> name for own name, values of data

	# all data values
	dataValues: (data) -> (value for value in values) for own name, values of data

	# inner function
	paintMore: (context, name, data, size) ->
		# calculate max
		max = 100
		for own name, values of data
			max = Math.max(max, @getMax(values))
		@gridLines(context, size, max)
		@gridTitle(context, size, name)
		@gridLegends(context, size, @dataSeries(data))
		i = 0
		context.lineWidth = 2 # first line is heavy
		for own name, values of data
			@graph(context, size, values, max, @graph_colors[i++])
			context.lineWidth = 1.5 # light weight on lines 2..

	# get size of the canvas
	size: (canvas) -> width: canvas.width, height: canvas.height

	# clear canvas
	clear: (context) -> context.clearRect(0,0,context.canvas.width,context.canvas.height)

	# Entry function for painting chart
	paint: (canvas, name, data) ->
		context = canvas.getContext('2d')
		@clear(context)
		if context?
			@paintMore(context, name, data, @size(canvas))
		else
			# error handling