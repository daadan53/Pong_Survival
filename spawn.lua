local spawn = {}

function spawn.Spawn(pEntities, dt)
    -- ENNEMIES --

    -- Si le boss a spawn alors arrete
    if pEntities.bossSpawn == false then
        local maxSpawn = math.random(5, 6) -- Mechant spawn toutes les 5sec
        pEntities.tempSpawn = pEntities.tempSpawn + dt
        if pEntities.tempSpawn >= maxSpawn then
            pEntities.CreateEnnemi(pEntities)
            pEntities.tempSpawn = 0
        end
    end

    -- BOSS --

    if pEntities.bossSpawn == false then
        local maxSpawnBoss = 15
        pEntities.tempSpawnBoss = pEntities.tempSpawnBoss + dt
        if pEntities.tempSpawnBoss >= maxSpawnBoss then
            pEntities.CreateBoss(pEntities)
            pEntities.tempSpawnBoss = 0
            pEntities.bossSpawn = true
        end
    end

    -- Si le boss est en état boom alors passe en true
    for i, sprite in ipairs(pEntities) do
        if sprite.type == "boss" then
            -- Il faut qu'il detect quand le boss est suppr 
            if sprite.life <= 0 then
                pEntities.bossSpawn = false
                break
            end
        end
    end
end

return spawn