#= require handlebars
#= require ember
#= require ember-data
#= require_self
#= require bottleneck

Application = Ember.Application.extend
  LOG_TRANSITIONS: true
  rootElement: '#main'
  store: 'App.Store'
  namespace: "api"
  endpoint: (->
    "#{@get('namespace')}"
  ).property('namespace')

  ajax: (path, opts = {}) ->
    url = "#{@get('endpoint')}#{path}"
    $.ajax url, $.extend({ dataType: 'json' }, opts)

  ready: ->
    console.log('ready')

App = Bottleneck = Application.create()

App.Store = DS.Store.extend
  revision: 11
  adapter: 'App.RESTAdapter'

App.RESTAdapter = DS.RESTAdapter.extend
  url: App.get("url")
  namespace: App.get("namespace")

App.store = App.Store.create()

window.App = App
window.Bottleneck = Bottleneck

$.fn.sortable = ->
