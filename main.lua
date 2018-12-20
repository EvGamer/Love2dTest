manager = require('manager')
Player = require('player')
Platform = require('platform')
colors = require('colors')

function love.load()
  manager:init()
  love.physics.setMeter(64)
  Player:new(manager, 250, 250, 64, 64, colors.red)
  Platform:new(manager, 0, 500, 1000, 64, colors.paleCyan)
end

function love.update(dt)
  manager:update(dt)
end

function love.draw()
  manager:draw()
end