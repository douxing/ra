mongoose = require 'mongoose'
thunkify = require 'thunkify'
parse    = require 'co-body'
util = require 'util'

models_path = "#{__dirname}/../models"
User     = require "#{models_path}/user"

exports.authenticate_action = (next) -->
  console.log 'check user'
  @user = yield User.findOne(_id: @session.current_user_id).exec()
  if @user
    yield next
  else
    @status = 401

exports.authorize_action = (next) -->
  console.log 'check user authorization'
  if @user.auth.role?.indexOf('optr') isnt -1
    yield next
  else
    @status = 401