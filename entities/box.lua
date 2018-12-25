constants = require('constants')
squareMeter = constants.meter ^ 2

Box = {
  name ='Box',
  bodyType = 'dynamic',
}

function Box:new(manager, x, y, width, height, mass, color)
  newObj = {
    manager = manager,
  }
  if manager then
    newObj.id = manager:addObject(newObj)
    newObj.body = love.physics.newBody(
      manager.world, x, y, self.bodyType
    )
    newObj.shape = love.physics.newRectangleShape(width, height)
    if mass then
      density = (width * height) / (mass * squareMeter)
    end
    newObj.fixture = love.physics.newFixture(
      newObj.body, newObj.shape, density
    )
    newObj.body:setFixedRotation(true)
  end
  newObj.color = color
  self.__index = self
  return setmetatable(newObj, self)
end

function Box:getPosition()
  return Body:getPosition()
end

function Box:update(dt)
end

function Box:draw()
  if self.color then
    love.graphics.setColor(
        self.color[1],
        self.color[2],
        self.color[3]
    )
    love.graphics.polygon(
        "fill",
        self.body:getWorldPoints(self.shape:getPoints())
    )
  end
end

return Box