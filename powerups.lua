
local Powerups = {}
Powerups.__index = Powerups

-- none of this works right now
function Powerups:new(world, x, y, kind)
    local p = setmetatable({}, Powerups)
    p.kind = kind or 'mushroom'

    -- create physics body for powerup
    p.body = love.physics.newBody(world, x, y, "dynamic")
    p.shape = love.physics.newRectangleShape(16,16)
    p.fixture = love.physics.newFixture(p.body, p.shape)
    p.fixture:setUserData(p) -- allows collission callbacks to identify this powerup

    return p
end

function Powerups:update(dt)
    if self.kind == 'mushroom' then
      
    end
end

function Powerups:draw()
    local x, y = self.body:getPosition()
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('fill', x - 8, y - 8, 16, 16)
    love.graphics.setColor(1,1,1)
end



