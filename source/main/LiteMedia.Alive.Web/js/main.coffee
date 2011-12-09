###
  Author: Mikael Lundin
  E-mail: mikael.lundin@litemedia.se

  Something like this is defined before this script is run
  var charts = {
    'CPU': {},
    'Disc': {}
  }
###

# global state
root = exports ? this

# Firebug console log helpers
log = (message) -> console.log(message) if console?
dir = (obj) -> console.dir(obj) if console?

# Create a worker for each chart
workers = for own name, data of charts
  { 'meta': { 'name': name, 'latency': data.latency}, 'agent': new Worker('?file=worker.js') }

# Update chart with [name] with [data]
paintChart = (name, data) ->	
	# NOTE requires that settings has been defined
	chart = new root.Chart(settings, charts[name])
	chart.paint(document.getElementById(name), name, data)

# Register callback that alerts the message from worker, for now
for worker in workers
	worker.agent.onmessage = (evt) -> paintChart(evt.data.name, evt.data.data)

# Run all workers
for worker in workers
  worker.agent.postMessage(worker.meta);

# Initialize the page by setting canvas size and painting empty charts
root.initialize = () ->
	# set width * height of charts
	canvases = document.getElementsByClassName("chart");
	width = Math.round(window.innerWidth / 3) - (20 * 3);
	height = width / 2
	for canvas in canvases
		canvas.width = width
		canvas.height = height
		# paint empty chart
		chart = new Chart(settings, charts[canvas.id]);
		chart.paint(canvas, canvas.id, []);
