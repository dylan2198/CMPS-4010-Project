---@diagnostic disable: duplicate-set-field, lowercase-global 

local STI = require('libraries.sti') -- STI library; useful for loading Tiled maps. also has some nice love.physics integration with Tiled "colidables" objects
love.graphics.setDefaultFilter('nearest','nearest')
require('player')
require('coin')
require('gui')

function love.load()
    local Camera = require('libraries.camera') -- camera library; useful for following player around map
    camera = Camera:new()
    map = STI('map/1.lua', {"box2d"}) -- load in map. also tells sti we will use box2d physics engine
    world = love.physics.newWorld(0, 0) -- creates a new physics simulation world with no gravity; a world is a container where physical objects exists
    world:setCallbacks(beginContact, endContact) -- setting callback fns to be called when fixtures collide / separate after collision
    map:box2d_init(world)
    -- Initializes Box2D physics for the map using the given world.
    -- This connects Tiled objects (with the "colidable" property) to the Box2D engine as static bodies.
    -- It automatically creates immovable collision shapes instead of manually looping through objects to define them (as seen in LOVE2D_Basics directory)
    -- Provided by STI's Box2D plugin; integrates the map with the physics world.
    map.layers.solids.visible = false
    background = love.graphics.newImage('assets/Mario1/Misc/background.png')
    GUI:load()
    Coin:new(300, 200)
    Coin:new(400, 200)
    Coin:new(500, 100)
    player:load()
end

function love.update(dt)
    world:update(dt)
    player:update(dt)
    Coin:updateAll(dt)
    GUI:update(dt)

    -- Camera: follow player
    local cx, cy = player.x, player.y

    -- Optional: clamp camera to map boundaries
    local mapWidth, mapHeight = map.width * map.tilewidth * 2, map.height * map.tileheight * 2
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()

    cx = math.max(cx, screenW / 2)
    cx = math.min(cx, mapWidth - screenW / 2)
    cy = math.max(cy, screenH / 2)
    cy = math.min(cy, mapHeight - screenH / 2)

    local lerp = 0.1
    local camX, camY = camera.x, camera.y
    camera:lookAt(camX + (cx - camX) * lerp, camY + (cy - camY) * lerp)

end


function love.draw()
    camera:attach()
        love.graphics.draw(background)
        map:draw(0, 0, 2, 2) -- draw every layer of map, with 2x scaling for x and y values of layers (map was created with the idea that we will scale it by 2 in code)

        -- everything drawn before push() and everything drawn after pop() are not affected by what runs between push() and pop()
        love.graphics.push() -- copies and pushes the pre-2x scaling of the COORDINATE SYSTEM to transformation stack
        love.graphics.scale(2, 2) -- scales entire coordinate system by 2; this will be for objects that are not apart of the map from Tiled
        player:draw() -- player gets scaled by 2x
        Coin:drawAll()
        love.graphics.pop() -- pops coordinate system in transformation stack (coord system before 2x scaling); we do this so we can draw objects that we don't want to 2x scale after love.graphics.pop()
        -- love.graphics.print('self.quad_width = ' .. player.quad_width, 10, 10)
        -- love.graphics.print('self.quad_height = ' .. player.quad_height, 10, 30)
    camera:detach()
    GUI:draw()
end

function love.keypressed(key) -- keypressed callback fn that runs if certain keys are pressed
    player:jump(key)
end

function beginContact(a, b, collision)
    if Coin:beginContact(a, b, collision) then return end
    player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
    player:endContact(a, b, collision)
end

