# global
root = exports ? this

# responsible for painting a chart
root.Chart = class Chart
	# create new instance of chart
	constructor: (@settings, @configuration) ->
		@base_color = @settings.base_color
		@graph_colors = @settings.graph_colors
		@padding = 5 #px
		@legend_size = 12 #px
		@label_font = '8.5 pt Arial'
		# margin is not a setting because it could potentially break the chart
		@margin =  top: 10, right: 100, bottom: 10, left: 30

	# set right margin by measuring series legends
	# this will only limit the width of right margin, not increase existing margin
	setMarginRight: (context, series) ->
		rightMargin = 0
		for legend in series
			width = context.measureText(legend).width
			rightMargin = Math.max(rightMargin, width)
		# max right margin is 1/4 of total width
		if rightMargin < (context.canvas.width / 4)
			@margin.right = rightMargin + @legend_size + (@padding * 2)

	# good enough log10 function
	log10: (val) -> Math.log(val) / Math.log(10)

	# get max value of graph, 100 is minimal
	# example: getMax [99] -> 100
	# example: getMax [101] -> 250
	# example: getMax [251] -> 500
	# example: getMax [501] -> 1000
	getMax: (data) ->
		max = 100
		for n in data
			max = Math.max(max, n)
		ceil = Math.pow(10, Math.ceil(@log10(max)))
		if (ceil / 4) > max 
			ceil / 4 
		else if (ceil / 2) > max
			ceil / 2
		else
			ceil

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

	# Type legend as 1K instead of 1000
	# Type legend as 1M instead of 1000000
	formatLabel: (label) ->
		if label >= 1000000
			"#{label / 1000000}M"
		else if label >= 1000
			"#{label / 1000}K"
		else
			"#{label}"

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
		context.font = '9pt Arial'
		context.textAlign = 'center'
		# place labels in the middle of the left margin
		x = @margin.left / 2
		# y of the 0 axis
		bottom = size.height - (@margin.bottom / 2)
		# y of the top label
		top = 15
		# the distance between labels on the canvas vertically
		yStep = (bottom - top) / 5
		# the step between labels 0, 20, 40, 60, 80, 100
		valueStep = max / 5
		context.fillText(@formatLabel(n * valueStep), x, bottom - (n * yStep)) for n in [0..6]

	# top text
	gridTitle: (context, size, title) ->
		x = size.width / 2
		context.font = '12pt Arial'
		context.textAlign = 'center'
		context.fillText(title, x, @margin.top * 2)

	# paint the legends of data series with color
	gridLegends: (context, size, series) ->
		context.font = '8.5pt Arial'
		context.textAlign = 'left'
		x = size.width - @margin.right + @padding
		y = (size.height / 2) - (series.length * (@legend_size + @padding) / 2)
		i = 0
		for legend in series
			context.fillStyle = @graph_colors[i++]
			context.fillRect(x, y, @legend_size, @legend_size)
			context.fillStyle = @base_color
			context.fillText(legend, x + @legend_size + @padding, y + @legend_size - (@legend_size / 4))
			y += @legend_size + @padding

	# get the series, CPU, CPU #1, CPU #2
	dataSeries: (data) -> name for own name, values of data

	# all data values
	dataValues: (data) -> (value for value in values) for own name, values of data

	# inner function
	paintMore: (context, title, data, size) ->
		# set right margin
		@setMarginRight(context, @dataSeries(data))

		# calculate max
		max = @configuration.max
		for own name, values of data
			max = Math.max(max, @getMax(values))
		@gridLines(context, size, max)
		@gridTitle(context, size, title)
		@gridLegends(context, size, @dataSeries(data))
		i = 0
		context.lineWidth = 2.5 # first line is heavy
		for own name, values of data
			@graph(context, size, values, max, @graph_colors[i++])
			context.lineWidth = 2 # light weight on lines 2..

	# get size of the canvas
	size: (canvas) -> width: canvas.width, height: canvas.height

	# clear canvas
	clear: (context) -> context.clearRect(0,0,context.canvas.width,context.canvas.height)

	# Entry function for painting chart
	paint: (canvas, title, data) ->
		context = canvas.getContext('2d')
		if context?
			@clear(context)
			@paintMore(context, title, data, @size(canvas))
		else
			# error handling