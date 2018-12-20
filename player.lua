Box = require('box')
keySettings = require('keySettings')
constants = require('constants')

function isKeyDown(keyPurpose)
  return (
    love.keyboard.isDown(keySettings[keyPurpose][1])
    or love.keyboard.isDown(keySettings[keyPurpose][2])
  )
end


Player = Box:new()
Player.speed = 400
Player.jumpHeight = 600
Player.mass = 1

function Player:new(manager, x, y, width, height, color)
  newObj = Box:new(manager, x, y, width, height, self.mass, color)
  self.__index = self
  return setmetatable(newObj, self)
end

function Player:update(dt)
  if isKeyDown('moveLeft') then
    self.body:applyForce(-self.speed, 0)
  elseif isKeyDown('moveRight') then
    self.body:applyForce(self.speed, 0)
  end

  if isKeyDown('jump') then
    vx, vy = self.body:getLinearVelocity()
    if vy == 0 then
      self.body:applyLinearImpulse(0, -self.jumpHeight)
    end
  end
end

return Player