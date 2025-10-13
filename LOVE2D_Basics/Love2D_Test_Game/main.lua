function love.load()
    wf = require('libraries.windfield.windfield') -- physics library
    -- creates new world; a place where physics objects exist
    -- the params (0,0) specify no gravity for this game since it is a top-down rpg example
    world = wf.newWorld(0,0) 

    camera = require('libraries.camera') -- player camera library
    cam = camera() -- creates a camera object

    anim8 = require('libraries.anim8') -- library for frame animations
    love.graphics.setDefaultFilter('nearest', "nearest") -- math stuff that scales pixel art nicely

    sti = require('libraries.sti') -- library that makes using the 'Tiled' application simpler
    gameMap = sti('maps/testMap..lua') -- load in Tiled map 

    player = {} -- player is represented by a table
    -- octagon-like collider; a collider is a object that can have physics properties
    player.collider = world:newBSGRectangleCollider(400, 250, 50, 100, 10) 
    player.collider:setFixedRotation(true) -- prevents collider from rotating
    -- starting positions of player on screen
    player.x = 400
    player.y = 200
    --player.speed = 5 (speed before player collider set up)
    player.speed = 300 -- (speed for player collider)
    -- loads in player sprite sheet, returns an Image object (userdata)
    player.spriteSheet = love.graphics.newImage('sprites/player-sheet.png')
    player.grid = anim8.newGrid(12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    -- params (12, 18) represent the size of each frame of an animation; a frame is just a slightly different drawing of the player to emulate motion in an animation
    -- we are using a provided sprite sheet in this game example and each frame is 12 x 18 pixels
    -- newGrid() returns a table to player.grid, which has its own attributes and functions
    -- a grid is a collection of tiles (see line 137)

    --[[ 
        MIGHT BE IMPORTANT: 
        player.spriteSheet:getWidth() == player.spriteSheet.getWidth(player.spriteSheet)
        when you see colons (:) in Lua, it is syntactic sugar for passing an objects 'self' ('self' in Python; 'this' in Java) to a function call on that object
        the reason player.spriteSheet now has getWidth() functions is because newImage() returned an Image object (userdata) to player.spriteSheet
        Image objects have their own attributes and functions
        so player.spriteSheet:getWidth() is just the act of calling a function that Image objects possess
    --]]

    player.animations = {} -- table that holds different animations
    -- newAnimation() returns a table, so these variables below will have functions and attributes accessible by them from newAnimation
    -- player.grid() is a shortcut and equivalent to calling player.grid:getFrames()
    -- the code below creates different tables that contain the frames to a certain animation (walking left animation, walking right, etc..)
    -- player.anim:draw() in draw() function is what actually makes these animations work
    player.animations.down = anim8.newAnimation( player.grid('1-4', 1), 0.2)
    player.animations.left = anim8.newAnimation( player.grid('1-4', 2), 0.2)
    player.animations.right = anim8.newAnimation( player.grid('1-4', 3), 0.2)
    player.animations.up = anim8.newAnimation( player.grid('1-4', 4), 0.2)
    player.anim = player.animations.down -- standard game start animation

    -- code below checks if there is a layer called 'Walls' from Tiled map
    -- if so, iterates over the objects in that Walls layer
    -- creates the colliders based on the object's x, y, width, and height (all can be found in testMap.tmx)
    -- makes them static (unmovable) and then inserts the colliders into the walls table
    walls = {}
    if gameMap.layers['Walls'] then
        for i, obj in pairs(gameMap.layers['Walls'].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            table.insert(walls, wall)
        end
    end

    -- same thing for trees in Tiled map
    trees = {}
    if gameMap.layers['Tree Objects'] then
        for i, obj in pairs(gameMap.layers['Tree Objects'].objects) do
            local tree = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            tree:setType('static')
            table.insert(trees, tree)
        end
    end

end

function love.update(dt) -- dt is delta time

    local isMoving = false

    -- velocity x & velocity y; represents player colliders velocity 
    local vx = 0 
    local vy = 0

    if love.keyboard.isDown("up") then
        player.anim = player.animations.up
        -- player.y = player.y - player.speed (this is old movement code before colliders implementation)
        vy = player.speed * -1 -- remember, going up REDUCES pixel values of y; thus negative here
        isMoving = true
    end

    if love.keyboard.isDown("down") then
        player.anim = player.animations.down
        --player.y = player.y + player.speed
        vy = player.speed
        isMoving = true
    end

    if love.keyboard.isDown("left") then
        player.anim = player.animations.left
        --player.x = player.x - player.speed
        vx = player.speed * -1
        isMoving = true
    end

    if love.keyboard.isDown("right") then
        player.anim = player.animations.right
        --player.x = player.x + player.speed 
        vx = player.speed
        isMoving = true
    end

    -- sets player linear velocity based on keyboard input conditionals above
    -- this is updated movement code since player's x and y is now lined up to the player collider
    player.collider:setLinearVelocity(vx, vy) 

    if isMoving == false then
        player.anim:gotoFrame(2) 
        -- if player is not moving, go to frame 2 in most recent play.anim frame set
        -- frame 2 is always a stationary frame
    end

    world:update(dt) -- code to keep physics objects updated according to delta time

    -- the code below makes the player position always line up with the collider
    -- we do this so the player does not walk through walls, trees, etc
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    if isMoving then
        player.anim:update(dt) -- updates animations according to delta time
        --[[ 

        an attempt at a basic explanation of how anim8 library is working here:
        -- an animation is simply a collection of frames.
        -- newAnimation() is passed a GRID for a specific animation (left, right, up, down)
        -- generally, a grid is just a collection of tiles, where tiles can be thought of as a sticker from a sticker set
        -- so a tile from the grid player.grid('1-4', 1, .02) will be one of the frames in row 1 of player-sheet.png
        -- player.grid is a var that references a table that holds all of the tiles (different frames)
        -- using player.grid(), we can specify what frames we want for a certain animation
        -- we can use a string with a range to specify columns 1-4, and then specify a row to select a certain set of frames
        -- for ex: anim8.newAnimation( player.grid('1-4',4), 0.2) says to consider all tiles in columns 1-4, but only choose row 1
        -- columns 1-4, row 1 represent the the 'down' animation
        --]]
    end

    cam:lookAt(player.x, player.y) -- make camera look at the players position

    local w = love.graphics.getWidth() -- width of game window screen
    local h = love.graphics.getHeight() -- height of game window screen

    -- i assume cam.x is assigned the value of player.x
    -- if cam.x is less than half the width of the window (w/2), then reassign cam.x to be (w/2)
    -- this ensures camera doesn't see beyond our map (just black space)
    -- the camera stops following the player if cam.x < (w/2), and follows the player again if cam.x ~< w/2

    if cam.x < w/2 then
        cam.x = w/2
        -- when player.x < the pixel value of the middle of the game window, keep cam looking at center of window to avoid seeing outside of map
    end

    -- same thing here for y
    if cam.y < h/2 then
        cam.y = h/2
    end

    -- in the 'Tiled' application, we chose a map with a size of 30 tiles x 30 tiles
    -- we also made each tile be 64 x 64 pixels in size

    local mapW = gameMap.width * gameMap.tilewidth -- 30 tiles x pixel width of 64 per tile = 30 x 64 = map width is 1920 pixels
    local mapH = gameMap.height * gameMap.tileheight -- 30 tiles x pixel height of 64 per tile = 30 x 64 = map height is 1920 pixels

    -- right border
    -- cam.x is just assigned the most recent value of player.x
    -- if cam.x (player.x) > the width of the map in pixels (1920) - half the width of the game window screen (300 for ex)
    -- then set cam.x to be 1920 - 300 = 1620
    -- in other words,
    -- [0.....1920] is map width
    -- [0...600] is game window width
    -- so [1320.. 1620.. 1920] is the left edge pixel count, middle pixel count, and right border pixel count that we want to limit the camera to show in a game window when player is near right border
    -- if cam.x > 1620, we set cam.x to be 1620 again, forcing the camera to focus on the middle of this section of the map
    -- which avoids the camera looking beyond the map edges
    if cam.x > (mapW - w/2) then
        cam.x = mapW - w/2
    end

    -- bottom border
    if cam.y > (mapH - h/2) then
        cam.y = mapH - h/2
    end

end

function love.draw()
    -- apply camera transformations, movement, etc within cam:attach() and cam:detach()
    -- can think of cam:attach() as your view through a camera, and cam:detach() as no longer viewing through a camera
    cam:attach()
        --gameMap:draw() can't do this in cam:attach()? have to draw individual layers
        gameMap:drawLayer(gameMap.layers['Grass']) -- layer priority 1 from Tiled (open testMap.tmx in Tiled to see better explanation)
        gameMap:drawLayer(gameMap.layers['Trees']) -- layer priority 2
        -- player.anim:draw(player.spriteSheet, player.x, player.y, nil, 6)
        -- player is rendered using its top left-most position. a player is 12 x 18 based on the player-sheet.png we are using
        -- the camera is centering on the top left-most position of the player instead of the center of the player/sprite, so there is some offset to be corrected
        -- offset x of 6 and offset y of 9 makes camera center on middle of player sprite (code below)
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 6, nil, 6, 9)
        -- world:draw() removes collider outlines when commented
    cam:detach()
    love.graphics.print('HUD EXAMPLE', 10, 10) -- example of a HUD
end
