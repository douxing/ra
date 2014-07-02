// Generated by CoffeeScript 1.7.1
var ra;

ra = angular.module('ra');

ra.controller('NavBarController', [
  '$scope', '$state', '$modal', function($scope, $state, $modal) {
    $scope.addUser = function() {
      var modal;
      modal = $modal.open({
        templateUrl: '/tpls/user/new.html',
        controller: [
          '$scope', '$http', function($scope, $http) {
            $scope.ok = function() {
              return $http.post('/users/add', {
                name: '无名'
              }).success(function(data, status, headers, config) {
                var t;
                t = [data, status, headers, config];
                return modal.close('ok');
              }).error(function(data, status, headers, config) {
                var t;
                t = [data, status, headers, config];
                return modal.dismiss('error');
              });
            };
            return $scope.cancel = function() {
              return modal.dismiss('cancel');
            };
          }
        ],
        backdrop: 'static'
      });
      return modal.result.then(function() {
        return $state.transitionTo($state.current, {}, {
          reload: true,
          inherit: true,
          notify: true
        });
      }, function() {});
    };
    $scope.addMatchday = function() {
      var modal;
      modal = $modal.open({
        templateUrl: '/tpls/matchday/new.html',
        controller: [
          '$scope', '$http', function($scope, $http) {
            $scope.ok = function() {
              return $http.post('/matchdays/add', {}).success(function(data, status, headers, config) {
                var t;
                t = [data, status, headers, config];
                return modal.close('ok');
              }).error(function(data, status, headers, config) {
                var t;
                t = [data, status, headers, config];
                return modal.dismiss('error');
              });
            };
            return $scope.cancel = function() {
              return modal.dismiss('cancel');
            };
          }
        ],
        backdrop: 'static'
      });
      return modal.result.then(function() {
        return $state.transitionTo($state.current, {}, {
          reload: true,
          inherit: true,
          notify: true
        });
      }, function() {});
    };
    $scope.viewMatches = function(edit) {
      return $state.go('matches', {
        edit: true,
        a: edit,
        b: 1
      });
    };
    return $scope.viewLast12 = function() {
      return $state.go('last12');
    };
  }
]);
