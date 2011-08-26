class Chart
	constructor: () ->
	log10: (val) -> Math.log(val) / Math.log(10)
	getMax: (data) ->
		max = 100
		for n in data
			max = Math.max(max, n)
		ceil = Math.pow(10, Math.ceil(log10(max)))
		console.log(ceil)
		if (ceil / 2) > max then ceil / 2 else ceil

# global instance
window.chart = new Chart()

margin = top: 10, right: 0, bottom: 10, left: 25

# Grid color
base_color = '#606060' 

# Graph colors
graph_colors = ['#006666','#339999','#00CC99','#66CCCC','#00FFCC','#33FFCC','#66FFCC','#99FFCC','#CCFFFF']

# log10
log10 = (val) -> Math.log(val) / Math.log(10)

# get max value of graph, 100 is minimal
# example: getMax [99] -> 100
# example: getMax [101] -> 250
# example: getMax [251] -> 500
# example: getMax [501] -> 1000
getMax = (data) ->
	max = 100
	console.log("data: #{data}")
	for n in data
		console.log("n: #{n}")
		max = Math.max(max, n)
	console.log("max: #{max}")
	ceil = Math.pow(10, Math.ceil(log10(max)))
	if (ceil / 4) > max
		ceil / 4
	else if (ceil / 2) > max
		ceil / 2
	else
		max

# Get the scaler of y
yScaler = (size, max) -> (size.height - margin.top - margin.bottom) / max

# Get number of pixels between discrete x
xStep = (size, length) -> Math.round((size.width - margin.top - margin.bottom) / length)

# paint one graph on the canvas
# todo, use quadratic curves?
graph = (context, size, data, max, color) ->
	scaler = yScaler size, 100
	step = xStep size, data.length
	x = margin.left
	y = size.height - margin.bottom - Math.round(data[0] * scaler)
	context.beginPath()
	context.moveTo(x, y) # start
	console.log("moveTo x: #{x}, y:#{y}")
	console.log('color:' + color)
	context.strokeStyle = color
	for item in data[1..data.length]
		console.log("lineTo x: #{x}, y:#{y}")
		x += step
		y = size.height - margin.bottom - Math.round(item * scaler)
		context.lineTo(x, y)
	context.stroke()

# paint grids
grids = (context, size) ->
	context.fillStyle = base_color
	context.strokeStyle = base_color
	context.lineWidth = 1
	context.beginPath()
	context.moveTo(margin.left, margin.top)
	context.lineTo(margin.left, size.height - margin.bottom)
	context.lineTo(size.width - margin.right, size.height - margin.bottom)
	context.stroke()

	# Grid text
	context.font = '8.5pt Arial'
	context.textAlign = 'center'
	context.fillText('0', margin.left / 2, size.height - (margin.bottom / 2))
	context.fillText('50', margin.left / 2, size.height / 2)
	context.fillText('100', margin.left / 2, 15)

# inner function
paintMore = (context, size, data) ->
	grids(context, size)
	i = 0
	context.lineWidth = 2 # first line is heavy
	for own name, values of data
		console.log(getMax values)
		graph(context, size, values, 100, graph_colors[i++])
		context.lineWidth = 1.5 # light weight on lines 2..

# get size of the canvas
size = (canvas) -> width: canvas.width, height: canvas.height

# Entry function for painting chart
this.paint = (canvas, data) =>
	context = canvas.getContext('2d')
	if context?
		paintMore(context, size(canvas), data)
	else
		# error handling