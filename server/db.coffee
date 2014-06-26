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

exports = module.exports = ->
	mongoose.connection.on 'connected', dbconnected
	mongoose.connection.on 'error', dberror
	mongoose.connection.on 'disconnected', dbdisconnected
	connect()
