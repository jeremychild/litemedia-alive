margin = 10

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
	context.beginPath()
	context.moveTo(margin, size.height - margin) # 0, 0
	x = margin
	step = xStep size, data.length
	scaler = yScaler size, 100
	for item in data
		x += step
		y = (size.height - margin) - Math.round(item * scaler)
		console.log('x:' + x + ', y:' + y)
		context.lineTo(x, y)		
	context.stroke()

# paint grids
grids = (context, size) ->
	context.beginPath()
	context.moveTo(margin, margin)
	context.lineTo(margin, size.height - margin)
	context.lineTo(size.width - margin, size.height - margin)
	context.stroke()

# inner function
paintMore = (context, size, data) ->
	grids(context, size)
	graph(context, size, [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89], 100, '')
	
size = (canvas) -> width: canvas.width, height: canvas.height

# Entry function for painting chart
this.paint = (canvas, data) =>
	context = canvas.getContext('2d')
	if context?
		paintMore(context, size(canvas), data)
	else
		# error handling