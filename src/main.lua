local mines = assert(require "mines")

local app = {}
local reset


------------------------------------------------------------------------
function love.load()
  local width, height
  local objects = love.graphics.newImage("images/objects.png")
  local tiles = love.graphics.newImage("images/tiles.png")
  local smileys = love.graphics.newImage("images/smileys.png")
  app.font = love.graphics.newFont("resources/beech.ttf", 40)
  app.score = love.graphics.newFont("resources/sans.ttf", 40)

  width, height = objects:getWidth(), objects:getHeight()
  app.objects = {
    mine = {
      img = objects,
      quad = love.graphics.newQuad(0, 0, 48, 48, width, height),
    },
    flag = {
      img = objects,
      quad = love.graphics.newQuad(48, 0, 48, 48, width, height),
    },
    xflag = {
      img = objects,
      quad = love.graphics.newQuad(96, 0, 48, 48, width, height),
    },
  }

  width, height = tiles:getWidth(), tiles:getHeight()
  app.tiles = {
    closed = {
      img = tiles,
      quad = love.graphics.newQuad(0, 0, 48, 48, width, height),
    },
    open = {
      img = tiles,
      quad = love.graphics.newQuad(48, 0, 48, 48, width, height),
    },
    red = {
      img = tiles,
      quad = love.graphics.newQuad(96, 0, 48, 48, width, height),
    },
  }

  width, height = smileys:getWidth(), smileys:getHeight()
  app.smileys = {
    playing = {
      img = smileys,
      quad = love.graphics.newQuad(0, 0, 48, 48, width, height),
    },
    win = {
      img = smileys,
      quad = love.graphics.newQuad(48, 0, 48, 48, width, height),
    },
    lose = {
      img = smileys,
      quad = love.graphics.newQuad(96, 0, 48, 48, width, height),
    },
  }

  app.fontcolors = {
    ["1"] = {0x00, 0x00, 0xa0},
    ["2"] = {0x00, 0xa0, 0x00},
    ["3"] = {0xa0, 0x00, 0x00},
    ["4"] = {0xa0, 0xa0, 0x00},
    ["5"] = {0xa0, 0x00, 0xa0},
    ["6"] = {0xa0, 0xa0, 0x00},
    ["7"] = {0xa0, 0xa0, 0xa0},
    ["8"] = {0x00, 0x00, 0x00},
  }

  reset()
end


------------------------------------------------------------------------
function love.draw()
  app.board:draw(0, 48, app.objects, app.tiles, app.font, app.fontcolors)

  love.graphics.setFont(app.score)
  if app.gameover and app.win then
    love.graphics.setColor({0x00, 0xff, 0x00})
  elseif app.gameover then
    love.graphics.setColor({0xff, 0x00, 0x00})
  else
    love.graphics.setColor({0x00, 0x00, 0xff})
  end
  love.graphics.print(app.board:gettime(), 10, 4)
  love.graphics.reset()

  local smiley
  if app.board.gameover and app.board.win then
    smiley = app.smileys.win
  elseif app.board.gameover then
    smiley = app.smileys.lose
  else
    smiley = app.smileys.playing
  end
  love.graphics.draw(smiley.img, smiley.quad, 216, 0)
end


------------------------------------------------------------------------
function love.mousereleased(x, y, button)
  local lx = math.floor(x / 48) + 1
  local ly = math.floor(y / 48)
  local pressed = love.keyboard.isDown
  if button == "l" and not (pressed("rgui") or pressed("lgui")) then
    app.board:open(lx, ly)
  else
    app.board:toggleflag(lx, ly)
  end
end


------------------------------------------------------------------------
function love.keyreleased(key)
  if key == "escape" then reset() end
end


------------------------------------------------------------------------
function reset()
  app.board = mines.newboard(10, 10, 16)
end


------------------------------------------------------------------------
local _graphics_reset = love.graphics.reset
function love.graphics.reset(...)
  _graphics_reset(...)
  love.graphics.setBackgroundColor({0xc6, 0xc7, 0xc9})
end
