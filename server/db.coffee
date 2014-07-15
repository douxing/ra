fs = require 'fs'
mongoose = require 'mongoose'
dbURI=
  dev: 'mongodb://localhost/ra_dev'
  prod: 'mongodb://localhost/ra_prod'

dbOptions = 
    server:
      socketOptions:
        keepAlive: 1

connect = (env) ->
  mongoose.connect dbURI[env], dbOptions

dbconnected = ->
  console.log 'Database connected.'

dberror = (err) ->
  console.log "Database error: #{err}"

dbdisconnected = (err) ->
  console.log 'Database disconnected.'
  connect()

exports = module.exports = (app, config) ->
  # connection to database
  mongoose.connection.on 'connected', dbconnected
  mongoose.connection.on 'error', dberror
  mongoose.connection.on 'disconnected', dbdisconnected
  connect config.env

  # model creation
  models_path = "#{config.root}/server/models"
  for file in fs.readdirSync models_path
    require "#{models_path}/#{file}" if file.indexOf('.js') > 0
