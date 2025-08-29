local Encounter, super = Class(Encounter)

function Encounter:init()
    super.init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* From the darkness, horrors crept!\n* [color:yellow]TP[color:reset] Gain reduced outside of [color:green]???"

    self.music = "titan_spawn"
    self.background = true

    local desperate = self:addEnemy("titanspawn", 520, 130)
    table.remove(desperate.waves, 2)   

    local evolving = self:addEnemy("titanspawn", 520, 290)
    evolving:setAnimation("idle_evolving")
    table.remove(evolving.waves, 1)
    self.light_size = 48
    self.purified = false


    self.reduced_tension= true

    self.difficulty = 1

end

function Encounter:onTurnEnd() 
    self.difficulty = self.difficulty + 1
end


function Encounter:beforeStateChange(old, new) 
    if (new == "DEFENDING" or old == "CUTSCENE")and self.purified then
       -- self:explode()
            Game.battle:setState("VICTORY")
    end
end

return Encounter
