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
Player.forwardForce = 800
Player.jumpImpulse = 700
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
      self.body:applyLinearImpulse(0,-self.jumpImpulse)
    end
  end
end

return Player