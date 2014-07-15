// Generated by CoffeeScript 1.7.1
var Matchday, User, authenticate_action, authorize_action, models_path, mongoose, parse, thunkify, util, _ref;

mongoose = require('mongoose');

thunkify = require('thunkify');

parse = require('co-body');

util = require('util');

models_path = "" + __dirname + "/../models";

Matchday = require("" + models_path + "/matchday");

User = require("" + models_path + "/user");

_ref = require('./session'), authenticate_action = _ref.authenticate_action, authorize_action = _ref.authorize_action;

module.exports = function(app, config) {
  console.log('about to add routes for users...');
  app.get('/users', authenticate_action, function*() {
    var users;
    console.log("about to route: GET /users");
    users = yield User.find().select('name').exec();
    debugger;
    this.body = users;
  });
  app.post('/users/add', authenticate_action, authorize_action, function*() {
    var body, save_result, user;
    console.log("about to route: POST /users/add");
    debugger;
    body = yield parse(this);
    console.log("user body: " + (util.inspect(body)));
    user = new User(body);
    user.save = thunkify(user.save);
    save_result = yield user.save();
    console.log("save_result: " + (util.inspect(save_result)));
    this.status = 201;
    this.body = user;
  });
  app.post('/users/signin', function*() {
    var body, user;
    console.log("about to route: POST /users/signin");
    body = yield parse(this);
    console.log("user body: " + (util.inspect(body)));
    user = yield User.findOne({
      'auth.email': body.auth.email
    }).exec();
    console.log("user = " + (util.inspect(user)));
    if ((user != null) && user.authenticate(body.auth.password)) {
      this.status = 200;
      this.session.current_user_id = user._id;
      this.body = {
        _id: user._id,
        name: user.name,
        auth: {
          email: user.auth.email,
          role: user.auth.role
        }
      };
    } else {
      this.status = 404;
      this.session.current_user_id = null;
    }
  });
  app["delete"]('/users/signout', function*() {
    console.log("about to route: POST /users/signout");
    this.session.current_user_id = null;
    this.status = 200;
  });
  return app.get('/users/current_user', function*() {
    var user;
    console.log("about to route: users/current_user");
    user = yield User.findOne({
      _id: this.session.current_user_id
    }).exec();
    this.status = 200;
    if (user) {
      this.body = {
        _id: user._id,
        name: user.name,
        auth: {
          email: user.auth.email,
          role: user.auth.role
        }
      };
    } else {
      this.body = {
        _id: null
      };
    }
    console.log("respond of users/current_user: " + (util.inspect(this.body)));
  });
};
