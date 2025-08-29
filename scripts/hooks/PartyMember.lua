local PartyMember, super = Class(PartyMember)

function PartyMember:drawPowerStat(index, x, y, menu)
        super.drawPowerStat(self)

    if self.has_act then
    if index == 1 and Game:getFlag("slain") > 0 then
        love.graphics.print("*", x - 26, y)

        love.graphics.print("Slain", x, y)
        love.graphics.print(Game:getFlag("slain"), x + 130, y)

        return true
    elseif index == 2 and Game:getFlag("purified") > 0 then
        love.graphics.print("*", x - 26, y)

        love.graphics.print("Purify", x, y)
        love.graphics.print(Game:getFlag("purified"), x + 130, y)

        return true
    end
end

end

return PartyMember
