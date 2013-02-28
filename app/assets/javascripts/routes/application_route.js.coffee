App.ApplicationRoute = Ember.Route.extend
  activate: (controller) ->
    App.set('currentUserController', @controllerFor('currentUser'))
    @controllerFor('currentUser').authenticate()

App.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo("projects")

App.ProjectsRoute = Ember.Route.extend
  model: ->
    App.Project.find()

App.ProjectRoute = Ember.Route.extend
  model: (params) ->
    App.Project.find(params.project_id)

App.ProjectSummaryRoute = Ember.Route.extend
  setupController: (controller, model) ->
    console.log(model.id)
    @controllerFor('projectNav').set('currentRoute', @get('routeName'))

  model: (params) ->
    project_id = @modelFor("project").id
    App.Summary.retrieve(project_id)

App.ProjectFlowRoute = Ember.Route.extend
  model: (params) ->
    project_id = @modelFor("project").id
    App.CumulativeFlow.find(project_id)

  setupController: ->
    console.log("setupController", "series", this.model().get('series'))
    @controllerFor('projectNav').set('currentRoute', @get('routeName'))
    @controllerFor('timeSeries').set('content', this.model().get('series'))

App.ProjectOutputRoute = Ember.Route.extend
  model: (params) ->
    project_id = @modelFor("project").id
    App.Output.retrieve(project_id)

  setupController: ->
    console.log("setupController", "series", this.model().get('series'))
    @controllerFor('projectNav').set('currentRoute', @get('routeName'))
    @controllerFor('timeSeries').set('content', this.model().get('series'))
    window.timeSeriesController = @controllerFor('timeSeries')

App.ProjectBreakdownRoute = Ember.Route.extend
  setupController: (controller) ->
    # content = []
    # for x in [0..10]
    #   do (x) =>
    #     x = parseInt(Math.random() * 10, 10)
    #     y = parseInt(Math.random() * 10, 10)
    #     content.pushObject(x: x, y: y)
    content = [{"id":250,"name":"[Feb 6][L] Users can click \"Register\" button","count":0},{"id":307,"name":"[Feb 19] [M] Remove unused email notification types","count":0},{"id":321,"name":"[Feb 19][S] Discover page shows featured challenges when nothing matches filters","count":0},{"id":269,"name":"[Feb 13] (M) Update Mixpanel Analytics","count":3},{"id":294,"name":"[Feb 18][S] Ability to customize help text on submission forms","count":1},{"id":305,"name":"[Feb 15] #821 Challenge guidelines only show up if you fill in both Eligibility and Submission Requirements fields","count":4},{"id":292,"name":"[Feb 8] \u26a0 Links to challenges on the discover page should not use the https protocol.","count":3},{"id":323,"name":"[Feb 19] [S] Remove unused emails","count":2}]
    controller.set("content", content)
    @controllerFor('projectNav').set('currentRoute', @get('routeName'))

App.ProjectSettingsRoute = Ember.Route.extend
  setupController: ->
    @controllerFor('projectNav').set('currentRoute', @get('routeName'))
