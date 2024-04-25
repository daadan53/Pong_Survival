local BSTATE = {}
BSTATE.NONE = ""
BSTATE.POURSUIT = "poursuit"
BSTATE.BOOM = "boom"
BSTATE.TIRE = "tire"
BSTATE.RETURNBALL = "return ball"
BSTATE.EAT = "eat"

local sceneManager = require("sceneManager")

function BSTATE.UpdateBoss(pBoss, pEntities, pProjo, ESTATE, ball, dt)

    -- NONE --
    if pBoss.state == BSTATE.NONE then
        pBoss.state = BSTATE.POURSUIT

    -- POURSUIT --
    elseif pBoss.state == BSTATE.POURSUIT then
        local minDist = 99999
        -- On récup le player
        for i, sprite in ipairs(pEntities) do

            if pBoss.life > 1 or pBoss.life > 0 and pBoss.targetEat == nil then
                if sprite.type == "player" then
                    -- Tourne toi vers le player
                    local angleToMe = math.angle(pBoss.x, pBoss.y, sprite.x, sprite.y)
                    pBoss.angle = angleToMe
                    pBoss.target = sprite

                    local distance = math.dist(pBoss.x,pBoss.y, sprite.x,sprite.y)
                    
                    if distance < pBoss.boomRange then 
                        pBoss.state = BSTATE.BOOM
                    end
                end
                

            elseif pBoss.life == 1 and pBoss.targetEat ~= nil then
                if sprite.type == "ennemi" then
                    local distance = math.dist(pBoss.x,pBoss.y,sprite.x, sprite.y)

                    --Boucle qui recherche continuellement le plus proche
                    if distance < minDist and sprite.state == ESTATE.DEAD then
                        minDist = distance --Min distance contient l'énnemi le plus proche
                        --print(minDist)
                        pBoss.targetEat = sprite
                    end

                end
               pBoss.state = BSTATE.EAT
            end
        end

        -- Suppr le boss une fois mort
        if pBoss.life <= 0 then 
            for i = #pEntities, 1, -1 do
                if pEntities[i] == pBoss then
                    table.remove(pEntities, i)
                    break
                end
            end
        end

        -- Si je suis sur un ennemi mort
        if pBoss.targetEat ~= nil and minDist < pBoss.eatRange then
            pBoss.state = BSTATE.EAT
        end
        
        pBoss.vx = pBoss.speed * 60 * math.cos(pBoss.angle)
        pBoss.vy = pBoss.speed * 60 * math.sin(pBoss.angle)


        --Attend un peu et tire
        local shootTimeBoss = 5
        pBoss.waitForShoot = pBoss.waitForShoot + dt
        if pBoss.waitForShoot >= shootTimeBoss then
            pBoss.state = BSTATE.TIRE
            pBoss.vx = 0
            pBoss.vy = 0
        end

        -- Si la balle est proche 
        local distanceBall = math.dist(pBoss.x,pBoss.y, ball.x,ball.y)
        if distanceBall < pBoss.width then
            pBoss.vx = 0
            pBoss.vy = 0
            pBoss.state = BSTATE.RETURNBALL
        end
        

    -- EAT --
    elseif pBoss.state == BSTATE.EAT then
        local distanceToEnnemi = math.dist(pBoss.x, pBoss.y, pBoss.targetEat.x, pBoss.targetEat.y)
       
        if pBoss.life == 1 then
            -- on redef l'angle 
            local angleToEnnemi = math.angle(pBoss.x, pBoss.y, pBoss.targetEat.x, pBoss.targetEat.y)
            pBoss.angle = angleToEnnemi

            pBoss.vx = pBoss.speed * 60 * math.cos(pBoss.angle)
            pBoss.vy = pBoss.speed * 60 * math.sin(pBoss.angle)
        end

        if distanceToEnnemi < pBoss.eatRange then
            for i = #pEntities, 1, -1 do
                local spriteRemove = pEntities[i]
                if spriteRemove == pBoss.targetEat then
                    table.remove(pEntities, i)
                    pBoss.life = pBoss.life + 1
                    pBoss.speed = pBoss.speed + 0.5
                    print("je mange")
                    break
                end
            end
        
            pBoss.targetEat = nil 
            pBoss.state = BSTATE.POURSUIT
        end

        local distance = math.dist(pBoss.x,pBoss.y, pBoss.target.x,pBoss.target.y)
        if distance < pBoss.boomRange then 
            pBoss.state = BSTATE.BOOM
        end

    -- BOOM --
    elseif pBoss.state == BSTATE.BOOM then
        local distance = math.dist(pBoss.x,pBoss.y, pBoss.target.x,pBoss.target.y)
       
        pProjo.Tire(pBoss.x, pBoss.y, pBoss.angle, 0, "boom")

        if distance < pBoss.boomRange then 
            pBoss.life = 0
            pBoss.target.life = 0
            pBoss.state = BSTATE.POURSUIT

        else
            pBoss.life = 0
            pBoss.state = BSTATE.POURSUIT
        end

    -- TIRE --
    elseif pBoss.state == BSTATE.TIRE then
        local stopForShoot = 1 -- Il s'arrete avant de commencer à tirer
        pBoss.vx = 0
        pBoss.vy = 0

        local angleToMe = math.angle(pBoss.x, pBoss.y, pBoss.target.x, pBoss.target.y)
        pBoss.angle = angleToMe

        pBoss.chronoReload = pBoss.chronoReload + dt

        if pBoss.chronoReload >= stopForShoot then
            -- On attend un peu et on tire
            pProjo.Tire(pBoss.x, pBoss.y, pBoss.angle, pBoss.bulletSpeed, pBoss.type)
            pBoss.waitForShoot = 0
            pBoss.state = BSTATE.POURSUIT
            pBoss.chronoReload = 0
        end

    -- RETURN BALL --
    elseif pBoss.state == BSTATE.RETURNBALL then
        pBoss.vx = 0
        pBoss.vy = 0

        -- Renvoie un angle entre deux point (boss, ball)
        local angleOfImpact = math.angle(pBoss.x,pBoss.y, ball.x,ball.y)
        -- Inversion de la direction de la composante x de la vitesse de la balle
        local speedMagnitude = math.sqrt(ball.speed_x^2 + ball.speed_y^2)

        ball.speed_x = speedMagnitude * math.cos(angleOfImpact)
        ball.speed_y = speedMagnitude * math.sin(angleOfImpact)

        pBoss.state = BSTATE.POURSUIT

    end


end

return BSTATE