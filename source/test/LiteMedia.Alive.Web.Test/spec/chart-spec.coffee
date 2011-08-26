describe "chart.getMax", () -> 
	it "gives 100 with data less than 100",
	-> expect(window.chart.getMax([51,99,1,2])).toEqual(100)

	it "gives 250 with data between 100 and 250",
	-> expect(window.chart.getMax([111,95,149,240])).toEqual(250)

	it "give 500 with data between 250 and 500",
	-> expect(window.chart.getMax([430,2,64,388])).toEqual(500)

	it "give 1000 with data between 500 and 1000",
	-> expect(window.chart.getMax([344,999,1,43])).toEqual(1000)