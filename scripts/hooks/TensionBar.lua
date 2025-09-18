local TensionBar, super = Utils.hookScript("TensionBar", true)

function TensionBar:init(x, y, dont_animate)
    self.star_sprite = Assets.getTexture("ui/battle/spr_thrash_star")
    self.tsiner = 0
    super.init(self, x, y, dont_animate)
end

function TensionBar:draw()
    super.draw(self)
    Draw.setColor(1, 1, 1, 1)

    if Game.battle.encounter.banish_goal then

    self.tsiner = self.tsiner + 1 * DTMULT
    local t = math.abs(math.sin(self.tsiner / 8) * 0.5) + 0.1
    local col = Utils.mergeColor(COLORS.white, COLORS.blue, t)

    local col2 = COLORS.white
    if Game.tension >= Game.battle.encounter.banish_goal then
        col2 = col
    end

    local offset = 0
    local bar_height = (Game.battle.encounter.banish_goal / Game:getMaxTension()) * self.height
    local top_y = (offset + self.height) - bar_height
    local bottom_y = (0 + self.height) - bar_height
    local star_y = (1 + self.height) - bar_height

    Draw.setColor(col2)
    Draw.rectangle("fill", 3, top_y, (0 + self.width) - 7, 3)
    Draw.draw(self.star_sprite, (self.x) - 14, star_y - 7, 
        0,
        0.5, 0.5)
    Draw.setColor(1, 1, 1, 1)
end
end

return TensionBar
