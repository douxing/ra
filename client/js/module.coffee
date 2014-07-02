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
          days = []
          for matchday in data.data
            days[matchday.id] = matchday
          days
      ]
    views:
      'main':
        templateUrl: '/tpls/match/list.html'
        controller: ['$rootScope', '$state', '$stateParams', 'users', 'matchdays', ($rootScope, $state, $stateParams, users, matchdays) ->
          user.matchdays = matchdays for user in users

          $rootScope.capsule.users.splice 0, $rootScope.capsule.users.length
          $rootScope.capsule.users.push user for user in users
          $rootScope.capsule.matchdays.splice 0, $rootScope.capsule.matchdays.length
          $rootScope.capsule.matchdays.push matchday for matchday in matchdays

          $rootScope.capsule.manage = if $stateParams.manage is 'manage' then true else false
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