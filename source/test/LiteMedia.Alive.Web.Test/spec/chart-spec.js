(function() {
  var chart, root, settings;
  root = typeof exports !== "undefined" && exports !== null ? exports : this;
  settings = {
    margin: {
      top: 0,
      right: 0,
      bottom: 0,
      right: 0
    }
  };
  chart = new root.Chart(settings);
  describe("chart max value", function() {
    it("is 100 when all data points are less than 100", function() {
      return expect(chart.getMax([51, 99, 1, 2])).toEqual(100);
    });
    it("is 500 when all data points are less than 500", function() {
      return expect(chart.getMax([430, 2, 64, 388])).toEqual(500);
    });
    return it("is 1000 when all data points are less than 1000", function() {
      return expect(chart.getMax([344, 999, 1, 43])).toEqual(1000);
    });
  });
  describe("chart.log10", function() {
    it("gives 1 for 10", function() {
      return expect(chart.log10(10)).toEqual(1);
    });
    it("gives 2 for 100", function() {
      return expect(chart.log10(100)).toEqual(2);
    });
    return it("gives almost 3 for 1000", function() {
      return expect(Math.round(chart.log10(1000))).toEqual(3);
    });
  });
  describe("chart.yScaler", function() {
    return it("gives 0.1 when height is 100 and max value is 1000 with no margin", function() {
      return expect(chart.yScaler({
        height: 100
      }, 1000)).toEqual(0.1);
    });
  });
  describe("distance between datapoints horizonally", function() {
    it("should be divided so that all datapoints take up the full width", function() {
      return expect(chart.xStep({
        width: 100
      }, 11)).toEqual(10);
    });
    it("is whole chart width when only two datapoints", function() {
      return expect(chart.xStep({
        width: 100
      }, 2)).toEqual(100);
    });
    return it("is zero with no datapoints", function() {
      return expect(chart.xStep({
        width: 100
      }, 0)).toEqual(0);
    });
  });
}).call(this);
