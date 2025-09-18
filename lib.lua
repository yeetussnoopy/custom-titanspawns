local lib = {}

function lib:init()
   Utils.hook(PartyBattler, "hurt", function(orig, self, amount, exact, color, options)
        if self.chara:checkArmor("shadowmantle") and Game.battle.encounter.toggle_shadow_mantle_all_bullets then
            amount = amount * 0.5
        end
        orig(self, amount, exact, color, options)
    end)
end

function lib:postInit(new_file)
    if new_file then
        Game:setFlag("purified", 0)
        Game:setFlag("slain", 0)
    end
end

return lib
