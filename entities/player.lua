local Box = require'entities/box'
local constants = require'constants'
local Timer = require'utils/timer'
local isKeyDown = require'utils/isKeyDown'
local WheelChassis = require'entities/chassis/wheelChassis'
local meter = constants.meter
local gravity = constants.gravity

Player = Box:new()
Player.acceleration = 20
Player.jumpHeight = 4.15 * meter
Player.mass = 10
Player.forwardForce = Player.mass * Player.acceleration * 60
Player.maxVelocity = 500
Player.cornerRadius = 5
Player.chassis = WheelChassis

function Player:new(manager, x, y, width, height, color, chassis)
  local newObj = Box:new(manager, x, y, width - self.cornerRadius, height, self.mass, color)
  newObj.dir = 0;
  newObj.grounded = false;
  newObj.timers = {
    jump = Timer:new(0.1);
    coyote = Timer:new(0.1)
  }
  newObj.chassis = chassis and chassis:new(newObj) or self.chassis:new(newObj)

  self.__index = self
  setmetatable(newObj, self)
  newObj:updateJumpImpulse()
  return newObj
end

function Player:updateJumpImpulse()
  local chassisMass = 0
  if(self.chassis and self.chassis.getMass) then
    chassisMass = self.chassis:getMass()
  end
  self.jumpImpulse = (self.mass + chassisMass) * (math.sqrt(2 * gravity * self.jumpHeight))
end

function Player:handleContact(contact)
  local cx1, cy1, cx2, cy2 = contact:getPositions()
  self.contactX1, self.contactY1, self.contactX2, self.contactY2 = cx1, cy1, cx2, cy2
  local lx, ty, rx, by = self.fixture:getBoundingBox()
  local vx, vy = self.body:getLinearVelocity()
  self.by = by
  if
    self.timers.jump:runOut()
    and self.chassis:isGrounded(contact)
  then
    self.grounded = true
    self.timers.coyote:reset()
  end
end

function Player:updateTimers(dt)
  for _, timer in pairs(self.timers) do
    timer:update(dt)
  end
end

function Player:update(dt)
  self.chassis:update(dt)
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
    and self.timers.jump:runOut()
  then
    self.grounded = false
    self.timers.jump:reset()
    self.jumpY = self.body:getY()
    self.body:setLinearVelocity(vx, 0)
    self.body:applyLinearImpulse(0, -self.jumpImpulse)
  end
  if self.timers.coyote:runOut() then
    self.grounded = false
  end
  self:updateTimers(dt)
end

function Player:draw()
  local x, y = self.body:getPosition()
  self:drawLines{
    { 'x: %.2f', x },
    { 'y: %.2f', y },
    { 'mass: %.2f', self.body:getMass() },
    { 'dt: %.2g', self.manager.dt},
    { 'vx: %.2f, vy: %.2f', self.body:getLinearVelocity() },
    { '%s', self.grounded and 'grounded' or '' },
    { 'jump timer %.2f', self.timers.jump:getTime()},
    { 'ground timer %.2f', self.timers.coyote:getTime()}
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
  self.chassis:draw()
end

return Player