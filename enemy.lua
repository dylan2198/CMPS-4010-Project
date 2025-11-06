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
            crushedFrames = {
                love.graphics.newImage("assets/Mario1/Characters/Enemies/2.png")  -- crushed goomba
            },
            animationSpeed = 0.2,
            spriteDirection = -1,
            crushDuration = 0.5
        },
        koopa = {
            frames = {
                love.graphics.newImage("assets/Mario1/Characters/Enemies/9.png"),
                love.graphics.newImage("assets/Mario1/Characters/Enemies/10.png")
            },
            crushedFrames = {
                love.graphics.newImage("assets/Mario1/Characters/Enemies/11.png")
            },
            animationSpeed = 0.18,
            spriteDirection = -1,
            crushDuration = 0.5
        },
        buzzybettle = {
            frames = {
                love.graphics.newImage("assets/Mario1/Characters/Enemies/19.png"),
                love.graphics.newImage("assets/Mario1/Characters/Enemies/20.png")
            },
            crushedFrames = {
                love.graphics.newImage("assets/Mario1/Characters/Enemies/18.png")
            },
            animationSpeed = 0.15,
            spriteDirection = -1,
            crushDuration = 0.5
        },
    }
end

function Enemy.removeAll()
    for i, v in ipairs(ActiveEnemies) do
        if v.physics and v.physics.body and not v.physics.body:isDestroyed() then
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
    instance.enemyType = enemyType or "goomba"

    instance.width = 16
    instance.height = 16
    instance.r = 0
    instance.speed = 30
    instance.direction = -1
    
    -- Animation properties
    instance.currentFrame = 1
    instance.animationTimer = 0
    
    -- Crush state
    instance.crushed = false
    instance.crushTimer = 0
    instance.toRemove = false  -- flag for safe removal

    -- create physics body
    instance.physics = {}
    instance.physics.body = love.physics.newBody(world, instance.x, instance.y, "dynamic")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.body:setPosition(instance.x, instance.y + (32 - instance.height)/2)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.body:setFixedRotation(true)
    instance.physics.body:setMass(25)
    
    -- Prevent rotation and vertical movement
    instance.physics.body:setLinearDamping(0)
    instance.physics.body:setAngularDamping(0)
    
    -- Set user data so we can identify this fixture in collisions
    instance.physics.fixture:setUserData({type = "enemy", instance = instance})

    table.insert(ActiveEnemies, instance)
    return instance
end

function Enemy:update(dt)
    if self.crushed then
        self:updateCrush(dt)
    else
        self:updateAnimation(dt)
        self:patrol(dt)
        self:checkMapBounds()
    end
    
    self:keepGrounded()
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

function Enemy:updateCrush(dt)
    local typeData = Enemy.enemyTypes[self.enemyType]
    if not typeData then return end
    
    self.crushTimer = self.crushTimer + dt
    
    -- Mark for removal after crush duration
    if self.crushTimer >= typeData.crushDuration then
        self.toRemove = true
    end
end

function Enemy:crush()
    if self.crushed then return end
    
    self.crushed = true
    self.crushTimer = 0
    self.currentFrame = 1
    
    -- Stop movement
    if self.physics.body and not self.physics.body:isDestroyed() then
        self.physics.body:setLinearVelocity(0, 0)
    end
    self.speed = 0
end

function Enemy:patrol(dt)
    if not self.physics.body or self.physics.body:isDestroyed() then return end
    self.physics.body:setLinearVelocity(self.speed * self.direction, 0)
end

function Enemy:keepGrounded()
    if not self.physics.body or self.physics.body:isDestroyed() then return end
    
    local vx, vy = self.physics.body:getLinearVelocity()
    if vy ~= 0 then
        self.physics.body:setLinearVelocity(vx, 0)
    end
end

function Enemy:checkMapBounds()
    if not self.physics.body or self.physics.body:isDestroyed() then return end
    
    local mapWidth = map.width * map.tilewidth
    local halfWidth = self.width / 2
    
    if self.x <= halfWidth then
        self.direction = 1
        self.physics.body:setX(halfWidth + 1)
    end
    
    if self.x >= mapWidth - halfWidth then
        self.direction = -1
        self.physics.body:setX(mapWidth - halfWidth - 1)
    end
end

function Enemy:flipDirection()
    self.direction = self.direction * -1
end

function Enemy:syncPhysics()
    if not self.physics.body or self.physics.body:isDestroyed() then return end
    
    self.x, self.y = self.physics.body:getPosition()
    self.r = self.physics.body:getAngle()
end

function Enemy:draw()
    local spriteW, spriteH = 32, 32
    local typeData = Enemy.enemyTypes[self.enemyType]
    
    if typeData then
        local img
        
        if self.crushed then
            img = typeData.crushedFrames[self.currentFrame] or typeData.crushedFrames[1]
        else
            img = typeData.frames[self.currentFrame]
        end
        
        if img then
            local offsetX = spriteW / 2
            local offsetY = spriteH - self.height / 2
            
            local scaleX = self.crushed and 1 or (self.direction * typeData.spriteDirection)
            love.graphics.draw(img, self.x, self.y, self.r, scaleX, 1, offsetX, offsetY)
        end
    else
        love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
    end
end

function Enemy.updateAll(dt)
    -- Update all enemies
    for i = #ActiveEnemies, 1, -1 do
        local enemy = ActiveEnemies[i]
        enemy:update(dt)
    end
    
    -- Remove marked enemies after update loop
    for i = #ActiveEnemies, 1, -1 do
        local enemy = ActiveEnemies[i]
        if enemy.toRemove then
            if enemy.physics.body and not enemy.physics.body:isDestroyed() then
                enemy.physics.body:destroy()
            end
            table.remove(ActiveEnemies, i)
        end
    end
end

function Enemy.drawAll()
    for _, instance in ipairs(ActiveEnemies) do
        instance:draw()
    end
end

function Enemy.getActiveEnemies()
    return ActiveEnemies
end

function Enemy.beginContact(a, b, collision)
    local enemyData = nil
    local otherFixture = nil
    
    if a:getUserData() and a:getUserData().type == "enemy" then
        enemyData = a:getUserData()
        otherFixture = b
    elseif b:getUserData() and b:getUserData().type == "enemy" then
        enemyData = b:getUserData()
        otherFixture = a
    end
    
    if not enemyData then return end
    
    local enemy = enemyData.instance
    
    if enemy.crushed then return end
    
    local nx, ny = collision:getNormal()
    
    if b:getUserData() and b:getUserData().type == "enemy" then
        nx = -nx
        ny = -ny
    end
    
    -- Check if player is involved in collision
    if otherFixture:getBody() == player.physics.body then
        if math.abs(ny) > 0.7 then
            if ny < 0 then
                -- Player stomped enemy from above
                enemy:crush()
                if player then
                    player.y_vel = -200
                end
                return
            end
        else
            -- Side collision - player takes damage
            if not enemy.crushed and not player.invincible then
                player:takeDamage(enemy.x)  -- pass enemy position for knockback direction
            end
        end
    end
    
    -- Horizontal collisions with walls flip direction
    if math.abs(nx) > 0.7 then
        enemy:flipDirection()
    end
end

return Enemy