local listProjo = {}

function listProjo.Tire(x, y, angle, vitesse, type)
    local projo = {}

    projo.x = x 
    projo.y = y
    projo.angle = angle
    projo.vitesse = vitesse
    projo.type = type

    table.insert(listProjo, projo)
end

function listProjo.Draw()
    for k, v in ipairs(listProjo) do
        if v.type == "player" then
            love.graphics.setColor(1, 0, 0, 1)
            love.graphics.circle("fill", v.x, v.y, 3)

        elseif v.type == "boom" then
            love.graphics.setColor(0, 1, 0, 1)
            love.graphics.circle("fill", v.x, v.y, 80)

        else
            love.graphics.setColor(0, 1, 0, 1)
            love.graphics.circle("fill", v.x, v.y, 7)
        end

        love.graphics.setColor(1, 1, 1, 1)
    end
end

return listProjo
