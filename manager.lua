constants = require('constants')
manager = {}

function manager:init()
  local gravity = constants.meter * 9.8
  self.world = love.physics.newWorld(0, gravity, true);
  self.objects = {}
  self.objectIndex = 1
end

function manager:update(dt)
  for i=1, #self.objects do
    self.objects[i]:update(dt)
  end
  self.world:update(dt)
end

function manager:draw()
  for i=1, #self.objects do
    self.objects[i]:draw()
  end
end

function manager:addObject(object)
  local i = self.objectIndex
  self.objects[i] = object
  self.objectIndex = i + 1
  return i
end

return manager