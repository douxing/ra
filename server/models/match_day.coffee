mongoose = require 'mongoose'

MatchDaySchema = new mongoose.Schema
  id: Number
  played_at: Date
  scores: [
    player: 
      type: mongoose.Schema.Types.ObjectId
      ref: 'User'
    score: Number
  ]