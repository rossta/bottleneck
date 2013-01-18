CardCountChartAlt = (function() {
  function CardCountChartAlt(selector, data) {
    var palette = new Rickshaw.Color.Palette( { scheme: 'classic9' } );

    var graph = new Rickshaw.Graph( {
      element: document.querySelector(selector),
      renderer: 'bar',
      series: [{
        data: data,
        color: 'steelblue'
      }]
    });

    graph.render();
  }

  return CardCountChartAlt;
})();
