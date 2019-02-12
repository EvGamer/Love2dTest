local constants = require('constants')
local squareMeter = constants.meter ^ 2
local unpack = require('utils/unpack')

Box = {
  name ='Box',
  bodyType = 'dynamic',
}

function Box.createShape(width, height)
  return love.physics.newRectangleShape(width, height)
end

function Box:new(manager, x, y, width, height, mass, color)
  local newObj = {
    manager = manager,
  }
  if manager then
    newObj.id = manager:addObject(newObj)
    newObj.body = love.physics.newBody(
      manager.world, x, y, self.bodyType
    )
    newObj.shape = self.createShape(width, height)
    if mass then
      density = (mass * squareMeter) / (width * height)
    end
    newObj.fixture = love.physics.newFixture(
      newObj.body, newObj.shape, density
    )
    newObj.fixture:setUserData(newObj)
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

function Box:drawLines(lines)
  local lx, ty, rx, by = self.fixture:getBoundingBox()
  love.graphics.setColor(1,1,1,1)
  for i = 1, #lines do
    love.graphics.print(
      string.format(lines[i][1], unpack(lines[i], 2)),
      rx + 5, by - 16 * (#lines - (i - 1))
    )
  end
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