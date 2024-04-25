local listSprites = {} 

require("init")

local spawn = require("spawn")
local createSprite = require("createSprite")
local ESTATE = require("ennemIA")
local BSTATE = require("boss")
local listProjo = require("projo")
local ball = require("ball")
local pads = require("pad")
local sceneManager = require("sceneManager")


local maxShoot = 0 -- Compte le nombre de fois qu'on a tiré
local isProtect = false
local shieldIsReloading = false

local timeGame = 0
local timeForOver = 0

local bdebug = false

function listSprites.CreatePlayer()
    local myPlayer = {}

    local img = love.graphics.newImage("Images/survivor-idle_handgun_1.png")

    myPlayer = createSprite.CreateSprite(listSprites, "player", "survivor-idle_handgun_", 19)
    myPlayer.x = screenWidth / 2
    myPlayer.y = screenHeight / 6
    myPlayer.vitesse = 150
    myPlayer.bulletSpeed = 400
    myPlayer.timeShoot = 0 -- Peut tirer toutes les 1 secondes
    myPlayer.reload = 0
    myPlayer.timerBoom = 0
    myPlayer.protectDuration = 0.5
    myPlayer.timeShield = 0
    myPlayer.timerReloadShield = 0
    myPlayer.maxAmmo = 5 -- Nombre de munitions max
    myPlayer.angle = 0
    myPlayer.life = 100
    myPlayer.width = img:getWidth()
    myPlayer.height = img:getHeight()
    myPlayer.Hurt = function(pHurt)
        myPlayer.life = myPlayer.life - pHurt --
        if myPlayer.life <= 0 then
            myPlayer.life = 0
            print("MORT")
        end
    end
    myPlayer.Hit = function()
        myPlayer.life = myPlayer.life - 10
        if myPlayer.life <= 0 then
            myPlayer.life = 0
        end
    end
    myPlayer.BossHit = function()
        myPlayer.life = myPlayer.life - 20
        if myPlayer.life <= 0 then
            myPlayer.life = 0
            print("MORT")
        end
    end

    return myPlayer
end

function listSprites.CreateEnnemi()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local img = love.graphics.newImage("Images/skeleton-move_1.png")

    local myEnnemi = createSprite.CreateSprite(listSprites, "ennemi", "skeleton-move_", 16)

    myEnnemi.width = img:getWidth()

    myEnnemi.x = love.math.random(10, screenWidth - 10)
    myEnnemi.y = love.math.random(10, screenHeight - 10)

    myEnnemi.speed = 1
    myEnnemi.target = nil
    myEnnemi.angle = 0
    myEnnemi.timerSpawn = 0
    myEnnemi.waitForShoot = 0 -- Tire au bout de 
    myEnnemi.chronoReload = 0 -- Stop toi avant de tirer
    myEnnemi.bulletSpeed = 400
    myEnnemi.hurtDammage = 0.5
    myEnnemi.life = 1

    myEnnemi.state = ESTATE.NONE
end

function listSprites.CreateBoss()

    local img = love.graphics.newImage("Images/skeleton-move_1.png")

    local myBoss = createSprite.CreateSprite(listSprites, "boss", "skeleton-move_", 16)

    myBoss.width = img:getWidth()

    myBoss.x = love.math.random(10, screenWidth - 10)
    myBoss.y = love.math.random(10, screenHeight - 10)

    myBoss.speed = 0.5
    myBoss.target = nil
    myBoss.targetEat = nil
    myBoss.eatRange = 30
    myBoss.boomRange = 80
    myBoss.angle = 0
    myBoss.timerSpawn = 0
    myBoss.waitForShoot = 0 -- Tire au bout de 
    myBoss.chronoReload = 0 -- Stop toi avant de tirer
    myBoss.bulletSpeed = 400
    myBoss.boum = 50 -- Explose
    myBoss.life = 3
    myBoss.bossSpawn = true

    myBoss.state = BSTATE.NONE

end

function listSprites.Load()
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    Init()

    myPlayer = listSprites.CreatePlayer()
    maxShoot = 0

     -- Spawn mana à 0 
     listSprites.tempSpawn = 0
     listSprites.tempSpawnBoss = 0
     listSprites.bossSpawn = false

end

