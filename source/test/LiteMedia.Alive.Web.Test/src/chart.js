(function() {
  var Chart, root;
  var __hasProp = Object.prototype.hasOwnProperty;
  root = typeof exports !== "undefined" && exports !== null ? exports : this;
  root.Chart = Chart = (function() {
    function Chart(settings) {
      this.settings = settings;
      this.base_color = this.settings.base_color;
      this.graph_colors = this.settings.graph_colors;
      this.padding = 5;
      this.legend_size = 12;
      this.label_font = '8.5 pt Arial';
      this.margin = {
        top: 10,
        right: 100,
        bottom: 10,
        left: 30
      };
    }
    Chart.prototype.setMarginRight = function(context, series) {
      var legend, rightMargin, width, _i, _len;
      rightMargin = 0;
      for (_i = 0, _len = series.length; _i < _len; _i++) {
        legend = series[_i];
        width = context.measureText(legend).width;
        rightMargin = Math.max(rightMargin, width);
      }
      if (rightMargin < (context.canvas.width / 4)) {
        return this.margin.right = rightMargin + this.legend_size + (this.padding * 2);
      }
    };
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
      if (length > 0) {
        return (size.width - this.margin.left - this.margin.right) / (length - 1);
      } else {
        return 0;
      }
    };
    Chart.prototype.graph = function(context, size, data, max, color) {
      var item, scaler, step, x, y, _i, _len, _ref;
      scaler = this.yScaler(size, max);
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
    Chart.prototype.gridLines = function(context, size, max) {
      var bottom, n, top, valueStep, x, yStep, _results;
      context.fillStyle = this.base_color;
      context.strokeStyle = this.base_color;
      context.lineWidth = 1;
      context.beginPath();
      context.moveTo(this.margin.left, this.margin.top);
      context.lineTo(this.margin.left, size.height - this.margin.bottom);
      context.lineTo(size.width - this.margin.right, size.height - this.margin.bottom);
      context.stroke();
      context.font = '10pt Arial';
      context.textAlign = 'center';
      x = this.margin.left / 2;
      bottom = size.height - (this.margin.bottom / 2);
      top = 15;
      yStep = (bottom - top) / 5;
      valueStep = max / 5;
      _results = [];
      for (n = 0; n <= 6; n++) {
        _results.push(context.fillText(n * valueStep, x, bottom - (n * yStep)));
      }
      return _results;
    };
    Chart.prototype.gridTitle = function(context, size, title) {
      var x;
      x = size.width / 2;
      context.font = '12pt Arial';
      context.textAlign = 'center';
      return context.fillText(title, x, this.margin.top * 2);
    };
    Chart.prototype.gridLegends = function(context, size, series) {
      var i, legend, x, y, _i, _len, _results;
      context.font = '8.5pt Arial';
      context.textAlign = 'left';
      x = size.width - this.margin.right + this.padding;
      y = (size.height / 2) - (series.length * (this.legend_size + this.padding) / 2);
      i = 0;
      _results = [];
      for (_i = 0, _len = series.length; _i < _len; _i++) {
        legend = series[_i];
        context.fillStyle = this.graph_colors[i++];
        context.fillRect(x, y, this.legend_size, this.legend_size);
        context.fillStyle = this.base_color;
        context.fillText(legend, x + this.legend_size + this.padding, y + this.legend_size - (this.legend_size / 4));
        _results.push(y += this.legend_size + this.padding);
      }
      return _results;
    };
    Chart.prototype.dataSeries = function(data) {
      var name, values, _results;
      _results = [];
      for (name in data) {
        if (!__hasProp.call(data, name)) continue;
        values = data[name];
        _results.push(name);
      }
      return _results;
    };
    Chart.prototype.dataValues = function(data) {
      var name, value, values, _results;
      _results = [];
      for (name in data) {
        if (!__hasProp.call(data, name)) continue;
        values = data[name];
        _results.push((function() {
          var _i, _len, _results2;
          _results2 = [];
          for (_i = 0, _len = values.length; _i < _len; _i++) {
            value = values[_i];
            _results2.push(value);
          }
          return _results2;
        })());
      }
      return _results;
    };
    Chart.prototype.paintMore = function(context, title, data, size) {
      var i, max, name, values, _results;
      this.setMarginRight(context, this.dataSeries(data));
      max = 100;
      for (name in data) {
        if (!__hasProp.call(data, name)) continue;
        values = data[name];
        max = Math.max(max, this.getMax(values));
      }
      this.gridLines(context, size, max);
      this.gridTitle(context, size, title);
      this.gridLegends(context, size, this.dataSeries(data));
      i = 0;
      context.lineWidth = 2.5;
      _results = [];
      for (name in data) {
        if (!__hasProp.call(data, name)) continue;
        values = data[name];
        this.graph(context, size, values, max, this.graph_colors[i++]);
        _results.push(context.lineWidth = 2);
      }
      return _results;
    };
    Chart.prototype.size = function(canvas) {
      return {
        width: canvas.width,
        height: canvas.height
      };
    };
    Chart.prototype.clear = function(context) {
      return context.clearRect(0, 0, context.canvas.width, context.canvas.height);
    };
    Chart.prototype.paint = function(canvas, title, data) {
      var context;
      context = canvas.getContext('2d');
      if (context != null) {
        this.clear(context);
        return this.paintMore(context, title, data, this.size(canvas));
      } else {
        ;
      }
    };
    return Chart;
  })();
}).call(this);
