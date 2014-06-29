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