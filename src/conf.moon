love.conf = (t) ->
    title = "LMines"
    id = title\lower!

    with t
        .version = "0.10.0"
        .identity = id

        with .window
            .title = title
            .icon = "images/#{id}.png"
            .width = 480
            .height = 528
            .fullscreen = false
