love.conf = (t) ->
    with t
        .version = "0.10.0"
        .identity = "lmines"

        with .window
            .title = "LMines"
            .icon = "images/lmines.png"
            .width = 480
            .height = 528
            .fullscreen = false
