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
