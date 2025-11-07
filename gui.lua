GUI = {}

function GUI:load()
    self.coins = {}
    self.coins.image = love.graphics.newImage('assets/Mario1/Misc/coin-512x512.png')

    local imgWidth, imgHeight = self.coins.image:getDimensions()
    self.coins.frameWidth = imgHeight     -- since each frame is square
    self.coins.frameHeight = imgHeight
    self.coins.scale = 0.095
    self.coins.x = 50 -- UPDATE THESE TO BE RELATIVE TO PLAYER.
    self.coins.y = 50 -- UPDATE THESE TO BE RELATIVE TO PLAYER.
    self.font = love.graphics.newFont(18)
    love.graphics.setFont(self.font)
    self.coins.quad = love.graphics.newQuad(
        0, 0,                              -- start of first frame
        self.coins.frameWidth, self.coins.frameHeight,
        imgWidth, imgHeight
    )
end

function GUI:update(dt)
    -- Currently no dynamic elements to update in the GUI
end

function GUI:draw()
    self:displayCoins()
    self:displayCoinText()
end

function GUI:displayCoins()
    love.graphics.setColor(0, 0, 0, .5)
    love.graphics.draw(
        self.coins.image,
        self.coins.quad,                    -- use the single frame
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
        self.coins.quad,                    -- use the single frame
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
    love.graphics.setColor(1, 1, 1, 1) -- reset color to white
    love.graphics.print(
        " x " .. tostring(player.coins),
        x,
        y
    ) 
    love.graphics.setColor(1, 1, 1, 1) -- reset color to white
end