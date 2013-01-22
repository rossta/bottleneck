class CardCountChartAlt
  constructor: (@selector, @data) ->

  render: ->
    palette = new Rickshaw.Color.Palette(scheme: 'classic9')

    # _(@data).each((d) ->
    #   d.color = palette.color()
    # )

    graph = new Rickshaw.Graph
      element: document.querySelector("#chart")
      width: 550
      height: 250
      renderer: 'bar'
      series: @data

    graph.render()

window.CardCountChartAlt = CardCountChartAlt
