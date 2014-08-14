// Generated by CoffeeScript 1.7.1
var ra,
  __slice = [].slice;

ra = angular.module('ra', ['ui.bootstrap', 'ui.router', 'ngGrid', 'ngCookies']);

ra.config([
  "$stateProvider", "$urlRouterProvider", function($stateProvider, $urlRouterProvider) {
    var guestTemplate, shiftTemplate;
    shiftTemplate = "<div class='container'><div class='jumbotron text-center'><p>Loading...</p></div></div>";
    guestTemplate = "<div class='container'><div class='jumbotron text-center'><p>请登录</p></div></div>";
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
    }).state('guest', {
      url: '/guest',
      views: {
        'main': {
          template: guestTemplate
        }
      }
    }).state("matches", {
      url: "/matches/:manage",
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
              var days, matchday, obj, scoreDict, _i, _j, _len, _len1, _ref, _ref1;
              days = [];
              _ref = data.data;
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                matchday = _ref[_i];
                scoreDict = {};
                _ref1 = matchday.scores;
                for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                  obj = _ref1[_j];
                  scoreDict[obj.player] = obj;
                }
                matchday.scores = scoreDict;
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
            '$rootScope', '$state', '$stateParams', 'users', 'matchdays', '$scope', '$http', '$window', function($rootScope, $state, $stateParams, users, matchdays, $scope, $http, $window) {
              var cellTemplate, headerCellTemplate, matchday, originalScore, user, _i, _j, _k, _len, _len1, _len2;
              headerCellTemplate = "<div class=\"ngHeaderSortColumn {{col.headerClass}}\" ng-style=\"{'cursor': col.cursor}\" ng-class=\"{ 'ngSorted': !noSortVisible }\"><div ng-click=\"col.sort($event)\" ng-class=\"'colt' + col.index\" class=\"ngHeaderText\">{{col.displayName}}</div><div class=\"ngSortButtonDown\" ng-show=\"col.showSortButtonDown()\"></div><div class=\"ngSortButtonUp\" ng-show=\"col.showSortButtonUp()\"></div><div class=\"ngSortPriority\">{{col.sortPriority}}</div><div ng-class=\"{ ngPinnedIcon: col.pinned, ngUnPinnedIcon: !col.pinned }\" ng-click=\"togglePin(col)\" ng-show=\"false\"></div></div><div ng-show=\"col.resizable\" class=\"ngHeaderGrip\" ng-click=\"col.gripClick($event)\" ng-mousedown=\"col.gripOnMouseDown($event)\"></div>";
              cellTemplate = "<div class=\"ngCellText\" ng-class=\"col.colIndex()\"><span ng-cell-text title='{{COL_FIELD}}'>{{COL_FIELD}}</span></div>";
              $scope.matchListCapsule = {
                gridOptions: {
                  data: 'matchListCapsule.gridData',
                  enablePinning: true,
                  enableCellSelection: $stateParams.manage === 'manage',
                  enableRowSelection: false,
                  enableCellEdit: $stateParams.manage === 'manage',
                  columnDefs: [
                    {
                      field: 'player',
                      width: 110,
                      sortable: false,
                      pinned: true,
                      enableCellEdit: false,
                      displayName: '球员/比赛日'
                    }
                  ]
                },
                gridData: []
              };
              for (_i = 0, _len = matchdays.length; _i < _len; _i++) {
                matchday = matchdays[_i];
                $scope.matchListCapsule.gridOptions.columnDefs.push({
                  field: "" + matchday.id,
                  displayName: "No." + (matchday.id + 1),
                  width: 80,
                  sortable: false,
                  headerCellTemplate: headerCellTemplate,
                  cellTemplate: cellTemplate
                });
              }
              for (_j = 0, _len1 = users.length; _j < _len1; _j++) {
                user = users[_j];
                user.matchday = {
                  player: user.name
                };
                for (_k = 0, _len2 = matchdays.length; _k < _len2; _k++) {
                  matchday = matchdays[_k];
                  user.matchday[matchday.id] = '';
                  if (matchday.scores[user._id] && matchday.scores[user._id].score) {
                    user.matchday[matchday.id] = matchday.scores[user._id].score;
                    if ($stateParams.manage !== 'manage') {
                      user.matchday[matchday.id] = user.matchday[matchday.id].toFixed(2);
                    }
                  }
                }
                $scope.matchListCapsule.gridData.push(user.matchday);
              }
              originalScore = null;
              $scope.$on('ngGridEventStartCellEdit', function() {
                var args, event;
                event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
                console.log("EndCellEdit: " + event + ", " + args);
                return originalScore = $scope.matchListCapsule.gridData[event.targetScope.row.rowIndex][event.targetScope.col.field];
              });
              return $scope.$on('ngGridEventEndCellEdit', function() {
                var args, event, score;
                event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
                console.log("EndCellEdit: " + event + ", " + args);
                score = $scope.matchListCapsule.gridData[event.targetScope.row.rowIndex][event.targetScope.col.field];
                matchday = matchdays[event.targetScope.col.field];
                user = users[event.targetScope.row.rowIndex];
                return $http.post("/matchdays/" + matchday._id + "/update_score", {
                  player: user._id,
                  score: score
                }).success(function(data, status, headers, config) {
                  var t;
                  t = [data, status, headers, config];
                  if (!data.score) {
                    data.score = '';
                  }
                  matchday.scores[user._id] = data;
                  return $scope.matchListCapsule.gridData[event.targetScope.row.rowIndex][event.targetScope.col.field] = "" + data.score;
                }).error(function(data, status, headers, config) {
                  var t;
                  t = [data, status, headers, config];
                  return $scope.matchListCapsule.gridData[event.targetScope.row.rowIndex][event.targetScope.col.field] = originalScore;
                });
              });
            }
          ]
        }
      },
      auth: true
    }).state('last12', {
      url: '/last12',
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
            return $http.get('/matchdays12').then(function(data) {
              var days, matchday, obj, scoreDict, _i, _j, _len, _len1, _ref, _ref1;
              days = {};
              _ref = data.data;
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                matchday = _ref[_i];
                scoreDict = {};
                _ref1 = matchday.scores;
                for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                  obj = _ref1[_j];
                  scoreDict[obj.player] = obj;
                }
                matchday.scores = scoreDict;
                days[matchday.id] = matchday;
              }
              return days;
            });
          }
        ]
      },
      views: {
        'main': {
          templateUrl: '/tpls/match/last12.html',
          controller: [
            '$scope', 'users', 'matchdays', function($scope, users, matchdays) {
              var attend_counter, base, cellTemplate, counter, data, denominator, first, id, matchday, matchdays_last_week, matchdays_this_week, num, numerator, sum_score, sum_score_last_week, t, user, weightScore, _i, _j, _k, _l, _len, _len1, _len2, _ref, _ref1, _results;
              t = [$scope, users, matchdays];
              (function($rootScope, $state, $stateParams, users, matchdays, $scope, $http, $window) {});
              cellTemplate = "<div class=\"ngCellText\" ng-class=\"col.colIndex()\"><span ng-cell-text title='{{COL_FIELD}}'>{{COL_FIELD}}</span></div>";
              $scope.matchListCapsule = {
                gridOptions: {
                  data: 'matchListCapsule.gridData',
                  enableRowSelection: false,
                  columnDefs: [
                    {
                      field: 'player',
                      sortable: false,
                      enableCellEdit: false,
                      displayName: ''
                    }
                  ]
                },
                gridData: []
              };
              matchdays_this_week = {};
              matchdays_last_week = {};
              first = true;
              counter = 0;
              for (id in matchdays) {
                matchday = matchdays[id];
                if (first) {
                  matchdays_last_week[id] = matchday;
                  first = false;
                } else if (counter === 12) {
                  matchdays_this_week[id] = matchday;
                } else {
                  matchdays_last_week[id] = matchday;
                  matchdays_this_week[id] = matchday;
                }
                counter += 1;
              }
              for (id in matchdays_this_week) {
                matchday = matchdays_this_week[id];
                $scope.matchListCapsule.gridOptions.columnDefs.push({
                  field: "" + id,
                  displayName: "No." + (matchday.id + 1),
                  sortable: false,
                  cellTemplate: cellTemplate
                });
              }
              $scope.matchListCapsule.gridOptions.columnDefs.push({
                field: "season_score",
                displayName: "结算分",
                cellTemplate: cellTemplate
              });
              $scope.matchListCapsule.gridOptions.columnDefs.push({
                field: "season_rank",
                displayName: "排名",
                cellTemplate: cellTemplate
              });
              $scope.matchListCapsule.gridOptions.columnDefs.push({
                field: "season_rank_diff",
                displayName: "成绩增减",
                cellTemplate: cellTemplate
              });
              weightScore = function(score, counter) {
                if (counter >= 7) {
                  return score;
                }
                if (counter === 6) {
                  return 0.95 * score;
                }
                if (counter === 5) {
                  return 0.90 * score;
                }
                if (counter === 4) {
                  return 0.8 * score;
                }
                if (counter === 3) {
                  return 0.6 * score;
                }
                if (counter === 2) {
                  return 0.4 * score;
                }
                if (counter === 1) {
                  return 0.2 * score;
                }
                return 0;
              };
              denominator = 0;
              for (num = _i = 9; _i <= 20; num = ++_i) {
                denominator += num;
              }
              for (_j = 0, _len = users.length; _j < _len; _j++) {
                user = users[_j];
                user.matchday_this_week = {
                  player: user.name
                };
                attend_counter = 0;
                base = 1.5;
                numerator = 9;
                sum_score = 0.0;
                for (id in matchdays_this_week) {
                  matchday = matchdays_this_week[id];
                  user.matchday_this_week[id] = '';
                  if (matchday.scores[user._id] && matchday.scores[user._id].score) {
                    sum_score += (matchday.scores[user._id].score - base) * numerator / denominator;
                    user.matchday_this_week[id] = matchday.scores[user._id].score.toFixed(2);
                    attend_counter += 1;
                  }
                  numerator += 1;
                }
                sum_score += base;
                user.matchday_this_week['season_score'] = weightScore(sum_score, attend_counter);
                attend_counter = 0;
                numerator = 9;
                sum_score_last_week = 0.0;
                for (id in matchdays_last_week) {
                  matchday = matchdays_last_week[id];
                  if (matchday.scores[user._id] && matchday.scores[user._id].score) {
                    sum_score_last_week += (matchday.scores[user._id].score - base) * numerator / denominator;
                    attend_counter += 1;
                  }
                  numerator += 1;
                }
                sum_score_last_week += base;
                user.matchday_this_week['season_score_last_week'] = weightScore(sum_score_last_week, attend_counter);
                $scope.matchListCapsule.gridData.push(user.matchday_this_week);
              }
              $scope.matchListCapsule.gridData.sort(function(m1, m2) {
                return m2.season_score_last_week - m1.season_score_last_week;
              });
              counter = 1;
              _ref = $scope.matchListCapsule.gridData;
              for (_k = 0, _len1 = _ref.length; _k < _len1; _k++) {
                data = _ref[_k];
                data['season_rank_last_week'] = counter;
                counter += 1;
              }
              $scope.matchListCapsule.gridData.sort(function(m1, m2) {
                return m2.season_score - m1.season_score;
              });
              counter = 1;
              _ref1 = $scope.matchListCapsule.gridData;
              _results = [];
              for (_l = 0, _len2 = _ref1.length; _l < _len2; _l++) {
                data = _ref1[_l];
                data['season_rank'] = counter;
                data['season_rank_diff'] = data['season_rank_last_week'] - data['season_rank'];
                data['season_score'] = data['season_score'].toFixed(3);
                _results.push(counter += 1);
              }
              return _results;
            }
          ]
        }
      }
    });
  }
]);

