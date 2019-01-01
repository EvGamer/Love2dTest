local Box = require('entities/box')
local constants = require('constants')
local Timer = require('utils/timer')
local isKeyDown = require('utils/isKeyDown')
local meter = constants.meter
local gravity = constants.gravity



function getJumpImpulse(height, mass)
  return mass * (math.sqrt(2 * gravity * height))
end

Player = Box:new()
Player.acceleration = 20
Player.jumpHeight = 4.15 * meter
Player.mass = 10
Player.forwardForce = Player.mass * Player.acceleration * 60
Player.maxVelocity = 500
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

function Player:handleContact(contact)
  local cx1, cy1, cx2, cy2 = contact:getPositions()
  self.contactX1, self.contactY1, self.contactX2, self.contactY2 = cx1, cy1, cx2, cy2
  local lx, ty, rx, by = self.fixture:getBoundingBox()
  local vx, vy = self.body:getLinearVelocity()
  self.by = by
  if
    self.timers.jump:runOut()
      and cy1 and cy2 and cx1 and cx2
      and by - cy1 <= 0.5 and by - cy1 <= 0.5
  then
    self.grounded = true
  end
end

function Player:update(dt)
  local vx, vy = self.body:getLinearVelocity()
  local x, y = self.body:getPosition()
  if isKeyDown('moveLeft') and -vx <= self.maxVelocity then
    self.dir = -1
  elseif isKeyDown('moveRight') and vx <= self.maxVelocity then
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
  self.grounded = false
  self.timers.jump:update(dt)
end

function Player:draw()
  local x, y = self.body:getPosition()
  self:drawLines{
    { 'x: %.2f', x },
    { 'y: %.2f', y },
    { 'mass: %.2f', self.body:getMass() },
    { 'dt: %.2g', self.manager.dt},
    { 'vx: %.2f, vy: %.2f', self.body:getLinearVelocity() },
    { '%s', self.grounded and 'grounded' or '' }
  }
  if
    self.contactX1 and self.contactY1
    and self.contactX2 and self.contactY2
  then
    love.graphics.line(
      self.contactX1, self.contactY1,
      self.contactX2, self.contactY2
    )
  end
  Box.draw(self)
end

return Player