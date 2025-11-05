-- libraries/camera.lua
local Camera = {}
Camera.__index = Camera

function Camera:new(x, y)
    local self = setmetatable({}, Camera)
    self.x, self.y = x or 0, y or 0
    return self
end

function Camera:attach() end
function Camera:detach() end
function Camera:lookAt(x, y) self.x, self.y = x, y end

return Camera
