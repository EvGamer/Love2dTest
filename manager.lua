manager = {}
function manager:init()
  local gravity = 1
  self.world = love.physics.newWorld(0, gravity);
  self.objects = {}
  self.objectIndex = 1
end

function manager:update(dt)
  self.world:update(dt)
end

function manager:draw()
  for __, object in pairs(self.objects) do
    object.draw()
  end
end

function manager:addObject(object)
  local i = self.objectIndex
  self.objects[i] = object
  self.objectIndex = i + 1
  return i
end

return manager