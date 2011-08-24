margin = 10

# Grid color
base_color = '#AFAFAF' 

# Graph colors
graph_colors = ['#006666','#339999','#00CC99','#66CCCC','#00FFCC','#33FFCC','#66FFCC','#99FFCC','#CCFFFF']

# get max value of graph, 100 is minimal
getMax = (data) ->
	max = 100
	for n in data
		max = Math.max(max, n)
	max

# Get the scaler of y
yScaler = (size, max) -> (size.height - margin * 2) / max

# Get number of pixels between discrete x
xStep = (size, length) -> Math.round((size.width - margin) / length)

# paint one graph on the canvas
# todo, use quadratic curves?
graph = (context, size, data, max, color) ->
	scaler = yScaler size, 100
	step = xStep size, data.length
	x = margin
	y = size.height - margin - Math.round(item * scaler)
	context.beginPath()
	context.moveTo(x, y) # start
	console.log('color:' + color)
	context.strokeStyle = color
	for item in data[1..data.length]
		x += step
		y = size.height - margin - Math.round(item * scaler)
		console.log("x: #{x}, y:#{y}")
		context.lineTo(x, y)		
	context.stroke()

# paint grids
grids = (context, size) ->
	context.strokeStyle = base_color
	context.lineWidth = 1
	context.beginPath()
	context.moveTo(margin, margin)
	context.lineTo(margin, size.height - margin)
	context.lineTo(size.width - margin, size.height - margin)
	context.stroke()

# inner function
paintMore = (context, size, data) ->
	grids(context, size)
	i = 0
	context.lineWidth = 2 # first line is heavy
	for own name, values of data
		graph(context, size, values, 100, graph_colors[i++])
		context.lineWidth = 1 # light weight on lines 2..

# get size of the canvas
size = (canvas) -> width: canvas.width, height: canvas.height

# Entry function for painting chart
this.paint = (canvas, data) =>
	context = canvas.getContext('2d')
	if context?
		paintMore(context, size(canvas), data)
	else
		# error handling