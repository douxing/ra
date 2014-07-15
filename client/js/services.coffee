ra = angular.module 'ra'

ra.factory 'UserService', ['$http', '$cookies', '$cookieStore', '$state', ($http, $cookies, $cookieStore, $state) ->
  sdo =
    _id: null
    name: ''
    auth:
      email: ''
      role: ''
      
    reload: ->
      $http.get '/users/current_user'
      .then (res) ->
        __resetSdo()
        data = res.data
        sdo._id = data._id
        if data._id
          sdo.name = data.name
          sdo.auth.email = data.auth.email
          sdo.auth.role = data.auth.role

    signin: (data)->
      sdo._id = data._id
      sdo.name = data.name
      sdo.auth.email = data.auth.email
      sdo.auth.role = data.auth.role

    signout: ->
      a = $cookies
      b = $cookieStore
      __resetSdo()
      $state.go 'guest', {}, { reload: true, inherit: true, notify: true }

  __resetSdo = ->
    sdo._id = null
    sdo.name = ''
    sdo.auth.email = ''
    sdo.auth.role = ''

  sdo

]