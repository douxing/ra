ra = angular.module 'ra', ['ui.bootstrap', 'ui.router']

ra.config ["$stateProvider", "$urlRouterProvider", ($stateProvider, $urlRouterProvider) ->
  shiftTemplate = "<div class='container'><div class='jumbotron text-center'><p>Loading...</p></div></div>";
  $urlRouterProvider.otherwise "/"

  $stateProvider.state 'index',
    url: '/'
    views:
      'main':
        template: shiftTemplate
        controller: ['$state', '$window', ($state, $window) ->
          $window.setTimeout ->
            $state.go 'matches'
          , 0
        ]
  .state "matches", 
    url: "/matches/:manage"
    resolve:
      users: ['$http', ($http) ->
        $http.get '/users'
        .then (data) ->
          data.data
      ],
      matchdays: ['$http', ($http) ->
        $http.get '/matchdays'
        .then (data) ->
          for matchday in data.data
            scoreDict = {}
            scoreDict[obj.player] = obj for obj in matchday.scores
            matchday.scores = scoreDict
            days[matchday.id] = matchday
          days
      ]
    views:
      'main':
        templateUrl: '/tpls/match/list.html'
        controller: ['$rootScope', '$state', '$stateParams', 'users', 'matchdays', '$scope', '$modal', '$window'
          ($rootScope, $state, $stateParams, users, matchdays, $scope, $modal, $window) ->
            user.matchdays = matchdays for user in users

            $rootScope.capsule.users.splice 0, $rootScope.capsule.users.length
            $rootScope.capsule.users.push user for user in users
            $rootScope.capsule.matchdays.splice 0, $rootScope.capsule.matchdays.length
            $rootScope.capsule.matchdays.push matchday for matchday in matchdays

            $rootScope.capsule.manage = if $stateParams.manage is 'manage' then true else false

            $scope.changeScore = (user, matchday) ->
              modal = $modal.open
                templateUrl: '/tpls/matchday/score.html'
                controller: ['$scope', '$http', ($scope, $http) ->
                  $scope.user = user
                  $scope.matchday = matchday
                  $scope.user_matchday_score_origin = $scope.user_matchday_score = matchday.scores[user._id].score ? ''

                  $scope.ok = ->
                    score = $window.parseInt $scope.user_matchday_score
                    $http.post "/matchdays/#{matchday._id}/update_score",
                      player: user._id
                      score: score
                    .success (data, status, headers, config) ->
                      t = [data, status, headers, config]
                      user.matchdays[matchday.id] = if score then score else null
                      modal.close 'ok'
                    .error (data, status, headers, config) ->
                      t = [data, status, headers, config]
                      modal.dismiss 'error'
                  $scope.cancel = ->
                    modal.dismiss 'cancel'
                ]
                backdrop: 'static'

              modal.result.then ->
                return
              , ->
                return
        ]
    auth: true
  .state 'last12',
    url: '/last12'
    views:
      'main':
        templateUrl: '/tpls/match/last12.html'
        controller: ['$scope', ($scope) ->
          $scope
        ]
    auth: true




]

ra.run ['$rootScope', '$location', ($rootScope, $location) ->
  $rootScope.capsule =
    state_changing: false
    edit: false
    users: []
    matchdays: []

  $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
    t = [event, toState, toParams, fromState, fromParams]
    $rootScope.state_changing = true

  $rootScope.$on '$stateChangeError', (event, toState, toParams, fromState, fromParams) ->
    t = [event, toState, toParams, fromState, fromParams].
    $rootScope.state_changing = false

  $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
    t = [event, toState, toParams, fromState, fromParams]
    $rootScope.state_changing = false

  $rootScope.$on '$stateNotFound', (event, toState, toParams, fromState, fromParams) ->
    t = [event, toState, toParams, fromState, fromParams]
    $rootScope.state_changing = false
]