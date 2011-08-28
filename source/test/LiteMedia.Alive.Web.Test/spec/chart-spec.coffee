# setup
root = exports ? this

# test settings
settings = margin: { top: 0, right: 0, bottom: 0, right: 0 }

chart = new root.Chart(settings)

describe "chart.getMax", -> 
    it "gives 100 with data less than 100",
    -> expect(chart.getMax([51,99,1,2])).toEqual(100)

    it "give 500 with data between 100 and 500",
    -> expect(chart.getMax([430,2,64,388])).toEqual(500)

    it "give 1000 with data between 500 and 1000",
    -> expect(chart.getMax([344,999,1,43])).toEqual(1000)

describe "chart.log10", ->
    it "gives 1 for 10", 
    -> expect(chart.log10(10)).toEqual(1)
    
    it "gives 2 for 100",
    -> expect(chart.log10(100)).toEqual(2)

describe "chart.yScaler", ->
    it "gives 0.1 when height is 100 and max value is 1000 with no margin",
    -> expect(chart.yScaler({ height: 100 }, 1000)).toEqual(0.1)