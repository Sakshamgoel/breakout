
--[[
	The Powerup class which generates the key and ball Powerup
	-Author: Saksham Goel
	szg0112@auburn.edu
	
	has 2 powerups:
		key powerup - enables to break the locked brick
		ball powerup - makes 2 copies of existing ball
	]]

Powerup = Class{}

function Powerup:init(skin)

	-- generated in the top middle of the screen randomly
	self.x = math.random(10, VIRTUAL_WIDTH - 20)
	self.y = 1
	self.height = 16
	self.width = 16

	-- once the paddle touches the powerup or if it goes below the screen, it is stopped from rendering
	self.inPlay = false

	-- once the paddle touches it, it is stopped from updatingq
	self.taken = false

	-- skin 1 is ball powerup, skin2 is key powerup
	self.skin = skin

	-- time after which the powerup is generated
	self.timer = math.random(10, 15)

	-- garbage timer to keep track how much time has passed
	self.garbageTimer = 0
end


function Powerup:update(dt)
	if not self.taken then
		self.garbageTimer = self.garbageTimer + dt
		if self.garbageTimer >= self.timer then
			self.garbageTimer = 0
			self.timer = math.random(10, 15)
			self.inPlay = true
		end
	end

	-- slowly going down towards the bottom of the screen
	if self.inPlay then
		self.y = self.y + POWERUP_SPEED * dt
	end

	-- if the player is unable to catch it, it will be generated again
	if self.y >= VIRTUAL_HEIGHT then
		self.inPlay = false
		self.y = 1
	end

end

-- instead of returning a boolean, the collides method of this class returns an integer to let the playstate know
-- which powerup has collided
function Powerup:collides(target)

	if self.x > target.x + target.width or target.x > self.x + self.width then
		return -1
	end

	if self.y > target.y + target.height or target.y > self.y + self.height then
		return -1
	end
	self.taken = true
	return self.skin
end

function Powerup:render()
	if self.inPlay then
		love.graphics.draw(gTextures['main'], gFrames['powerups'][self.skin], self.x, self.y)
	end
end