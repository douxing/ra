mongoose = require 'mongoose'
route    = require 'koa-route'
thunkify = require 'thunkify'
parse    = require 'co-body'

util = require 'util'

models_path = "#{__dirname}/../models"

Matchday = require "#{models_path}/matchday"
User     = require "#{models_path}/user"

module.exports = (app, config) ->
  console.log 'about to add routes for users...'

  app.use route.get '/users', (req, res) -->
    console.log "about to route: GET /matchdays"
    users = yield User.find().exec()
    @body = users

  app.use route.post '/users/add', (req, res) -->
    console.log "about to route: POST /users/add"
    body = yield parse @

    console.log "user body: #{util.inspect body}"

    user = new User body
    user.name = 'noname' unless user.name
    user.save = thunkify(user.save)
    yield user.save()
    @status = 201
    @body = user

