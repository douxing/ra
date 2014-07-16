// Generated by CoffeeScript 1.7.1
var Matchday, ObjectId, User, arg, async, col, configObj, dbOptions, dbURI, fs, key, matchday_counter, matchdays, mongoose, path, row, thunkify, user_counter, users, value, workbook, worksheet, xlsx, _i, _j, _len, _ref,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

fs = require('fs');

path = require('path');

mongoose = require('mongoose');

thunkify = require('thunkify');

xlsx = require('xlsx');

async = require('async');

ObjectId = mongoose.Types.ObjectId;

configObj = {
  root: path.join(__dirname, '..'),
  env: 'dev',
  port: 3000
};

dbURI = {
  dev: 'mongodb://localhost/ra_dev',
  prod: 'mongodb://localhost/ra_prod'
};

User = require("" + configObj.root + "/server/models/user");

Matchday = require("" + configObj.root + "/server/models/matchday");

_ref = process.argv;
for (_i = 0, _len = _ref.length; _i < _len; _i++) {
  arg = _ref[_i];
  if (arg === '--prod') {
    configObj.env = 'prod';
    configObj.port = 8080;
  }
}

dbOptions = {
  server: {
    socketOptions: {
      keepAlive: 1
    }
  }
};

workbook = xlsx.readFile("" + __dirname + "/scores.xlsx");

worksheet = workbook.Sheets[workbook.SheetNames[0]];

users = {};

matchdays = {};

user_counter = 0;

for (row = _j = 2; _j <= 25; row = ++_j) {
  user_counter += 1;
  users[row] = {
    name: '',
    qq: '',
    auth: {
      email: '',
      role: ''
    }
  };
}

matchday_counter = 0;

for (key in worksheet) {
  value = worksheet[key];
  if (__indexOf.call(key, '!') >= 0) {
    continue;
  }
  row = parseInt(/\d+/.exec(key)[0]);
  col = /\D+/.exec(key)[0];
  if (row > 25) {
    continue;
  }
  if (row === 1) {
    if (col >= 'D' && col <= 'Z' || col >= 'AA' && col <= 'AP') {
      matchday_counter += 1;
      matchdays[col] = {
        id: value.v - 1,
        scores: []
      };
    }
  } else if (col === 'A') {
    users[row].name = value.v;
  } else if (col === 'B') {
    users[row].qq = value.v;
    users[row].auth.email = "" + value.v + "@qq.com";
  } else if (col === 'C') {
    if (value.v === 1) {
      users[row].auth.role = 'optr';
    }
  }
}

mongoose.connect(dbURI[configObj.env], dbOptions);

mongoose.connection.on('connected', function() {
  return async.series([
    function(callback) {
      return User.remove({}, function() {
        console.log('users removed');
        return callback();
      });
    }, function(callback) {
      return Matchday.remove({}, function() {
        console.log('matchdays removed');
        return callback();
      });
    }, function(callback) {
      var counter, user, _results;
      counter = 0;
      _results = [];
      for (row in users) {
        user = users[row];
        _results.push((function() {
          var dbuser, usr;
          usr = user;
          dbuser = new User(usr);
          dbuser.auth.password = "" + usr.qq;
          return dbuser.save(function(error) {
            if (error) {
              callback(error);
              return console.log('error when save usr');
            } else {
              usr._id = dbuser._id.toString();
              counter += 1;
              if (counter === user_counter) {
                return callback();
              }
            }
          });
        })());
      }
      return _results;
    }, function(callback) {
      var counter, matchday, md, score, user, _results;
      for (key in worksheet) {
        value = worksheet[key];
        if (__indexOf.call(key, '!') >= 0) {
          continue;
        }
        row = parseInt(/\d+/.exec(key)[0]);
        col = /\D+/.exec(key)[0];
        if (row > 1 && row <= 25 && (col >= 'D' && col <= 'Z' || col >= 'AA' && col <= 'AP')) {
          score = parseFloat(value.v);
          if (!score) {
            continue;
          }
          user = users[row];
          matchday = matchdays[col];
          matchday.scores.push({
            player: ObjectId(user._id),
            score: value.v
          });
        }
      }
      counter = 0;
      _results = [];
      for (col in matchdays) {
        matchday = matchdays[col];
        md = new Matchday(matchday);
        _results.push(md.save(function(error) {
          if (error) {
            callback(error);
            return console.log('error when save matchday');
          } else {
            counter += 1;
            if (counter === matchday_counter) {
              return callback();
            }
          }
        }));
      }
      return _results;
    }
  ], function(error) {
    if (error) {
      return console.log("error: " + error);
    } else {
      return console.log('ok!');
    }
  });
});