function listSprites.Update(dt)

    listSprites.timeScore = nil -- Contiendra le score 

    for i = #listSprites, 1,  -1 do
        sprite = listSprites[i]

        if sprite.type == "player" or sprite.type == "boss" or sprite.type == "ennemi" and sprite.state ~= ESTATE.DEAD then
            sprite.currentFrame = sprite.currentFrame + 0.5
            if sprite.currentFrame >= #sprite.img + 1 then
                sprite.currentFrame = 1
            end
        end

        if sprite.type == "player" then

            -- On récup la position de la souris et on l'applique à l'angle
            local mouseX, mouseY = love.mouse.getPosition()
            sprite.angle = math.atan2(mouseY - sprite.y, mouseX - sprite.x)
            --print(sprite.angle)

            -- Déplacement x et y en fonction de l'angle
            local dx = sprite.vitesse * math.cos(sprite.angle)
            local dy = sprite.vitesse * math.sin(sprite.angle)
            local maxTimeShoot = 0.5 -- Cadence de 0.5 sec
            local timeReload = 10 -- Recharge une mun toutes les 5 secondes

            sprite.timeShoot = sprite.timeShoot + dt -- Compteur pour cadence

            -- MOUV --
            if love.keyboard.isDown("up") and sprite.type == "player" then
                sprite.x = sprite.x + dx * dt
                sprite.y = sprite.y + dy * dt
            elseif love.keyboard.isDown("down") and sprite.type == "player" then
                sprite.x = sprite.x - dx * dt
                sprite.y = sprite.y - dy * dt
            end

            -- PROTECT --
            if isProtect and not shieldIsReloading then
                sprite.timeShield = sprite.timeShield + dt
    
                if sprite.timeShield >= sprite.protectDuration then
                    isProtect = false
                    sprite.timeShield = 0
                    shieldIsReloading = true
                end
            end

            if shieldIsReloading then
                sprite.timerReloadShield = sprite.timerReloadShield + dt 
                if sprite.timerReloadShield >= 5 then
                    shieldIsReloading = false
                    sprite.timerReloadShield = 0
                end
            end

            -- TIR --
            if love.mouse.isDown(1) and maxShoot < sprite.maxAmmo then
                -- RELOAD --
                if sprite.timeShoot >= maxTimeShoot then
                    local angleShootX = sprite.x + 15 * math.cos(sprite.angle + 45)
                    local angleShootY = sprite.y + 15 * math.sin(sprite.angle + 45)
                    listProjo.Tire(angleShootX, angleShootY, sprite.angle, sprite.bulletSpeed, sprite.type)
                    sprite.timeShoot = 0
                    maxShoot = maxShoot + 1
                --print(maxShoot)
                end

            -- RELOAD --
            elseif maxShoot == sprite.maxAmmo then
                -- Reload toutes les 10 secondes
                sprite.reload = sprite.reload + dt
                if sprite.reload >= timeReload then
                    maxShoot = 0
                    sprite.reload = 0
                end
            end

            -- Touché par la balle
            local distanceBall = math.dist(sprite.x,sprite.y, ball.x,ball.y)
            if distanceBall < sprite.width/2  and isProtect == false then
                sprite.life = 0 
                listSprites.timeScore = math.floor(ball.timeGame)
                sceneManager.ChangeScene("gameOver")

            -- Renvoie la balle
            elseif distanceBall < sprite.width/2  and isProtect and not shieldIsReloading then
                local angleOfImpact = math.angle(sprite.x,sprite.y, ball.x,ball.y)
                local speedMagnitude = math.sqrt(ball.speed_x^2 + ball.speed_y^2)

                local newSpeedX = speedMagnitude * math.cos(angleOfImpact)
                local newSpeedY = speedMagnitude * math.sin(angleOfImpact)

                ball.speed_x = newSpeedX
                ball.speed_y = newSpeedY
            end

            -- MORT --
            if sprite.life <= 0 then
                sprite.vitesse = 0
                timeForOver = timeForOver + dt
                if timeForOver > 0.5 then
                    listSprites.timeScore = math.floor(ball.timeGame)
                    sceneManager.ChangeScene("gameOver")
                    timeForOver = 0
                end
            end

            -- On fait avancer les projectiles
            for n = #listProjo, 1, -1 do
                local p = listProjo[n]
                local vx = p.vitesse * math.cos(p.angle)
                local vy = p.vitesse * math.sin(p.angle)
                local boomTimer = 1 -- Le cercle d'éxplosion se detruira au bout de 
        
                p.x = p.x + vx * dt
                p.y = p.y + vy * dt

                local distShoot = math.dist(p.x,p.y, sprite.x, sprite.y)

                -- Si l'ennemi touche le player
                if distShoot < sprite.width/2 and p.type == "ennemi"  then
                    table.remove(listProjo, n)
                    sprite.Hit()

                -- Boss touche player
                elseif distShoot < sprite.width/2 and p.type == "boss"  then
                    table.remove(listProjo, n)
                    sprite.BossHit()

                elseif p.type == "boom" then
                    sprite.timerBoom = sprite.timerBoom + dt
                    if sprite.timerBoom >= boomTimer then
                        table.remove(listProjo, n)
                        sprite.timerBoom = 0
                    end
                    

                --On suppr projo si il sort de l'écran
                elseif p.x < 0 or p.x > screenWidth or p.y < 0 or p.y > screenHeight then
                    table.remove(listProjo, n)

                else -- Donc si l'ennemi est touché
                    for en = #listSprites, 1, -1 do
                        local e = listSprites[en]
                        if e.type == "ennemi" and e.life > 0 then
                            if math.dist(p.x,p.y, e.x,e.y) < e.width/2 and p.type == "player" then
                                e.life = e.life - 1
                                table.remove(listProjo, n)
                                if e.life == 0 then
                                    e.state = ESTATE.DEAD
                                end
                            end

                        -- Si le boss est touché
                        elseif e.type == "boss" and e.life > 0 then
                            if math.dist(p.x,p.y, e.x,e.y) < e.width/2 and p.type == "player" then
                                e.life = e.life - 1
                                table.remove(listProjo, n)
                                if e.life == 0 then
                                    e.life = 0
                                    e.state = BSTATE.BOOM
                                end
                            end
                        end
                    end

                end
            end
        end

        -- ENNEMI --
        if sprite.type == "ennemi" then
            sprite.x = sprite.x + sprite.vx * dt
            sprite.y = sprite.y + sprite.vy * dt
            ESTATE.UpdateEnnemi(sprite, listSprites, listProjo, ball, dt)
        end

        -- BOSS --

        if sprite.type == "boss" then
            sprite.x = sprite.x + sprite.vx * dt
            sprite.y = sprite.y + sprite.vy * dt
            BSTATE.UpdateBoss(sprite, listSprites, listProjo, ESTATE, ball, dt)

        end

    end

    -- BALL --

    ball.Update(dt)

    -- PAD --

    pads.Update(dt)

    -- ENNEMIES SPAWN --

    spawn.Spawn(listSprites, dt)

