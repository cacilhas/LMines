ffi = assert require "ffi"

_VERSION = "1.0"
_DESCRIPTION = "LMines – Lua-implemented Mines"
_AUTHOR = "ℜodrigo ℭacilhας <batalema@cacilhas.info>"
_URL = ""
_LICENSE = "BSD 3-Clause License"

import floor, random, randomseed from math

local *


--------------------------------------------------------------------------------
ffi.cdef [[
    typedef struct {
        int value;
        unsigned char open;
        unsigned char flag;
    } cell_t;
]]


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
        @board = [Cell! for _ = 1, width * height]

        for _ = 1, bombs
            done = false
            while not done
                x, y = (random width), (random height)
                cell = @\get x, y
                if cell and cell.value != -1
                    done = true
                    cell.value = -1
                    for t in *around
                        cell = @\get x + t.dx, y + t.dy
                        cell.value += 1 if cell and cell.value != -1

    get: (x, y) =>
        @board[(y-1) * @width + x] if (x >= 1) and (x <= @width) and (y >= 1) and (y <= @height)

    toggleflag: (x, y) =>
        unless @gameover
            @started = love.timer.getTime! unless @started
            cell = @\get x, y
            if cell
                if cell.open == 1
                    false
                else
                    cell.flag = if cell.flag == 1 then 0 else 1
                    cell

    open: (x, y) =>
        unless @gameover
            @started = love.timer.getTime! unless @started
            cell = @\get x, y
            if cell
                if cell.open == 1 or cell.flag == 1
                    false
                else
                    if cell.value == -1
                        cell.open = 1
                        @gameover = true
                        @win = false
                        @stopped = @\gettime!
                    else
                        @\_keepopening x, y
                        @\_checkgameover!
                    cell

    _keepopening: (x, y) =>
        cell = @\get x, y
        if cell and cell.open == 0
            cell.open = 1
            if cell.value == 0
                @\_keepopening x + t.dx, y + t.dy for t in *around

    _checkgameover: =>
        count = @bombs
        for cell in *@board
            count +=1 if cell.open == 1 and cell.value != -1

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
                cell = @\get x, y

                local tile
                if cell.open == 1 and cell.value == -1
                    tile = tiles.red
                elseif cell.open == 1
                    tile = tiles.open
                else
                    tile = tiles.closed
                love.graphics.draw tile.img, tile.quad, lx, ly

                object = nil
                if @gameover
                    if cell.open == 1
                        object = objects.mine if cell.value == -1

                    elseif cell.value == -1
                        object = if @win or cell.flag == 1 then objects.flag else objects.mine

                    elseif cell.flag == 1
                        object = objects.xflag

                elseif cell.flag == 1
                    object = objects.flag

                if object
                    love.graphics.draw object.img, object.quad, lx, ly

                elseif cell.open == 1 and cell.value > 0
                    with love.graphics
                        .setFont font
                        .setColor fontcolors[cell.value] or {0, 0, 0}
                        .print (tostring cell), lx+4, ly+4
                        .reset!


--------------------------------------------------------------------------------
Cell = ffi.metatype "cell_t", {
    __tostring: =>
        tostring @value

    __concat: (other) =>
        tostring @value .. tostring other
}



--------------------------------------------------------------------------------
{
    :_VERSION
    :_DESCRIPTION
    :_AUTHOR
    :_URL
    :_LICENSE
    newboard: Board
}
