---@diagnostic disable: duplicate-set-field, lowercase-global 
WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
GAME_WIDTH, GAME_HEIGHT = 512, 480
local STI = require('libraries.sti') -- STI library; useful for loading Tiled maps. also has some nice love.physics integration with Tiled "colidables" objects
love.graphics.setDefaultFilter('nearest','nearest')
require('player')
require('coin')
require('gui')
require('sounds')
local Enemy = require('enemy')

function love.load()
    push = require('libraries.push')
    push:setupScreen(GAME_WIDTH, GAME_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {fullscreen = false})
    camera = require('libraries.camera')
    cam = camera()

    sounds:loadSounds()
    map = STI('map/level1-1.lua') -- load in map. also tells sti we will use box2d physics engine
    world = love.physics.newWorld(0, 0) -- creates a new physics simulation world with no gravity; a world is a container where physical objects exists
    world:setCallbacks(beginContact, endContact) -- setting callback fns to be called when fixtures collide / separate after collision
    --map:box2d_init(world)
    -- Initializes Box2D physics for the map using the given world.
    -- This connects Tiled objects (with the "collidable" property) to the Box2D engine as static bodies.
    -- It automatically creates immovable collision shapes instead of manually looping through objects to define them (as seen in LOVE2D_Basics directory)
    -- Provided by STI's Box2D plugin; integrates the map with the physics world.
    map.layers.collidables.visible = false

    tile_layer = map.layers['ground']
    collision_layer = map.layers['collidables']
    fixture_to_tiles = {}
    createCollisionFixtures()

    -- setup code to allow background to constantly repeat in love.draw()
    background = love.graphics.newImage('assets/Mario1/Misc/background1.png')
    background:setWrap("repeat", "clamp")
    bg_quad = love.graphics.newQuad(0, 0, love.graphics.getWidth(), love.graphics.getHeight(), background:getDimensions())

    player:load()
    Enemy.loadAssets()
    GUI:load()
    -- maybe place these coins behind blocks
    --Coin:new(300, 200)
    --Coin:new(400, 200)
    --Coin:new(500, 100)
    -- enemies able to walk over non-block areas; look into
    enemies = {}
    for i = 1, 11 do
        table.insert(enemies, Enemy.newRelativeToPlayer(i * 450, 0, 'goomba'))
    end
    for i = 1, 5 do
        table.insert(enemies, Enemy.newRelativeToPlayer(i * 300, 0, 'buzzybettle'))
    end
    -- Enemy.newRelativeToPlayer(500, 0, "goomba")
    -- Enemy.newRelativeToPlayer(600, 0, "buzzybettle")
    -- Enemy.newRelativeToPlayer(800, 0, "buzzybettle")
    -- Enemy.newRelativeToPlayer(1000, 0, "buzzybettle")
    -- Enemy.newRelativeToPlayer(1200, 0, "buzzybettle")
    -- Enemy.newRelativeToPlayer(1500, 0, "buzzybettle")
    sounds.theme:play()
end

function love.update(dt)
    world:update(dt)
    player:update(dt)
    Coin:updateAll(dt)
    Enemy.updateAll(dt)
    cam:lookAt((player.x * 2) + (love.graphics.getWidth() - GAME_WIDTH) / 2, player.y) -- player.x * 2 because of 2x game scaling in love.draw()
    cam:update(map)
    GUI:update(dt)
end


function love.draw()
    push:start()
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
    push:finish()
end

function love.keypressed(key) -- keypressed callback fn that runs if certain keys are pressed
    player:jump(key)
    -- pipe code if 's' or down arrow pressed?
end

function createCollisionFixtures()
    -- creates one singular static body to hold all tile fixtures
    collision_body = love.physics.newBody(world, 0, 0, 'static')
    
    -- iterate through all objects defined in tiled, create merged fixtures for each
    for _, object in pairs(collision_layer.objects) do
        if object.shape == 'rectangle' then
            -- creates one fixture for entire object
            local shape = love.physics.newRectangleShape(object.x + (object.width / 2), object.y + (object.height / 2), object.width, object.height)
            local fixture = love.physics.newFixture(collision_body, shape)

            -- calculates which tiles this fixture covers
            local start_x = math.floor(object.x / map.tilewidth)
            local end_x = math.ceil((object.x + object.width) / map.tilewidth)
            local start_y = math.floor(object.y / map.tileheight)
            local end_y = math.ceil((object.y + object.height) / map.tileheight)

            -- store the mapping between a fixture and its associated tiles
            local tiles = {}
            for ty = start_y, end_y - 1 do
                for tx = start_x, end_x - 1 do
                    table.insert(tiles, {x = tx, y = ty})
                end
            end

            -- this or something like this could be used to rebuild the fixtures accordingly after breaking a block
            fixture_to_tiles[fixture] = {
                tiles = tiles,
                bounds = {
                    start_x = start_x,
                    end_x = end_x,
                    start_y = start_y,
                    end_y = end_y
                }
            }
        end

    end

end

function beginContact(a, b, collision)
    if Coin:beginContact(a, b, collision) then return end
    player:beginContact(a, b, collision)
    Enemy.beginContact(a, b, collision)
end

function endContact(a, b, collision)
    player:endContact(a, b, collision)
end

