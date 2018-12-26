constants = require('constants')
Platform = require('entities/platform')
FollowingCamera = require('followingCamera')
manager = {}
meter = constants.meter;

function handleContact(a, b)
  if a and a.handleContact then
    a:handleContact(b)
  end
end

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
  self.width = 20
  self.height = 20
  -- Add entities
  self.player = Player:new(self, 250, 250, 64, 64, colors.red)
  Platform:new(self, 250, 500, 1000, 64, colors.paleCyan)
  Platform:new(self,750, 1000, 500,  64, colors.green)
  local xCam, yCam = 200, 200
  self.camera = FollowingCamera:new(
    self, self.player, xCam, yCam,
    love.graphics.getWidth() - xCam,
    love.graphics.getHeight() - yCam
  )
  -- Edges of the world
  self:makeBarrier(0, -1, self.width, 0) --top
  self:makeBarrier(self.width, 0, self.width + 1, self.height) --right
  self:makeBarrier(0, self.height, self.width, self.height + 1) --bottom
  self:makeBarrier(-1, 0, 0, self.height) --left
end

function manager:getWorldSize()
  return self.width * meter, self.height * meter;
end

function manager:update(dt)
  for i=1, #self.objects do
    self.objects[i]:update(dt)
  end
  self.camera:update()
  self.world:update(dt)
  for _, contact in pairs(self.world:getContacts()) do
    local fixtureA, fixtureB = contact:getFixtures()
    local entityA = fixtureA:getUserData()
    local entityB = fixtureB:getUserData()
    handleContact(entityA, entityB)
    handleContact(entityB, entityA)
  end
end

function manager:draw()
  love.graphics.origin()

  local matrix = love.math.newTransform(
    love.graphics.getWidth() / 2 - self.camera.x,
    love.graphics.getHeight() / 2 - self.camera.y
  )
  love.graphics.applyTransform(matrix)
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