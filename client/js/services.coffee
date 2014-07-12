ra = angular.module 'ra'

ra.factory 'UserService', ['$http', ($http) ->
  sdo =
    id: null
    name: ''
    reload: ->
      # TODO: reload

]