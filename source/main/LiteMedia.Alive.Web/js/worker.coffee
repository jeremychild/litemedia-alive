# Stub function
log = (msg) -> # postMessage { 'data': msg }

# State
state = {}

# Keep track if a request is ongoing
ongoingRequest = false

# Process data and retrieve an url for chart
process = (evt) ->
	if not ongoingRequest
		ongoingRequest = true
		counters = {}
		getData(evt.data.name, handleResponse, failedResponse)
	
# Handle the counter response
handleResponse = (responseData) ->
	state = appendToState responseData
	postMessage(name: responseData.Name, data: state)

# Failed response
failedResponse = (message) ->

# Append the json response to state data
appendToState = (data) -> 
	#state[data.Name] = {} if not state[data.Name]?
	for counter in data.Counters
		# Create counter in state if it doesn't exist
		state[counter.Name] = [] unless state[counter.Name]
		# Limit the amount of values at 60, // TODO make this configurable
		state[counter.Name].splice(0, 1) if state[counter.Name].length > 61
		# Push the new counter value onto the array
		state[counter.Name].push(counter.CurrentValue)
	state

# Get url
getDataUrl = (name) -> '?data=' + name

# Get the group data by name
getData = (name, successCallback, failureCallback) ->
	result = {}
	httpRequest = new XMLHttpRequest() if this.XMLHttpRequest?
	httpRequest = new ActiveXObject("Microsoft.XMLHTTP") if this.ActiveXObject
	
	# Bind completed request to callback
	httpRequest.onreadystatechange = ->
		try
			if httpRequest.readyState is 4
				if httpRequest.status is 200
					successCallback(JSON.parse(httpRequest.responseText))
				else
					failureCallback(httpRequest.responseText)
				ongoingRequest = false
			else
				ongoingRequest = true
		catch error
			ongoingRequest = false
			failureCallback()

	httpRequest.open('GET', getDataUrl(name))
	httpRequest.send(null)
	result

# Bind worker onmessage to executing process with a certain interval
this.onmessage = (evt) => setInterval((-> process(evt)), 50)
#this.onmessage = (evt) => process(evt)