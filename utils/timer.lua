Timer = {}
mtTimer = { __index=Timer }

function Timer:new(initial, left)
  local newObj = {
    left = left or 0,
    initial = initial,
  }
  setmetatable(newObj, mtTimer)
  return newObj
end


function Timer:update(dt)
  if self.left > 0 then self.left = self.left - dt end
end

function Timer:runOut()
  return self.left <= 0
end

function Timer:reset()
  self.left = self.initial
end

function Timer:getTime()
  return self.left
end

return Timer