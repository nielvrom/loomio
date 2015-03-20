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
    return false if $scope.loadingDiscussionsDate
    $scope.loadingDiscussionsDate = true
    $scope.loadMore().then ->
      $scope.loadingDiscussionsDate = false

  $scope.loadMoreFromGroup = (group) ->
    loadKey = "loadingDiscussions#{group.id}"
    return false if $scope[loadKey]
    $scope[loadKey] = true
    $scope.loadMore(groupId: group.id).then ->
      $scope.expandedGroups.push group.id
      $scope[loadKey] = false

  $scope.unread = (discussion) ->
    discussion.isUnread() or $scope.filter != 'unread'

  $scope.lastInboxActivity = (discussion) ->
    -discussion.lastInboxActivity()

  timeframe = (options = {}) ->
    today = moment().startOf 'day'
    (discussion) ->
      discussion.lastInboxActivity()
                .isBetween(today.clone().subtract(options['fromCount'] or 1, options['from']),
                           today.clone().subtract(options['toCount'] or 1, options['to']))

  inTimeframe = (fn) ->
    ->
      $scope.loadedCount() > 0 and _.find $scope.dashboardDiscussions(), (discussion) ->
        fn(discussion) and $scope.unread(discussion)

  $scope.today     = timeframe(from: 'second', toCount: -10, to: 'year')
  $scope.yesterday = timeframe(from: 'day', to: 'second')
  $scope.thisWeek  = timeframe(from: 'week', to: 'day')
  $scope.thisMonth = timeframe(from: 'month', to: 'week')
  $scope.older     = timeframe(fromCount: 3, from: 'month', to: 'month')

  $scope.anyToday     = inTimeframe($scope.today)
  $scope.anyYesterday = inTimeframe($scope.yesterday)
  $scope.anyThisWeek  = inTimeframe($scope.thisWeek)
  $scope.anyThisMonth = inTimeframe($scope.thisMonth)
  $scope.anyOlder     = inTimeframe($scope.older)

  $scope.groupName = (group) ->
    group.name

  $scope.anyThisGroup = (group) ->
    $scope.loadedCount() > 0 and _.find group.discussions(), (discussion) ->
      $scope.unread(discussion)
