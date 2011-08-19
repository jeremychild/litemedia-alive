###
  Author: Mikael Lundin
  E-mail: mikael.lundin@litemedia.se
###

###
  Something like this is defined before this script is run
  var charts = {
    'CPU': {},
    'Disc': {}
  }
###

# Firebug console log helpers
log = (message) -> console.log(message) if console?
dir = (obj) -> console.dir(obj) if console?

# Create a worker for each chart
workers = for own name, data of charts
  { 'meta': { 'name': name, 'latency': data.latency}, 'agent': new Worker('?file=worker.js') }

# Register callback that alerts the message from worker, for now
for worker in workers
	worker.agent.onmessage = (evt) -> 
		document.getElementById(evt.data.name).src = createChartUrl(evt.data.name, evt.data.data)

# Run all workers
for worker in workers
  worker.agent.postMessage(worker.meta);

# Create a chart url
createChartUrl = (name, data) ->
	'http://chart.googleapis.com/chart?' + (getArguments name, data).join('&')

getArguments = (name, data) ->
	arguments =
		chxs: '0,676767,11.5,0,l,000000',
		chxt: 'y',
		# Width
		chs: '440x220',
		# Chart type
		cht: 'lc',
		chco:'006666,339999,00CC99,66CCCC,00FFCC,33FFCC,66FFCC,99FFCC,CCFFFF',
		# Chart title
		chtt: escape(name),
		# Chart data legends
		chdl: (escape(counterName) for counterName, values of data).join('|'),
		# Chart data values
		chd: 't:' + (values.join(',') for counterName, values of data).join('|'),
		chls: 3,
		chma: '5,5,5,25'
	
	for key, value of arguments	
		"#{key}=#{value}"