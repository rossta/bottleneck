App.User = DS.Model.extend
  name: DS.attr('string')
  email: DS.attr('string')
  authenticationToken: DS.attr('string')
