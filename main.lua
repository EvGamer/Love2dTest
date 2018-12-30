local manager = require('manager')

local constants = require('constants')

love.window.setTitle('Platformer test')
love.window.setMode(1024, 768, {
  resizable = true,
})

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