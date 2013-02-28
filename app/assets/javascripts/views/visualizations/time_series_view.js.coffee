App.TimeSeriesView = Ember.View.extend
  templateName: "visualizations/time_series"
  content: null

  graph: null
  palette: null

  contentDidChange: (->
    this.get('graph').update()
  ).observes('content.@each.value')

  height: (->
    250
  ).property()

  width: (->
    d3.min([550, $(window).width() - 80])
  ).property()

  createGraph: ->
    window.flowView = this
    data = @get('content')
    console.log("data", data)

    @set('palette', new Rickshaw.Color.Palette(scheme: 'classic9'))
    @get('palette').runningIndex = 0;

    data.forEach((d) =>
      console.log(d)
      d.color = @get('palette').color(d.name)
    )

    graph = new Rickshaw.Graph
      element: @$(".chart")[0]
      width: @get('width')
      height: @get('height')
      stroke: true
      renderer: 'area'
      min: 'auto'
      series: data

    @set('graph', graph)

    xAxis = new Rickshaw.Graph.Axis.Time
      graph: graph
      ticksTreatment: 'glow'

    @set('xAxis', xAxis)

    yAxis = new Rickshaw.Graph.Axis.Y
      graph: graph
      orientation: 'left'
      tickFormat: Rickshaw.Fixtures.Number.formatKMBT
      ticksTreatment: 'glow'
      element: @$(".y_axis")[0]

    @set('yAxis', yAxis)

    legend = new Rickshaw.Graph.Legend
      element: @$(".legend")[0]
      graph: graph

    @set('legend', legend)

    # requires jquery.ui
    # slider = new Rickshaw.Graph.RangeSlider
    #   graph: graph
    #   element: @$('.slider')

    hoverDetail = new Rickshaw.Graph.HoverDetail
      graph: graph

    @set('hoverDetail', hoverDetail)

    annotator = new Rickshaw.Graph.Annotate
      graph: graph
      element: @$('.timeline')[0]

    @set('annotator', annotator)

    highlighter = new Rickshaw.Graph.Behavior.Series.Highlight
      graph: graph
      legend: legend

    @set('highlighter', highlighter)

    # requires jquery.ui
    shelving = new Rickshaw.Graph.Behavior.Series.Toggle
      graph: graph
      legend: legend

    # order = new Rickshaw.Graph.Behavior.Series.Order
    #   graph: graph
    #   legend: legend

    graph.render()

  didInsertElement: ->
    @createGraph()
