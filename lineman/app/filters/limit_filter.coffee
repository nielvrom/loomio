angular.module('loomioApp').filter 'limitByFn', ->
  (items, f) ->
    items.slice 0, f()
