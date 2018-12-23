constants = require('constants')
Platform = require('platform')
manager = {}
meter = constants.meter;

function manager:makeBarrier(x0, y0, x1, y1)
  local w = math.abs(x0 - x1) * meter
  local h =  math.abs(y0 - y1) * meter
  Platform:new(self, x0 * meter + w/2, y0 * meter + h/2, w, h);
end

function manager:init()
  local gravity = constants.gravity
  self.world = love.physics.newWorld(0, gravity, true);
  self.objects = {}
  self.objectIndex = 1
  self.width = 10
  self.height = 64
  -- Edges of the world
  self:makeBarrier(0, -1, self.width, 0) --top
  self:makeBarrier(self.width, 0, self.width + 1, self.height) --right
  self:makeBarrier(0, self.height, self.width, self.height + 1) --bottom
  self:makeBarrier(-1, 0, 0, self.height) --left
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