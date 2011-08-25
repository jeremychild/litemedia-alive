(function() {
  var base_color, getMax, graph, graph_colors, grids, margin, paintMore, size, xStep, yScaler;
  var __hasProp = Object.prototype.hasOwnProperty, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  margin = {
    top: 10,
    right: 0,
    bottom: 10,
    left: 25
  };
  base_color = '#AFAFAF';
  graph_colors = ['#006666', '#339999', '#00CC99', '#66CCCC', '#00FFCC', '#33FFCC', '#66FFCC', '#99FFCC', '#CCFFFF'];
  getMax = function(data) {
    var max, n, _i, _len;
    max = 100;
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      n = data[_i];
      max = Math.max(max, n);
    }
    return max;
  };
  yScaler = function(size, max) {
    return (size.height - margin.top - margin.bottom) / max;
  };
  xStep = function(size, length) {
    return Math.round((size.width - margin.top - margin.bottom) / length);
  };
  graph = function(context, size, data, max, color) {
    var item, scaler, step, x, y, _i, _len, _ref;
    scaler = yScaler(size, 100);
    step = xStep(size, data.length);
    x = margin.left;
    y = size.height - margin.bottom - Math.round(data[0] * scaler);
    context.beginPath();
    context.moveTo(x, y);
    console.log("moveTo x: " + x + ", y:" + y);
    console.log('color:' + color);
    context.strokeStyle = color;
    _ref = data.slice(1, (data.length + 1) || 9e9);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      console.log("lineTo x: " + x + ", y:" + y);
      x += step;
      y = size.height - margin.bottom - Math.round(item * scaler);
      context.lineTo(x, y);
    }
    return context.stroke();
  };
  grids = function(context, size) {
    context.fillStyle = base_color;
    context.strokeStyle = base_color;
    context.lineWidth = 1;
    context.beginPath();
    context.moveTo(margin.left, margin.top);
    context.lineTo(margin.left, size.height - margin.bottom);
    context.lineTo(size.width - margin.right, size.height - margin.bottom);
    context.stroke();
    context.font = '9pt Arial';
    context.textAlign = 'center';
    context.fillText('0', margin.left / 2, size.height - (margin.bottom / 2));
    context.fillText('50', margin.left / 2, size.height / 2);
    return context.fillText('100', margin.left / 2, 15);
  };
  paintMore = function(context, size, data) {
    var i, name, values, _results;
    grids(context, size);
    i = 0;
    context.lineWidth = 1.5;
    _results = [];
    for (name in data) {
      if (!__hasProp.call(data, name)) continue;
      values = data[name];
      graph(context, size, values, 100, graph_colors[i++]);
      _results.push(context.lineWidth = 1);
    }
    return _results;
  };
  size = function(canvas) {
    return {
      width: canvas.width,
      height: canvas.height
    };
  };
  this.paint = __bind(function(canvas, data) {
    var context;
    context = canvas.getContext('2d');
    if (context != null) {
      return paintMore(context, size(canvas), data);
    } else {
      ;
    }
  }, this);
}).call(this);
