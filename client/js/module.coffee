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
      ],
      matchdays: ['$http', ($http) ->
        $http.get '/matchdays'
        .then (data) ->
          matchdays = {}
          for d in data.data
            matchdays[d.player] = d.score
          matchdays 
      ]
    views:
      'main':
        templateUrl: '/tpls/match/list.html'
        controller: ['$rootScope', '$state', 'users', 'matchdays', ($rootScope, $state, users, matchdays) ->
          user.matchdays = matchdays for user in users

          $rootScope.capsule =
            users: users
            matchdays: matchdays

          return
        ]
    auth: true




]

ra.run ['$location', ($location) ->
  a = $location
]