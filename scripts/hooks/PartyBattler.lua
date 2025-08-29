local PartyBattler, super = Class(PartyBattler)

function PartyBattler:hurt(amount, exact, color, options)

  if self.chara:checkArmor("shadowmantle") then
        amount = amount * 0.5
        Assets.playSound("alert")
    end
    super.hurt(self, amount, exact, color, options)   
end

return PartyBattler
