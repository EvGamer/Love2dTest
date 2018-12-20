manager = {}
function manager:init()
  local gravity = 1
  self.world = love.physics.newWorld(0, gravity);
  self.objects = {}
end

function manager:update(dt)
  self.world:update(dt)
end

return manager