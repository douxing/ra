// Generated by CoffeeScript 1.7.1
var Matchday, ObjectId, User, models_path, mongoose, parse, route, thunkify, util;

mongoose = require('mongoose');

route = require('koa-route');

thunkify = require('thunkify');

parse = require('co-body');

util = require('util');

models_path = "" + __dirname + "/../models";

ObjectId = mongoose.Types.ObjectId;

Matchday = require("" + models_path + "/matchday");

User = require("" + models_path + "/user");

module.exports = function(app, config) {
  console.log('about to add routes for matchdays...');
  app.use(route.get('/matchdays', function*() {
    var matchdays;
    console.log("about to route: GET /matchdays");
    matchdays = yield Matchday.find().exec();
    this.body = matchdays;
  }));
  app.use(route.post('/matchdays/add', function*() {
    var body, matchday;
    console.log("about to route: POST matchdays/add");
    body = yield parse(this);
    console.log("matchday body: " + (util.inspect(body)));
    matchday = new Matchday(body);
    matchday.id = yield Matchday.count().exec();
    matchday.save = thunkify(matchday.save);
    yield matchday.save();
    this.status = 201;
    this.body = matchday;
  }));
  return app.use(route.post('/matchdays/:id/update_score', function*(matchday_id) {
    var body, i, index, matchday, obj, _i, _len, _ref;
    console.log("about to route: POST /matchdays/" + matchday_id + "/update_score");
    matchday = yield Matchday.findOne({
      _id: ObjectId(matchday_id)
    }).exec();
    body = yield parse(this);
    if (body.score) {
      body.score = parseFloat(body.score.trim());
    }
    console.log("matchday body: " + (util.inspect(body)) + " \nmatchday: " + (util.inspect(matchday)));
    index = void 0;
    _ref = matchday.scores;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      obj = _ref[i];
      if (obj.player.toString() === body.player) {
        index = i;
        break;
      }
    }
    if (index) {
      if (body.score) {
        matchday.scores[index].score = body.score;
      } else {
        matchday.scores.splice(index, 1);
      }
    } else {
      if (body.score) {
        matchday.scores.push({
          player: ObjectId(body.player),
          score: body.score
        });
      }
    }
    matchday.save = thunkify(matchday.save);
    yield matchday.save();
    this.status = 201;
  }));
};
