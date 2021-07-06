--[[
    GD50
    Breakout Remake
    -- Ball Class --
    Author: Colton Ogden
    cogden@cs50.harvard.edu
    Represents a ball which will bounce back and forth between the sides
    of the world space, the player's paddle, and the bricks laid out above
    the paddle. The ball can have a skin, which is chosen at random, just
    for visual variety.
]]

Ball = Class{}

function Ball:init(skin)
	self.width = 8
	self.height = 8

	self.dx = 0
	self.dy = 0

	self.skin = skin
end

function Ball:collides(target)

	if self.x > target.x + target.width or target.x > self.x + self.width then
		return false
	end

	if self.y > target.y + target.height or target.y > self.y + self.height then
		return false
	end
	return true
end

function Ball:reset()
	self.x = VIRTUAL_WIDTH / 2 - 2
	self.y = VIRTUAL_HEIGHT / 2 - 2

	self.dx = 0
	self.dy = 0
end

function Ball:setValues(ball)
	self.x = ball.x
	self.y = ball.y
	self.dx = ball.dx
	self.dy = ball.dy
	self.skin = ball.skin
end

function Ball:update(dt)

	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt

	if self.x <= 0 then
		self.x = 0
		self.dx = -self.dx
		gSounds['wall-hit']:play()
	end

	if self.x >= VIRTUAL_WIDTH - 8 then
		self.x = VIRTUAL_WIDTH - 8
		self.dx = -self.dx
		gSounds['wall-hit']:play()
	end

	if self.y <= 0 then
		self.y = 0
		self.dy = -self.dy
		gSounds['wall-hit']:play()
	end
end

function Ball:render()
	love.graphics.draw(gTextures['main'], gFrames['balls'][self.skin], self.x, self.y)
end
