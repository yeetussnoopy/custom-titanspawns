---@class TensionBarGlow : Object
local TensionBarGlow, super = Class(Object)

function TensionBarGlow:init(x, y)
    super.init(self, x, y)

    self.apparent = Game.tension
    self.alphamod = 1
end

function TensionBarGlow:update()
    super.update(self)

    self.alphamod = Utils.approach(self.alphamod, 0, 0.15 * DTMULT)
    if self.alphamod <= 0 then
        self:remove()
    end
end

function TensionBarGlow:draw()
    local xx = 0
    local yy = 0
    local z = 1

    Draw.setColor(1, 1, 1, 1)

    love.graphics.setBlendMode("add")


    local tplogo = Game.battle.tension_bar.tp_text

    local alpha = (1 - (1 * 0.25)) * self.alphamod

    Draw.draw(tplogo, -30 - (z), 30, 0, 1, 1)
    self:draw_w_offset(-z, 0, alpha)

    Draw.draw(tplogo, -30 + (z), 30, 0, 1, 1)
    self:draw_w_offset(z, 0, alpha)

    Draw.draw(tplogo, -30, (30) - (z), 0, 1, 1)
    self:draw_w_offset(0, -z, alpha)

    Draw.draw(tplogo, -30, 30 + (z), 0, 1, 1)
    self:draw_w_offset(0, z, alpha)

    Draw.draw(tplogo, -30 - (z), (30) - (z), 0, 1, 1)
    self:draw_w_offset(-z, -z, alpha)

    Draw.draw(tplogo, -30 + (z), (30) - (z), 0, 1, 1)
    self:draw_w_offset(z, -z, alpha)

    Draw.draw(tplogo, -30 - (z), 30 + (z), 0, 1, 1)
    self:draw_w_offset(-z, z, alpha)

    Draw.draw(tplogo, -30 + (z), 30 + (z), 0, 1, 1)
    self:draw_w_offset(z, z, alpha)

    love.graphics.setBlendMode("alpha")


    Draw.setColor(1, 1, 1, 0.75 * self.alphamod)
    Draw.draw(Game.battle.tension_bar.tp_bar_fill, xx, 0, 0, 1, 1)

    super.draw(self)
end

function TensionBarGlow:draw_w_offset(dx, dy, alpha)
    local xx = 0
    local yy = 0

    love.graphics.setFont(Game.battle.tension_bar.font)
    Draw.setColor(1, 1, 1, alpha)

    if Game.tension < 100 then
        love.graphics.print(tostring(math.floor(Game.tension)), -30 + dx, 70 + dy)
        love.graphics.print("%", -25 + dx, 95 + dy)
    else
        love.graphics.print("M", -28 + dx, 70 + dy)
        love.graphics.print("A", -24 + dx, 90 + dy)
        love.graphics.print("X", -20 + dx, 110 + dy)
    end
end

return TensionBarGlow
