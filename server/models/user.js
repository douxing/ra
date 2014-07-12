// Generated by CoffeeScript 1.7.1
var UserModel, UserSchema, crypto, mongoose;

crypto = require('crypto');

mongoose = require('mongoose');

UserSchema = new mongoose.Schema({
  name: String,
  auth: {
    email: String,
    hashed_password: String,
    salt: String,
    created_at: Date,
    role: {
      type: String,
      "default": ''
    }
  }
});

UserSchema.virtual('auth.password').set(function(password) {
  this.auth._password = password;
  this.auth.salt = UserModel.makeSalt();
  return this.auth.hashed_password = UserModel.encryptPassword(this.auth._password, this.auth.salt);
}).get(function() {
  return this.auth._password;
});

UserSchema.path('auth.email').validate(function(email) {
  return email.length;
}, 'Email cnanot be blank');

UserSchema.path('auth.email').validate(function(email, fn) {
  if (this.isNew) {
    return UserModel.find({
      "auth.email": email
    }).exec(function(error, users) {
      return fn(!error && users.length === 0);
    });
  } else {
    return fn(true);
  }
}, 'Email already exists');

UserSchema.pre('save', function(next) {
  if (!this.isNew) {
    return next();
  }
  debugger;
  if (this.auth.password && this.auth.password.length) {
    return next();
  } else {
    return next(new Error('Invalid password'));
  }
});

UserSchema.method({
  authenticate: function(plainText) {
    return UserModel.encryptPassword(plainText, this.salt);
  }
});

UserSchema["static"]({
  makeSalt: function() {
    return '' + Math.round(new Date().valueOf() * Math.random());
  },
  encryptPassword: function(password, salt) {
    if (password && password.length && salt && salt.length) {
      return crypto.createHmac('sha1', salt).update(password).digest('hex');
    } else {
      return '';
    }
  }
});

UserModel = module.exports = mongoose.model('User', UserSchema);
