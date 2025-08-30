local RedShoot, super = Class(Wave)
function RedShoot:init()
    super.init(self)
    self.time = 15
    self.difficulty = Game.battle.encounter.difficulty or 3
end

function RedShoot:lengthdir_x(len, dir)
    return len * math.cos(dir)
end

function RedShoot:lengthdir_y(len, dir)
    return len * math.sin(dir)
end

function RedShoot:onStart()
    Game.battle.soul.toggle = true

    local sound = Assets.playSound("snd_spawn_attack")
    sound:setLooping(true)


    local attacker = Game.battle.enemies[1]
    --Assets.playSound("motor_swing_down")
    Assets.playSound("boost", 1, 0.5)

    local afterimage = Game.battle:addChild(AfterImage(attacker.sprite, 1, 0.1))
    afterimage.layer = Game.battle.tension_bar.layer + 1
    afterimage:addFX(ColorMaskFX({ 1, 0, 0 }, 1))

    attacker:setColor(COLORS.red)

    if self.difficulty >= 2 then
        self.timer:everyInstant(7 / 3, function()
            local tempdir = Utils.random(360);
            local tempdist = 150 + Utils.random(50);
            local list = Utils.pick({ { "desperate", false, 3 }, { "desperate", true, 3 } })



            local arena = Game.battle.arena
            local spawn = self:spawnBullet("darkspawn", arena.x + self:lengthdir_x(tempdist, tempdir),
                arena.y + self:lengthdir_y(tempdist, tempdir), list[1])
            spawn.max_speed = list[3]
            spawn.slow_track = list[2]

            spawn.remove_offscreen = false
        end)
    end

    -- Every 0.33 seconds...
    self.timer:everyInstant(12 / 3, function()
        local tempdir = Utils.random(360);
        local tempdist = 150 + Utils.random(50);

        local arena = Game.battle.arena

        local x, y = attacker:getRelativePos(attacker.width / 2, attacker.height / 2)



        self.timer:tween(0.4, attacker, { scale_y = 3 }, "out-quad", function()
            Assets.playSound("snd_spawn_weaker", 1, 1.8)
            attacker:setSprite("spr_darkshape_desperate_animated_1")
            attacker:shake(3)
            local spawn = self:spawnBullet("redshape", x, y)
            spawn.physics.direction = Utils.angle(self.x, self.y, Game.battle.soul.x + 10, Game.battle.soul.y + 10)
            spawn.sprite.rotation = spawn.physics.direction
            spawn.max_speed = 9
            spawn.skip_spawn = true
            spawn.speed_max_multiplier = 0.8
            self.timer:tween(0.4, attacker, { scale_y = 2 }, "in-quad", function()
                attacker:setAnimation("idle_desperate")
            end)
        end)
    end)
end

function RedShoot:getEnemyRatio()
    local enemies = #Game.battle:getActiveEnemies()
    if enemies <= 1 then
        return 12 / 3
    elseif enemies == 2 then
        return 15 / 3
    elseif enemies >= 3 then
        return 15 / 3
    end
end

function RedShoot:update()
    -- Code here gets called every frame

    super.update(self)
end

function RedShoot:onEnd()
    local attacker = Game.battle.enemies[1]
    --Assets.playSound("motor_swing_down")

    local afterimage = Game.battle:addChild(AfterImage(attacker.sprite, 1, 0.1))
    afterimage.layer = Game.battle.tension_bar.layer + 1
    afterimage:addFX(ColorMaskFX({ 1, 0, 0 }, 1))

    attacker:setColor(COLORS.white)

    Assets.stopSound("snd_spawn_attack")
end

return RedShoot
