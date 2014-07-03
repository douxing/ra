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
    console.log "about to route: POST /matchdays/#{matchday_id}/update_score"
    machday = yield Matchday.find({_id: mongoose.Schema.Types.ObjectId(matchday_id)}).exec()
    body = yield parse @
    body.score = parseFloat body.score.trim() if body.score
    console.log "matchday body: #{util.inspect body}"
    index = undefined
    for obj, i in matchday.scores
      if obj.player.toString() is body.player
        index = i
        break
    if index # found
      if body.score
        matchday.scores.push
          player: mongoose.Schema.Types.ObjectId(body.player)
          score: body.score
      else
        matchday.splice index, 1
    else # not found
      if body.score
        matchday[index].score = body.score
      
    matchday.save = thunkify(matchday.save)
    yield matchday.save()
    @status = 201


