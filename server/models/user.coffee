crypto = require 'crypto'
mongoose = require 'mongoose'

UserSchema = new mongoose.Schema
  name: String
  auth:
    email: String
    hashed_password: String
    salt: String
    created_at: Date
    role:
      type: String
      default: ''

UserSchema.virtual 'auth.password' 
.set (password) ->
  @auth._password = password
  @auth.salt = UserModel.makeSalt()
  @auth.hashed_password = UserModel.encryptPassword @auth._password, @auth.salt
.get ->
  @auth._password

UserSchema.path 'auth.email'
.validate (email) ->
  return email.length;
,
  'Email cnanot be blank'

UserSchema.path 'auth.email'
.validate (email, fn) ->
  # Check only when it is a new user or when email field is modified
  if @isNew
    UserModel.find {"auth.email": email}
    .exec (error, users) ->
      fn !error && users.length is 0
  else
    fn true
,
  'Email already exists'

UserSchema.pre 'save', (next) ->
  unless @isNew then return next()
  # register the user with password
  debugger
  if @auth.password and @auth.password.length
    next()
  else 
    next new Error 'Invalid password'
 
UserSchema.method {
  authenticate: (plainText) ->
    UserModel.encryptPassword plainText, @salt
} 

UserSchema.static {
  makeSalt: ->
    '' + Math.round(new Date().valueOf() * Math.random())

  encryptPassword: (password, salt) ->
    if password and password.length and salt and salt.length
     return crypto.createHmac('sha1', salt).update(password).digest 'hex'
    else return ''
}


UserModel = module.exports = mongoose.model 'User', UserSchema