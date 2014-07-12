ra = angular.module 'ra'

ra.controller 'NavBarController', [
  '$scope', '$state', '$modal', ($scope, $state, $modal) ->
    $scope.addUser = ->
      modal = $modal.open
        templateUrl: '/tpls/user/new.html'
        controller: ['$scope', '$http', ($scope, $http) ->
          $scope.user = 
            name: ''
            auth:
              email: ''
              password: ''
          $scope.ok = ->
            $http.post '/users/add', $scope.user
            .success (data, status, headers, config) ->
              t = [data, status, headers, config]
              modal.close 'ok'
            .error (data, status, headers, config) ->
              t = [data, status, headers, config]
              modal.dismiss 'error'
          $scope.cancel = ->
            modal.dismiss 'cancel'
        ]
        backdrop: 'static'

      modal.result.then ->
        $state.transitionTo $state.current, {}, { reload: true, inherit: true, notify: true }
      , ->
        return

    $scope.addMatchday = ->
      modal = $modal.open
        templateUrl: '/tpls/matchday/new.html'
        controller: ['$scope', '$http', ($scope, $http) ->
          $scope.ok = ->
            $http.post '/matchdays/add', {}
            .success (data, status, headers, config) ->
              t = [data, status, headers, config]
              modal.close 'ok'
            .error (data, status, headers, config) ->
              t = [data, status, headers, config]
              modal.dismiss 'error'
          $scope.cancel = ->
            modal.dismiss 'cancel'
        ]
        backdrop: 'static'

      modal.result.then ->
        $state.transitionTo $state.current, {}, { reload: true, inherit: true, notify: true }
      , ->
        return

    $scope.viewMatches = (edit) ->
      manage = if edit then 'manage' else null
      $state.go 'matches', 
        manage: manage

    $scope.viewLast12 =  ->
      $state.go 'last12'
]
