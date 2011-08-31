(function() {
  /*
    Author: Mikael Lundin
    E-mail: mikael.lundin@litemedia.se
  
    Something like this is defined before this script is run
    var charts = {
      'CPU': {},
      'Disc': {}
    }
  */  var data, dir, imageSize, log, name, paintChart, root, worker, workers, _i, _j, _len, _len2;
  var __hasProp = Object.prototype.hasOwnProperty;
  root = typeof exports !== "undefined" && exports !== null ? exports : this;
  log = function(message) {
    if (typeof console !== "undefined" && console !== null) {
      return console.log(message);
    }
  };
  dir = function(obj) {
    if (typeof console !== "undefined" && console !== null) {
      return console.dir(obj);
    }
  };
  workers = (function() {
    var _results;
    _results = [];
    for (name in charts) {
      if (!__hasProp.call(charts, name)) continue;
      data = charts[name];
      _results.push({
        'meta': {
          'name': name,
          'latency': data.latency
        },
        'agent': new Worker('?file=worker.js')
      });
    }
    return _results;
  })();
  imageSize = function() {
    var margin, width;
    margin = 60;
    width = Math.round(window.innerWidth / 3) - margin;
    return {
      width: width,
      height: Math.round(width / 2)
    };
  };
  paintChart = function(name, data) {
    var chart;
    chart = new root.Chart(settings);
    return chart.paint(document.getElementById(name), name, data);
  };
  for (_i = 0, _len = workers.length; _i < _len; _i++) {
    worker = workers[_i];
    worker.agent.onmessage = function(evt) {
      return paintChart(evt.data.name, evt.data.data);
    };
  }
  for (_j = 0, _len2 = workers.length; _j < _len2; _j++) {
    worker = workers[_j];
    worker.agent.postMessage(worker.meta);
  }
}).call(this);
