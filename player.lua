player = {}

function player:load()
    -- keeps track of player position
    self.x = 16 -- hard coded values for now..
    self.y = 340
    -- initial player dimensions (small mario)
    self.width = 16
    self.height = 16
    -- player velocity variables for movement; 0 by default so player doesn't move by default
    self.x_vel = 0
    self.y_vel = 0
    self.max_speed = 200 -- how many pixels/sec the player is able to move
    -- to avoid player going from 0 pixels/sec to 200 pixels/sec instantly we use the two vars below:
    self.acceleration = 4000 -- 200 / 4000 = .05 seconds to get to max speed
    self.friction = 3500 -- 200 / 3500 = .0571 seconds to come to full stop
    self.gravity = 1500
    self.jump_amount = -350
    self.grounded = false
    self.jump_count = 0
    self.max_jumps = 2 -- allows for double jumps
    self.jump_timer = 0 -- tracks how long the jump key has been held
    self.jump_time_max = 0.15 -- -- max seconds for extra upward force
    self.jump_hold = false -- is the jump key currently held
    self.coins = 0
    self.state = 'idle'
    self.form = 'small_mario'
    self.direction = 'right'
    self.quad_width = 0
    self.quad_height = 0

    self:loadAssets()

    -- table to hold players physical collision information;
    -- player physics objects are composed of 3 parts in LOVE2D:
    -- Body -> “where the player is and how it moves”
    -- Shape -> “what part of the player can hit or be hit”
    -- Fixture -> “glues the shape to the body so physics can act on it”
    self.physics = {}
    self.physics.body = love.physics.newBody(world, self.x, self.y, "dynamic") -- a body keeps track of position, velocity, and rotations; i.e. where an object is and where it's going
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.width, self.height) -- defining the shape of the physical body. used to dictate player collisions
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
end

function player:loadAssets()
    mario = love.graphics.newImage('assets/Mario1/Characters/Mario.png') -- load the player sprite sheet
    
    -- table loaded with small mario quads. weird numbers to account for sprite sheet; mario's hat kept getting cut off with 16x16
    self.small_mario_quads = {x_offset = 8, y_offset = 15, frame_width = 16, frame_height = 17}
    for i = 0, 7 do
        self.small_mario_quads[i + 1] = love.graphics.newQuad( 
            (i * 32) + self.small_mario_quads.x_offset,
            self.small_mario_quads.y_offset,
            self.small_mario_quads.frame_width,
            self.small_mario_quads.frame_height,
            mario:getDimensions()
        )
    end

    -- self.normal_mario_quads = { }
    -- for i = 8, 25 do
    --     self.big_mario_quads[i] = love.graphics.newQuad(
    --         i * 32,
    --         0,
    --         32, 32,
    --         mario:getDimensions()
    --     )
    -- end
    

    self.animations = {timer = 0, rate = 0.19}

    -- probably will add smallMarioRun, normalMarioRun, fireMarioRun, etc inner tables here later
    self.animations.idle = {

        small_mario = {

            total = 1,
            current = 1,
            frame_width = self.small_mario_quads.frame_width, -- width & heights of quad/frame
            frame_height = self.small_mario_quads.frame_height,
            quads = {self.small_mario_quads[1]}
        }

        -- normal_mario = {
        --     total = 9,
        --     current = 1,
        --     frame_width = self.normal_mario_quads.frame_width
        -- },

        -- fire_mario = {

        -- }
    }

    self.animations.run = {

        small_mario = {
            total = 3,
            current = 1,
            frame_width = self.small_mario_quads.frame_width,
            frame_height = self.small_mario_quads.frame_height,
            quads = {
                self.small_mario_quads[2],
                self.small_mario_quads[3],
                self.small_mario_quads[4]
            }
        }

        -- normal_mario = {

        -- },

        -- fire_mario = {

        -- }
    }

    self.animations.jump = {

        small_mario = {
            total = 1,
            current = 1,
            frame_width = self.small_mario_quads.frame_width,
            frame_height = self.small_mario_quads.frame_height,
            quads = {
                self.small_mario_quads[6]
            }
        }

        -- normal_mario = {
       
        -- },

        -- fire_mario = {

        -- }
    }

    self.animations.current_quad = self.animations.idle.small_mario.quads[1] -- default player
