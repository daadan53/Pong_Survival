require("utility")

local ball = require("ball")

local timeGame = 0
local dizaine = 0

local pads = {}
    pads.pad_1 = {}
    pads.pad_1.x = 1
    pads.pad_1.y = 1
    pads.pad_1.speed = 300
    pads.pad_1.width = 20
    pads.pad_1.height = 80
    pads.pad_1.addSpeed = 20


    pads.pad_2 = {}
    pads.pad_2.x = 300
    pads.pad_2.y = 400
    pads.pad_2.speed = 300
    pads.pad_2.width = 20
    pads.pad_2.height = 80
    pads.pad_2.addSpeed = 20


function pads.Load()

    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    pads.pad_2.x = screenWidth - pads.pad_2.width
    pads.pad_2.y = screenHeight - pads.pad_2.height


end


function pads.Update(dt)

     -- Timer Vitesse pad --

    timeGame = timeGame + dt
    if math.floor(timeGame) % 10 == 0 and dizaine ~= math.floor(timeGame) then
        dizaine = math.floor(timeGame) --On save dizaine pour pouvoir le verif
        pads.pad_1.speed = pads.pad_1.speed + pads.pad_1.addSpeed
        pads.pad_2.speed = pads.pad_2.speed + pads.pad_2.addSpeed
    end

    pads.pad_1.y = pads.pad_1.y + pads.pad_1.speed * dt * math.sign(ball.y - pads.pad_1.y - pads.pad_1.height / 2)
    pads.pad_2.y = pads.pad_2.y + pads.pad_2.speed * dt * math.sign(ball.y - pads.pad_2.y - pads.pad_2.height / 2)

    -- Raquette gauche
    if ball.x - ball.width / 2 <= pads.pad_1.x + pads.pad_1.width then
        if ball.y + ball.height > pads.pad_1.y and ball.y < pads.pad_1.y + pads.pad_1.height then
            ball.speed_x = math.abs(ball.speed_x)
        end
    end

    if ball.x + ball.width / 2 >= pads.pad_2.x then
        -- La balle est SUR la raquette droite ?
        if ball.y - ball.height < pads.pad_2.y + pads.pad_2.height and ball.y + ball.width > pads.pad_2.y then
            ball.speed_x = -math.abs(ball.speed_x)
        end
    end

end

function pads.Draw()

    love.graphics.rectangle("fill", pads.pad_1.x, pads.pad_1.y, pads.pad_1.width, pads.pad_1.height)
    love.graphics.rectangle("fill", pads.pad_2.x, pads.pad_2.y, pads.pad_2.width, pads.pad_2.height)

end

return pads