local sceneMenu = {}

local pads = require("pad")
local ball = require("ball")
local sceneManager = require("sceneManager")

function sceneMenu.Load()
    ball.CenterBall()
    pads.Load()
end

function sceneMenu.Update(dt)
    ball.Update(dt)
    pads.Update(dt)
end

function sceneMenu.Draw()
    ball.Draw()
    pads.Draw()
    love.graphics.print("PONG SURVIVAL", screenWidth/6 * 2.3, screenHeight/2 - 100, 0, 2, 2)
    love.graphics.print("Appuyez sur Espace pour jouer", screenWidth/6 * 2.3, screenHeight/2)
    love.graphics.print("Appuyez sur Echap pour quitter", screenWidth/6 * 2.3, screenHeight/5*3)
end

function sceneMenu.Keypressed(key)
    if key == "space" then
        sceneManager.ChangeScene("jeu")

    elseif key == 'escape' then
        love.event.quit()
    end
end

return sceneMenu