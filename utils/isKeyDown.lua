local keySettings = require('keySettings')

local function isKeyDown(keyPurpose)
  return (
    love.keyboard.isDown(keySettings[keyPurpose][1])
      or (keySettings[keyPurpose][2] and love.keyboard.isDown(keySettings[keyPurpose][2]))
  )
end

return isKeyDown