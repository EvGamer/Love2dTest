Box = require('entities/box')

Platform = Box:new()
Platform.bodyType = 'static'

function Platform:new(manager, x, y, width, height, color)
  local newObj = Box:new(manager, x, y, width, height, nil, color)
  self.__index = self
  newObj.body:setType('static')
  return setmetatable(newObj, self)
end

return Platform