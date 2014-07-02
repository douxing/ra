// Generated by CoffeeScript 1.7.1
var ra;

ra = angular.module('ra', ['ui.bootstrap', 'ui.router']);

ra.config([
  "$stateProvider", "$urlRouterProvider", function($stateProvider, $urlRouterProvider) {
    var shiftTemplate;
    shiftTemplate = "<div class='container'><div class='jumbotron text-center'><p>Loading...</p></div></div>";
    $urlRouterProvider.otherwise("/");
    return $stateProvider.state('index', {
      url: '/',
      views: {
        'main': {
          template: shiftTemplate,
          controller: [
            '$state', '$window', function($state, $window) {
              return $window.setTimeout(function() {
                return $state.go('matches');
              }, 0);
            }
          ]
        }
      }
    }).state("matches", {
      url: "/matches",
      resolve: {
        users: [
          '$http', function($http) {
            return $http.get('/users').then(function(data) {
              return data.data;
            });
          }
        ],
        matchdays: [
          '$http', function($http) {
            return $http.get('/matchdays').then(function(data) {
              var days, matchday, _i, _len, _ref;
              days = [];
              _ref = data.data;
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                matchday = _ref[_i];
                days[matchday.id] = matchday;
              }
              return days;
            });
          }
        ]
      },
      views: {
        'main': {
          templateUrl: '/tpls/match/list.html',
          controller: [
            '$rootScope', '$state', '$stateParams', 'users', 'matchdays', function($rootScope, $state, $stateParams, users, matchdays) {
              var matchday, user, _i, _j, _k, _len, _len1, _len2;
              for (_i = 0, _len = users.length; _i < _len; _i++) {
                user = users[_i];
                user.matchdays = matchdays;
              }
              $rootScope.capsule.users.splice(0, $rootScope.capsule.users.length);
              for (_j = 0, _len1 = users.length; _j < _len1; _j++) {
                user = users[_j];
                $rootScope.capsule.users.push(user);
              }
              $rootScope.capsule.matchdays.splice(0, $rootScope.capsule.matchdays.length);
              for (_k = 0, _len2 = matchdays.length; _k < _len2; _k++) {
                matchday = matchdays[_k];
                $rootScope.capsule.matchdays.push(matchday);
              }
              return $rootScope.capsule.edit = $stateParams.edit;
            }
          ]
        }
      },
      auth: true
    }).state('last12', {
      url: '/last12',
      views: {
        'main': {
          templateUrl: '/tpls/match/last12.html',
          controller: [
            '$scope', function($scope) {
              return $scope;
            }
          ]
        }
      },
      auth: true
    });
  }
]);

ra.run([
  '$rootScope', '$location', function($rootScope, $location) {
    $rootScope.capsule = {
      state_changing: false,
      edit: false,
      users: [],
      matchdays: []
    };
    $rootScope.$on('$stateChangeStart', function(event, toState, toParams, fromState, fromParams) {
      var t;
      t = [event, toState, toParams, fromState, fromParams];
      return $rootScope.state_changing = true;
    });
    $rootScope.$on('$stateChangeError', function(event, toState, toParams, fromState, fromParams) {
      var t;
      return t = [event, toState, toParams, fromState, fromParams].$rootScope.state_changing = false;
    });
    $rootScope.$on('$stateChangeSuccess', function(event, toState, toParams, fromState, fromParams) {
      var t;
      t = [event, toState, toParams, fromState, fromParams];
      return $rootScope.state_changing = false;
    });
    return $rootScope.$on('$stateNotFound', function(event, toState, toParams, fromState, fromParams) {
      var t;
      t = [event, toState, toParams, fromState, fromParams];
      return $rootScope.state_changing = false;
    });
  }
]);
