manager = require('manager')
Player = require('player')
Platform = require('platform')
colors = require('colors')
constants = require('constants')

function love.load()
  love.physics.setMeter(constants.meter)
  manager:init()
end

function love.update(dt)
  manager:update(dt)
end

function love.draw()
  manager:draw()
end