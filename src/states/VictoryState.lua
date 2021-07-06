

--[[
    GD50
    Breakout Remake
    -- StartState Class --
    Author: Colton Ogden
    cogden@cs50.harvard.edu
    Represents the state that the game is in when we've just completed a level.
    Very similar to the ServeState, except here we increment the level 
]]

VictoryState = Class{__includes = BaseState}

function VictoryState:enter(params)
	self.score = params.score
	self.level = params.level
	self.health = params.health
	self.paddle = params.paddle
	self.highScores = params.highScores
	self.paddleScore = params.paddleScore or 0

end

function VictoryState:update(dt)
	self.paddle:update(dt)

	--next state is serve state with 1 + level
	if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
		gStateMachine:change('serve', {
			level = self.level + 1,
            bricks = LevelMaker.createMap(self.level + 1),
            paddle = self.paddle,
            health = self.health,
            score = self.score,
            highScores = self.highScores,
            paddleScore = self.paddleScore
		})
	end
end

function VictoryState:render()
	self.paddle:render()

	renderHealth(self.health)
	renderScore(self.score)

	--level complete text
	love.graphics.setFont(gFonts['large'])
    love.graphics.printf("Level " .. tostring(self.level) .. " complete!",
        0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')

    -- instructions text
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter to serve!', 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH, 'center')
end