App.BarChartLegendView = Ember.View.extend
  templateName: "visualizations/bar_chart_legend"

  classNames: ["ext_rickshaw_legend"]

  data: (->
    @get('content')
  ).property('content')
