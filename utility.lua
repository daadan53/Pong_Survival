-- Fonction utilitaire pour obtenir le signe d'un nombre
function math.sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end 