class ProjectSpinner
  constructor: (@selector) ->

  opts:
    width: 4, # The line thickness
    radius: 10, # The radius of the inner circle
    corners: 1, # Corner roundness (0..1)
    rotate: 0, # The rotation offset
    color: '#000', # #rgb or #rrggbb
    speed: 1, # Rounds per second
    trail: 60, # Afterglow percentage
    shadow: false, # Whether to render a shadow
    hwaccel: false, # Whether to use hardware acceleration
    className: 'spinner', # The CSS class to assign to the spinner
    zIndex: 2e9, # The z-index (defaults to 2000000000)
    top: 'auto', # Top position relative to parent in px
    left: 'auto' # Left position relative to parent in px

  spin: ->
    new Spinner(@opts).spin($(@selector)[0])

class ProjectListForm
  constructor: (@selector) ->

  enable: ->
    $(@selector).submit (e) ->
      # e.preventDefault()
      $.ajax(
        type: "PUT"
        url: $(this).attr('action')
        data: $(this).serialize()
        dataType: 'json'
      )
      false

@ProjectSpinner = ProjectSpinner
@ProjectListForm = ProjectListForm
