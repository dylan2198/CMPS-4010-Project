GUI = {}

function GUI:load()
    self.coins = {}
    self.coins.image = love.graphics.newImage('assets/Mario1/Misc/coin-512x512.png')

    local imgWidth, imgHeight = self.coins.image:getDimensions()
    self.coins.frameWidth = imgHeight
    self.coins.frameHeight = imgHeight
    self.coins.scale = 0.095
    self.coins.x = 50
    self.coins.y = 50
    
    self.font = love.graphics.newFont(18)
    love.graphics.setFont(self.font)
    
    self.coins.quad = love.graphics.newQuad(
        0, 0,
        self.coins.frameWidth, self.coins.frameHeight,
        imgWidth, imgHeight
    )
    
    -- Hearts setup
    self.hearts = {}
    self.hearts.maxHearts = 3
    self.hearts.currentHearts = 3
    self.hearts.size = 25
    self.hearts.spacing = 35
    self.hearts.x = 50
    self.hearts.y = 120  -- moved further down
end

function GUI:update(dt)
    -- Currently no dynamic elements to update in the GUI
end

function GUI:draw()
    self:displayCoins()
    self:displayCoinText()
    self:displayHearts()
end

function GUI:displayCoins()
    love.graphics.setColor(0, 0, 0, .5)
    love.graphics.draw(
        self.coins.image,
        self.coins.quad,
        self.coins.x + 2,
        self.coins.y + 2,
        0,
        self.coins.scale,
        self.coins.scale,
        self.coins.frameWidth / 2,
        self.coins.frameHeight / 2
    )
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        self.coins.image,
        self.coins.quad,
        self.coins.x,
        self.coins.y,
        0,
        self.coins.scale,
        self.coins.scale,
        self.coins.frameWidth / 2,
        self.coins.frameHeight / 2
    )
end

function GUI:displayCoinText()
    local x = self.coins.x + (self.coins.frameWidth * self.coins.scale) / 2 + 9
    local y = self.coins.y - (self.coins.frameHeight * self.coins.scale) / 2 + 9
    love.graphics.setColor(0, 0, 0, .5)
    love.graphics.print(
        " x " .. tostring(player.coins),
        x+2,
        y+2
    )
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(
        " x " .. tostring(player.coins),
        x,
        y
    ) 
end

function GUI:displayHearts()
    for i = 1, self.hearts.maxHearts do
        local x = self.hearts.x + (i - 1) * self.hearts.spacing
        local y = self.hearts.y
        
        -- Draw shadow
        love.graphics.setColor(0, 0, 0, 0.5)
        self:drawHeart(x + 2, y + 2, self.hearts.size)
        
        -- Draw heart (filled if current, outline if lost)
        if i <= self.hearts.currentHearts then
            love.graphics.setColor(1, 0, 0, 1)  -- red for filled hearts
            self:drawHeart(x, y, self.hearts.size)
        else
            love.graphics.setColor(0.3, 0.3, 0.3, 1)  -- gray for empty hearts
            self:drawHeartOutline(x, y, self.hearts.size)
        end
    end
    
    love.graphics.setColor(1, 1, 1, 1)  -- reset color
end

function GUI:drawHeart(x, y, size)
    local scale = size / 20
    love.graphics.polygon("fill", {
        x, y + 6 * scale,
        x - 10 * scale, y - 4 * scale,
        x - 10 * scale, y - 8 * scale,
        x - 6 * scale, y - 12 * scale,
        x, y - 8 * scale,
        x + 6 * scale, y - 12 * scale,
        x + 10 * scale, y - 8 * scale,
        x + 10 * scale, y - 4 * scale
    })
end

function GUI:drawHeartOutline(x, y, size)
    local scale = size / 20
    love.graphics.setLineWidth(2)
    love.graphics.polygon("line", {
        x, y + 6 * scale,
        x - 10 * scale, y - 4 * scale,
        x - 10 * scale, y - 8 * scale,
        x - 6 * scale, y - 12 * scale,
        x, y - 8 * scale,
        x + 6 * scale, y - 12 * scale,
        x + 10 * scale, y - 8 * scale,
        x + 10 * scale, y - 4 * scale
    })
    love.graphics.setLineWidth(1)
end

function GUI:loseHeart()
    if self.hearts.currentHearts > 0 then
        self.hearts.currentHearts = self.hearts.currentHearts - 1
        print("Heart lost! Remaining: " .. self.hearts.currentHearts)
        
        -- Optional: Check for game over
        if self.hearts.currentHearts <= 0 then
            print("Game Over!")
            -- You can add game over logic here
        end
    end
end

function GUI:gainHeart()
    if self.hearts.currentHearts < self.hearts.maxHearts then
        self.hearts.currentHearts = self.hearts.currentHearts + 1
    end
end

function GUI:resetHearts()
    self.hearts.currentHearts = self.hearts.maxHearts
end

return GUI