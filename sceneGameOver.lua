local scene = {}

local sceneManager = require("sceneManager")
local listSprites = require("sprite")
local listProjo = require("projo")

function scene.Load()

    listSprites.bossSpawn = false

end

function scene.Update(dt)

    for n = #listSprites, 1, -1 do
        local sprite = listSprites[n]

        if sprite.type == "ennemi" then
            table.remove(listSprites, n)

        elseif sprite.type == "boss" then
            table.remove(listSprites, n)

        elseif sprite.type == "player" then
            table.remove(listSprites, n)
        end
    end

    for p = #listProjo, 1, -1 do
        local projo = listProjo[p]

        if projo.type == "player" then
            table.remove(listProjo, p)
        elseif projo.type == "ennemi" then 
            table.remove(listProjo, p)
        elseif projo.type == "boss" then 
            table.remove(listProjo, p)
        elseif projo.type == "boom" then
            table.remove(listProjo, p) 
        end
    end
end

function scene.Draw()
    love.graphics.print("PERDU !", screenWidth/6 * 2.1, 70, 0, 4, 4)
    love.graphics.print("Vous avez survécu "..listSprites.timeScore.." secondes", screenWidth/6 * 1.5, screenHeight/2 - 65, 0, 2, 2)
    love.graphics.print("Appuyez sur Espace pour rejouer", screenWidth/6 * 2.1, screenHeight/2)
    love.graphics.print("Appuyez sur Echap pour quitter", screenWidth/6 * 2.1, screenHeight/5*3)
end

function scene.Keypressed(key)
    if key == "space" then
        sceneManager.ChangeScene("jeu")

    elseif key == 'escape' then
        love.event.quit()
    end
end

return scene