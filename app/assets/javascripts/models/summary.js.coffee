App.Summary = Ember.Object.extend
  projectId: null
  name: null
  time_zone: null
  current_wip: null
  starting_wip: null
  lead_time: null
  arrival_rate: null
  capacity: null
  average_wip: null
  average_lead_time: null
  average_arrival_rate: null

  retrieveProperties: ->
    App.ajax "/projects/#{@get('projectId')}/summary",
      success: (response) =>
        @setProperties(response.summary)
        console.log(this)

App.Summary.reopenClass
  retrieve: (projectId) ->
    summary = App.Summary.create(projectId: projectId)
    summary.retrieveProperties()
    summary
