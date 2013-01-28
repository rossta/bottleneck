class CardCountChartAlt
  constructor: (@selector, @data = {}) ->
    @palette = new Rickshaw.Color.Palette(scheme: 'classic9')

  rearrange: =>
    x = @x
    xAxis = @xAxis
    data = @data
    svg = @svg
    sort = ->
      x0 = x.domain(data.sort(
            if @checked
            then ((a, b) -> b.count - a.count)
            else ((a, b) -> d3.ascending(a.name, b.name))
          )
          .map((d) -> d.name))
          .copy()

      transition = svg.transition().duration(750)
      delay = (d, i) -> i * 50

      transition.selectAll(".bar")
        .delay(delay)
        .attr("x", (d) -> x0(d.name))

      transition.select(".x.axis")
          .call(xAxis)
        .selectAll("g")
          .delay(delay)

    d3.select("#{@selector} input").on("change", sort)

  render: ->
    console.log(@data)
    margin =
      top: 20
      right: 20
      bottom: 30
      left: 40

    width   = 550 - margin.left - margin.right
    height  = 500 - margin.top - margin.bottom

    @x = d3.scale.ordinal().rangeRoundBands([0, width], .1, 1)
    @y = d3.scale.linear().range([height, 0])

    @xAxis = d3.svg.axis().scale(@x).orient("bottom")
    @yAxis = d3.svg.axis().scale(@y).orient("left")
    xAxis = @xAxis
    yAxis = @yAxis

    $(@selector).css("position", "relative")

    @svg = d3.select(@selector).append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

    @x.domain(@data.map((d) -> d.name))
    @y.domain([0, d3.max(@data, (d) -> d.count)])

    @svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0,#{height})")
      .call(xAxis)

    @svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
      .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("Days")

    @svg.selectAll(".bar")
        .data(@data)
      .enter().append("rect")
        .attr("class", "bar")
        .attr("x", (d) =>
          @x(d.name))
        .attr("width", @x.rangeBand())
        .attr("y", (d) =>
          @y(d.count))
        .attr("fill", (d) => @palette.color())
        .attr("height", (d) =>
          height - @y(d.count))

    @rearrange()

window.CardCountChartAlt = CardCountChartAlt
