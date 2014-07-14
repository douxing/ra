ra = angular.module 'ra'

ra.factory 'UserService', ['$http', ($http) ->
  sdo =
    _id: null
    name: ''
    auth:
      email: ''
      role: ''
      
    reload: ->
      $http.get '/users/current_user'
      .then (res) ->
        sdo.signout()
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
      sdo._id = null
      sdo.name = ''
      sdo.auth.email = ''
      sdo.auth.role = ''

]