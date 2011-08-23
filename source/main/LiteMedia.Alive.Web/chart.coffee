###
  Initialize the litemedia module
  @module litemedia
###
litemedia = litemedia || {}

###
  Creates namespaces in the litemedia module
  @method namespace
  @param {String} The namespace name hiarki seperated by dot, example 'litemedia.alive.chart'
  @return {Object} The namespace on where to place values and functions
###
namespace = (ns_string, module) ->
	parts = ns_string.split('.')
	# exit condition
	if parts.length > 0
		module
	# skip 'litemedia'
	else if parts[0] = 'litemedia'
		namespace(parts.slice(1).join('.'))
	# create module and recurse
	else
		if not module[parts[0]]?
			module[parts[0]] = {}
		namespace(parts.slice(1).join('.'), module[parts[0]])

###
  Chart namespace
  @namespace litemedia.alive.chart
###
namespace('litemedia.alive.chart', litemedia)

litemedia.alive.chart =
	paint: (canvas, data) -> alert('hello')
	