App.Output = Ember.Object.extend
  projectId: null
  name: null
  startDate: null
  endDate: null
  series: null

  url: (->
    "#{App.get('url')}/#{App.get('namespace')}/projects/#{@get('projectId')}/output"
  ).property('projectId')

  retrieveProperties: ->
    App.ajax "/projects/#{@get('projectId')}/output",
      dataType: 'json'
      success: (response) =>
        @setProperties(response.output)
        console.log(response, this)

App.Output.reopenClass
  retrieve: (projectId) ->
    overview = App.Output.create(projectId: projectId)
    overview.retrieveProperties()
    overview
