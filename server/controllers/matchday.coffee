mongoose = require 'mongoose'
route    = require 'koa-route'
thunkify = require 'thunkify'
parse    = require 'co-body'

util = require 'util'

models_path = "#{__dirname}/../models"

Matchday = require "#{models_path}/matchday"
User     = require "#{models_path}/user"

module.exports = (app) ->
  app.use route.get '/matchdays', (req, res) -->
    console.log "about to route: GET /matchdays"
    matchdays = yield Matchday.find().exec()
    @body = matchdays

  app.use route.post 'matchdays/add', (req, res) -->
    console.log "about to route: POST matchdays/add"
    body = yield parse @

    console.log "matchday body: #{util.inspect body}"

    matchday = new Matchday body
    matchday.id = yield Matchday.count().exec()
    matchday.id += 1
    matchday.save = thunkify(matchday.save)
    yield matchday.save
    @status = 201
    @body = matchday