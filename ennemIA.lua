local ESTATE = {}
ESTATE.NONE = ""
ESTATE.POURSUIT = "poursuit"
ESTATE.ATTACK = "attack"
ESTATE.TIRE = "tire"
ESTATE.DEAD = "dead"

local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()

function ESTATE.UpdateEnnemi(pEnnemi, pEntities, pProjo, ball, dt)
    if pEnnemi.state == ESTATE.NONE then
        pEnnemi.state = ESTATE.POURSUIT

    -- POURSUITE --
    elseif pEnnemi.state == ESTATE.POURSUIT then
        local shootTime = 3 -- Attends 3 secondes avant de tirer
        -- On récup le player
        for i, sprite in ipairs(pEntities) do
            if sprite.type == "player" then
                -- Tourne toi verds le player donc le x de la target ==> pEnnemi.target.x = ton angle ?

                local angleToMe = math.angle(pEnnemi.x, pEnnemi.y, sprite.x, sprite.y)
                pEnnemi.angle = angleToMe
                pEnnemi.target = sprite

            end
        end

        -- Avance en fonction de ton nouvel angle
        pEnnemi.vx = pEnnemi.speed * 60 * math.cos(pEnnemi.angle)
        pEnnemi.vy = pEnnemi.speed * 60 * math.sin(pEnnemi.angle)

        -- Def des frontières
        if pEnnemi.x < 0 then
            pEnnemi.x = 0
        end
        if pEnnemi.x > screenWidth then
            pEnnemi.x = screenWidth
        end

        if pEnnemi.y < 0 then
            pEnnemi.y = 0
        end

        if pEnnemi.y > screenHeight then
            pEnnemi.y = screenHeight
        end

        -- A porté d'attaque ?
        local distance = math.dist(pEnnemi.x, pEnnemi.y, pEnnemi.target.x, pEnnemi.target.y)
        if distance < 5 then -- and pEnnemi.target.type == "player" ==> target est pas définit, il faut le definir
            pEnnemi.state = ESTATE.ATTACK
            pEnnemi.vx = 0
            pEnnemi.vy = 0
        else
            --Attend un peu et tire
            pEnnemi.waitForShoot = pEnnemi.waitForShoot + dt
            if pEnnemi.waitForShoot >= shootTime then
                pEnnemi.state = ESTATE.TIRE
                pEnnemi.vx = 0
                pEnnemi.vy = 0
            end
        end

        local distanceBall = math.dist(pEnnemi.x,pEnnemi.y, ball.x,ball.y)
        if distanceBall < pEnnemi.width then
            local angleOfImpact = math.angle(pEnnemi.x,pEnnemi.y, ball.x,ball.y)
            -- Inversion de la direction de la composante x de la vitesse de la balle
            local speedMagnitude = math.sqrt(ball.speed_x^2 + ball.speed_y^2)

            local newSpeedX = speedMagnitude * math.cos(angleOfImpact)
            local newSpeedY = speedMagnitude * math.sin(angleOfImpact)

            ball.speed_x = newSpeedX
            ball.speed_y = newSpeedY
            pEnnemi.state = ESTATE.DEAD
        end

    -- ATTACK --
    elseif pEnnemi.state == ESTATE.ATTACK then
        if math.dist(pEnnemi.x, pEnnemi.y, pEnnemi.target.x, pEnnemi.target.y) > 5 then
            pEnnemi.state = ESTATE.POURSUIT
        else
            if pEnnemi.target.life ~= 0 then
                pEnnemi.target.Hurt(pEnnemi.hurtDammage)
            end
        end

    -- TIRE --
    elseif pEnnemi.state == ESTATE.TIRE then
        local stopForShoot = 1 -- Il s'arrete avant de commencer à tirer
        pEnnemi.vx = 0
        pEnnemi.vy = 0
        for i, sprite in ipairs(pEntities) do
            if sprite.type == "player" then
                -- Tourne toi verds le player donc le x de la target ==> pEnnemi.target.x = ton angle ?

                local angleToMe = math.angle(pEnnemi.x, pEnnemi.y, sprite.x, sprite.y)
                pEnnemi.angle = angleToMe
            end
        end
        pEnnemi.chronoReload = pEnnemi.chronoReload + dt

        if pEnnemi.chronoReload >= stopForShoot then
            -- On attend un peu et on tire
            pProjo.Tire(pEnnemi.x, pEnnemi.y, pEnnemi.angle, pEnnemi.bulletSpeed, pEnnemi.type)
            pEnnemi.waitForShoot = 0
            pEnnemi.state = ESTATE.POURSUIT
            pEnnemi.chronoReload = 0
        end

    -- MORT --
    elseif pEnnemi.state == ESTATE.DEAD then
        pEnnemi.vx = 0
        pEnnemi.vy = 0
    end
end

return ESTATE