function love.load()
    wf = require('libraries.windfield.windfield')

    -- first step to working with LOVE physics is to create a world
    -- a world is a space where physics objects exist, and we use the world to create objects
    world = wf.newWorld(0, 500) -- params (x = 0, y = 500) add gravity effects to world.
    -- this makes objects fall downwards, but not all objects need to be affected by gravity; see ground object below player var

    -- player object below is a rectangle collider; a physics object in our world
    -- normally in love.physics you would need to define a body, fixture, and shape
    -- a collider from windfield in a combination of these things in one place
    player = world:newRectangleCollider(350, 100, 80, 80)
    ground = world:newRectangleCollider(100, 400, 600, 100)
    ground:setType('static') -- makes this collider not affected by gravity; player lands on this platform
end

function love.update(dt)

    -- if love.keyboard.isDown('left') then
    --     player:applyForce(-5000, 0)
    -- elseif love.keyboard.isDown('right') then
    --     player:applyForce(5000, 0)
    -- end

    -- forces keep stacking and growing more intense; i.e. acceleration continues to grow as you go left/right
    -- we can limit this by only applying a force if player object is not already moving at a max speed
    -- max speeds below are a left/right velocity of -300, 300
    local px, py = player:getLinearVelocity() -- gets player object's velocity and puts x and y values into px, py respectively
    if love.keyboard.isDown('left') and px > -300 then
        player:applyForce(-8000, 0)
        -- does not applyForce if left velocity is -300 or less
    elseif love.keyboard.isDown('right') and px < 300 then
        player:applyForce(8000, 0)
        -- does not applyForce if right velocity is 300 or more
    end

    -- makes sure world and physics are updated according to delta time
    world:update(dt)
end

function love.draw()
    -- draws shapes of all colliders in world
    world:draw()
end

-- callback function that reacts if 'up' key is pressed
function love.keypressed(key)
    if key == 'up' then
        -- a quick "impulse" is applied to collider object if 'up' key is pressed
        -- negative y-value, so object goes upward
            -- in love2D, larger values of y signify a lower position
            -- ex: (0,0) is upper most left corner of a game window
            -- (0, 100) is left-most position for x, but y-value is 100 pixels lower than in (0,0)
        player:applyLinearImpulse(0, -5000)
    end
end


