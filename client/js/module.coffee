ra = angular.module 'ra', ['ui.bootstrap', 'ui.router', 'ngGrid', 'ngCookies']

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
            cellTemplate = """
<div class="ngCellText" ng-class="col.colIndex()"><span ng-cell-text title='{{COL_FIELD}}'>{{COL_FIELD}}</span></div>
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
                cellTemplate: cellTemplate

            for user in users
              user.matchday = 
                player: user.name
              for matchday in matchdays
                user.matchday[matchday.id] = ''
                if matchday.scores[user._id] and matchday.scores[user._id].score
                  user.matchday[matchday.id] = matchday.scores[user._id].score
                  unless $stateParams.manage is 'manage'
                    user.matchday[matchday.id] = user.matchday[matchday.id].toFixed(2)
                
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
    resolve:
      users: ['$http', ($http) ->
        $http.get '/users'
        .then (data) ->
          data.data
      ],
      matchdays: ['$http', ($http) ->
        $http.get '/matchdays12'
        .then (data) ->
          days = {}
          for matchday in data.data
            scoreDict = {}
            scoreDict[obj.player] = obj for obj in matchday.scores
            matchday.scores = scoreDict
            days[matchday.id] = matchday
          days
      ]
    views:
      'main':
        templateUrl: '/tpls/match/last12.html'
        controller: ['$scope', 'users', 'matchdays'
          ($scope, users, matchdays) ->
            t = [$scope, users, matchdays]
            ($rootScope, $state, $stateParams, users, matchdays, $scope, $http, $window) ->
            cellTemplate = """
<div class="ngCellText" ng-class="col.colIndex()"><span ng-cell-text title='{{COL_FIELD}}'>{{COL_FIELD}}</span></div>
"""
            $scope.matchListCapsule =
              gridOptions:
                data: 'matchListCapsule.gridData'
                enableRowSelection: false
                columnDefs: [
                  { 
                    field: 'player'
                    sortable: false
                    enableCellEdit: false
                    displayName: ''
                  }
                ]
              gridData: []

            for id, matchday of matchdays
              $scope.matchListCapsule.gridOptions.columnDefs.push
                field: "#{id}"
                displayName: "No.#{matchday.id + 1}"
                sortable: false
                cellTemplate: cellTemplate

            $scope.matchListCapsule.gridOptions.columnDefs.push
              field: "season_score"
              displayName: "结算分"
              cellTemplate: cellTemplate

            weightScore = (score, counter) ->
              return score if counter >= 7
              return 0.95 * score if counter is 6
              return 0.90 * score if counter is 5
              return 0.8 * score if counter is 4
              return 0.6 * score if counter is 3
              return 0.4 * score if counter is 2
              return 0.2 * score if counter is 1
              0

            for user in users
              user.matchday = 
                player: user.name

              attend_counter = 0
              numerator = 45
              denominator = 0
              for id, matchday of matchdays
                if matchday.scores[user._id] and matchday.scores[user._id].score
                  attend_counter += 1
                  denominator += numerator
                numerator += 5

              base = 1.5
              numerator = 45
              sum_score = 0.0
              for id, matchday of matchdays
                user.matchday[id] = ''
                if matchday.scores[user._id] and matchday.scores[user._id].score
                  if attend_counter
                    sum_score += (matchday.scores[user._id].score - base) * numerator / denominator
                  user.matchday[id] = matchday.scores[user._id].score.toFixed(2)
                numerator += 5
              sum_score += base
              user.matchday['season_score'] = weightScore(sum_score, attend_counter).toFixed(3)
              $scope.matchListCapsule.gridData.push user.matchday

        ]
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

    reload.then ->
      if toState.auth
        unless UserService._id
          $state.go 'last12'
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