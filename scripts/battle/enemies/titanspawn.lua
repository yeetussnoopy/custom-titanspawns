local TitanSpawn, super = Class(EnemyBattler)

function TitanSpawn:init()
    super.init(self)

    self.name = "Titan Spawn"
    self:setActor("titanspawn")

    self.max_health = 3000
    self.health = 3000
    self.attack = 18
    self.defense = 0
    self.money = 0

    self.disable_mercy = true
    self.tired = false

    self.waves = {
        "customredshapeshoot",
        "darkspawn_test",
    }

    --self.check = { "AT 30 DF 200\nA shard of fear. Appears in places of deep dark.", "Expose it to LIGHT... and gather COURAGE to gain TP.", "Then, \"[color:yellow]BANISH[color:reset]\" it!" }

    self.text = {
        "* You hear your heart beating in your ears.",
        "* When did you start being yourself?",
        "* It sputtered in a voice like crushed glass.",
        -- "* Ralsei mutters to himself to stay calm.",
        "* Smells like adrenaline."
    }

    self:registerAct("Brighten", "Powerup\nlight", "all", 4)

    self.banish_amt =  64

    self:registerAct("Banish", "Defeat\nEnemy", nil,  self.banish_amt)

    self.dialogue_override = nil
    self.t_siner = 0

    self.tired_percentage = -1
    self.can_freeze = false

    self.toggle_slain_message = true
end

function TitanSpawn:getGrazeTension()
    return 0
end

function TitanSpawn:update()
    super.update(self)
    if (Game.battle.state == "MENUSELECT") and (Game.tension >=  self.banish_amt) then
        self.t_siner = self.t_siner + (1 * DTMULT)
        if Game.battle.menu_items[3] then
            if Game.battle.menu_items[3].name == "Banish" then
                Game.battle.menu_items[3].color =
                    function()
                        return (Utils.mergeColor(COLORS.yellow, COLORS.white, 0.5 + (math.sin(self.t_siner / 4) * 0.5)))
                    end
            end
        end
    end
end

function TitanSpawn:isXActionShort(battler)
    return true
end

function TitanSpawn:hurt(amount, battler, on_defeat, color, show_status, attacked)
    if battler.chara:checkWeapon("blackshard") or battler.chara:checkWeapon("twistedswd") then
        amount = amount * 10
    end
    super.hurt(self, amount, battler, on_defeat, color, show_status, attacked)
end

function TitanSpawn:originalHurt()
    if self.sprite.sprite == "titanspawn_original_idle/spr_titan_spawn_idle" then
        self:toggleOverlay(true)
        self.overlay_sprite:setSprite("titanspawn_original_idle/spr_titan_spawn_hurt")
    end
end

function TitanSpawn:onHurt(damage, battler)
    super.onHurt(self)
    self:originalHurt()

    Assets.playSound("snd_spawn_weaker")


    self.sprite:addFX(ShaderFX("wave", {
        ["wave_sine"] = function() return Kristal.getTime() * 30 end,
        ["wave_mag"] = 2,
        ["wave_height"] = 0.7,
        ["texsize"] = { SCREEN_WIDTH, SCREEN_HEIGHT }
    }), "wave")


    self.sprite:addFX(ShaderFX("wave", {
        ["wave_sine"] = function() return Kristal.getTime() * 30 end,
        ["wave_mag"] = 1,
        ["wave_height"] = 2,
        ["texsize"] = { SCREEN_WIDTH, SCREEN_HEIGHT }
    }), "wave")

    Game.battle.timer:after(1.2, function()
        self.sprite:removeFX("wave")
        self.sprite:removeFX("wave")
    end)
end

function TitanSpawn:onTurnEnd()
    Game.battle.encounter.light_size = 48
end

function TitanSpawn:getEncounterText()
    if (Game.tension >=  self.banish_amt) then
        return "* The atmosphere feels tense...\n* (You can use [color:yellow]BANISH[color:reset]!)"
    end
    return super.getEncounterText(self)
end

function TitanSpawn:onShortAct(battler, name)
    if name == "Standard" then
        return "* " .. battler.chara:getName() .. " tried to ACT, but failed!"
    end
    return nil
end

