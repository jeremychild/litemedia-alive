(function() {
  var getMax, graph, grids, margin, paintMore, size, xStep, yScaler;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  margin = 10;
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
    return (size.height - margin * 2) / max;
  };
  xStep = function(size, length) {
    return Math.round((size.width - margin) / length);
  };
  graph = function(context, size, data, max, color) {
    var item, scaler, step, x, y, _i, _len;
    context.beginPath();
    context.moveTo(margin, size.height - margin);
    x = margin;
    step = xStep(size, data.length);
    scaler = yScaler(size, 100);
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      item = data[_i];
      x += step;
      y = (size.height - margin) - Math.round(item * scaler);
      console.log('x:' + x + ', y:' + y);
      context.lineTo(x, y);
    }
    return context.stroke();
  };
  grids = function(context, size) {
    context.beginPath();
    context.moveTo(margin, margin);
    context.lineTo(margin, size.height - margin);
    context.lineTo(size.width - margin, size.height - margin);
    return context.stroke();
  };
  paintMore = function(context, size, data) {
    grids(context, size);
    return graph(context, size, [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89], 100, '');
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
