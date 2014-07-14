ra = angular.module 'ra', ['ui.bootstrap', 'ui.router', 'ngGrid']

ra.config ["$stateProvider", "$urlRouterProvider", ($stateProvider, $urlRouterProvider) ->
  shiftTemplate = "<div class='container'><div class='jumbotron text-center'><p>Loading...</p></div></div>"
  guestTemplate = "<div class='container'><div class='jumbotron text-center'><p>请登录</p></div></div>"
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
  .state 'guest',
    url: '/guest'
    views:
      'main':
        template: guestTemplate
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
        controller: ['$rootScope', '$state', '$stateParams', 'users', 'matchdays', '$scope', '$http', '$window'
          ($rootScope, $state, $stateParams, users, matchdays, $scope, $http, $window) ->
            headerCellTemplate = """
<div class="ngHeaderSortColumn {{col.headerClass}}" ng-style="{'cursor': col.cursor}" ng-class="{ 'ngSorted': !noSortVisible }"><div ng-click="col.sort($event)" ng-class="'colt' + col.index" class="ngHeaderText">{{col.displayName}}</div><div class="ngSortButtonDown" ng-show="col.showSortButtonDown()"></div><div class="ngSortButtonUp" ng-show="col.showSortButtonUp()"></div><div class="ngSortPriority">{{col.sortPriority}}</div><div ng-class="{ ngPinnedIcon: col.pinned, ngUnPinnedIcon: !col.pinned }" ng-click="togglePin(col)" ng-show="false"></div></div><div ng-show="col.resizable" class="ngHeaderGrip" ng-click="col.gripClick($event)" ng-mousedown="col.gripOnMouseDown($event)"></div>
"""
            $scope.matchListCapsule =
              gridOptions:
                data: 'matchListCapsule.gridData'
                enablePinning: true
                enableCellSelection: $stateParams.manage is 'manage'
                enableRowSelection: false
                enableCellEdit: $stateParams.manage is 'manage'
                columnDefs: [
                  { 
                    field: 'player'
                    width: 110
                    sortable: false
                    pinned: true
                    enableCellEdit: false
                    displayName: '球员/比赛日'
                  }
                ]
              gridData: []

            for matchday in matchdays
              $scope.matchListCapsule.gridOptions.columnDefs.push
                field: "#{matchday.id}"
                displayName: "No.#{matchday.id + 1}"
                width: 80
                sortable: false
                headerCellTemplate: headerCellTemplate

            for user in users
              user.matchday = 
                player: user.name
              for matchday in matchdays
                user.matchday[matchday.id] = ''
                if matchday.scores[user._id] and matchday.scores[user._id].score
                  user.matchday[matchday.id] = matchday.scores[user._id].score
                else
                  user.matchday[matchday.id].score = ''
                
              $scope.matchListCapsule.gridData.push user.matchday

            originalScore = null
            $scope.$on 'ngGridEventStartCellEdit', (event, args...) ->
              console.log "EndCellEdit: #{event}, #{args}"
              originalScore = $scope.matchListCapsule.gridData[event.targetScope.row.rowIndex][event.targetScope.col.field]

            $scope.$on 'ngGridEventEndCellEdit', (event, args...) ->
              console.log "EndCellEdit: #{event}, #{args}"
              score = $scope.matchListCapsule.gridData[event.targetScope.row.rowIndex][event.targetScope.col.field]
              matchday = matchdays[event.targetScope.col.field]
              user = users[event.targetScope.row.rowIndex]
              $http.post "/matchdays/#{matchday._id}/update_score",
                player: user._id
                score: score
              .success (data, status, headers, config) ->
                t = [data, status, headers, config]
                data.score = '' unless data.score
                matchday.scores[user._id] = data
                $scope.matchListCapsule.gridData[event.targetScope.row.rowIndex][event.targetScope.col.field] = "#{data.score}"
              .error (data, status, headers, config) ->
                t = [data, status, headers, config]
                $scope.matchListCapsule.gridData[event.targetScope.row.rowIndex][event.targetScope.col.field] = originalScore
                        

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

ra.run ['$rootScope', '$location', 'UserService', '$state', ($rootScope, $location, UserService, $state) ->
  $rootScope.rootCapsule =
    state_changing: false
    edit: false
    current_user: UserService

  reload = UserService.reload()

  $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
    t = [event, toState, toParams, fromState, fromParams]
    $rootScope.rootCapsule.state_changing = true

    if toState.auth
      reload.then ->
        unless UserService._id
          $state.go 'guest'
          event.preventDefault()

  $rootScope.$on '$stateChangeError', (event, toState, toParams, fromState, fromParams) ->
    t = [event, toState, toParams, fromState, fromParams]
    $rootScope.rootCapsule.state_changing = false

  $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
    t = [event, toState, toParams, fromState, fromParams]
    $rootScope.rootCapsule.state_changing = false

  $rootScope.$on '$stateNotFound', (event, toState, toParams, fromState, fromParams) ->
    t = [event, toState, toParams, fromState, fromParams]
    $rootScope.rootCapsule.state_changing = false
]