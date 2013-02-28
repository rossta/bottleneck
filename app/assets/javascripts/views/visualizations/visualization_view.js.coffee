App.VisualizationView = Ember.View.extend
  tagName: 'svg'

  data: (->
    @get("content")
  ).property("content")

  attributeBindings: ['width', 'height', 'preserveAspectRatio', 'viewBox']

  xMargin: 0

  yMargin: 0

  xScale: (->
    d3.scale.linear()
  ).property('content').cacheable()

  yScale: (->
    d3.scale.linear()
  ).property('content').cacheable()

  xFormatter: (x) ->
    x

  yFormatter: (y) ->
    y

  xAxis: (->
    d3.svg.axis().scale(@get('xScale')).orient('bottom').tickFormat(@get('xFormatter'))
  ).property('xScale')

  yAxis: (->
    d3.svg.axis().scale(@get('yScale')).orient('left').tickFormat(@get('yFormatter'))
  ).property('yScale')

  svg: (->
    d3.select("##{@$().attr('id')}")
  ).property()

  didInsertElement: ->
    svg         = @get('svg')
    xScale      = @get('xScale')
    yScale      = @get('yScale')
    xMargin     = @get('xMargin')
    yMargin     = @get('yMargin')
    width       = @get('width')
    height      = @get('height')
    xFormatter  = @get('xFormatter')
    yFormatter  = @get('yFormatter')
    xAxis       = @get('xAxis')
    yAxis       = @get('yAxis')

    svg.append('g')
      .attr('class', 'x axis')
      .attr("transform", "translate(0, #{(height - yMargin)})")
      .call(xAxis)

    svg.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate(#{xMargin}, 0)")
      .call(yAxis)

    svg.insert("g", ":first-child")
      .attr("class", "x grid")
      .attr("transform", "translate(0, #{(height - yMargin)})")
      .call(xAxis.tickSize(-height + (yMargin * 2), 0, 0).tickFormat(""))

    svg.insert("g", ":first-child")
      .attr("class", "y grid")
      .attr("transform", "translate(#{xMargin}, 0)")
      .call(yAxis.tickSize(-width + (xMargin * 2), 0, 0).tickFormat(""))
