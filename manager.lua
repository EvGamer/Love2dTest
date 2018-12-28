constants = require('constants')
Platform = require('entities/platform')
FollowingCamera = require('followingCamera')
map1 = require'assets/maps/map1'
manager = {}
meter = constants.meter;

function point(x, y)
  return {x, y}
end

function createArea(x, y)
  return {
    x0 = x,
    y0 = y,
    x = x,
    y = y,
  }
end

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

function manager:initMapEntities(layer)
  for _, object in pairs(layer.objects) do
    if object.type == 'player' then
      self.player = Player:new(
        self, object.x, object.y, meter, meter, colors.red
      )
    end
  end
end

function getAreaIndex(areas, x, y)
  for i=1, #areas do
    if
      areas[i].x0 <= x and x <= areas[i].x
      and areas[i].y0 <= y and y <= areas[i].y
    then
      return i
    end
  end
  return nil
end

function getTile(layer, x, y)
  return layer.data[x + (y-1)*layer.width]
end

function existEqual(a, b)
  return a~=nil and a==b
end

function manager:initTiles(layer)
  local areas = {}

  for i=1, layer.height do
    for j=1, layer.width do
      local topAreaIndex = getAreaIndex(areas, j, i-1)
      if topAreaIndex then
        if getTile(layer, x, y) == 2 then

        end
      end
    end
  end

  for i=1, #areas do
    local width = (areas[i].x - areas[i].x0 + 1) * meter
    local height = (areas[i].y - areas[i].y0 + 1) * meter
    local x = (areas[i].x0 - 1) * meter + width * 0.5
    local y = (areas[i].y0 - 1) * meter + height * 0.5
    print(areas[i].x0, areas[i].y0, areas[i].x, areas[i].y)
    print(x,y, width, height)
    if(width > 0 and height > 0) then
      Platform:new(self, x, y, width, height, colors.green)
    end
  end
end

function manager:init()
  local gravity = constants.gravity
  self.world = love.physics.newWorld(0, gravity, true);
  self.objects = {}
  self.objectIndex = 1
  self.width = map1.width
  self.height = map1.height
  -- Add entities
  for _, layer in pairs(map1.layers) do
    if layer.type == 'objectgroup' then
      self:initMapEntities(layer)
    elseif layer.type == 'tilelayer' then
      self:initTiles(layer)
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