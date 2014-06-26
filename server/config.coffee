var serve = require 'koa-static'

exports = module.exports = (app, config) -->
	app.use serve "#{config.root}/client"