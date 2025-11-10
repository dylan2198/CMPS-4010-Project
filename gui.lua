GUI = {}

function GUI:load()
    self.font = love.graphics.newFont('assets/Fonts/super-mario-bros-nes.ttf', 12)
    self.timer = 400
    self.positions = {}
    self.positions.points = (player.x * 2) - 48
    self.positions.coins = self.positions.points + 100
    self.positions.world = self.positions.coins + 100
    self.positions.time = self.positions.world + 100

    self.coin = {}
    self.coin.image = love.graphics.newImage('assets/Mario1/Misc/Items.png')
    local imgWidth, imgHeight = self.coin.image:getDimensions()
    self.coin.frameWidth = 16
    self.coin.frameHeight = 16
    self.coin.scale = 0.94
    self.coin.quad = love.graphics.newQuad(
        0, 16,                              -- gets normal coin
        self.coin.frameWidth, self.coin.frameHeight,
        imgWidth, imgHeight
    )

    -- might do this later
        -- self.coin.quads = { timer = 0, rate = 0.12
        --     coin1 = love.graphics.newQuad(
        --     0, 32,                              -- start of first frame
        --     self.coin.frameWidth, self.coin.frameHeight,
        --     imgWidth, imgHeight
        --     ),

        --     coin2 = love.graphics.newQuad(
        --     16, 32,                              -- start of first frame
        --     self.coin.frameWidth, self.coin.frameHeight,
        --     imgWidth, imgHeight
        --     ),

        --     coin3 = love.graphics.newQuad(
        --     32, 32,                              -- start of first frame
        --     self.coin.frameWidth, self.coin.frameHeight,
        --     imgWidth, imgHeight
        --     ),

        --     coin4 = love.graphics.newQuad(
        --     48, 32,                              -- start of first frame
        --     self.coin.frameWidth, self.coin.frameHeight,
        --     imgWidth, imgHeight
        --     )

        -- }


end

-- might do this later
    -- function GUI:animate(dt)
    --     self.coin.quads.timer = self.coin.quads.timer + dt -- framerate code here
    --     if self.coin.quads.timer > elf.coin.quads.rate then -- frame has passed, setNewFrame()
    --         self.animations.timer = 0
    --         self:setNewFrame()
    --     end
    -- end


function GUI:update(dt)
    -- print('cam.x: ',cam.x)
    -- print('(player.x * 2) + (love.graphics.getWidth() - GAME_WIDTH) / 2: ', (player.x * 2) + (love.graphics.getWidth() - GAME_WIDTH) / 2)
    -- print('player.x * 2: ',player.x * 2)
    -- this math is weird, but the print statements above at least give some insight as to why the code below works
    if ((player.x * 2) + (love.graphics.getWidth() - GAME_WIDTH) / 2) == cam.x then 
        self.positions.points = player.x * 2 - 176
        self.positions.coins = self.positions.points + 100
        self.positions.world = self.positions.coins + 100
        self.positions.time = self.positions.world + 100
    end
    self.timer = self.timer - (1 * dt) -- decriments level timer
end

function GUI:draw()
    self:displayCoin()
    love.graphics.setFont(self.font)
    love.graphics.print('MARIO\n' .. string.format('%06d', player.points), self.positions.points, 10)
    love.graphics.print(" \n×" .. string.format('0%d' ,player.coins), self.positions.coins + 28, 10) 
    love.graphics.print('WORLD\n 1-1', self.positions.world, 10)
    love.graphics.print('TIME\n ' .. string.format('%d', self.timer), self.positions.time, 10)
end

function GUI:displayCoin()
    love.graphics.draw(
        self.coin.image,
        self.coin.quad,                    -- use the single frame
        self.positions.coins + 20,
        30,
        0,
        self.coin.scale,
        self.coin.scale,
        self.coin.frameWidth / 2,
        self.coin.frameHeight / 2
    )
end