--[[
    GD50
    Breakout Remake
    -- StartState Class --
    Author: Colton Ogden
    cogden@cs50.harvard.edu
    Represents the state the game is in when we've just started; should
    simply display "Breakout" in large text, as well as a message to press
    Enter to begin.
]]

-- the "__includes" bit here means we're going to inherit all of the methods
-- that BaseState has, so it will have empty versions of all StateMachine methods
-- even if we don't override them ourselves; handy to avoid superfluous code!
StartState = Class{__includes = BaseState}

local highlighted = 1

function StartState:enter(params)
	self.highScores = params.highScores
end

function StartState:update(dt)
	if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
		highlighted = highlighted == 1 and 2 or 1
		gSounds['paddle-hit']:play()
	end

	if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then

		gSounds['confirm']:play()
		if highlighted == 1 then
			gStateMachine:change('paddle-select', {
				highScores = self.highScores
			})
		else
			gStateMachine:change('high-scores', {
				highScores = self.highScores
			})
		end
	end

	if love.keyboard.wasPressed('escape') then
		love.event.quit()
	end
end

function StartState:render()

	love.graphics.setFont(gFonts['large'])
	love.graphics.printf("BREAKOUT", 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')

	love.graphics.setFont(gFonts['medium'])

	--if first option is highlighted, then it is rendered blue
	if highlighted == 1 then
		love.graphics.setColor(0, 0, 0, 255)
	end

	love.graphics.printf("START", 0, VIRTUAL_HEIGHT / 2 + 70, VIRTUAL_WIDTH, 'center')

	-- resetting the color
	love.graphics.setColor(255, 255, 255, 255)

	--if second option is highlighted, then it is rendered blue
		if highlighted == 2 then
			love.graphics.setColor(0, 0, 0, 255)
		end

		love.graphics.printf("HIGHSCORES", 0, VIRTUAL_HEIGHT / 2 + 90, VIRTUAL_WIDTH, 'center')

		--resetting the color
		love.graphics.setColor(255, 255, 255, 255)
end