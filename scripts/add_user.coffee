fs = require 'fs'
path = require 'path'
mongoose = require 'mongoose'
thunkify = require 'thunkify'

configObj = 
  root: path.join __dirname, '..'
  env: 'dev'
  port: 3000

dbURI=
  dev: 'mongodb://localhost/ra_dev'
  prod: 'mongodb://localhost/ra_prod'  

User = require "#{configObj.root}/server/models/user"

for arg in process.argv
  if arg is '--prod'
    configObj.env = 'prod'
    configObj.port = 8080

dbOptions = 
  server:
    socketOptions:
      keepAlive: 1

mongoose.connect dbURI[configObj.env], dbOptions

mongoose.connection.on 'connected', ->
  herrlich = new User
    name: '克立'
    auth:
      email: 'herrlich@qq.com'
      role: 'optr'
  herrlich.auth.password = '123456'

  debugger
  herrlich.save (error) ->
    debugger
    process.exit 0