function TitanSpawn:onAct(battler, name)
    
    if name == "Brighten" then
        battler:flash()
        Game.battle.timer:after(7 / 30, function()
            Assets.playSound("boost")
            battler:flash()

            for _, chara in ipairs(Game.battle.party) do
                chara:flash()
            end
            local bx, by = Game.battle:getSoulLocation()
            local soul = Sprite("effects/soulshine", bx, by)
            soul:play(1 / 30, false, function() soul:remove() end)
            soul:setOrigin(0.25, 0.25)
            soul:setScale(2, 2)
            Game.battle:addChild(soul)
        end)

        Game.battle.encounter.light_size = 63

        return "* " .. battler.chara:getName() .. "'s SOUL shone brighter!"
    elseif name == "Banish" then
        battler:setAnimation("act")

        Game.battle:startCutscene(function(cutscene)
            cutscene:text("* " .. battler.chara:getName() .. "'s SOUL emitted a brilliant light!")
            battler:flash()
            cutscene:playSound("revival")

            cutscene:playSound("snd_great_shine", 1, 1.2)

            local bx, by = Game.battle:getSoulLocation()

            local soul = Game.battle:addChild(purifyevent(bx + 20, by + 10))
            soul.color = Game:getPartyMember(Game.party[1].id).soul_color or { 1, 0, 0 }
            soul.layer = 501
            --  soul.graphics.fade = 0.20
            --soul.graphics.fade_to = 0

            local flash_parts = {}
            local flash_part_total = 20
            local flash_part_grow_factor = 0.5
            for i = 1, flash_part_total - 1 do
                -- width is 1px for better scaling
                local part = Rectangle(bx + 20, 0, 1, SCREEN_HEIGHT)
                part:setOrigin(0.5, 0)
                part.layer = soul.layer - i
                part:setColor(1, 1, 1, -(i / flash_part_total))
                part.graphics.fade = flash_part_grow_factor / 16
                part.graphics.fade_to = math.huge
                part.scale_x = i * i * 2
                part.graphics.grow_x = flash_part_grow_factor * i * 2
                table.insert(flash_parts, part)
                Game.battle:addChild(part)
            end

            local rect = nil

            local function fade(step, color)
                rect = Rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                rect:setParallax(0, 0)
                rect:setColor(color)
                rect.layer = soul.layer + 1
                rect.alpha = 0
                rect.graphics.fade = step
                rect.graphics.fade_to = 1
                Game.battle:addChild(rect)
                cutscene:wait(1 / step / 45)
            end

            cutscene:wait(50 / 30)

            -- soul:remove()
            fade(0.04, { 1, 1, 1 })
            for _, enemy in ipairs(Game.battle.enemies) do
                enemy.alpha = 0
            end
            cutscene:wait(20 / 30)
            for _, part in ipairs(flash_parts) do
                part:remove()
            end

            rect.graphics.fade = 0.02
            rect.graphics.fade_to = 0


            local wait = function() return soul.t > 540 end
            cutscene:wait(wait)

            Game:addFlag("purified", #Game.battle.enemies)
            for _, enemy in ipairs(Game.battle.enemies) do
                cutscene:playSound("spare")
                enemy:recruitMessage("purified")
            end

            Game.battle.encounter.purified = true
        end)

        return
    elseif name == "Standard" then
        Game.battle:startActCutscene(function(cutscene)
            cutscene:text("* " ..
                battler.chara:getName() ..
                " tried to \"[color:yellow]ACT[color:reset]\"...\n* But, the enemy couldn't understand!")
        end)
        return

    elseif name == "Check" then
        if Game:getTension() >= self.banish_amt then
            return {"* TITAN SPAWN - AT 30 DEF 200\n* A shard of fear. Appears in\nplaces of deep dark.", "* The atmosphere feels tense...\n* (You can use \"[color:yellow]BANISH[color:reset]\"!)"}
        else
            return { "* TITAN SPAWN - AT 30 DF 200\n* A shard of fear. Appears in\nplaces of deep dark.", "Expose it to LIGHT... and gather COURAGE to gain TP.", "Then, \"[color:yellow]BANISH[color:reset]\" it!" }
    end
end
    return super:onAct(self, battler, name)
end

function TitanSpawn:onDefeat(damage, battler)
    self:onDefeatFatal()
end

function TitanSpawn:getSpareText(battler, success)
    return "* But, it was not something that\ncan understand MERCY."
end

function TitanSpawn:onDefeatFatal(damage, battler)
    super.onDefeatFatal(self, damage, battler)
    Game:addFlag("slain", 1)
    if self.toggle_slain_message then
    self:recruitMessage("slain")
    end
    if self.sprite.sprite == "titanspawn_original_idle/spr_titan_spawn_idle" then
        self:setSprite("titanspawn_original_idle/spr_titan_spawn_hurt")
    end
end

function TitanSpawn:freeze()
    self:onDefeat()
end

return TitanSpawn