end


function player:incrementCoins()
    self.coins = self.coins + 1
    print("Coins collected: " .. self.coins)
end

function player:update(dt)
    self:setState()
    self:setDirection()
    self:animate(dt)
    self:syncPhysics()
    self:move(dt)
    self:applyGravity(dt)


     -- Variable jump height: if player holds jump, keep upward force for a short time
    if self.jump_hold then
        self.jump_timer = self.jump_timer + dt
        if self.jump_timer < self.jump_time_max and love.keyboard.isDown('w', 'up') then
            self.y_vel = self.jump_amount  -- keeps upward velocity for "floaty" feel
        else
            self.jump_hold = false
        end
    end
end

function player:setForm()
    -- code here to determine player form based on power up pickups (normal mario, fire mario) later down the line?
end

function player:setState()
    if not self.grounded then
        self.state = 'jump'
    elseif self.x_vel == 0 then
        self.state = 'idle'
    else
        self.state = 'run'
    end
    -- add slide, death, etc states here later?
end

function player:setDirection()
    if self.x_vel < 0 then
        self.direction = 'left'
    elseif self.x > 0 then
        self.direction = 'right'
    end
end

function player:animate(dt)
    self.animations.timer = self.animations.timer + dt -- framerate code here
    if self.animations.timer > self.animations.rate then -- frame has passed, setNewFrame()
        self.animations.timer = 0
        self:setNewFrame()
    end
end

function player:setNewFrame()
    -- depending on player state and form, anim references the correct animation table
    -- for ex, code below does something like this: anim = player.animations.idle.small_mario
    local anim = self.animations[self.state] and self.animations[self.state][self.form]

    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end

    self.animations.current_quad = anim.quads[anim.current] -- gets current quad/frame
    -- update quad_width and quad_height accordingly;
        -- if we are in the small_mario table, these values should be a certain size for the love.graphics.draw offset variables in player:draw()
        -- if we are in the normal_mario table, these values should change accordingly
    self.quad_width = anim.frame_width
    self.quad_height = anim.frame_height
end

function player:applyGravity(dt)
    if not self.grounded then -- if player is not grounded, then apply gravity
        self.y_vel = self.y_vel + self.gravity * dt
    end
end

-- the function below just changes velocity based on keyboard input; player.physics.body is the actual object we control with keyboard input using this line in syncPhysics(): self.physics.body:setLinearVelocity(self.x_vel, self.y_vel) 
function player:move(dt)
    if love.keyboard.isDown('d', 'right') then
        if self.x_vel < self.max_speed then
            if self.x_vel + self.acceleration * dt < self.max_speed then -- ensures player body does not go over max_speed; dt is a fraction
            -- self.state = 'run'?
            self.x_vel = self.x_vel + self.acceleration * dt 
            else
                self.x_vel = self.max_speed
            end
        end
    elseif love.keyboard.isDown('a', 'left') then
        if self.x_vel > self.max_speed * -1 then
            if self.x_vel - self.acceleration * dt > self.max_speed * -1 then
            self.x_vel = self.x_vel - self.acceleration * dt
            else
                self.x_vel = self.max_speed * -1
            end
        end
    else 
        player:applyFriction(dt) -- else applyFriction() if no key pressed
    end
end

function player:applyFriction(dt) -- code to stop player movement when keys are not pressed
    if self.x_vel > 0 then -- if right velocity > 0, keep gradually reducing velocity to 0
        if self.x_vel - self.friction * dt > 0 then
            self.x_vel = self.x_vel - self.friction * dt
        else
            self.x_vel = 0
        end
    elseif self.x_vel < 0 then
        if self.x_vel + self.friction * dt < 0 then -- if left velocity is < 0, keep gradually reducing velocity to 0
            self.x_vel = self.x_vel + self.friction * dt
        else
            self.x_vel = 0
        end
    end
end

