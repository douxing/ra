mongoose = require 'mongoose'
thunkify = require 'thunkify'
parse    = require 'co-body'

util = require 'util'

models_path = "#{__dirname}/../models"

Matchday = require "#{models_path}/matchday"
User     = require "#{models_path}/user"

module.exports = (app, config) ->
  console.log 'about to add routes for users...'

  app.get '/users', -->
    console.log "about to route: GET /matchdays"
    users = yield User.find().exec()
    @body = users

  app.post '/users/add', -->
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

  # app.use route.post '/users/signin', -->
  #   console.log "about to route: POST /users/signin"
  #   body = yield parse @

  #   console.log "user body: #{util.inspect body}"

  #   User.findOne({email: body.email}).exec (error, user) ->
  #     if error
  #       @status = 
  #     else unless user
  #       return


  #   user.save = thunkify(user.save)
  #   save_result = yield user.save()

  #   console.log "save_result: #{util.inspect save_result}"

  #   @status = 201
  #   @body = user

