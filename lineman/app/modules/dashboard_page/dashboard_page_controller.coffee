angular.module('loomioApp').controller 'DashboardPageController', ($scope, Records) ->

  $scope.pageHash = { unread: {}, all: {} }
  $scope.perPage  = { date: 25, group: 5 }

  $scope.refresh = (options = {}) ->
    params =
      filter:  $scope.filter
      per:     $scope.perPage[$scope.sort]
      from:    $scope.limitFor(options['groupId'] or 'date')
      groupId: options['groupId']
    if $scope.sort == 'date' or options['groupId']
      Records.discussions.fetchInboxByDate  params
    else
      Records.discussions.fetchInboxByGroup params

  $scope.limitFor = (field = 'date') ->
    $scope.pageHash[$scope.filter][field] or 0

  $scope.iterateLimit = (field = 'date') ->
    $scope.pageHash[$scope.filter][field] = $scope.limitFor(field) + $scope.perPage[$scope.sort]

  $scope.setOptions = (options = {}) ->
    $scope.filter = options['filter'] if options['filter']
    $scope.sort   = options['sort']   if options['sort']
    $scope.refresh()
  $scope.setOptions sort: 'group', filter: 'all'
  $scope.iterateLimit()

  $scope.dashboardDiscussions = ->
    _.sortBy(window.Loomio.currentUser.inboxDiscussions(), (discussion) ->
      $scope.lastInboxActivity(discussion))
      .slice(0, $scope.limitFor('date'))

  $scope.dashboardGroups = ->
    _.filter window.Loomio.currentUser.groups(), (group) -> group.isParent()
  _.each $scope.dashboardGroups(), (group) -> $scope.iterateLimit(group.id)

  $scope.footerReached = ->
    return false if $scope.loadingDiscussions
    $scope.loadingDiscussionsDate = true
    $scope.loadMore().then ->
      $scope.loadingDiscussionsDate = false

  $scope.loadMoreFromGroup = (group) ->
    return false if $scope.loadingDiscussions
    $scope["loadingDiscussions#{group.id}"] = true
    $scope.loadMore({groupId: group.id}).then ->
      $scope["loadingDiscussions#{group.id}"] = false

  $scope.loadMore = (options = {}) ->
    $scope.refresh(options).then -> $scope.iterateLimit(options['groupId'])

  $scope.unread = (discussion) ->
    discussion.isUnread() or $scope.filter != 'unread'

  $scope.lastInboxActivity = (discussion) ->
    -discussion.lastInboxActivity()

  $scope.startOfDay = ->
    moment().startOf('day').clone()

  $scope.today = (discussion) ->
    discussion.lastInboxActivity().isAfter $scope.startOfDay()

  $scope.yesterday = (discussion) ->
    discussion.lastInboxActivity().isBetween($scope.startOfDay().subtract(1, 'day'), $scope.startOfDay())

  $scope.thisWeek = (discussion) ->
    discussion.lastInboxActivity().isBetween($scope.startOfDay().subtract(1, 'week'), $scope.startOfDay().subtract(1, 'day'))

  $scope.thisMonth = (discussion) ->
    discussion.lastInboxActivity().isBetween($scope.startOfDay().subtract(1, 'month'), $scope.startOfDay().subtract(1, 'week'))

  $scope.older = (discussion) ->
    discussion.lastInboxActivity().isBefore($scope.startOfDay().subtract(1, 'month'))

  $scope.anyToday = ->
    _.find $scope.dashboardDiscussions(), (discussion) ->
      $scope.today(discussion) and $scope.unread(discussion)

  $scope.anyYesterday = ->
    _.find $scope.dashboardDiscussions(), (discussion) ->
      $scope.yesterday(discussion) and $scope.unread(discussion)

  $scope.anyThisWeek = ->
    _.find $scope.dashboardDiscussions(), (discussion) ->
      $scope.thisWeek(discussion) and $scope.unread(discussion)

  $scope.anyThisMonth = ->
    _.find $scope.dashboardDiscussions(), (discussion) ->
      $scope.thisMonth(discussion) and $scope.unread(discussion)

  $scope.anyOlder = ->
    _.find $scope.dashboardDiscussions(), (discussion) ->
      $scope.older(discussion) and $scope.unread(discussion)

  $scope.groupName = (group) ->
    group.name

  $scope.anyThisGroup = (group) ->
    _.find group.discussions(), (discussion) ->
      $scope.unread(discussion)