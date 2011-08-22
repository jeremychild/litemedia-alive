(function() {
  /*
    Author: Mikael Lundin
    E-mail: mikael.lundin@litemedia.se
  
    Something like this is defined before this script is run
    var charts = {
      'CPU': {},
      'Disc': {}
    }
  */  var createChartUrl, data, dir, getArguments, imageSize, log, name, paintChart, worker, workers, _i, _j, _len, _len2;
  var __hasProp = Object.prototype.hasOwnProperty, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
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
    var image;
    image = document.getElementById(name);
    return image.src = createChartUrl(name, data, imageSize());
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
  createChartUrl = function(name, data, size) {
    return 'http://chart.googleapis.com/chart?' + (getArguments(name, data, size)).join('&');
  };
  getArguments = function(name, data, size) {
    var counterName, key, value, values, _results;
    arguments = {
      chxs: '0,676767,11.5,0,l,000000',
      chxt: 'y',
      chs: size.width + 'x' + size.height,
      cht: 'lc',
      chco: '006666,339999,00CC99,66CCCC,00FFCC,33FFCC,66FFCC,99FFCC,CCFFFF',
      chtt: escape(name),
      chdl: ((function() {
        var _results;
        _results = [];
        for (counterName in data) {
          values = data[counterName];
          _results.push(escape(counterName));
        }
        return _results;
      })()).join('|'),
      chd: 't:' + ((function() {
        var _results;
        _results = [];
        for (counterName in data) {
          values = data[counterName];
          _results.push(values.join(','));
        }
        return _results;
      })()).join('|'),
      chls: 3,
      chma: '5,5,5,25'
    };
    _results = [];
    for (key in arguments) {
      value = arguments[key];
      _results.push("" + key + "=" + value);
    }
    return _results;
  };
  document.onload = __bind(function() {
    var name, values, _results;
    _results = [];
    for (name in charts) {
      if (!__hasProp.call(charts, name)) continue;
      values = charts[name];
      _results.push(paintChart(name, values));
    }
    return _results;
  }, this);
}).call(this);
