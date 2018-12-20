manager = require('manager')

function love.load()
  manager:init()
end

function love.update()
  manager.update()
end

function love.draw()
  manager:draw()
end