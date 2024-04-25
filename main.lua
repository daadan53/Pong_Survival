io.stdout:setvbuf("no")

local sceneManager = require("sceneManager")
sceneManager.AddScene("menu", "sceneMenu")
sceneManager.AddScene("jeu", "sprite")
sceneManager.AddScene("gameOver", "sceneGameover")

sceneManager.ChangeScene("menu")

function love.load()
    sceneManager.Load()
end

function love.update(dt)
    sceneManager.Update(dt)
end

function love.draw()
    sceneManager.Draw()
end

function love.keypressed(key)
    sceneManager.Keypressed(key)
end
