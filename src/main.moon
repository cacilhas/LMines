mines = assert require "mines"
import floor from math

app = {}
local reset


--------------------------------------------------------------------------------
love.load = ->
    with love.graphics
        objects = .newImage "images/objects.png"
        tiles = .newImage "images/tiles.png"
        smileys = .newImage "images/smileys.png"
        app.font = .newFont "resources/beech.ttf", 40
        app.score = .newFont "resources/sans.ttf", 40

        width, height = objects\getWidth!, objects\getHeight!
        app.objects =
            mine:
                img: objects
                quad: .newQuad 0, 0, 48, 48, width, height
            flag:
                img: objects
                quad: .newQuad 48, 0, 48, 48, width, height
            xflag:
                img: objects
                quad: .newQuad 96, 0, 48, 48, width, height

        width, height = tiles\getWidth!, tiles\getHeight!
        app.tiles =
            closed:
                img: tiles
                quad: .newQuad 0, 0, 48, 48, width, height
            open:
                img: tiles
                quad: .newQuad 48, 0, 48, 48, width, height
            red:
                img: tiles
                quad: .newQuad 96, 0, 48, 48, width, height

        width, height = smileys\getWidth!, smileys\getHeight!
        app.smileys =
            playing:
                img: smileys
                quad: .newQuad 0, 0, 48, 48, width, height
            win:
                img: smileys
                quad: .newQuad 48, 0, 48, 48, width, height
            lose:
                img: smileys
                quad: .newQuad 96, 0, 48, 48, width, height

        app.fontcolors =
            ["1"]: {0x00, 0x00, 0xa0}
            ["2"]: {0x00, 0xa0, 0x00}
            ["3"]: {0xa0, 0x00, 0x00}
            ["4"]: {0xa0, 0xa0, 0x00}
            ["5"]: {0xa0, 0x00, 0xa0}
            ["6"]: {0xa0, 0xa0, 0x00}
            ["7"]: {0xa0, 0xa0, 0xa0}
            ["8"]: {0x00, 0x00, 0x00}

    reset!


--------------------------------------------------------------------------------
love.draw = ->
    app.board\draw 0, 48, app.objects, app.tiles, app.font, app.fontcolors
    with love.graphics
        .setFont app.score
        if app.gameover and app.win
            .setColor 0x00, 0xff, 0x00
        elseif app.gameover
            .setColor 0xff, 0x00, 0x00
        else
            .setColor 0x00, 0x00, 0xff
        .print app.board\gettime!, 10, 4
        .reset!

        local smiley
        if app.board.gameover and app.board.win
            smiley = app.smileys.win
        elseif app.board.gameover
            smiley = app.smileys.lose
        else
            smiley = app.smileys.playing
        .draw smiley.img, smiley.quad, 216, 0


--------------------------------------------------------------------------------
love.mousereleased = (x, y, button) ->
    lx = (floor x / 48) + 1
    ly = (floor y / 48)
    with love.keyboard
        if button == "l" and not ((.isDown "rgui") or (.isDown "lgui"))
            app.board\open lx, ly
        else
            app.board\toggleflag lx, ly

--------------------------------------------------------------------------------
love.keyreleased = (key) ->
    reset! if key == "escape"


--------------------------------------------------------------------------------
reset = -> app.board = mines.newboard 10, 10, 16


--------------------------------------------------------------------------------
_graphics_reset = love.graphics.reset
love.graphics.reset = (...) ->
    _graphics_reset ...
    love.graphics.setBackgroundColor 0xc6, 0xc7, 0xc9
