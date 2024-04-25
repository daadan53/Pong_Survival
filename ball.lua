require("utility")

local ball = {}

ball.x = 20
ball.y = 20
ball.speed_x = 300
ball.speed_y = 300
ball.width = 20
ball.height = 20
ball.angle = 0
ball.addSpeed = 10
ball.speedMagnitude = 0

ball.timeGame = 0
local dizaine = 0 -- Var qui stock toutes les dizaines

function ball.CenterBall()
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
    
    ball.x = screenWidth / 2 - ball.width / 2
    ball.y = screenHeight / 2 - ball.height / 2
end

function ball.Speed(speed_x, speed_y, addSpeed)
    if math.sign(speed_x) == 1 then
        speed_x = speed_x + addSpeed
    elseif math.sign(speed_x) == -1 then
        speed_x = speed_x - addSpeed
    end

    if math.sign(speed_y) == 1 then
        speed_y = speed_y + addSpeed
    elseif math.sign(speed_y) == -1 then
        speed_y = speed_y - addSpeed
    end

    return speed_x, speed_y
end

function ball.Update(dt)

    ball.timeGame = ball.timeGame + dt
    if math.floor(ball.timeGame) % 10 == 0 and dizaine ~= math.floor(ball.timeGame) then
        dizaine = math.floor(ball.timeGame) --On save dizaine pour pouvoir le verif
        ball.speed_x, ball.speed_y = ball.Speed(ball.speed_x, ball.speed_y, ball.addSpeed) -- On ajoute la vitesse toutes les 10 secondes
    end

    ball.x = ball.x + ball.speed_x * dt
    ball.y = ball.y + ball.speed_y * dt

    -- On calcul la vitesse de la balle
    local speedMagnitude = math.sqrt(ball.speed_x ^ 2 + ball.speed_y ^ 2)
    -- Angle en radian par rapport au vecteur horiontale
    local angleInRadians = math.atan2(ball.speed_y, ball.speed_x)
    --print(angleInRadians)

    ball.speedMagnitude = speedMagnitude

    -- Mur gauche
    if ball.x + ball.width <= 0 then
        -- Mur droit
        ball.CenterBall()
        ball.timeGame = ball.timeGame - 10
    elseif ball.x >= screenWidth - ball.width / 2 then
        ball.CenterBall()
        ball.timeGame = ball.timeGame - 10
    -- Mur haut et bas
    elseif ball.y <= 0 or ball.y >= screenHeight - ball.height then
        -- Inverser la composante y de la vitesse pour rebondir
        angleInRadians = -angleInRadians

        ball.speed_x = speedMagnitude * math.cos(angleInRadians)
        ball.speed_y = speedMagnitude * math.sin(angleInRadians)

        if ball.y - ball.height <= 0 then
            ball.y = 0
        else
            ball.y = screenHeight - ball.height
        end
    end

end

function ball.Draw()
    love.graphics.circle("fill", ball.x, ball.y, ball.width, ball.height)

    -- TIMER --
    love.graphics.print("Temps de survie : " .. math.floor(ball.timeGame), screenWidth / 2 - 100, 10)
end

return ball
