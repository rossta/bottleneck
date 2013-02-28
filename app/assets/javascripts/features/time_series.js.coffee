class TimeSeries
  constructor: (@data, @options = {}) ->

  render: ->
    # spectrum14
    # colorwheel
    # cool
    # spectrum2000
    # spectrum2001
    # classic9
    # munin

    palette = new Rickshaw.Color.Palette(scheme: 'classic9')
    palette.runningIndex = @options.colorIndex || 0;

    @data = _(@data).sortBy((d) ->
      -d.position
    )

    _(@data).each((d) ->
      console.log(d)
      d.color = palette.color(d.name)
    )

    graph = new Rickshaw.Graph
      element: document.querySelector("#chart")
      width: _.min([550, $(window).width() - 80]),
      height: 250
      stroke: true
      renderer: 'area'
      min: 'auto'
      series: @data

    xAxis = new Rickshaw.Graph.Axis.Time
      graph: graph
      ticksTreatment: 'glow'

    yAxis = new Rickshaw.Graph.Axis.Y
      graph: graph
      orientation: 'left'
      tickFormat: Rickshaw.Fixtures.Number.formatKMBT
      ticksTreatment: 'glow'
      element: document.querySelector("#y_axis")

    legend = new Rickshaw.Graph.Legend
      element: document.querySelector("#legend")
      graph: graph

    slider = new Rickshaw.Graph.RangeSlider
      graph: graph
      element: $('#slider')

    hoverDetail = new Rickshaw.Graph.HoverDetail
      graph: graph

    annotator = new Rickshaw.Graph.Annotate
      graph: graph
      element: document.getElementById('timeline')

    highlighter = new Rickshaw.Graph.Behavior.Series.Highlight
      graph: graph
      legend: legend

    shelving = new Rickshaw.Graph.Behavior.Series.Toggle
      graph: graph
      legend: legend

    order = new Rickshaw.Graph.Behavior.Series.Order
      graph: graph
      legend: legend

    graph.render()

window.TimeSeries = TimeSeries
