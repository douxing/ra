ra = angular.module 'ra'

ra.controller 'NavBarController', [
  '$scope', '$rootScope', '$modal', ($scope, $rootScope, $modal) ->
    $scope.addUser = ->
      modal = $modal.open
        templateUrl: '/tpls/user/new.html'
        controller: ['$scope', '$http', ($scope, $http) ->
          $scope.ok = ->
            $http.post 'users/add', 
              name: '无名'
            .success (data) ->
              t = data
              modal.close 'ok'
            .error (data) ->
              t = data
              modal.dismiss 'error'
          $scope.cancel = ->
            modeal.dismiss 'cancel'
        ]
        backdrop: 'static'

      modal.result.then ->
        return
      , ->
        return

    $scope.addMatchday = ->
      modal = $modal.open
        templateUrl: '/tpls/matchday/new.html'
        controller: ['$scope', '$http', ($scope, $http) ->
          $scope.ok = ->
            $http.post 'matchday/add'
            .success (data) ->
              t = data
              modal.close 'ok'
            .error (data) ->
              t = data
              modal.dismiss 'error'
          $scope.cancel = ->
            modeal.dismiss 'cancel'
        ]
        backdrop: 'static'

      modal.result.then ->
        return
      , ->
        return


]
