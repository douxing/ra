fs = require 'fs'
mongoose = require 'mongoose'
dbURI = 'mongodb://localhost/ra_dev'
dbOptions = 
    server:
      socketOptions:
        keepAlive: 1

connect = ->
  mongoose.connect dbURI, dbOptions

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
  connect()

  # model creation
  models_path = "#{config.root}/server/models"
  for file in fs.readdirSync models_path
    require "#{models_path}/#{file}" if file.indexOf('.js') > 0
