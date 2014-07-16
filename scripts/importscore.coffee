fs = require 'fs'
path = require 'path'
mongoose = require 'mongoose'
thunkify = require 'thunkify'
xlsx = require 'xlsx'
async = require 'async'

ObjectId = mongoose.Types.ObjectId

configObj = 
  root: path.join __dirname, '..'
  env: 'dev'
  port: 3000

dbURI=
  dev: 'mongodb://localhost/ra_dev'
  prod: 'mongodb://localhost/ra_prod'

User = require "#{configObj.root}/server/models/user"
Matchday = require "#{configObj.root}/server/models/matchday"

for arg in process.argv
  if arg is '--prod'
    configObj.env = 'prod'
    configObj.port = 8080

dbOptions = 
  server:
    socketOptions:
      keepAlive: 1

workbook = xlsx.readFile "#{__dirname}/scores.xlsx"
worksheet = workbook.Sheets[workbook.SheetNames[0]]

users = {}
matchdays = {}

user_counter = 0
# init users
for row in [2..25]
  user_counter += 1
  users[row] =
    name: ''
    qq: ''
    auth:
      email: ''
      role: ''

# fill in users and init matchdays
matchday_counter = 0
for key, value of worksheet
  continue if '!' in key
  row = parseInt(/\d+/.exec(key)[0])
  col = /\D+/.exec(key)[0]

  continue if row > 25
  if row is 1
    if col >= 'D' and col <='Z' or col >= 'AA' and col <= 'AP'
      matchday_counter += 1
      matchdays[col] =
        id: value.v - 1
        scores: []
  else if col is 'A'
    users[row].name = value.v
  else if col is 'B'
    users[row].qq = value.v
    users[row].auth.email = "#{value.v}@qq.com"
  else if col is 'C'
    users[row].auth.role = 'optr' if value.v is 1

mongoose.connect dbURI[configObj.env], dbOptions

mongoose.connection.on 'connected', ->
  async.series [
    (callback) ->
      User.remove {}, ->
        console.log 'users removed'
        callback()
  ,
    (callback) ->
      Matchday.remove {}, ->
        console.log 'matchdays removed'    
        callback()
  , 
    (callback) ->
      counter = 0
      for row, user of users
        do ->
          usr = user
          dbuser = new User usr
          dbuser.auth.password = "#{usr.qq}"
          dbuser.save (error) ->
            if error
              callback(error)
              console.log 'error when save usr'
            else
              usr._id = dbuser._id.toString()
              counter += 1
              if counter is user_counter
                callback()
  , 
    (callback) ->
      for key, value of worksheet
        continue if '!' in key
        row = parseInt(/\d+/.exec(key)[0])
        col = /\D+/.exec(key)[0]

        if row > 1 and row <= 25 and (col >= 'D' and col <='Z' or col >= 'AA' and col <= 'AP')
          score = parseFloat value.v
          continue unless score
          user = users[row]
          matchday = matchdays[col]
          matchday.scores.push
            player: ObjectId(user._id)
            score: value.v

      counter = 0
      for col, matchday of matchdays
        md = new Matchday matchday
        md.save (error) ->
          if error
            callback(error)
            console.log 'error when save matchday'
          else
            counter += 1
            if counter is matchday_counter
              callback()
  ], (error) ->
    if error
      console.log "error: #{error}"
    else
      console.log 'ok!'
