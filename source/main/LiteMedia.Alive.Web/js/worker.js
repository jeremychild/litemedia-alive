(function() {
  var appendToState, failedResponse, getData, getDataUrl, handleResponse, log, process, state;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  log = function(msg) {};
  state = {};
  process = function(evt) {
    var counters;
    counters = {};
    return getData(evt.data.name, handleResponse, failedResponse);
  };
  handleResponse = function(responseData) {
    state = appendToState(responseData);
    return postMessage({
      name: responseData.Name,
      data: state
    });
  };
  failedResponse = function(message) {};
  appendToState = function(data) {
    var counter, _i, _len, _ref;
    _ref = data.Counters;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      counter = _ref[_i];
      if (!state[counter.Name]) {
        state[counter.Name] = [];
      }
      if (state[counter.Name].length > 61) {
        state[counter.Name].splice(0, 1);
      }
      state[counter.Name].push(counter.CurrentValue);
    }
    return state;
  };
  getDataUrl = function(name) {
    return '?data=' + name;
  };
  getData = function(name, successCallback, failureCallback) {
    var httpRequest, result;
    result = {};
    if (this.XMLHttpRequest != null) {
      httpRequest = new XMLHttpRequest();
    }
    if (this.ActiveXObject) {
      httpRequest = new ActiveXObject("Microsoft.XMLHTTP");
    }
    httpRequest.onreadystatechange = function() {
      try {
        if (httpRequest.readyState === 4) {
          if (httpRequest.status === 200) {
            return successCallback(JSON.parse(httpRequest.responseText));
          } else {
            return failureCallback(httpRequest.responseText);
          }
        }
      } catch (error) {
        return failureCallback();
      }
    };
    httpRequest.open('GET', getDataUrl(name));
    httpRequest.send(null);
    return result;
  };
  this.onmessage = __bind(function(evt) {
    return setInterval((function() {
      return process(evt);
    }), Math.round(evt.data.latency * 1.25));
  }, this);
}).call(this);
