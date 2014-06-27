// Generated by CoffeeScript 1.7.1
var ra;

ra = angular.module('ra', ['ui.bootstrap', 'ui.router']);

ra.config([
  "$stateProvider", "$urlRouterProvider", function($stateProvider, $urlRouterProvider) {
    var shiftTemplate;
    shiftTemplate = "<div class='container'><div class='jumbotron text-center'><p>...</p><p>Shifting...</p></div></div>";
    $urlRouterProvider.otherwise("/");
    return $stateProvider.state('index', {
      url: '/',
      views: {
        'main': {
          template: shiftTemplate,
          controller: [
            '$state', function($state) {
              return $state.go('match.list');
            }
          ]
        }
      }
    }).state("match.list", {
      url: "/matches",
      resolve: {
        users: [
          '$http', function($http) {
            var users;
            return users = [
              {
                id: '1',
                name: 'one'
              }, {
                id: '2',
                name: 'two'
              }, {
                id: '3',
                name: 'three'
              }
            ];
          }
        ],
        matchdays: [
          '$http', function($http) {
            var matchdays;
            return matchdays = [
              {
                id: '1',
                seq: '1',
                date: '2014-06-20',
                scores: [
                  {
                    id: '1',
                    score: '2.66'
                  }, {
                    id: '2',
                    score: '0.33'
                  }, {
                    id: '3',
                    score: '0.33'
                  }
                ],
                id: '2',
                seq: '2',
                date: '2014-06-27',
                scores: [
                  {
                    user_id: '1',
                    score: '2.0'
                  }, {
                    user_id: '2',
                    score: '1.0'
                  }
                ]
              }
            ];
          }
        ]
      },
      views: {
        'main': {
          templateUrl: '/tpls/match/list.html',
          controller: [
            '$scope', '$state', 'users', 'matchdays', function($scope, $state, users, matchdays) {
              var marchday_score, matchday, s, score, user, _i, _len;
              for (_i = 0, _len = users.length; _i < _len; _i++) {
                user = users[_i];
                user.scores = (function() {
                  var _j, _k, _len1, _len2, _ref, _results;
                  _results = [];
                  for (_j = 0, _len1 = matchdays.length; _j < _len1; _j++) {
                    matchday = matchdays[_j];
                    score = null;
                    _ref = matchday.scores;
                    for (_k = 0, _len2 = _ref.length; _k < _len2; _k++) {
                      s = _ref[_k];
                      if (s.user_id === user.id) {
                        score = s.score;
                        break;
                      }
                    }
                    _results.push(marchday_score = {
                      user_id: user.id,
                      matchday_id: matchday.id,
                      score: score
                    });
                  }
                  return _results;
                })();
              }
              $scope.capsule = {
                users: users,
                matchdays: matchdays
              };
            }
          ]
        }
      },
      auth: true
    });
  }
]);

ra.run([
  '$location', function($location) {
    var a;
    return a = $location;
  }
]);
