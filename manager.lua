constants = require('constants')
Platform = require('entities/platform')
FollowingCamera = require('followingCamera')
map1 = require'assets/maps/map1'
manager = {}
meter = constants.meter;

function handleContact(a, b)
  if a and a.handleContact then
    a:handleContact(b)
  end
end

function makeCoordinateConverter(width, height)
  local pixelWidth = width * meter
  local pixelHeight = height * meter
  return function(x, y)
    return x, y
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
  self.width = map1.width
  self.height = map1.height
  self.convertXY = makeCoordinateConverter(self.width, self.height)
  -- Add entities
  for _, layer in pairs(map1.layers) do
    if layer.type == 'objectgroup' then
      for _, object in pairs(layer.objects) do
        if object.type == 'player' then
          local x, y = self.convertXY(object.x, object.y)
          self.player = Player:new(
            self, x, y, meter, meter, colors.red
          )
        end
      end
    elseif layer.type == 'tilelayer' then
      for i=1, layer.height do
        for j=1, layer.width do
          if layer.data[j + (i-1)*layer.width] == 2 then
            local x, y = self.convertXY((j-1)*meter, (i-1)*meter)
            Platform:new(self, x+meter/2, y+meter/2, meter, meter, colors.green)
          end
        end
      end
    end
  end
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
  self.camera:update(dt)
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