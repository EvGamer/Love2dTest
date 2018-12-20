manager = require('manager')
Player = require('player')
Platform = require('platform')
colors = require('colors')
constants = require('constants')

function love.load()
  manager:init()
  love.physics.setMeter(constants.meter)
  Player:new(manager, 250, 250, 64, 64, colors.red)
  Platform:new(manager, 250, 500, 1000, 64, colors.paleCyan)
end

function love.update(dt)
  manager:update(dt)
end

function love.draw()
  manager:draw()
end