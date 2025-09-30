local Encounter, super = Class(Encounter)

function Encounter:init()
    super.init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text =
    "* From the darkness, horrors crept!\n* [color:yellow]TP[color:reset] Gain reduced outside of [color:green]???"

    self.music = "titan_spawn"
    self.background = true

    local desperate = self:addEnemy("titanspawn", 520, 130)
    table.remove(desperate.waves, 2)

    local evolving = self:addEnemy("titanspawn", 520, 290)
    evolving:setAnimation("idle_evolving")
    table.remove(evolving.waves, 1)
    self.light_size = 48
    self.purified = false



    --makes all bullets in the encounter considered for shadowmantle prevention
    self.toggle_shadow_mantle_all_bullets = true

    --set to nil for no displayable banish goal on the TP bar
    self.banish_goal = 64

    self.reduced_tension = true

    self.difficulty = 1

    --toggle smoke effect around the border
    self.toggle_smoke = true

    self.darkness_controller = nil
end

function Encounter:onTurnEnd()
    self.difficulty = self.difficulty + 1
end

function Encounter:beforeStateChange(old, new)
    if self.toggle_smoke then
        if old == "INTRO" and not self.darkness_controller then
            Game.battle.timer:after(1, function()
                self.darkness_controller = Game.battle:addChild(TitanDarknessController())
                self.darkness_controller.total_enemies = #Game.battle:getActiveEnemies()
            end)
        end
    end
    if (new == "DEFENDING" or old == "CUTSCENE") and self.purified then
        -- self:explode()
        Game.battle:setState("VICTORY")
    end

end

function Encounter:onStateChange(old, new)
     if new == "VICTORY" and self.darkness_controller and Game.battle.used_violence then
      self.darkness_controller.toggle_lessen = true
      Kristal.Console:log("dsfdsf")
    end
end
return Encounter
