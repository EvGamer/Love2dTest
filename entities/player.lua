Box = require('entities/box')
keySettings = require('keySettings')
constants = require('constants')
Timer = require('utils/timer')
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
  local newObj = Box:new(manager, x, y, width, height, self.mass, color)
  newObj.dir = 0;
  newObj.grounded = false;
  newObj.timers = {
    jump = Timer.new(0, 1);
  }
  self.__index = self
  return setmetatable(newObj, self)
end

function Player:handleContact()
  local vx, vy = self.body:getLinearVelocity()
  if self.timers.jump:runOut() and vy == 0 then
    self.grounded = true
  end
end

function Player:update(dt)
  local vx, vy = self.body:getLinearVelocity()
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
    isKeyDown('jump')
    and self.grounded
  then
    self.grounded = false
    self.timers.jump:reset()
    self.body:applyLinearImpulse(0, -self.jumpImpulse)
  end

  self.timers.jump:update(dt)
end

function Player:draw()
  local lx, ty, rx, by = self.fixture:getBoundingBox()
  love.graphics.setColor(1,1,1,1)
  if self.grounded then
    love.graphics.print('Ouch', rx + 5, ty)
  end
  love.graphics.print(self.timers.jump:getTime(), rx + 5, ty-16)
  Box.draw(self)
end

return Player