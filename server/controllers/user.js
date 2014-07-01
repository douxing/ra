// Generated by CoffeeScript 1.7.1
var Matchday, User, models_path, mongoose, parse, route, thunkify;

mongoose = require('mongoose');

route = require('koa-route');

thunkify = require('thunkify');

parse = require('co-body');

models_path = "" + __dirname + "/../models";

Matchday = require('#{models_path}/matchday');

User = require('#{models_path}/user');

moduls.exports = function(app) {
  app.use(route.get('/users', function*(req, res) {
    var users;
    users = yield User.find().exec();
    this.body = users;
  }));
  return app.use(route.post('users/add', function*(req, res) {
    var body, user;
    body = yield parse(this);
    console.log("user body: " + (util.inspect(body)));
    user = new User(body);
    if (!user.name) {
      user.name = 'noname';
    }
    user.save = thunkify(user.save);
    yield user.save;
    this.status = 201;
    this.body = user;
  }));
};