end

function listSprites.Draw()

    -- PROJO --
    listProjo.Draw()

    -- PLAYER PROJO --
    love.graphics.print(maxShoot.." / 5", 100 ,screenHeight - 20)

    -- PONG --
    ball.Draw()
    pads.Draw()

        -- SPRITE --
    for i, sprite in ipairs(listSprites) do
        local frame = sprite.img[math.floor(sprite.currentFrame)]
        

        if sprite.type == "boss" then
            love.graphics.setColor(1,0,0,1)
        else
            love.graphics.setColor(1,1,1,1)
        end

        if sprite.type == "player" then
            -- TIMER PROJO -- 
            love.graphics.print("Reload in "..math.floor(sprite.reload), 150, screenHeight - 20)

            if isProtect and not shieldIsReloading then
                love.graphics.setColor(0.5,0.5,1,1)
            else
                love.graphics.setColor(1,1,1,1)
            end
            love.graphics.draw(frame, sprite.x, sprite.y, sprite.angle, 1, 1, sprite.width / 2, sprite.height / 2)
            love.graphics.print("Vie : "..math.floor(sprite.life), 20, screenHeight - 20)

        else 
            love.graphics.draw(frame, sprite.x, sprite.y, sprite.angle, 1, 1, sprite.width / 2, sprite.height / 2)
        end

        love.graphics.setColor(1,1,1,1)

    end

    if bDebug == true then
        love.graphics.print("pad : " .. pads.pad_1.speed, 10, 20)
        love.graphics.print("ball : " .. ball.speed_x, 10, 40)
        love.graphics.print("ball : " .. ball.speedMagnitude, 10, 60)
    end

end

function listSprites.Keypressed(key)

    -- C'est true jusqu'au bout de 0.2 sec
    if (key == "kp0" or key == "space") and not shieldIsReloading and not isProtect then 
        isProtect = true
    end

    if key == "d" then
        if bDebug == false then
            bDebug = true
        else
            bDebug = false
        end
    end

    if key == 'escape' then
        love.event.quit()
    end

end



return listSprites
