Box = require('entities/box')
keySettings = require('keySettings')
constants = require('constants')
meter = constants.meter
gravity = constants.gravity

function isKeyDown(keyPurpose)
  return (
    love.keyboard.isDown(keySettings[keyPurpose][1])
    or love.keyboard.isDown(keySettings[keyPurpose][2])
  )
end

function getJumpImpulse(height, mass)
  return mass * (math.sqrt(2 * gravity * height))
end

Player = Box:new()
Player.forwardForce = 400
Player.jumpHeight = 4 * meter
Player.mass = 1
Player.jumpImpulse = getJumpImpulse(Player.jumpHeight, Player.mass)

function Player:new(manager, x, y, width, height, color)
  newObj = Box:new(manager, x, y, width, height, self.mass, color)
  newObj.dir = 0;
  self.__index = self
  return setmetatable(newObj, self)
end

function Player:update(dt)
  vx, vy = self.body:getLinearVelocity()
  y = self.body:getY()
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

  if
    vy == 0
  then
    self._yBeforeJump = nil;
  end

  if isKeyDown('jump') then
    if not self._yBeforeJump then
      self._yBeforeJump = self.body:getY()
      self.body:applyLinearImpulse(0, -self.jumpImpulse)
    end
  end
end

function Player:draw()
  lx, ty, rx, by = self.fixture:getBoundingBox()
  vx, vy = self.body:getLinearVelocity()
  y = self.body:getY()
  mass = self.body:getMass()
  Box.draw(self)
  love.graphics.setColor(1,1,1,1)
  love.graphics.print(string.format('%.2f jump height', ((self._yBeforeJump or y) - y)/meter), rx + 5, ty)
  love.graphics.print(string.format('%.2f y before jump', (self._yBeforeJump or 0)/meter), rx + 5, ty + 16)
end

return Player