ra.run([
  '$rootScope', '$location', 'UserService', '$state', function($rootScope, $location, UserService, $state) {
    var reload;
    $rootScope.rootCapsule = {
      state_changing: false,
      edit: false,
      current_user: UserService
    };
    reload = UserService.reload();
    $rootScope.$on('$stateChangeStart', function(event, toState, toParams, fromState, fromParams) {
      var t;
      t = [event, toState, toParams, fromState, fromParams];
      $rootScope.rootCapsule.state_changing = true;
      return reload.then(function() {
        if (toState.auth) {
          if (!UserService._id) {
            $state.go('last12');
            return event.preventDefault();
          }
        }
      });
    });
    $rootScope.$on('$stateChangeError', function(event, toState, toParams, fromState, fromParams) {
      var t;
      t = [event, toState, toParams, fromState, fromParams];
      return $rootScope.rootCapsule.state_changing = false;
    });
    $rootScope.$on('$stateChangeSuccess', function(event, toState, toParams, fromState, fromParams) {
      var t;
      t = [event, toState, toParams, fromState, fromParams];
      return $rootScope.rootCapsule.state_changing = false;
    });
    return $rootScope.$on('$stateNotFound', function(event, toState, toParams, fromState, fromParams) {
      var t;
      t = [event, toState, toParams, fromState, fromParams];
      return $rootScope.rootCapsule.state_changing = false;
    });
  }
]);
