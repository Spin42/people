class Hrguru.Models.User extends Backbone.Model

  visibleBy:
    users: true
    roles: true
    projects: true
    locations: true

  membership: null

  initialize: ->
    super
    @set('daysToEndMembership', -1)
    @next_projects = new Hrguru.Models.Project(@get('next_projects'))
    @initMembership()
    @listenTo(EventAggregator, 'users:updateVisibility', @updateVisibility)

  initMembership: ->
    return unless @get('membership')
    @membership = new Hrguru.Models.Membership(@get('membership'))
    if @membership.started && @membership.hasEndDate()
      @set('daysToEndMembership', @membership.daysToEnd())

  updateVisibility: (data) ->
    @visibleBy.roles = @visibleByRoles(data.roles)
    @visibleBy.projects = @visibleByProjects(data.projects)
    @visibleBy.locations = @visibleByLocations(data.locations)
    @visibleBy.users = @visibleByUsers(data.users)
    @trigger 'toggle_visible', @isVisible()

  isVisible: ->
    @visibleBy.roles && @visibleBy.projects && @visibleBy.users && @visibleBy.locations

  visibleByUsers: (users) ->
    return true if users.length < 1
    @id in users

  visibleByRoles: (roles) ->
    return true if roles.length < 1
    return false unless @get('role')?
    @get('role')._id in roles

  visibleByProjects: (projects) ->
    return true if projects.length < 1
    return false unless @get('projects')?
    myProjects = @myProjects()
    (_.difference myProjects, projects).length < myProjects.length

  visibleByLocations: (locations) ->
    return true if locations.length < 1
    return false unless @get('location')?
    @get('location')._id in locations

  myProjects: ->
    _.map @get("projects"), (p) -> p.project._id

  isActive: ->
    !@get('archived')

  hasTechnicalRole: ->
    @get('role').technical

  isPotential: ->
    return false unless @hasTechnicalRole()
    if @get('has_project') && !@hasProjectsOnlyPotentialOrNotbillable()
      return false unless @get('daysToEndMembership') < 30 && @membership.hasEndDate()
    (!@hasNextProjects() || @nextProjectsOnlyPotentialOrNotbillable())

  hasNextProjects: ->
    @next_projects?

  hasProjectsOnlyPotentialOrNotbillable: ->
    @areOnlyPotenialOrNotbillable(@get('projects'))

  nextProjectsOnlyPotentialOrNotbillable: ->
    @areOnlyPotenialOrNotbillable(@next_projects)

  areOnlyPotenialOrNotbillable: (projects) ->
    _.all projects, (project) =>
      @userProjectIsPotential(project) or !@userProjectIsBillable(project)

  userProjectIsPotential: (next_project) ->
    next_project.project.potential

  userProjectIsBillable: (current_project) ->
    current_project.billable

class Hrguru.Collections.Users extends Backbone.Collection
  model: Hrguru.Models.User
  url: Routes.users_path()

  sortAttribute: 'name'
  sortDirection: 1

  sortUsers: (attr) ->
    @sortAttribute = attr
    @sort()
    return

  comparator: (a, b) ->
    a = a.get(@sortAttribute)
    b = b.get(@sortAttribute)
    return 0 if a is b
    if @sortDirection is 1
      return -1 unless a
      return 1 unless b
      (if a > b then 1 else -1)
    else
      return 1 unless a
      return -1 unless b
      (if a < b then 1 else -1)
