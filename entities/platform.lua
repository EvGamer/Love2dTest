Box = require('entities/box')

Platform = Box:new()
Platform.bodyType = 'static'

function Platform:new(manager, x, y, width, height, color)
  local newObj = Box:new(manager, x, y, width, height, nil, color)
  self.__index = self
  newObj.body:setType('static')
  return setmetatable(newObj, self)
end

function Platform:draw()
  if self.color then
    love.graphics.setColor(
      self.color[1],
      self.color[2],
      self.color[3]
    )
    love.graphics.polygon(
      "line",
      self.body:getWorldPoints(self.shape:getPoints())
    )
  end
end

return Platform