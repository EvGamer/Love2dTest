Box = {
  name ='Box',
  bodyType = 'dynamic',
}

function Box:new(manager, x, y, width, height, mass, color)
  newObj = {
    manager = manager,
    id = manager.addObject(newObj),
    body = love.physics.newBody(
      manager.world, x, y, self.bodyType
    ),
  }
  newObj.shape = love.physics.newRectangleShape(width, height)
  newObj.fixture = love.physics.newFixture(
    newObj.body, newObj.shape, (width * height) / mass
  )
  newObj.body:setFixedRotation(true)
  newObj.color = color
  self.__index = self
  return setmetatable(newObj, self)
end

function Box:update(dt)
end

function Box:draw()
  love.setColor(
    self.color[1],
    self.color[2],
    self.color[3]
  )
  love.graphics.polygon("fill", self.body.getWorldPoints(self.shape.getPoints()))
end