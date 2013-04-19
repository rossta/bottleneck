App.Project = DS.Model.extend
  name: DS.attr('string')
  lists: DS.hasMany('App.List')
