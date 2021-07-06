--[[
    GD50
    Breakout Remake
    -- PlayState Class --
    Author: Colton Ogden
    cogden@cs50.harvard.edu
    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]
PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    --instead of a single ball, now a table containing all the balls is checked for, be it 3 or be it 1
    self.balls = params.balls
    self.level = params.level

    --boolean to check if the key powerup was obtained or not
    self.hasKey = false
    --key powerup is only shown if the locked brick is there in the play state, else it is redundant
    self.containsLockedBrick = false
    self.lockedBrickIndex = -1

    -- give ball random starting velocity
    for k, ball in pairs(self.balls) do
        ball.dx = math.random(-200, 200)
        ball.dy = math.random(-50, -60)
    end
    --variable to keep in check the increase in score
    -- as soon as it crosses the score constant, paddle size increases
    self.paddleScore = params.paddleScore or 0

    --powerup objects are created
    self.ballPowerup = Powerup(1)
    self.keyPowerup = Powerup(2)
end

function PlayState:update(dt)

    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    --loop to check if the current state contains a locked brick or not
    for k, brick in pairs(self.bricks) do
        if brick.isLockedBrick then
            self.containsLockedBrick = true
            self.lockedBrickIndex = k
        end
    end

    --if ball powerup is obtained, then 2 other balls generate
    if self.ballPowerup:collides(self.paddle) == 1 and self.ballPowerup.inPlay then
        self.ballPowerup.inPlay = false
        self.ball2 = Ball()
        self.ball3 = Ball()
        self.ball2:setValues(self.balls[1])
        self.ball3:setValues(self.balls[1])
        self.balls[2] = self.ball2
        self.balls[3] = self.ball3
    end

    -- if key powerup is obtained, then the hasKey boolean is set to true
    if self.keyPowerup:collides(self.paddle) == 2 and self.keyPowerup.inPlay then
        self.keyPowerup.inPlay = false
        self.hasKey = true
    end


    self.paddle:update(dt)
    for k, ball in pairs(self.balls) do
        ball:update(dt)
    end

    self.ballPowerup:update(dt)
    if self.containsLockedBrick then
        if not self.bricks[self.lockedBrickIndex].hasKey then
            self.keyPowerup:update(dt)
        end
    end

    for k, ball in pairs(self.balls) do
        if ball:collides(self.paddle) then
            ball.dy = -ball.dy
            ball.y = self.paddle.y - 8


            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                
                ball.dx = -50 -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))

            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            
            end

            gSounds['paddle-hit']:play()
        end
    end

    for k, brick in pairs(self.bricks) do

        for k, ball in pairs(self.balls) do
            --only check colision if we're in play
            if brick.inPlay and ball:collides(brick) then

                brick:hit()


                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        score = self.score,
                        balls = self.balls,
                        level = self.level,
                        health = self.health,
                        paddle = self.paddle,
                        highScores = self.highScores,
                        paddleScore = self.paddleScore
                    })
                end

                --add score
                self.score = self.score + (brick.tier * 100 + brick.color * 25)
                self.paddleScore = self.paddleScore + (brick.tier * 100 + brick.color * 25)

                --checking if we need to increase paddle size
                if self.paddleScore >= SCORE_CONSTANT then
                    self.paddleScore = 0
                    self.paddle:increaseSize()

                end

                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    ball.x = brick.x - 8
                    ball.dx = -ball.dx
                
                --right edge, only if we're moving left
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    ball.x = brick.x + 32
                    ball.dx = -ball.dx

                elseif ball.y < brick.y then
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                else
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end
                ball.dy = ball.dy * 1.02
                break

            end
        end
    end
    for k, ball in pairs(self.balls) do
        if ball.y >= VIRTUAL_HEIGHT then
            table.remove(self.balls, k)
        end
    end

    -- instead of checking for just one ball, we check if every ball in the balls table is gone
    if #self.balls == 0 then
        self.health = self.health - 1
        self.paddle:decreaseSize()
        gSounds['hurt']:play()

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                level = self.level,
                highScores = self.highScores,
                paddleScore = self.paddleScore
            })
        end
    end

    for k, brick in pairs(self.bricks) do
        brick:update(dt, self.hasKey)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

end

function PlayState:render()

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    for k, ball in pairs(self.balls) do
        ball:render()
    end
    self.ballPowerup:render()

    if self.containsLockedBrick then
        if not self.bricks[self.lockedBrickIndex].hasKey then
            self.keyPowerup:render()
        end
    end

    renderScore(self.score)
    renderHealth(self.health)

    if  self.paused then
        love.graphics.draw(gTextures['pause'], VIRTUAL_WIDTH / 2 - 150, VIRTUAL_HEIGHT / 2 - 150, 0, 0.6, 0.6)
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end
    return true
end