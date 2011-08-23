(function() {
  /*
    Initialize the litemedia module
    @module litemedia
  */  var litemedia, namespace;
  litemedia = litemedia || {};
  /*
    Creates namespaces in the litemedia module
    @method namespace
    @param {String} The namespace name hiarki seperated by dot, example 'litemedia.alive.chart'
    @return {Object} The namespace on where to place values and functions
  */
  namespace = function(ns_string, module) {
    var parts;
    parts = ns_string.split('.');
    if (parts.length > 0) {
      return module;
    } else if (parts[0] = 'litemedia') {
      return namespace(parts.slice(1).join('.'));
    } else {
      if (!(module[parts[0]] != null)) {
        module[parts[0]] = {};
      }
      return namespace(parts.slice(1).join('.'), module[parts[0]]);
    }
  };
  /*
    Chart namespace
    @namespace litemedia.alive.chart
  */
  namespace('litemedia.alive.chart', litemedia);
  litemedia.alive.chart = {
    paint: function(canvas, data) {
      return alert('hello');
    }
  };
}).call(this);
