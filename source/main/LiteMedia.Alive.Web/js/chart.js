(function() {
  var Chart, root;
  var __hasProp = Object.prototype.hasOwnProperty;
  root = typeof exports !== "undefined" && exports !== null ? exports : this;
  root.Chart = Chart = (function() {
    function Chart(settings) {
      this.settings = settings;
      this.margin = this.settings.margin;
      this.base_color = this.settings.base_color;
      this.graph_colors = this.settings.graph_colors;
    }
    Chart.prototype.log10 = function(val) {
      return Math.log(val) / Math.log(10);
    };
    Chart.prototype.getMax = function(data) {
      var ceil, max, n, _i, _len;
      max = 100;
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        n = data[_i];
        max = Math.max(max, n);
      }
      ceil = Math.pow(10, Math.ceil(this.log10(max)));
      if ((ceil / 2) > max) {
        return ceil / 2;
      } else {
        return ceil;
      }
    };
    Chart.prototype.yScaler = function(size, max) {
      return (size.height - this.margin.top - this.margin.bottom) / max;
    };
    Chart.prototype.xStep = function(size, length) {
      return Math.round((size.width - this.margin.top - this.margin.bottom) / length);
    };
    Chart.prototype.graph = function(context, size, data, max, color) {
      var item, scaler, step, x, y, _i, _len, _ref;
      scaler = this.yScaler(size, 100);
      step = this.xStep(size, data.length);
      x = this.margin.left;
      y = size.height - this.margin.bottom - Math.round(data[0] * scaler);
      context.beginPath();
      context.moveTo(x, y);
      context.strokeStyle = color;
      _ref = data.slice(1, (data.length + 1) || 9e9);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        x += step;
        y = size.height - this.margin.bottom - Math.round(item * scaler);
        context.lineTo(x, y);
      }
      return context.stroke();
    };
    Chart.prototype.grids = function(context, size) {
      context.fillStyle = this.base_color;
      context.strokeStyle = this.base_color;
      context.lineWidth = 1;
      context.beginPath();
      context.moveTo(this.margin.left, this.margin.top);
      context.lineTo(this.margin.left, size.height - this.margin.bottom);
      context.lineTo(size.width - this.margin.right, size.height - this.margin.bottom);
      context.stroke();
      context.font = '8.5pt Arial';
      context.textAlign = 'center';
      context.fillText('0', this.margin.left / 2, size.height - (this.margin.bottom / 2));
      context.fillText('50', this.margin.left / 2, size.height / 2);
      return context.fillText('100', this.margin.left / 2, 15);
    };
    Chart.prototype.paintMore = function(context, size, data) {
      var i, name, values, _results;
      this.grids(context, size);
      i = 0;
      context.lineWidth = 2;
      _results = [];
      for (name in data) {
        if (!__hasProp.call(data, name)) continue;
        values = data[name];
        this.graph(context, size, values, 100, this.graph_colors[i++]);
        _results.push(context.lineWidth = 1.5);
      }
      return _results;
    };
    Chart.prototype.size = function(canvas) {
      return {
        width: canvas.width,
        height: canvas.height
      };
    };
    Chart.prototype.paint = function(canvas, data) {
      var context;
      context = canvas.getContext('2d');
      if (context != null) {
        context.clearRect(0, 0, context.canvas.width, context.canvas.height);
        return this.paintMore(context, this.size(canvas), data);
      } else {
        ;
      }
    };
    return Chart;
  })();
}).call(this);
