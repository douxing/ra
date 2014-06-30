// Generated by CoffeeScript 1.7.1
var app, configObj, koa;

koa = require('koa');

app = koa();

configObj = {
  root: __dirname
};

require('./server/config')(app, configObj);

require('./server/db')(app, configObj);

app.use(function*(next) {
  var err;
  try {
    yield next;
  } catch (_error) {
    err = _error;
    this.app.emit('app.error', err, this);
    if (err.name === 'ValidationError') {
      return this.status = 400;
    }
    this.status = err.status || 500;
  }
});

app.on('app.error', function(err) {
  return console.error(err);
});

require('./server/controllers/user')(app, configObj);

require('./server/controllers/matchday')(app, configObj);

app.listen(3000);

console.log('listening on port 3000');
