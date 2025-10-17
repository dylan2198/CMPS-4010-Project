---@diagnostic disable: duplicate-set-field, lowercase-global 

local STI = require('libraries.sti') -- STI library; useful for loading Tiled maps. also has some nice love.physics integration with Tiled "colidables" objects
require('player')
require('coin')
function love.load()
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
    Coin:new(300, 200)
    Coin:new(400, 200)
    Coin:new(500, 100)
    player:load()
end

function love.update(dt)
    world:update(dt) -- updates the state of the world (physics)
    player:update(dt)
    Coin:updateAll(dt)
end

function love.draw()
    love.graphics.draw(background)
    map:draw(0, 0, 2, 2) -- draw every layer of map, with 2x scaling for x and y values of layers (map was created with the idea that we will scale it by 2 in code)

    -- everything drawn before push() and everything drawn after pop() are not affected by what runs between push() and pop()
    love.graphics.push() -- copies and pushes the pre-2x scaling of the COORDINATE SYSTEM to transformation stack
    love.graphics.scale(2, 2) -- scales entire coordinate system by 2; this will be for objects that are not apart of the map from Tiled
    player:draw() -- player gets scaled by 2x
    Coin:drawAll()

    love.graphics.pop() -- pops coordinate system in transformation stack (coord system before 2x scaling); we do this so we can draw objects that we don't want to 2x scale after love.graphics.pop()

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

