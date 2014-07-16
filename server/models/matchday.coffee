mongoose = require 'mongoose'

scoreSchema = new mongoose.Schema
  player: 
    type: mongoose.Schema.Types.ObjectId
    ref: 'User'
  score: Number
,
  _id: false

MatchdaySchema = new mongoose.Schema
  id: Number
  played_at: Date
  scores: [scoreSchema]

module.exports = mongoose.model 'Matchday', MatchdaySchema