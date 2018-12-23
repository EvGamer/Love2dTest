FollowingCamera = {}

function adjustToBoundaries(radius, value,  max, min)
  local _max = max - radius
  if value > _max then return _max end
  local _min = min + radius
  if value < _min then return _min end
  return value
end

function shiftCoordToFit(center, objL, objH, camL, camH)
  local dl = objL - camL
  local dh = objH - camH
  if dl < 0 then return center + dl end
  if dh > 0 then return center + dh end
  return center
end

function FollowingCamera:new(manager, followed, minX, minY, maxX, maxY)
  newObj = {
    manager = manager,
    followed = followed,
    minX = minX,
    minY = minY,
    maxX = maxX,
    maxY = maxY,
  }
  self.__index = self
  setmetatable(newObj, self)
  x, y = newObj.followed.body:getPosition()
  newObj:follow(x, y)
  return newObj
end

function FollowingCamera:setPosition(x, y)
  width, height = self.manager:getWorldSize()
  self.x = adjustToBoundaries(
    love.graphics.getWidth() / 2,
    x, width, 0
  )
  self.y = adjustToBoundaries(
    love.graphics.getHeight() / 2,
    y, height, 0
  )
end

function FollowingCamera:follow(x, y)
  local left, top, right, bottom = self.followed.fixture:getBoundingBox()
  local ox, oy = x - love.graphics.getWidth() / 2, y - love.graphics.getHeight() / 2
  self:setPosition(
    shiftCoordToFit(x, left, right, ox + self.minX, ox + self.maxX),
    shiftCoordToFit(y, top, bottom, oy + self.minY, oy + self.maxY)
  )
end

function FollowingCamera:update()
  self:follow(self.x, self.y)
end

return FollowingCamera