Box = require('entities/box')

Platform = Box:new()
Platform.bodyType = 'static'
Platform.name = 'Platform'
Platform.edgeDistance = 10



function Platform.createShape(width, height)
  local hw, hh = width/2, height/2;
  return love.physics.newPolygonShape(
    -hw, -hh + Platform.edgeDistance,
    hw, -hh + Platform.edgeDistance,
    hw, hh,
    -hw, hh
  )
end

function Platform:new(manager, x, y, width, height, color)
  local newObj = Box.new(Platform, manager, x, y, width, height, nil, color)
  self.__index = self
  newObj.body:setType('static')
  local hw, hh = width/2, height/2;
  newObj.edge = love.physics.newEdgeShape(
    -hw, -hh,
    hw, -hh
  )
  newObj.edgeFixture = love.physics.newFixture(newObj.body, newObj.edge);
  return setmetatable(newObj, self)
end

function Platform:draw()
  if self.color then
    love.graphics.setColor(
      self.color[1],
      self.color[2],
      self.color[3]
    )
    local hw, hh = width/2, height/2;
    love.graphics.polygon(
      'line',
      self.body:getWorldPoints(self.shape:getPoints())
    )
    love.graphics.line(
      self.body:getWorldPoints(self.edge:getPoints())
    )
  end
end

return Platform