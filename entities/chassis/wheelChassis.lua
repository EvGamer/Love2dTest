local WheelChassis = {}

function WheelChassis:new(bound)
  newObj = {
    bound = bound,
  }
  self.__index = self
  setmetatable(newObj, self)
  newObj.radius = 15
  newObj.wheelShape = love.physics.newCircleShape(newObj.radius)
  local x, y = newObj.bound.body:getPosition()
  local left, top, right, bottom = newObj.bound.fixture:getBoundingBox(1)
  newObj.lWheel = newObj:createWheel(left, bottom)
  newObj.rWheel = newObj:createWheel(right, bottom)
  return newObj
end

function WheelChassis:createWheel(x, y)
  print(y)
  local body = love.physics.newBody(
    self.bound.manager.world,
    x, y, 'dynamic'
  )
  local fixture = love.physics.newFixture(body, self.wheelShape, 0)
  fixture:setUserData(self.bound)
  local joint = love.physics.newWeldJoint(body, self.bound.body, x, y, x, y, false)
  return {
    fixture = fixture,
    body = body,
    joint = joint
  }
end

function WheelChassis:update(dt)

end

function WheelChassis:draw()
  local lx, ly = self.lWheel.body:getPosition()
  local rx, ry = self.rWheel.body:getPosition()
  love.graphics.circle('fill', lx, ly, self.radius, 10)
  love.graphics.circle('fill', rx, ry, self.radius, 10)
end

return WheelChassis