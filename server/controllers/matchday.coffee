mongoose = require 'mongoose'
route    = require 'koa-route'
thunkify = require 'thunkify'
parse    = require 'co-body'

util = require 'util'

models_path = "#{__dirname}/../models"

Matchday = require "#{models_path}/matchday"
User     = require "#{models_path}/user"

module.exports = (app, config) ->
  console.log 'about to add routes for matchdays...'

  app.use route.get '/matchdays', -->
    console.log "about to route: GET /matchdays"
    matchdays = yield Matchday.find().exec()
    @body = matchdays

  app.use route.post '/matchdays/add', -->
    console.log "about to route: POST matchdays/add"
    body = yield parse @

    console.log "matchday body: #{util.inspect body}"

    matchday = new Matchday body
    matchday.id = yield Matchday.count().exec()
    matchday.save = thunkify(matchday.save)
    yield matchday.save()
    @status = 201
    @body = matchday

  app.use route.post '/matchdays/:id/update_score', (matchday_id) -->
    console.log "about to route: POST /matchdays/:id/update_score"
    machday = yield Matchday.find({_id: matchday_id}).exec()
    body = yield parse @
    console.log "matchday body: #{util.inspect body}"
    index = -1
    for obj, i in matchday.scores
      if obj.player.toString() is body.player
        index = i
        break
    if index == -1
      if body.score
        matchday.scores.push
          player: body.player
          score: body.score
    else
      if body.score
        matchday[index].player = body.player
        matchday[index].score = body.score
      else
        matchday.splice index, 1

    matchday.save = thunkify(matchday.save)
    yield matchday.save()
    @status = 201


