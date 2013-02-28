Bottleneck.Router.map ->
  @resource 'projects'
  @resource 'project', path: '/projects/:project_id', ->
    @route 'summary'
    @route 'flow'
    @route 'output'
    @route 'breakdown'
    @route 'settings'
    @route 'dates'
