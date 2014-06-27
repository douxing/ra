koa = require 'koa'
app = koa()

configObj = 
	root: __dirname

require('./server/config')(app, configObj)

app.listen 3000

console.log 'listening on port 3000'
