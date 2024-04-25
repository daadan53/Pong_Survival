local sceneManager = {}

local currentScene = nil

listeDeScenes = {}

function sceneManager.AddScene(pNom, pModule)
    --On ajoute à listScenes pnom qui contient le require du module
    listeDeScenes[pNom] = require(pModule) -- pNom ce sera la scène a charger et pModule c'est le module qui contient cette scène
end

function sceneManager.ChangeScene(pNom)
    currentScene = listeDeScenes[pNom] -- On def scenecourante en chargeant la snène du nom
    currentScene.Load() -- On appel la focntion load dans le module de la scène précédemment appelé
end

function sceneManager.Load()
    -- On appel la fonction update du module de la scène précédemment def
    currentScene.Load() -- Du coup il faut absolument que chaque module de scène est les memes fonctions (appelé pareil)
end

function sceneManager.Update(dt)
    -- On appel la fonction update du module de la scène précédemment def
    currentScene.Update(dt) -- Du coup il faut absolument que chaque module de scène est les memes fonctions (appelé pareil)
end

function sceneManager.Draw()
    currentScene.Draw()
end

function sceneManager.Keypressed(key)
    currentScene.Keypressed(key)
end

return sceneManager
