# setup
root = exports ? this

# test settings
settings = margin: { top: 0, right: 0, bottom: 0, right: 0 }

chart = new root.Chart(settings)

describe "chart max value", -> 
    it "is 100 when all data points are less than 100",
    -> expect(chart.getMax([51,99,1,2])).toEqual(100)

    it "is 500 when all data points are less than 500",
    -> expect(chart.getMax([430,2,64,388])).toEqual(500)

    it "is 1000 when all data points are less than 1000",
    -> expect(chart.getMax([344,999,1,43])).toEqual(1000)

describe "chart.log10", ->
    it "gives 1 for 10", 
    -> expect(chart.log10(10)).toEqual(1)
    
    it "gives 2 for 100",
    -> expect(chart.log10(100)).toEqual(2)

    it "gives almost 3 for 1000",
    -> expect(Math.round(chart.log10(1000))).toEqual(3)
    
describe "chart.yScaler", ->
    it "gives 0.1 when height is 100 and max value is 1000 with no margin",
    -> expect(chart.yScaler({ height: 100 }, 1000)).toEqual(0.1)

describe "distance between datapoints horizonally", ->
    it "should be divided so that all datapoints take up the full width",
    -> expect(chart.xStep({ width: 100 }, 11)).toEqual(10)

    it "is whole chart width when only two datapoints",
    -> expect(chart.xStep({ width: 100 }, 2)).toEqual(100)

    it "is zero with no datapoints",
    -> expect(chart.xStep({ width: 100 }, 0)).toEqual(0)