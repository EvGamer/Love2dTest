local constants = require('constants')
local FollowingCamera = require('followingCamera')
local Player = require('entities/player')
local Platform = require('entities/platform')
local colors = require('colors')
local map1 = require'assets/maps/map1'
local manager = {}
local meter = constants.meter;

function point(x, y)
  return {x, y}
end

function createArea(x0, y0, x, y)
  return {
    x0 = x0,
    y0 = y0,
    x = x or x0,
    y = y or y0,
  }
end

function handleContact(contact, a, b)
  if a and a.handleContact then
    a:handleContact(contact, b)
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
        self, object.x, object.y, meter-16, meter-16, colors.red
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

function addArea(areas, x, y, x0, y0)
  table.insert(areas, createArea(x, y, x0, y0))
end

function manager:initTilesHorizontaly(layer)
  local i = 0
  local areas = {}
  for x=1, layer.width do
    for y=1, layer.height do
      local cur = getAreaIndex(areas, x, y)
      local top = getAreaIndex(areas, x, y-1)
      local left = getAreaIndex(areas, x-1, y)
      local topLeft = getAreaIndex(areas, x-1, y-1)
      if x == 1 then
        i = i + 1
      end
      if getTile(layer, x, y) == 2 then
        if left then
          if left == top then
            areas[left].x = x
          else
            addArea(areas, areas[left].x0, y, x, areas[left].y)
            areas[left].y = y-1
          end
        elseif top and topLeft ~= top then
          areas[top].y = y
        else
          addArea(areas, x, y)
        end
      elseif cur and cur == left then
        addArea(areas, areas[left].x, y, x-1, areas[left].y)
        areas[left].y = y-1
      end
    end
  end
  print(i)
  for i=1, #areas do
    local width = (areas[i].x - areas[i].x0 + 1) * meter
    local height = (areas[i].y - areas[i].y0 + 1) * meter
    local x = (areas[i].x0 - 1) * meter + width * 0.5
    local y = (areas[i].y0 - 1) * meter + height * 0.5
    if(width > 0 and height > 0) then
      Platform:new(self,
        math.floor(x),
        math.floor(y),
        math.floor(width),
        math.floor(height),
        {1, 1, 1}
      )
    end
  end
end

function manager:initTiles(layer)
  local areas = {}
  for y=1, layer.height do
    for x=1, layer.width do
      local cur = getAreaIndex(areas, x, y)
      local top = getAreaIndex(areas, x, y-1)
      local left = getAreaIndex(areas, x-1, y)
      local topLeft = getAreaIndex(areas, x-1, y-1)
      if getTile(layer, x, y) == 2 then
        if top then
          if left == top then
            areas[top].y = y
          else
            addArea(areas, x, areas[top].y0, areas[top].x, y)
            areas[top].x = x-1
          end
        elseif left and topLeft ~= left then
          areas[left].x = x
        else
          addArea(areas, x, y)
        end
      elseif cur and cur == top then
        addArea(areas, x, areas[top].y0, areas[top].x, y - 1)
        areas[top].x = x-1
      end
    end
  end
  for i=1, #areas do
    local width = (areas[i].x - areas[i].x0 + 1) * meter
    local height = (areas[i].y - areas[i].y0 + 1) * meter
    local x = (areas[i].x0 - 1) * meter + width * 0.5
    local y = (areas[i].y0 - 1) * meter + height * 0.5
    if(width > 0 and height > 0) then
      Platform:new(self,
        math.floor(x),
        math.floor(y),
        math.floor(width),
        math.floor(height),
        {1, 1, 1}
      )
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
  self.dt = 0
  -- Add entities
  for _, layer in pairs(map1.layers) do
    if layer.type == 'objectgroup' then
      self:initMapEntities(layer)
    elseif layer.type == 'tilelayer' then
      self:initTilesHorizontaly(layer)
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
  self.dt = dt
  for i=1, #self.objects do
    self.objects[i]:update(dt)
  end
  self.camera:update(dt)
  self.world:update(dt)
  for _, contact in pairs(self.world:getContacts()) do
    local fixtureA, fixtureB = contact:getFixtures()
    local entityA = fixtureA:getUserData()
    local entityB = fixtureB:getUserData()
    handleContact(contact, entityA, entityB)
    handleContact(contact, entityB, entityA)
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