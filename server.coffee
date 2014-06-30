koa = require 'koa'
app = koa()

configObj = 
	root: __dirname

require('./server/config')(app, configObj)
require('./server/db')(app, configObj)

app.use (next) -->
  try
    yield next
  catch err
    @app.emit 'app.error', err, this
    if err.name is 'ValidationError'
      return @status = 400

    @status = err.status or 500
  

app.on 'app.error', (err) ->
  console.error err

require('./controllers/user')(app, configObj)
require('./controllers/matchday')(app, configObj)

app.listen 3000

console.log 'listening on port 3000'
