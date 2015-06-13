love.conf = (t) ->
    with t
        .version = "0.9.1"
        .identity = "lmines"

    with t.window
        .title = "LMines"
        .icon = "images/lmines.png"
        .width = 480
        .height = 528
        .fullscreen = false
