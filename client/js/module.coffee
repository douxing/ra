ra = angular.module 'ra', ['ui.bootstrap', 'ui.router']

ra.config ["$stateProvider", "$urlRouterProvider", ($stateProvider, $urlRouterProvider) ->
  shiftTemplate = "<div class='container'><div class='jumbotron text-center'><p>...</p><p>Shifting...</p></div></div>";
  $urlRouterProvider.otherwise "/"

  $stateProvider.state 'index',
    url: '/'
    views:
      template: shiftTemplate
      controller: ['$state', ($state) ->
        $state.go 'match.list'
      ]
  .state "match.list", 
    url: "/matches"
    resolve:
      users: ['$http', ($http) ->
        users = [
          id: '1'
          name: 'one'
        ,
          id: '2'
          name: 'two'
        ,
          id: '3'
          name: 'three'
        ]
      ],
      matchdays: ['$http', ($http) ->
        matchdays = [
          id: '1'
          seq: '1'
          date: '2014-06-20'
          scores: [
            id: '1'
            score: '2.66'
          ,
            id: '2'
            score: '0.33'
          ,
            id: '3'
            score: '0.33'
          ]
          ,
          id: '2'
          seq: '2'
          date: '2014-06-27'
          scores: [
            user_id: '1'
            score: '2.0'
          ,
            user_id: '2'
            score: '1.0'
          ]
        ]
      ]
    views:
      'main':
        templateUrl: '/tpls/match/list.html'
        controller: ['$scope', '$state', 'users', 'matchdays', ($scope, $state, users, matchdays) ->
          for user in users
            user.scores = for matchday in matchdays
              score = null
              for s in matchday.scores
                if s.user_id is user.id
                  score = s.score
                  break
              marchday_score =
                user_id: user.id
                matchday_id: matchday.id
                score: score

          $scope.capsule =
            users: users
            matchdays: matchdays

          return
        ]
    auth: true




]