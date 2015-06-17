mines = assert require "mines"
color = assert require "color"
import floor from math

local *
app = {}


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
            [1]: color 0x00, 0x00, 0xa0, 0xff
            [2]: color 0x00, 0xa0, 0x00, 0xff
            [3]: color 0xa0, 0x00, 0x00, 0xff
            [4]: color 0xa0, 0xa0, 0x00, 0xff
            [5]: color 0xa0, 0x00, 0xa0, 0xff
            [6]: color 0xa0, 0xa0, 0x00, 0xff
            [7]: color 0xa0, 0xa0, 0xa0, 0xff
            [8]: color 0x00, 0x00, 0x00, 0xff
            default: color 0x00, 0x00, 0x00, 0xff

        setmetatable app.fontcolors, {
            __call: (index) =>
                return @[index] or @default
        }

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
with graphics_reset = love.graphics.reset
    love.graphics.reset = (...) ->
        graphics_reset ...
        love.graphics.setBackgroundColor 0xc6, 0xc7, 0xc9
