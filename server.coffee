koa = require 'koa'
session = require('koa-session')
app = koa()

configObj = 
	root: __dirname

require('server/config')(app, configObj)

app.keys = ['8 oclock every friday']
app.use(session())

app.use( -->
  user = this.session.user || {name: 'a', value: 0}
  user.name += 'a'
  user.value += 1
  this.session.user = user
  this.body = user.name + " - " + user.value
);

app.listen 3000

console.log 'listening on port 3000'
