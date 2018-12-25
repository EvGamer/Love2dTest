Box = require('box')
keySettings = require('keySettings')
constants = require('constants')
meter = constants.meter

function isKeyDown(keyPurpose)
  return (
    love.keyboard.isDown(keySettings[keyPurpose][1])
    or love.keyboard.isDown(keySettings[keyPurpose][2])
  )
end


Player = Box:new()
Player.forwardForce = 400
Player.jumpImpulse = 600
Player.jumpHeight = 2 * meter
Player.mass = 1

function Player:new(manager, x, y, width, height, color)
  newObj = Box:new(manager, x, y, width, height, self.mass, color)
  newObj.dir = 0;
  self.__index = self
  return setmetatable(newObj, self)
end

function Player:update(dt)
  vx, vy = self.body:getLinearVelocity()
  if isKeyDown('moveLeft') then
    self.dir = -1
  elseif isKeyDown('moveRight') then
    self.dir = 1
  else
    self.dir = 0
    if vy == 0 and vx ~= 0 then
      self.dir = -math.abs(vx)/vx
    end
  end
  self.body:applyForce(self.dir*self.forwardForce, 0)
  if isKeyDown('jump') then
    if vy == 0 then
      self._yBeforeJump = self.body:getY()
      print(self._yBeforeJump)
      self.body:applyLinearImpulse(0, -self.jumpImpulse)
    end
  end
  if
    self._yBeforeJump
    and self._yBeforeJump - self.body:getY() >= self.jumpHeight
  then
    self.body:applyForce(0, -vy);
  end
end

function Player:draw()
  lx, ty, rx, by = self.fixture:getBoundingBox()
  y = self.body:getY()
  Box.draw(self)
  love.graphics.setColor(1,1,1,1)
  love.graphics.print(self._yBeforeJump or 'none', rx + 5, ty + 5)
  love.graphics.print(y or 'none', rx + 5, ty + 16)
  love.graphics.print((self._yBeforeJump or 0) - y or 'none', rx + 5, ty + 32)
end

return Player