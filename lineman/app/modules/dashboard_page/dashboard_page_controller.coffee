angular.module('loomioApp').controller 'DashboardPageController', ($scope, Records) ->

  $scope.loaded =
    date:
      unread: 0
      all: 0
    group:
      unread: 0
      all: 0
  $scope.perPage =
    date: 25
    group: 5
  $scope.expandedGroupSize = 10
  $scope.expandedGroups = []

  $scope.loadMore = (options = {}) ->
    callFetch(
      filter:  $scope.filter
      per:     $scope.perPage[$scope.sort]
      from:    $scope.loadedCount()
      groupId: options['groupId']).then ->
      return if options['groupId']
      $scope.loaded[$scope.sort][$scope.filter] = $scope.loadedCount() + $scope.perPage[$scope.sort]

  callFetch = (params) ->
    if $scope.sort == 'date' or params['groupId']
      Records.discussions.fetchInboxByDate(params)
    else
      Records.discussions.fetchInboxByGroup(params)

  $scope.loadedCount = (groupId) ->
    if $scope.groupIsExpanded(groupId)
      $scope.expandedGroupSize
    else
      $scope.loaded[$scope.sort][$scope.filter]

  $scope.groupIsExpanded = (groupId) ->
    _.find($scope.expandedGroups, (id) -> id == groupId)

  $scope.setOptions = (options = {}) ->
    $scope.filter = options['filter'] if options['filter']
    $scope.sort   = options['sort']   if options['sort']
    $scope.loadMore() if $scope.loadedCount() == 0
  $scope.setOptions sort: 'group', filter: 'all'

  $scope.dashboardDiscussions = ->
    _.sortBy(window.Loomio.currentUser.inboxDiscussions(), (discussion) ->
      $scope.lastInboxActivity(discussion))
      .slice(0, $scope.loadedCount())

  $scope.dashboardGroups = ->
    _.filter window.Loomio.currentUser.groups(), (group) -> group.isParent()

  $scope.footerReached = ->
    return false if $scope.loadingDiscussions
    $scope.loadingDiscussionsDate = true
    $scope.loadMore().then ->
      $scope.loadingDiscussionsDate = false

  $scope.loadMoreFromGroup = (group) ->
    return false if $scope.loadingDiscussions
    $scope["loadingDiscussions#{group.id}"] = true
    $scope.loadMore({groupId: group.id}).then ->
      $scope.expandedGroups.push group.id
      $scope["loadingDiscussions#{group.id}"] = false

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
    $scope.loadedCount() > 0 and _.find $scope.dashboardDiscussions(), (discussion) ->
      $scope.today(discussion) and $scope.unread(discussion)

  $scope.anyYesterday = ->
    $scope.loadedCount() > 0 and _.find $scope.dashboardDiscussions(), (discussion) ->
      $scope.yesterday(discussion) and $scope.unread(discussion)

  $scope.anyThisWeek = ->
   $scope.loadedCount() > 0 and  _.find $scope.dashboardDiscussions(), (discussion) ->
      $scope.thisWeek(discussion) and $scope.unread(discussion)

  $scope.anyThisMonth = ->
    $scope.loadedCount() > 0 and _.find $scope.dashboardDiscussions(), (discussion) ->
      $scope.thisMonth(discussion) and $scope.unread(discussion)

  $scope.anyOlder = ->
    $scope.loadedCount() > 0 and _.find $scope.dashboardDiscussions(), (discussion) ->
      $scope.older(discussion) and $scope.unread(discussion)

  $scope.groupName = (group) ->
    group.name

  $scope.anyThisGroup = (group) ->
    $scope.loadedCount() > 0 and _.find group.discussions(), (discussion) ->
      $scope.unread(discussion)
