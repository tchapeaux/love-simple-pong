function love.load()
    require "variables"

    player = {}
    player.Y = HEIGHT / 2
    player.score = 0
    opponent = {}
    opponent.Y = HEIGHT / 2
    opponent.score = 0

    ball = {}
    ball.X = WIDTH / 2
    ball.Y = HEIGHT / 2
    ball.speedX = BALL_SPEED/math.sqrt(2)
    ball.speedY = BALL_SPEED/math.sqrt(2)
    ball.timer = BALL_TIMER
    ball.timerFactor = function(ball)
        return (BALL_TIMER - ball.timer) / BALL_TIMER
    end

    -- (unused)
    particleSystems = {}
end

function love.draw()
    love.graphics.setFont(scoreFont)
    love.graphics.setColor(255, 255, 255)

    for i, part in ipairs(particleSystems) do
        part:draw()
    end

    love.graphics.setLineWidth(2)
    love.graphics.line(
        WIDTH / 2,
        10,
        WIDTH / 2,
        HEIGHT - 10)

    -- player
    love.graphics.setColor(255, 128, 0)
    love.graphics.rectangle(
        "fill",
        PLAYER_X,
        player.Y - PLAYER_HEIGHT / 2,
        PLAYER_WIDTH,
        PLAYER_HEIGHT)

    -- opponent
    love.graphics.setColor(127, 0, 255)
    love.graphics.rectangle(
        "fill",
        WIDTH - PLAYER_X,
        opponent.Y - PLAYER_HEIGHT / 2,
        - PLAYER_WIDTH, PLAYER_HEIGHT)

    love.graphics.setColor(255, 255, 255)
    love.graphics.printf(player.score, 10, 10, WIDTH / 2, "center")
    love.graphics.printf(opponent.score, WIDTH / 2, 10, WIDTH / 2, "center")

    -- ball
    alpha = ball:timerFactor()
    love.graphics.setColor(255, 255, 255, 255 * alpha)
    love.graphics.rectangle("fill", ball.X - BALL_RAD, ball.Y - BALL_RAD, 2 * BALL_RAD, 2 * BALL_RAD)
    -- love.graphics.arc(
    --     "fill",
    --     ball.X,
    --     ball.Y,
    --     BALL_RAD,
    --     0,
    --     2 * math.pi * ball:timerFactor()
    --     )
end

function love.update(dt)
    if PAUSE then
        return
    end

    for i, part in ipairs(particleSystems) do
        part:update(dt)
    end

    -- Player
    -- keyboards control:
    -- if love.keyboard.isDown("down") then
    --     player.Y = player.Y + PLAYER_SPEED * dt
    -- elseif love.keyboard.isDown("up") then
    --     player.Y = player.Y - PLAYER_SPEED * dt
    -- end
    -- mouse controls
    oldMX, oldMY = mx, my
    mx, my = love.mouse.getPosition()
    player.Y = my
    player.Y = math.min(player.Y, HEIGHT - PLAYER_HEIGHT / 2 - 10)
    player.Y = math.max(player.Y, PLAYER_HEIGHT / 2 + 10)

    -- Opponent
    -- most basic AI ever: follow the ball
    if ball.speedY < 0 and ball.Y < opponent.Y then
        opponent.Y = opponent.Y - PLAYER_SPEED * dt
    end
    if ball.speedY > 0 and ball.Y > opponent.Y then
        opponent.Y = opponent.Y + PLAYER_SPEED * dt
    end
    opponent.Y = math.min(opponent.Y, HEIGHT - PLAYER_HEIGHT / 2 - 10)
    opponent.Y = math.max(opponent.Y, PLAYER_HEIGHT / 2 + 10)

    -- Ball
    if ball.timer > 0 then
        ball.timer = ball.timer - dt
        ball.timer = math.max(0, ball.timer)
    else
        ball.X = ball.X + ball.speedX * dt
        ball.Y = ball.Y + ball.speedY * dt
    end

    -- Ball collision with player
    if ball.speedX < 0
        and ball.X - BALL_RAD <= PLAYER_X + PLAYER_WIDTH
        and math.abs(ball.Y - player.Y) < PLAYER_HEIGHT
        then
        ball.speedX = -1 * ball.speedX
        ball.speedY = ball.speedY + (my - oldMY) / dt
    end

    -- Ball collision with opponent
    if ball.speedX > 0
        and ball.X + BALL_RAD >= WIDTH - PLAYER_X - PLAYER_WIDTH
        and math.abs(ball.Y - opponent.Y) < PLAYER_HEIGHT
        then
        ball.speedX = -1 * ball.speedX
    end

    -- Ball collision with walls
    if ball.speedY < 0 and ball.Y - BALL_RAD < 0 then
        ball.speedY = -1 * ball.speedY
    elseif ball.speedY > 0 and ball.Y + BALL_RAD > HEIGHT then
        ball.speedY = -1 * ball.speedY
    end

    -- Scoring
    if ball.X - BALL_RAD < 0 then
        opponent.score = opponent.score + 1
        reset_ball(ball)
    end
    if ball.X + BALL_RAD > WIDTH then
        player.score = player.score + 1
        reset_ball(ball)
    end
end

function love.keyreleased(k)
    if k == "p" then
        PAUSE = not PAUSE
    elseif k == "escape" then
        love.event.quit()
    end
end

function reset_ball(ball)
    ball.X = WIDTH / 2
    ball.Y = HEIGHT / 2
    ball.timer = BALL_TIMER
    ball.speedX = - 1 * ball.speedX
    ball.speedY = BALL_SPEED / math.sqrt(2)
end
