koa = require 'koa'
router = require 'koa-router'
app = koa()

configObj = 
  root: __dirname
  env: 'dev'
  port: 3000

for arg in process.argv
  if arg is '--prod'
    configObj.env = 'prod'
    configObj.port = 8080

require('./server/config')(app, configObj)
require('./server/db')(app, configObj)

app.use (next) -->
  try
    yield next
  catch err
    console.log "error: #{err}"
    @app.emit 'app.error', err, this
    if err.name is 'ValidationError'
      return @status = 400
    @status = err.status or 500
  
app.on 'app.error', (err) ->
  console.error "app.error: #{err}"

# routes
app.use router app

require('./server/controllers/user')(app, configObj)
require('./server/controllers/matchday')(app, configObj)

app.listen configObj.port

console.log "listening on port #{configObj.port}"
