local mines = {
    _VERSION = "1.0",
    _DESCRIPTION = "LMines – Lua-implemented Mines",
    _AUTHOR = "ℜodrigo ℭacilhας <batalema@cacilhas.info>",
    _URL = "",
    _LICENSE = "BSD 3-Clause License",
}


------------------------------------------------------------------------
math.randomseed(os.time())


------------------------------------------------------------------------
local around = {
    {dx=-1, dy=-1},
    {dx=0, dy=-1},
    {dx=1, dy=-1},
    {dx=-1, dy=0},
    {dx=1, dy=0},
    {dx=-1, dy=1},
    {dx=0, dy=1},
    {dx=1, dy=1},
}


------------------------------------------------------------------------
local Board = {
    new = function(cls, width, height, bombs)
        width = width or 16
        height = height or 16
        bombs = bombs or 40

        if bombs >= width * height then
            return nil, "invalid parameters"
        end

        local x, y, index
        local self = {
            width = width,
            height = height,
            bombs = bombs,
            gameover = false,
        }
        for _ = 1, width * height do
            table.insert(self, {value=0, open=false, flagged=false})
        end

        self = setmetatable(self, cls)
        for _ = 1, bombs do
            local index
            local done = false
            while not done do
                x = math.random(width)
                y = math.random(height)
                local cel = self:get(x, y)
                if cel and cel.value ~= "B" then
                    done = true
                    cel.value = "B"
                    table.foreachi(around, function(_, t)
                        local cel = self:get(x+t.dx, y+t.dy)
                        if cel and cel.value ~= "B" then
                            cel.value = cel.value + 1
                        end
                    end)
                end
            end
        end
        table.foreachi(self, function(_, cel) cel.value = tostring(cel.value) end)
        return self
    end,

    __index = {
        get = function(self, x, y)
            if (x >= 1) and (x <= self.width) and (y >= 1) and (y <= self.height) then
                return self[(y-1) * self.width + x]
            end
        end,

        toggleflag = function(self, x, y)
            if self.gameover then return end
            if not self.started then self.started = love.timer.getTime() end

            local cel = self:get(x, y)
            if not cel then return end

            if cel.open then
                return false
            else
                cel.flag = not cel.flag
                return cel
            end
        end,

        open = function(self, x, y)
            if self.gameover then return end
            if not self.started then self.started = love.timer.getTime() end

            local cel = self:get(x, y)
            if not cel then return end

            if cel.open or cel.flag then
                return false
            else
                if cel.value == "B" then
                    cel.open = true
                    self.gameover = true
                    self.win = false
                    local time = self:gettime()
                    self.gettime = function() return time end

                else
                    self:_keepopening(x, y)
                    self:_checkgameover()
                end
                return cel
            end
        end,

        _keepopening = function(self, x, y)
            local cel = self:get(x, y)
            if (not cel) or cel.open then return end
            if cel.value ~= "0" then cel.open = true return end

            cel.open = true
            table.foreachi(around, function(_, t)
                self:_keepopening(x+t.dx, y+t.dy)
            end)
        end,

        _checkgameover = function(self)
            local count = self.bombs
            table.foreachi(self, function(_, cel)
                if cel.open and cel.value ~= "B" then
                    count = count + 1
                end
            end)

            if count == (self.width * self.height) then
                self.gameover = true
                self.win = true
                local time = self:gettime()
                self.gettime = function() return time end
            end
        end,

        gettime = function(self)
            if not self.started then return "00:00" end
            local t = love.timer.getTime() - self.started
            return ("%02d:%02d"):format(math.floor(t / 60),
                                        math.floor(t % 60))
        end,

        draw = function(self, xoffset, yoffset, objects, tiles, font, fontcolors)
            local x, y, lx, ly, cel
            for y = 1, self.height do
                for x = 1, self.width do
                    lx = (x - 1) * 48 + xoffset
                    ly = (y - 1) * 48 + yoffset
                    cel = self:get(x, y)
                    local tile, object

                    -- tile
                    if cel.open and cel.value == "B" then
                        tile = tiles.red
                    elseif cel.open then
                        tile = tiles.open
                    else
                        tile = tiles.closed
                    end
                    love.graphics.draw(tile.img, tile.quad, lx, ly)

                    -- object
                    if self.gameover and cel.flag and cel.value ~= "B" then
                        object = objects.xflag
                    elseif cel.flag then
                        object = objects.flag
                    elseif cel.open and cel.value == "B" then
                        object = objects.mine
                    else
                        object = nil
                    end

                    if object then
                        love.graphics.draw(object.img, object.quad, lx, ly)

                    elseif cel.open and cel.value ~= "B" and cel.value ~= "0" then
                        love.graphics.setFont(font)
                        love.graphics.setColor(fontcolors[cel.value] or {0, 0, 0})
                        love.graphics.print(cel.value, lx+4, ly+4)
                        love.graphics.reset()
                    end
                end
            end
        end,
    },
}


------------------------------------------------------------------------
mines.newboard = function(...) return Board:new(...) end


------------------------------------------------------------------------
return mines
