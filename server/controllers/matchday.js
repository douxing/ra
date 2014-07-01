// Generated by CoffeeScript 1.7.1
var Matchday, User, models_path, mongoose, parse, route, thunkify, util;

mongoose = require('mongoose');

route = require('koa-route');

thunkify = require('thunkify');

parse = require('co-body');

util = require('util');

models_path = "" + __dirname + "/../models";

Matchday = require("" + models_path + "/matchday");

User = require("" + models_path + "/user");

module.exports = function(app) {
  app.use(route.get('/matchdays', function*(req, res) {
    var matchdays;
    matchdays = yield Matchday.find().exec();
    this.body = matchdays;
  }));
  return app.use(route.post('matchdays/add', function*(req, res) {
    var body, matchday;
    body = yield parse(this);
    console.log("matchday body: " + (util.inspect(body)));
    matchday = new Matchday(body);
    matchday.id = yield Matchday.count().exec();
    matchday.id += 1;
    matchday.save = thunkify(matchday.save);
    yield matchday.save;
    this.status = 201;
    this.body = matchday;
  }));
};
