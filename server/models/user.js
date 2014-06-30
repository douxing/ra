// Generated by CoffeeScript 1.7.1
var UserSchema, mongoose;

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

module.exports = mongoose.model('User', UserSchema);
