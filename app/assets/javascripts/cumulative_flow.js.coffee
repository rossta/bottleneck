class CumulativeFlow
  constructor: (@data) ->

  render: ->
    palette = new Rickshaw.Color.Palette( { scheme: 'classic9' } );

    _(@data).each((d) ->
      d.color = palette.color()
    )

    @data = _(@data).sortBy((d) ->
      d.position
    )

    graph = new Rickshaw.Graph
      element: document.querySelector("#chart")
      width: 550
      height: 250
      series: @data

    xAxis = new Rickshaw.Graph.Axis.Time
      graph: graph

    yAxis = new Rickshaw.Graph.Axis.Y
      graph: graph
      orientation: 'left'
      tickFormat: Rickshaw.Fixtures.Number.formatKMBT
      element: document.querySelector("#y_axis")

    legend = new Rickshaw.Graph.Legend
      element: document.querySelector("#legend")
      graph: graph

    slider = new Rickshaw.Graph.RangeSlider
      graph: graph
      element: $('#slider')

    graph.render()

  window.CumulativeFlow = CumulativeFlow
