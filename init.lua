local ball = require("ball")
local pads = require("pad")

function Init()

    ball.timeGame = 0
    ball.speed_x = 300
    ball.speed_y = 300
    ball.CenterBall()

    pads.Load()
    pads.pad_1.speed = 300
    pads.pad_2.speed = 300

end