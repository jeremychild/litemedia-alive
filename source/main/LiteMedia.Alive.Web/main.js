(function() {
  /*
    Author: Mikael Lundin
    E-mail: mikael.lundin@litemedia.se
  */
  /*
    Something like this is defined before this script is run
    var charts = {
      'CPU': {},
      'Disc': {}
    }
  */  var createChartUrl, data, dir, getArguments, log, name, simpleEncode, simpleEncoding, worker, workers, _i, _j, _len, _len2;
  var __hasProp = Object.prototype.hasOwnProperty;
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
  for (_i = 0, _len = workers.length; _i < _len; _i++) {
    worker = workers[_i];
    worker.agent.onmessage = function(evt) {
      return document.getElementById(evt.data.name).src = createChartUrl(evt.data.name, evt.data.data);
    };
  }
  for (_j = 0, _len2 = workers.length; _j < _len2; _j++) {
    worker = workers[_j];
    worker.agent.postMessage(worker.meta);
  }
  createChartUrl = function(name, data) {
    return 'http://chart.googleapis.com/chart?' + (getArguments(name, data)).join('&');
  };
  getArguments = function(name, data) {
    var counterName, key, value, values, _results;
    arguments = {
      chxs: '0,676767,11.5,0,l,000000',
      chxt: 'y',
      chs: '440x220',
      cht: 'lc',
      chco: '006666,339999,00CC99,66CCCC,00FFCC,33FFCC,66FFCC,99FFCC,CCFFFF',
      chtt: escape(name),
      chdl: ((function() {
        var _results;
        _results = [];
        for (counterName in data) {
          values = data[counterName];
          _results.push(counterName.replace(' ', '+'));
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
  simpleEncoding = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  simpleEncode = function(valueArray, maxValue) {
    var num, _k, _len3, _results;
    _results = [];
    for (_k = 0, _len3 = valueArray.length; _k < _len3; _k++) {
      num = valueArray[_k];
      _results.push((typeof currentValue !== "undefined" && currentValue !== null) && currentValue >= 0 ? simpleEncoding.charAt(Math.round((simpleEncoding.length - 1) * currentValue / maxValue)) : void 0);
    }
    return _results;
  };
}).call(this);
