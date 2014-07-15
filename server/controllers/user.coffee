mongoose = require 'mongoose'
thunkify = require 'thunkify'
parse    = require 'co-body'
util = require 'util'

models_path = "#{__dirname}/../models"
Matchday = require "#{models_path}/matchday"
User     = require "#{models_path}/user"

{authenticate_action, authorize_action} = require('./session')

module.exports = (app, config) ->
  console.log 'about to add routes for users...'

  app.get '/users', authenticate_action, -->
    console.log "about to route: GET /users"
    users = yield User.find().select('name').exec()
    debugger
    @body = users

  app.post '/users/add', authenticate_action, authorize_action, -->
    console.log "about to route: POST /users/add"
    debugger
    body = yield parse @

    console.log "user body: #{util.inspect body}"

    user = new User body

    user.save = thunkify(user.save)
    save_result = yield user.save()

    console.log "save_result: #{util.inspect save_result}"

    @status = 201
    @body = user

  app.post '/users/signin', -->
    console.log "about to route: POST /users/signin"
    body = yield parse @

    console.log "user body: #{util.inspect body}"
    user = yield User.findOne({'auth.email': body.auth.email}).exec()
    console.log "user = #{util.inspect user}"

    if user? and user.authenticate body.auth.password
      @status = 200
      @session.current_user_id = user._id
      @body =
        _id: user._id
        name: user.name
        auth:
          email: user.auth.email
          role: user.auth.role
    else
      @status = 404
      @session.current_user_id = null

  app.delete '/users/signout', -->
    console.log "about to route: POST /users/signout"
    @session.current_user_id = null
    @status = 200

  app.get '/users/current_user', -->
    console.log "about to route: users/current_user"
    user = yield User.findOne(_id: @session.current_user_id).exec()
    @status = 200

    if user
      @body = 
        _id: user._id
        name: user.name
        auth:
          email: user.auth.email
          role: user.auth.role
    else
      @body =
        _id: null

    console.log "respond of users/current_user: #{util.inspect @body}"    



