App.CumulativeFlow = DS.Model.extend
  name: DS.attr('string')
  startDate: DS.attr('date')
  endDate: DS.attr('date')
  series: DS.attr('array')
