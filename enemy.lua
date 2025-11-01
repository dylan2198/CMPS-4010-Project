-- enemy.lua
local Enemy = {}
Enemy.__index = Enemy

local Player = require("player")

local ActiveEnemies = {}

function Enemy.loadAssets()
    -- Load all enemy frames
    Enemy.enemyTypes = {
        goomba = {
            frames = {
                love.graphics.newImage("assets/Mario1/Characters/Enemies/0.png"),
                love.graphics.newImage("assets/Mario1/Characters/Enemies/1.png")
            },
            animationSpeed = 0.2
        },
        koopa = {
            frames = {
                love.graphics.newImage("assets/Mario1/Characters/Enemies/9.png"),
                love.graphics.newImage("assets/Mario1/Characters/Enemies/10.png")
            },
            animationSpeed = 0.18
        },
        buzzybettle = {
            frames = {
                love.graphics.newImage("assets/Mario1/Characters/Enemies/19.png"),
                love.graphics.newImage("assets/Mario1/Characters/Enemies/20.png")
            },
            animationSpeed = 0.15
        },
    }
end

function Enemy.removeAll()
    for i, v in ipairs(ActiveEnemies) do
        if v.physics and v.physics.body then
            v.physics.body:destroy()
        end
    end
    ActiveEnemies = {}
end

function Enemy.newRelativeToPlayer(offsetX, offsetY, enemyType)
    local px, py = Player.x or 0, Player.y or 0
    local enemyY = py
    return Enemy.new(px + (offsetX or 100), enemyY, enemyType)
end

function Enemy.new(x, y, enemyType)
    local instance = setmetatable({}, Enemy)
    instance.x = x or 0
    instance.y = y or 0
    instance.enemyType = enemyType or "goomba"  -- default to goomba

    instance.width = 16
    instance.height = 16
    instance.r = 0
    instance.speed = 30
    instance.direction = -1
    
    -- Animation properties
    instance.currentFrame = 1
    instance.animationTimer = 0

    -- create physics body
    instance.physics = {}
    instance.physics.body = love.physics.newBody(world, instance.x, instance.y, "dynamic")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.body:setPosition(instance.x, instance.y + (32 - instance.height)/2)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.body:setFixedRotation(true)
    instance.physics.body:setMass(25)

    table.insert(ActiveEnemies, instance)
    return instance
end

function Enemy:update(dt)
    self:updateAnimation(dt)
    self:patrol(dt)
    self:syncPhysics()
end

function Enemy:updateAnimation(dt)
    local typeData = Enemy.enemyTypes[self.enemyType]
    if not typeData then return end
    
    self.animationTimer = self.animationTimer + dt
    
    if self.animationTimer >= typeData.animationSpeed then
        self.animationTimer = self.animationTimer - typeData.animationSpeed
        self.currentFrame = self.currentFrame + 1
        
        if self.currentFrame > #typeData.frames then
            self.currentFrame = 1
        end
    end
end

function Enemy:patrol(dt)
    local vx = self.speed * self.direction
    self.physics.body:setLinearVelocity(vx, 0)
end

function Enemy:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.r = self.physics.body:getAngle()
end

function Enemy:draw()
    local spriteW, spriteH = 32, 32
    local typeData = Enemy.enemyTypes[self.enemyType]
    
    if typeData then
        local img = typeData.frames[self.currentFrame]
        
        if img then
            local offsetX = spriteW / 2
            local offsetY = spriteH - self.height / 2

            love.graphics.draw(img, self.x, self.y, self.r, 1, 1, offsetX, offsetY)
        end
    else
        -- fallback
        love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
    end
end

function Enemy.updateAll(dt)
    for _, instance in ipairs(ActiveEnemies) do
        instance:update(dt)
    end
end

function Enemy.drawAll()
    for _, instance in ipairs(ActiveEnemies) do
        instance:draw()
    end
end

return Enemy