local ControlledCamera = {}

function ControlledCamera:new(manager, x, y, scrollSpeed)
  local newObj = {
    manager = manager,
    scrollSpeed = scrollSpeed,
    mouseDown = false,
    x = x,
    y = y,
  }
  self.__index = self
  setmetatable(newObj, self)
  return newObj
end

function ControlledCamera:update()
  if love.mouse.isDown(1) then
    local x, y = love.mouse.getPosition()
    if self._prevMousePosition then
      self.x = self.x + (self._prevMousePosition.x - x)
      self.y = self.y + (self._prevMousePosition.y - y)
    end
    self._prevMousePosition = { x=x, y=y }
  else
    self._prevMousePosition = nil
  end
end

return ControlledCamera