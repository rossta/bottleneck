class CumulativeFlow
  constructor: (@data) ->

  render: ->
    # spectrum14
    # colorwheel
    # cool
    # spectrum2000
    # spectrum2001
    # classic9
    # munin

    palette = new Rickshaw.Color.Palette( { scheme: 'munin' } )

    @data = _(@data).sortBy((d) ->
      -d.position
    )

    _(@data).each((d) ->
      d.color = palette.color()
    )

    graph = new Rickshaw.Graph
      element: document.querySelector("#chart")
      width: 550
      height: 250
      stroke: true
      renderer: 'area'
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

  window.CumulativeFlow = CumulativeFlow
