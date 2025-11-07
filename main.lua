---@diagnostic disable: duplicate-set-field, lowercase-global 

local STI = require('libraries.sti') -- STI library; useful for loading Tiled maps. also has some nice love.physics integration with Tiled "colidables" objects
love.graphics.setDefaultFilter('nearest','nearest')
require('player')
require('coin')
require('gui')
local Enemy = require('enemy')

function love.load()
    camera = require('libraries.camera')
    cam = camera()
    
    map = STI('map/level1-1.lua', {"box2d"}) -- load in map. also tells sti we will use box2d physics engine
    world = love.physics.newWorld(0, 0) -- creates a new physics simulation world with no gravity; a world is a container where physical objects exists
    world:setCallbacks(beginContact, endContact) -- setting callback fns to be called when fixtures collide / separate after collision
    map:box2d_init(world)
    -- Initializes Box2D physics for the map using the given world.
    -- This connects Tiled objects (with the "collidable" property) to the Box2D engine as static bodies.
    -- It automatically creates immovable collision shapes instead of manually looping through objects to define them (as seen in LOVE2D_Basics directory)
    -- Provided by STI's Box2D plugin; integrates the map with the physics world.
    map.layers.ground_blocks.visible = false

    -- setup code to allow background to constantly repeat in love.draw()
    background = love.graphics.newImage('assets/Mario1/Misc/background1.png')
    background:setWrap("repeat", "clamp")
    bg_quad = love.graphics.newQuad(0, 0, love.graphics.getWidth(), love.graphics.getHeight(), background:getDimensions())

    GUI:load()
    Coin:new(300, 200)
    Coin:new(400, 200)
    Coin:new(500, 100)

    player:load()
    Enemy.loadAssets()
    -- enemies able to walk over non-block areas; look into
    Enemy.newRelativeToPlayer(400, 0, "goomba")
    Enemy.newRelativeToPlayer(600, 0, "buzzybettle")
    Enemy.newRelativeToPlayer(800, 0, "buzzybettle")
    Enemy.newRelativeToPlayer(1000, 0, "buzzybettle")
    Enemy.newRelativeToPlayer(1200, 0, "buzzybettle")
    Enemy.newRelativeToPlayer(1500, 0, "buzzybettle")
end

function love.update(dt)
    world:update(dt)
    player:update(dt)
    Coin:updateAll(dt)
    GUI:update(dt)
    Enemy.updateAll(dt)
    cam:lookAt(player.x * 2, player.y) -- player.x * 2 because of 2x game scaling in love.draw()
    cam:update(map)
end


function love.draw()
    cam:attach()
        love.graphics.draw(background, bg_quad, cam.x - love.graphics.getWidth() / 2, 0)
        -- everything drawn before push() and everything drawn after pop() are not affected by what runs between push() and pop()
        love.graphics.push() -- copies and pushes the pre-2x scaling of the coordinate system to transformation stack
            love.graphics.scale(2, 2) -- scales everything within push() & pop() by 2x
            -- draw map layers individually; have to do this for camera library
            map:drawLayer(map.layers['castle'])
            map:drawLayer(map.layers['grass'])
            map:drawLayer(map.layers['test'])
            map:drawLayer(map.layers['ground'])
            player:draw()
            Coin:drawAll()
            Enemy.drawAll()
        love.graphics.pop() -- pops the coordinate system stored in transformation stack (before 2x scaling); we do this so we can draw objects that we don't want to 2x scale after love.graphics.pop()
        GUI:draw()
    cam:detach()
end

function love.keypressed(key) -- keypressed callback fn that runs if certain keys are pressed
    player:jump(key)
end

function beginContact(a, b, collision)
    if Coin:beginContact(a, b, collision) then return end
    player:beginContact(a, b, collision)
    Enemy.beginContact(a, b, collision)
end

function endContact(a, b, collision)
    player:endContact(a, b, collision)
end

