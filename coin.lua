Coin = {}
Coin.__index = Coin
ActiveCoins = {}
function Coin:new(x, y)
    local coin = setmetatable({}, Coin)
    coin.x = x
    coin.y = y
    coin.image = love.graphics.newImage('assets/Mario1/Misc/coin-512x512.png')

    -- Frame setup
    local imgWidth, imgHeight = coin.image:getDimensions()
    coin.frameHeight = imgHeight         -- assuming square frames
    coin.frameWidth = imgHeight
    coin.frames = 25                      -- coin sheet has 25 frames
    coin.currentFrame = 1
    coin.animationTimer = 0
    coin.animationSpeed = 0.05           -- tweak for desired spin speed
    coin.scale = 0.03                     -- adjust size

    coin.physics = {}
    coin.physics.body = love.physics.newBody(world, coin.x, coin.y, "static")
    coin.physics.shape = love.physics.newRectangleShape(coin.frameWidth * coin.scale, coin.frameHeight * coin.scale)
    coin.physics.fixture = love.physics.newFixture(coin.physics.body, coin.physics.shape)
    coin.physics.fixture:setSensor(true) -- makes fixture a sensor so player can pass through it

    coin.toBeRemoved = false
    -- Build quads
    coin.quads = {}
    for i = 0, coin.frames - 1 do
        coin.quads[i + 1] = love.graphics.newQuad(
            i * coin.frameWidth, 0,
            coin.frameWidth, coin.frameHeight,
            imgWidth, imgHeight
        )
    end

    table.insert(ActiveCoins, coin)
end

function Coin:drawAll()
    for _, coin in ipairs(ActiveCoins) do
        coin:draw()
    end
end

function Coin:update(dt)
    self.animationTimer = self.animationTimer + dt
    if self.animationTimer >= self.animationSpeed then
        self.animationTimer = self.animationTimer - self.animationSpeed
        self.currentFrame = self.currentFrame + 1
        if self.currentFrame > self.frames then
            self.currentFrame = 1
        end
    end

    self:checkRemove()
end

function Coin:updateAll(dt)
    for _, coin in ipairs(ActiveCoins) do
        coin:update(dt)
    end
end

function Coin:draw()
    love.graphics.draw(
        self.image,
        self.quads[self.currentFrame],
        self.x, self.y,
        0,               -- rotation angle
        self.scale, self.scale,
        self.frameWidth / 2, self.frameHeight / 2
    )
end

function Coin:beginContact(a, b, collision)
    for i, coin in ipairs(ActiveCoins) do
        if a == coin.physics.fixture or b == coin.physics.fixture then
            if a == player.physics.fixture or b == player.physics.fixture then
                print("Coin collected!")
                player:incrementCoins()
                coin.toBeRemoved = true
                table.remove(ActiveCoins, i)
                return true
            end
        end
    end
end

function Coin:remove()
    for i, coin in ipairs(ActiveCoins) do
        if coin == self then
            self.physics.body:destroy()
            table.remove(ActiveCoins, i)
            break
        end
    end
end

function Coin:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end