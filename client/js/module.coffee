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
    url: "/matches"
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

          $rootScope.capsule.edit = $stateParams.edit
        ]
    auth: true




]

ra.run ['$rootScope', '$location', ($rootScope, $location) ->
  $rootScope.capsule = 
    users: []
    matchdays: []

  a = $location
]