function player:syncPhysics()
    self.x, self.y = self.physics.body:getPosition() -- syncs the physical body's position to the player's x and y coord position
    self.physics.body:setLinearVelocity(self.x_vel, self.y_vel) 
    -- the line above makes the physical body actually move. it uses our player's velocity variables; i.e. this will affect the body's movement based on user keyboard input, collisions, etc
end

-- beginContact() and endContact() handle fixture collisions that the player is apart of
function player:beginContact(a, b, collision)
    -- collision:getNormal() returns a normal vector from the collision(Contact) object
    -- A normal vector is a unit vector perpendicular to a given object at a particular point.
    -- when two fixtures collide, the callback fn beginContact() is called and passed a, b, and collision, where a, b are the colliding fixtures and collision is a Contact object containing information on the collision
    -- the normal vector indicates how fixture A contacted fixture B
    -- fixtures A and B collide:
        -- if A -> B (A collides with B from the left), then normal vector returned = (1,0); A contacted B from the left
        -- if B <- A, then normal vector = (-1,0); A contacted B from the right
        -- if A collides with B from above (A falls onto B) then normal vector = (0,1); A contacted B from above
        -- if A collides with B from below (B collides into A from below) then normal vector = (0,-1); B contacted A from below
        -- whether a fixture is determined to be fixture A or B can seem random, so we check in the code below to see which one of A,B is the player fixture
        -- the two if-statements do the same thing; it is just checking if the player is landing on a fixture from above; if so, set self.y_vel = 0 and set self.grounded = true to stop the constant falling of the fixture
    
    if self.grounded then return end -- if player already grounded, skip code below
    local nx, ny = collision:getNormal()
    if a == self.physics.fixture then -- if the player is the 'A' fixture
        if ny > 0 then -- A (player) collided with B (ground)
            self:land(collision) -- passing collision object to player.land 
        elseif ny < 0 then
            self.y_vel = 0 -- makes player fall quickly when bumping head; conflicts with current jump_hold logic
        end
    elseif b == self.physics.fixture then
        if ny < 0 then -- B (player) collided with A (ground)
            self:land(collision)
        elseif ny > 0 then
            self.y_vel = 0
        end
    end
end

function player:land(collision)
    self.current_ground_collision = collision -- when player lands on another fixture, assign the current collision(Contact) object to a player attribute; this contains information about the colliding objects
    self.y_vel = 0 -- player is no longer falling; fixes issue where player couldn't move because of constant increasing of y_vel
    self.jump_count = 0 -- reset jump count upon landing
    self.grounded = true -- player landed on a fixture, so player is grounded
end

function player:jump(key)
    if key == 'w' or key == 'up' then
        if self.jump_count < self.max_jumps then
            self.y_vel = self.jump_amount

            -- optional: make second jump slightly weaker
            if self.jump_count == 1 then
                self.y_vel = self.y_vel * 0.15
            end

            self.grounded = false
            self.jump_count = self.jump_count + 1

            -- start tracking jump hold
            self.jump_hold = true
            self.jump_timer = 0
        end
    end
end


function player:endContact(a, b, collision) -- runs when the player is no longer contacting another fixture
    -- self.grounded = false -- only having this line is wrong because this is setting the players grounded boolean to false no matter what fixtures have stopped colliding; this would introduce bugs as we progress
    if a == self.physics.fixture or b == self.physics.fixture then -- checks to see if the player is one of the fixture that activated endContact() callback fn
        if self.current_ground_collision == collision then -- if collision objects match, the player has stopped colliding with a fixture directly below it. thus we need to make the player not grounded and applyGravity()
            self.grounded = false
        end
    end

end

function player:draw()
    -- love.graphics.rectangle('fill', self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)

    scale_x = 1
    if self.direction == 'left' then
        scale_x = -1 -- flips quad/frame
    end
    --love.graphics.draw(mario, self.animations.current_quad, self.x, self.y, 0, scale_x, 1, self.small_mario_quads.frame_width / 2, self.small_mario_quads.frame_height / 2) 
    love.graphics.draw(mario, self.animations.current_quad, self.x, self.y, 0, scale_x, 1, self.quad_width / 2, self.quad_height / 2)
end