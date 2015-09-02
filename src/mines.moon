ffi = assert require "ffi"

_VERSION = "1.0"
_DESCRIPTION = "LMines – Lua-implemented Mines"
_AUTHOR = "ℜodrigo Arĥimedeς ℳontegasppa ℭacilhας <batalema@cacilhas.info>"
_URL = "https://bitbucket.org/cacilhas/lmines"
_LICENSE = "BSD 3-Clause License"

import floor, random, randomseed from math

local *


--------------------------------------------------------------------------------
ffi.cdef [[
    struct cell {
        int value;
        bool open, flag;
    };

    struct dcoords {
        int dx, dy;
    };
]]


local around
with dcoords = (...) -> ffi.new "struct dcoords", ...
    around = {
        dcoords -1, -1
        dcoords  0, -1
        dcoords  1, -1
        dcoords -1,  0
        dcoords  1,  0
        dcoords -1,  1
        dcoords  0,  1
        dcoords  1,  1
    }


--------------------------------------------------------------------------------
class Board
    gameover: false

    new: (width=16, height=16, bombs=40) =>
        error "invalid parameters" if bombs >= width * height
        @width, @height, @bombs = width, height, bombs
        @board = [ffi.new "struct cell" for _ = 1, width * height]

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

    get: (x, y) => @board[(y-1) * @width + x] if 1 <= x and x <= @width

    toggleflag: (x, y) =>
        unless @gameover
            @started = love.timer.getTime! unless @started
            if cell = @\get x, y
                if cell.open
                    false
                else
                    cell.flag = not cell.flag
                    cell

    open: (x, y) =>
        unless @gameover
            @started = love.timer.getTime! unless @started
            if cell = @\get x, y
                if cell.open or cell.flag
                    false
                else
                    if cell.value == -1  -- bomb
                        cell.open = true
                        @gameover = true
                        @win = false
                        @stopped = @\gettime!
                    else
                        @\_keepopening x, y
                        @\_checkgameover!
                    cell

    _keepopening: (x, y) =>
        cell = @\get x, y
        if cell and not cell.open
            cell.open = true
            if cell.value == 0
                @\_keepopening x + t.dx, y + t.dy for t in *around

    _checkgameover: =>
        count = @bombs
        for cell in *@board
            count += 1 if cell.open and cell.value != -1

        if count == @width * @height
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
                tile = if cell.open and cell.value == -1
                    tiles.red
                elseif cell.open
                    tiles.open
                else
                    tiles.closed
                love.graphics.draw tile.img, tile.quad, lx, ly

                object = if @gameover
                    if cell.open
                        objects.mine if cell.value == -1

                    elseif cell.value == -1
                        if @win or cell.flag then objects.flag else objects.mine

                    elseif cell.flag
                        objects.xflag

                elseif cell.flag
                    objects.flag

                with love.graphics
                    if object
                        .draw object.img, object.quad, lx, ly

                    elseif cell.open and cell.value > 0
                        .setFont font
                        .setColor (fontcolors cell.value)\explode!
                        .print "#{cell.value}", lx+4, ly+4
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
