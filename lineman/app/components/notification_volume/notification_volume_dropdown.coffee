angular.module('loomioApp').directive 'notificationVolumeDropdown', ->
  scope: {translateRoot: '@', group: '=?', discussion: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/notification_volume/notification_volume_dropdown.html'
  replace: true
  controller: 'NotificationVolumeDropdownController'
  link: (scope, element, attrs) ->
