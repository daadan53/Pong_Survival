local createSprite = {}

function createSprite.CreateSprite(pList, pType, psImageFile, pnFrames)
    local mySprite = {}

    mySprite.type = pType
    mySprite.img = {}

    mySprite.currentFrame = 1

    for i = 1, pnFrames do
        local fileName = "Images/" .. psImageFile .. tostring(i) .. ".png" -- Changer NewIdle par quelque chose de modulaire
        --print("Load frame " .. fileName .. pType)
        mySprite.img[i] = love.graphics.newImage(fileName)
    end

    mySprite.x = 0
    mySprite.y = 0
    mySprite.vx = 0
    mySprite.vy = 0

    mySprite.width = mySprite.img[1]:getWidth()
    mySprite.height = mySprite.img[1]:getHeight()

    -- On crée une liste qui sera mis dans une liste pour contenir toutes les frames de chaques perso
    table.insert(pList, mySprite)

    return mySprite
end


return createSprite