App.ApplicationController = Ember.Controller.extend()

App.Controller = Ember.Controller.extend
  currentUser: null

App.ObjectController = Ember.ObjectController.extend
  currentUser: null

App.CurrentUserController = Ember.ObjectController.extend
  content: null

  autenticated: (->
    App.get('token')?
  ).property('App.token')

  isSignedIn: (->
    @get('content')?
  ).property('content')

  setUser: (attributes) ->
    App.set('token', attributes.authentication_token)
    @store.load(App.User, attributes)
    @set('content', App.User.find(attributes.id))

  authenticate: ->
    if @get('isSignedIn')
      @get('content')
    else
      App.ajax '/users/me',
        success: (data) =>
          @setUser(data.user)

App.ProjectsController = Ember.ArrayController.extend
  startProject: ->
    console.log("startProject")

App.ProjectController = App.ObjectController.extend()

App.ProjectNavController = App.ObjectController.extend
  currentRoute: null
  isFlow: (-> @get('currentRoute') == "project.flow").property('currentRoute')
  isSummary: (-> @get('currentRoute') == "project.summary").property('currentRoute')
  isOutput: (-> @get('currentRoute') == "project.output").property('currentRoute')
  isBreakdown: (-> @get('currentRoute') == "project.breakdown").property('currentRoute')
  isSettings: (-> @get('currentRoute') == "project.settings").property('currentRoute')
  isDates: (-> @get('currentRoute') == "project.dates").property('currentRoute')

App.ProjectSummaryController = Ember.ObjectController.extend
  need: ["project"]

App.ProjectOutputController = Ember.ObjectController.extend()

App.ProjectBreakdownController = Ember.ArrayController.extend
  name: "Breakdown"

App.BreakdownController = Ember.ArrayController.extend
  name: "Breakdown"

App.NavigationController = App.Controller.extend
  needs: ['currentUser']

App.ProjectFlowController = Ember.ObjectController.extend
  title: (->
    "Cumulative Flow"
  ).property('startDate', 'endDate')

  dateDescription: (->
    "#{this.formatDate(this.get('startDate'))}
        to #{this.formatDate(this.get('endDate'))}"
  ).property('startDate', 'endDate')

  formatDate: (date) ->
    moment(date).format(this.get('format'))

  format: "MMM Do, YYYY"

App.TimeSeriesController = Ember.ArrayController.extend
  content: []
