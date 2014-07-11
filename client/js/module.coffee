ra = angular.module 'ra', ['ui.bootstrap', 'ui.router', 'ngGrid']

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

            $rootScope.rootCapsule.users.splice 0, $rootScope.rootCapsule.users.length
            $rootScope.rootCapsule.users.push user for user in users
            $rootScope.rootCapsule.matchdays.splice 0, $rootScope.rootCapsule.matchdays.length
            $rootScope.rootCapsule.matchdays.push matchday for matchday in matchdays

            $rootScope.rootCapsule.manage = if $stateParams.manage is 'manage' then true else false

            headerCellTemplate = '''
<div class="ngHeaderSortColumn {{col.headerClass}}" ng-style="{'cursor': col.cursor}" ng-class="{ 'ngSorted': !noSortVisible }"><div ng-click="col.sort($event)" ng-class="'colt' + col.index" class="ngHeaderText">{{col.displayName}}</div><div class="ngSortButtonDown" ng-show="col.showSortButtonDown()"></div><div class="ngSortButtonUp" ng-show="col.showSortButtonUp()"></div><div class="ngSortPriority">{{col.sortPriority}}</div><div ng-class="{ ngPinnedIcon: col.pinned, ngUnPinnedIcon: !col.pinned }" ng-click="togglePin(col)" ng-show="false"></div></div><div ng-show="col.resizable" class="ngHeaderGrip" ng-click="col.gripClick($event)" ng-mousedown="col.gripOnMouseDown($event)"></div>
            '''

            $scope.capsule = 
              myData: [
                { name: "Moroni", age: 50, birthday: "Oct 28, 1970", salary: "60,000" },
                    { name: "Tiancum", age: 43, birthday: "Feb 12, 1985", salary: "70,000" },
                    { name: "Jacob", age: 27, birthday: "Aug 23, 1983", salary: "50,000" },
                    { name: "Nephi", age: 29, birthday: "May 31, 2010", salary: "40,000" },
                    { name: "Enos", age: 34, birthday: "Aug 3, 2008", salary: "30,000" },
                    { name: "Moroni", age: 50, birthday: "Oct 28, 1970", salary: "60,000" },
                    { name: "Tiancum", age: 43, birthday: "Feb 12, 1985", salary: "70,000" },
                    { name: "Jacob", age: 27, birthday: "Aug 23, 1983", salary: "40,000" },
                    { name: "Nephi", age: 29, birthday: "May 31, 2010", salary: "50,000" },
                    { name: "Enos", age: 34, birthday: "Aug 3, 2008", salary: "30,000" },
                    { name: "Moroni", age: 50, birthday: "Oct 28, 1970", salary: "60,000" },
                    { name: "Tiancum", age: 43, birthday: "Feb 12, 1985", salary: "70,000" },
                    { name: "Jacob", age: 27, birthday: "Aug 23, 1983", salary: "40,000" },
                    { name: "Nephi", age: 29, birthday: "May 31, 2010", salary: "50,000" },
                    { name: "Enos", age: 34, birthday: "Aug 3, 2008", salary: "30,000" }
              ]
              gridOptions:
                enablePinning: true
                columnDefs: [{ field: "name", width: 120, pinned: true, headerCellTemplate: headerCellTemplate },
                    { field: "age", width: 120 },
                    { field: "birthday1", width: 120 },
                    { field: "salary", width: 120 }
                  ]
                data: 'capsule.myData'

            $scope.changeScore = (user, matchday) ->
              modal = $modal.open
                templateUrl: '/tpls/matchday/score.html'
                controller: ['$scope', '$http', ($scope, $http) ->
                  $scope.user = user
                  $scope.matchday = matchday
                  $scope.user_matchday_score_origin = $scope.user_matchday_score = matchday.scores[user._id]?.score ? ''

                  $scope.ok = ->
                    $http.post "/matchdays/#{matchday._id}/update_score",
                      player: user._id
                      score: $scope.user_matchday_score
                    .success (data, status, headers, config) ->
                      t = [data, status, headers, config]
                      matchday.scores[user._id] = data
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
  $rootScope.rootCapsule =
    state_changing: false
    edit: false
    users: []
    matchdays: []

  $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
    t = [event, toState, toParams, fromState, fromParams]
    $rootScope.state_changing = true

  $rootScope.$on '$stateChangeError', (event, toState, toParams, fromState, fromParams) ->
    t = [event, toState, toParams, fromState, fromParams]
    $rootScope.state_changing = false

  $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
    t = [event, toState, toParams, fromState, fromParams]
    $rootScope.state_changing = false

  $rootScope.$on '$stateNotFound', (event, toState, toParams, fromState, fromParams) ->
    t = [event, toState, toParams, fromState, fromParams]
    $rootScope.state_changing = false
]