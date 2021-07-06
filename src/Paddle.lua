--[[
    GD50
    Breakout Remake
    -- Paddle Class --
    Author: Colton Ogden
    cogden@cs50.harvard.edu
    Represents a paddle that can move left and right. Used in the main
    program to deflect the ball toward the bricks; if the ball passes
    the paddle, the player loses one heart. The Paddle can have a skin,
    which the player gets to choose upon starting the game.
]]
Paddle = Class{}

function Paddle:init(skin)

	self.x = VIRTUAL_WIDTH / 2 - 32
	self.y = VIRTUAL_HEIGHT - 32

	self.size = 2

	self.width = PADDLE_S_SIZE * self.size
	self.height = 16

	self.dx = 0

	self.skin = skin
end

function Paddle:update(dt)
	if love.keyboard.isDown('left') then
		self.dx = -PADDLE_SPEED
	elseif love.keyboard.isDown('right') then
		self.dx = PADDLE_SPEED
	else
		self.dx = 0
	end

	if self.dx < 0 then
		self.x = math.max(0, self.x + self.dx * dt)
	else
		self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
	end
end

function Paddle:render()
	love.graphics.draw(gTextures['main'], gFrames['paddles'][self.size + 4 * (self.skin - 1)], self.x, self.y)
end

--function to decrease the size once the health drops
function Paddle:decreaseSize()
	self.size = math.max(1, self.size - 1)
	--resetting the width everytime the size is changed
	self.width = PADDLE_S_SIZE * self.size
end

-- function to increase the size once the score crosses a certain amount
function Paddle:increaseSize()
	self.size = math.min(4, self.size + 1)
	--resetting the width everytime the size is changed
	self.width = PADDLE_S_SIZE * self.size
end
