local Basic, super = Class(Wave)
function Basic:init()
    super:init(self)
    self.time = 20
    self.difficulty = Game.battle.encounter.difficulty or 3
end

function Basic:lengthdir_x(len, dir)
    return len * math.cos(dir)
end

function Basic:lengthdir_y(len, dir)
    return len * math.sin(dir)
end

function Basic:onStart()
    Game.battle.soul.toggle = true


    local sound = Assets.playSound("snd_spawn_attack")
    sound:setLooping(true)


    if self.difficulty >= 2 then
        self.timer:everyInstant(15 / 3, function()
            local tempdir = Utils.random(360);
            local tempdist = 150 + Utils.random(50);
            local arena = Game.battle.arena

            local spawn = self:spawnBullet("redshape", arena.x + self:lengthdir_x(tempdist, tempdir),
                arena.y + self:lengthdir_y(tempdist, tempdir))
            self.skip_spawn = true
        end)
    end

    -- Every 0.33 seconds...
    self.timer:everyInstant(self:getEnemyRatio(), function()
        local tempdir = Utils.random(360);
        local tempdist = 150 + Utils.random(50);
        local selection = { { "evolving", false, 2.25, "darkspawn" }, { "evolving", true, 3, "darkspawn" } }

        if self.difficulty >= 2 then
            table.insert(selection, { "mine", true, 2.25, "blown_bullet" })
        end
        local list = Utils.pick(selection)

        local arena = Game.battle.arena
        local spawn = self:spawnBullet(list[4], arena.x + self:lengthdir_x(tempdist, tempdir),
            arena.y + self:lengthdir_y(tempdist, tempdir), list[1])
        spawn.max_speed = list[3]
        spawn.yeetus_mode = list[2]
        spawn.tension_amount = 2

        spawn.remove_offscreen = false
    end)
end

function Basic:getEnemyRatio()
    local enemies = #Game.battle:getActiveEnemies()
    if enemies <= 1 then
        return 4 / 3
    elseif enemies == 2 then
        return 7 / 3
    elseif enemies >= 3 then
        return 15 / 3
    end
end

function Basic:update()
    -- Code here gets called every frame

    super.update(self)
end

function Basic:onEnd()
    Assets.stopSound("snd_spawn_attack")
end

return Basic
