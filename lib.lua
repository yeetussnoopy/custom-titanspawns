local lib = {}

function lib:init()

--[[     Utils.hook(PartyBattler, "hurt", function(orig, self,amount, exact, target, swoon, options)
        Kristal.Console:log("hooked")
        orig(self, amount, exact, target, swoon, options)
    end)


   Utils.hook(PartyBattler, "hurt", function(orig, self, amount, exact, color, options)
        if self.chara:checkArmor("shadowmantle") and options["dark_bullet"] then
            amount = amount * 0.66
        end
        orig(self, amount, exact, color, options)
    end)]]
end

function lib:postInit(new_file)
    if new_file then
        Game:setFlag("purified", 0)
        Game:setFlag("slain", 0)
    end
end

return lib
