#= require views/visualizations/visualization_view
App.BarChartView = App.VisualizationView.extend
  classNames: ["rickshaw_graph"]

  margin: {top: 20, right: 20, bottom: 30, left: 40}

  height: (->
    250
  ).property()

  width: (->
    d3.min([@get('data').length * @get('barWidth'), Ember.$(window).width() - 40])
  ).property('data')

  innerWidth: (->
    @get("width") - @get("margin.left") - @get("margin.right")
  ).property()

  barWidth: 50

  innerHeight: (->
    @get("height") - @get("margin.top") - @get("margin.top")
  ).property()

  xScale: (->
    d3.scale.ordinal().rangeRoundBands([0, @get('innerWidth')], 0.5)
  ).property('innerWidth')

  yScale: (->
    d3.scale.linear().range([@get('innerHeight'), 0])
  ).property('innerHeight')

  xAxis: (->
    d3.svg.axis().scale(@get("xScale")).orient("bottom")
  ).property("xScale")

  yAxis: (->
    d3.svg.axis().scale(@get("yScale")).orient("left")
  ).property("yScale")

  yTicks: (->
    Math.floor(@get("height") / @get("pixelsPerTick"));
  ).property("height")

  xTicks: (->
    Math.floor(@get("width") / @get("pixelsPerTick"));
  ).property("width")

  tickSize: 4

  pixelsPerTick: 75

  didInsertElement: ->
    data   = @get("data")
    width  = @get("innerWidth")
    height = @get("innerHeight")
    xScale = @get("xScale")
    yScale = @get("yScale")
    xAxis  = @get("xAxis")
    yAxis  = @get("yAxis")
    margin = @get("margin")
    xTicks = @get("xTicks")
    yTicks = @get("yTicks")

    color = d3.scale.category10()

    svg = d3.select("##{@$().attr("id")}")

    svg = svg.append("g")
      .attr("transform", "translate(#{margin.left}, #{margin.top})")

    xScale.domain(data.map((d) -> d.id))
    yScale.domain([0, d3.max(data, ((d) -> d.count))])

    svg.append("g")
      .attr("class", "y_ticks")
      .call(yAxis.ticks(yTicks).tickSubdivide(0).tickSize(@get("tickSize")))
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".70em")
      .style("text-anchor", "end")
      .text("Days")

    svg.append("g")
      .attr("class", "y_grid")
      .call(yAxis.ticks(yTicks).tickSubdivide(0).tickSize(-width))

    svg.append("g")
      .attr("class", "x_grid_d3")
      .call(xAxis.ticks(xTicks).tickSubdivide(0).tickSize(height));

    svg.selectAll("bar")
      .data(data)
    .enter()
      .append("rect")
      .style("opacity", 1)
      .style("fill", ((d, i) -> color(i)))
      .attr("class", "bar")
      .attr("x", ((d) -> xScale(d.id)))
      .attr("width", xScale.rangeBand())
      .attr("y", height)
      .attr("height", 1)
      .transition()
      .duration(2000)
      .attr("y", ((d) -> yScale(d.count)))
      .attr("height", ((d) -> d3.max([height - yScale(d.count), 2])))

    svg.selectAll("rect")
      .on("mouseover", (d) ->
        d3.select(this).transition().style("opacity", 0.75)
      )
      .on("mouseout", (d, i) ->
        d3.select(this).transition().style("opacity", 1)
      )

# CardListHistory = (function() {
#   function CardListHistory(selector, data) {

#     var valueLabelWidth = 40; // space reserved for value labels (right)
#     var barHeight = 20; // height of one bar
#     var barLabelWidth = 100; // space reserved for bar labels
#     var barLabelPadding = 5; // padding between bar and bar labels (left)
#     var gridLabelHeight = 18; // space reserved for gridline labels
#     var gridChartOffset = 3; // space between start of grid and first bar
#     var maxBarWidth = 420; // width of the bar with the max value
#     var palette = new Rickshaw.Color.Palette( { scheme: 'classic9' } );

#     // accessor functions
#     var barLabel = function(d) { return d['x']; };
#     var barValue = function(d) { return parseInt(d['y']); };

#     // scales
#     var yScale = d3.scale.ordinal().domain(d3.range(0, data.length)).rangeBands([0, data.length * barHeight]);
#     var y = function(d, i) { return yScale(i); };
#     var yText = function(d, i) { return y(d, i) + yScale.rangeBand() / 2; };
#     var x = d3.scale.linear().domain([0, d3.max(data, barValue)]).range([0, maxBarWidth]);
#     // svg container element
#     var chart = d3.select(selector).append("svg")
#       .attr('width', maxBarWidth + barLabelWidth + valueLabelWidth)
#       .attr('height', gridLabelHeight + gridChartOffset + data.length * barHeight);
#     // grid line labels
#     var gridContainer = chart.append('g')
#       .attr('transform', 'translate(' + barLabelWidth + ',' + gridLabelHeight + ')');
#     gridContainer.selectAll("text").data(x.ticks(10)).enter().append("text")
#       .attr("x", x)
#       .attr("dy", -3)
#       .attr("text-anchor", "middle")
#       .text(String);
#     // vertical grid lines
#     gridContainer.selectAll("line").data(x.ticks(10)).enter().append("line")
#       .attr("x1", x)
#       .attr("x2", x)
#       .attr("y1", 0)
#       .attr("y2", yScale.rangeExtent()[1] + gridChartOffset)
#       .style("stroke", "#ccc");
#     // bar labels
#     var labelsContainer = chart.append('g')
#       .attr('transform', 'translate(' + (barLabelWidth - barLabelPadding) + ',' + (gridLabelHeight + gridChartOffset) + ')');
#     labelsContainer.selectAll('text').data(data).enter().append('text')
#       .attr('y', yText)
#       .attr('stroke', 'none')
#       .attr('fill', 'black')
#       .attr("dy", ".35em") // vertical-align: middle
#       .attr('text-anchor', 'end')
#       .text(barLabel);
#     // bars
#     var barsContainer = chart.append('g')
#       .attr('transform', 'translate(' + barLabelWidth + ',' + (gridLabelHeight + gridChartOffset) + ')');
#     barsContainer.selectAll("rect").data(data).enter().append("rect")
#       .attr('y', y)
#       .attr('height', yScale.rangeBand())
#       .attr('width', function(d) { return x(barValue(d)); })
#       .attr('stroke', 'white')
#       .attr('fill', function() { return palette.color() });
#     // bar value labels
#     barsContainer.selectAll("text").data(data).enter().append("text")
#       .attr("x", function(d) { return x(barValue(d)); })
#       .attr("y", yText)
#       .attr("dx", 3) // padding-left
#       .attr("dy", ".35em") // vertical-align: middle
#       .attr("text-anchor", "start") // text-align: right
#       .attr("fill", "black")
#       .attr("stroke", "none")
#       .text(function(d) { return d3.round(barValue(d), 2); });
#     // start line
#     barsContainer.append("line")
#       .attr("y1", -gridChartOffset)
#       .attr("y2", yScale.rangeExtent()[1] + gridChartOffset)
#       .style("stroke", "#000");
#   }

#   return CardListHistory;
