var ra = angular.module('ra', []);

ra.controller('RootController', [
'$scope', '$http',
function ($scope, $http) {
  $scope.rootCapsule = {
    rankers: [],
    players: [],
    error: ''    
  }

  users = null
  matchdays = null
  $scope.getRankers = function() {
    $http.jsonp('http://122.226.182.22:8080/users?callback=JSON_CALLBACK').then(function (data) {
      users = data.data
      // $http.get('http://122.226.182.22:8080/matchdays12').then(function (data) {
      //   matchdays = {}
      //   for(var i = 0; i < data.data.length; ++i) {
      //     matchday = data.data[i];
      //     scoreDict = {};
      //     for(var j = 0; j < matchdays.scores.length; ++j) {
      //       scoreDict[obj.player] = matchdays.scores[j];
      //     }
      //     matchday.scores = scoreDict
      //     matchdays[matchday.id] = matchday
      //   }



      // }, function (error) {
      //   $scope.rootCapsule.error = '网络错误：比赛日'
      // });
      rankers.splice(0, rankers.length);
      for(i = 0; i < users.length; ++i) {
        rankers.push(user);
      }
    }, function(error) {
      $scope.rootCapsule.error = '网络错误：用户'
    });

  }

}]);