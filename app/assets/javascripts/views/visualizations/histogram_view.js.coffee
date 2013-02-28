#= require views/visualizations/visualization_view
App.HistogramView = App.VisualizationView.extend
  histogram: (->
    firstElement = @get('content')[0]
    if firstElement.x and firstElement.y
      @get('content')
    else
      d3.layout.histogram()(@get('content'))
  ).property('content')

  xScale: (->
    width = @get('width')
    xMargin = @get('xMargin')
    d3.scale.ordinal()
      .domain(@get('histogram').map((d) -> d.x))
      .rangeRoundBands([0 - xMargin, width - xMargin])
  ).property('histogram')

  yScale: (->
    height  = @get('height')
    yMargin = @get('yMargin')
    d3.scale.linear()
      .domain([0, d3.max((d) -> d.y)])
      .range([height - yMargin, 0 + yMargin])
  ).property('histogram')

  didInsertElement: ->
    svg = @get('svg')
    xScale = @get('xScale')
    yScale = @get('yScale')
    height = @get('height')
    yMargin = @get('yMargin')

    svg.selectAll("rect")
      .data(@get('histogram'))
      .enter().append("rect")
      .attr("class", "sample")
      .attr("x", ((d) -> xScale(d.x)))
      .attr("y", ((d) -> yScale(d.x)))
      .attr("width", xScale.rangeBand())
      .attr("height", ((d) -> height - yMargin - yScale(d.y)))

    @_super()
