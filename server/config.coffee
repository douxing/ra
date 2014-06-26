serve = require 'koa-static'
session = require 'koa-session'


exports = module.exports = (app, config) ->
	# serve static files
	app.use serve "#{config.root}/client"

	# session control
	app.keys = ['8 oclock every friday']
	app.use session()