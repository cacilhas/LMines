_VERSION = "1.0"
_DESCRIPTION = "LMines – Lua-implemented Mines"
_AUTHOR = "ℜodrigo ℭacilhας <batalema@cacilhas.info>"
_URL = ""
_LICENSE = "BSD 3-Clause License"

import floor, random, randomseed from math


--------------------------------------------------------------------------------
around = {
    {dx: -1, dy: -1}
    {dx: 0, dy: -1}
    {dx: 1, dy: -1}
    {dx: -1, dy: 0}
    {dx: 1, dy: 0}
    {dx: -1, dy: 1}
    {dx: 0, dy: 1}
    {dx: 1, dy: 1}
}


--------------------------------------------------------------------------------
class Board
    gameover: false

    new: (width=16, height=16, bombs=40) =>
        error "invalid parameters" if bombs >= width * height
        @width, @height, @bombs = width, height, bombs
        @board = [{value: 0, open: false, flagged: false} for _ = 1, width * height]

        for _ = 1, bombs
            done = false
            while not done
                x, y = (random width), (random height)
                cel = @\get x, y
                if cel and cel.value != "B"
                    done = true
                    cel.value = "B"
                    for t in *around
                        cel = @\get x + t.dx, y + t.dy
                        cel.value += 1 if cel and cel.value != "B"
        cel.value = tostring cel.value for cel in *@board

    get: (x, y) =>
        @board[(y-1) * @width + x] if (x >= 1) and (x <= @width) and (y >= 1) and (y <= @height)

    toggleflag: (x, y) =>
        unless @gameover
            @started = love.timer.getTime! unless @started
            cel = @\get x, y
            if cel
                if cel.open
                    false
                else
                    cel.flag = not cel.flag
                    cel

    open: (x, y) =>
        unless @gameover
            @started = love.timer.getTime! unless @started
            cel = @\get x, y
            if cel
                if cel.open or cel.flag
                    false
                else
                    if cel.value == "B"
                        cel.open = true
                        @gameover = true
                        @win = false
                        @stopped = @\gettime!
                    else
                        @\_keepopening x, y
                        @\_checkgameover!
                    cel

    _keepopening: (x, y) =>
        cel = @\get x, y
        if cel and not cel.open
            cel.open = true
            if cel.value == "0"
                @\_keepopening x + t.dx, y + t.dy for t in *around

    _checkgameover: =>
        count = @bombs
        for cel in *@board
            count +=1 if cel.open and cel.value != "B"

        if count == (@width * @height)
            @gameover = true
            @win = true
            @stopped = @\gettime!

    gettime: =>
        if @stopped
            @stopped
        elseif @started
            t = love.timer.getTime! - @started
            "%02d:%02d"\format (floor t / 60), (floor t % 60)
        else
            "00:00"

    draw: (xoffset, yoffset, objects, tiles, font, fontcolors) =>
        for y = 1, @height
            for x = 1, @width
                lx = (x - 1) * 48 + xoffset
                ly = (y - 1) * 48 + yoffset
                cel = @\get x, y

                local tile
                if cel.open and cel.value == "B"
                    tile = tiles.red
                elseif cel.open
                    tile = tiles.open
                else
                    tile = tiles.closed
                love.graphics.draw tile.img, tile.quad, lx, ly

                object = nil
                if @gameover
                    if cel.open
                        object = objects.mine if cel.value == "B"

                    elseif cel.value == "B"
                        object = if @win or cel.flag then objects.flag else objects.mine
                    elseif cel.flag
                        object = objects.xflag

                elseif cel.flag
                    object = objects.flag

                if object
                    love.graphics.draw object.img, object.quad, lx, ly

                elseif cel.open and cel.value != "B" and cel.value != "0"
                    with love.graphics
                        .setFont font
                        .setColor fontcolors[cel.value] or {0, 0, 0}
                        .print cel.value, lx+4, ly+4
                        .reset!


--------------------------------------------------------------------------------
{
    :_VERSION
    :_DESCRIPTION
    :_AUTHOR
    :_URL
    :_LICENSE
    newboard: Board
}
