App.List = DS.Model.extend
  name: DS.attr('string'),
  project: DS.belongsTo('App.Project')
