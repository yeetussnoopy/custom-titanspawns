local Darkshape, super = Class(Bullet)

function Darkshape:init(x, y)
    super.init(self, x, y, "bullets/darkspace/spr_darkshape_desperate_animated") -- Replace with your sprite path
    self:setScale(2, 2)
    self.damage = 120
    self.destroy_on_hit = false
    self.remove_offscreen = false

    self.phase = "spawn"
    self.phase_timer = -35

    self.light = 0
    self.light_rate = 0.0075
    self.light_recover = 0.0025
    self.light_threshold = 0
    self.light_damage = 0

    self.alpha = 0.5
    self.image_s = 0.5
    self.image_d = 0
    self.image_max = 2
    self.image_min = 0
    self.big_shrink = 1

    self.speed_max = 1.25
    self.pushback_radius = 40
    self.x_goal = x
    self.y_goal = y
    self.box_distance = 300
    self.box_angle = 90

    self.timer = 0
    self.true_timer = 0
    self.fast_timer = 0
    self.fastval = 2

    self.death_dir = 0
    self.deathrattle = nil
    self.shakeme = false

    Game.battle.timer:tween(0.5, self, { box_distance = 100 }, "out-quad")

    if love.math.random(0, 1) == 1 then
        Game.battle.timer:tween(0.5, self, { box_angle = 0 }, "out-quad")
    else
        Game.battle.timer:tween(0.5, self, { box_angle = 180 }, "out-quad")
    end

    self.phase = "stalk"

    self:explode()
end

function Darkshape:update()
    super.update(self)

    if self.fast_timer > 0 then
        self.timer = self.timer + self.fastval
        self.fast_timer = self.fast_timer - 1 * DTMULT
    else
        self.timer = self.timer + 1 * DTMULT
    end
    self.true_timer = self.true_timer + 1 * DTMULT

    if love.math.random(1, 21) == 1 then
        self.fast_timer = 10 + love.math.random(0, 6)
    end

    if self.alpha < 1 then
        self.alpha = math.min(self.alpha + 0.05, 1)
        if self.alpha == 1 then
            local soul = Game.battle.soul
            if soul then
                self.physics.direction = Utils.angle(self.x, self.y, soul.x, soul.y)
            end
        end
    end

    if self.alpha == 1 then
        self.scale_x = self.alpha * 2
        self.scale_y = self.alpha * 2
    else
        self.scale_x = self.alpha + ((self.timer % 2) * 0.1) * 2
        self.scale_y = self.alpha + ((self.timer % 2) * 0.1) * 2
    end

    if self.light < 1 then
        local arena = Game.battle.arena
        self.x_goal = arena.x + math.cos(math.rad(self.box_angle)) * self.box_distance
        self.y_goal = arena.y + math.sin(math.rad(self.box_angle)) * self.box_distance

        self.x = self.x_goal + math.sin(self.true_timer * 0.1) * 4
        self.y = self.y_goal + math.cos(self.true_timer * 0.065) * 4

        self:chaseHeart()
    end

    if self.phase == "sudden reposition" then
        self:updateSuddenReposition()
    elseif self.phase == "stalk" then
        self:updateStalk()
    elseif self.phase == "encircle" then
        self:updateEncircle()
    elseif self.phase == "death" then
        self:updateDeath()
    end

    self.image_d = Utils.clamp(self.image_d, self.image_min, self.image_max)
    self.image_d = self.image_d + self.image_s
    if self.image_d >= self.image_max then
        self.image_d = self.image_d - (self.image_max - self.image_min)
    end
    if self.image_d < 0 then
        self.image_d = 0
        self.image_s = 0
    end

    self.light_damage = math.max(self.light_damage - 0.04, 0)
end

function Darkshape:chaseHeart()
    local soul = Game.battle.soul
    if not soul then return end

    local hx = soul.x 
    local hy = soul.y 
    if self.alpha == 1 and self.light < 1 and self.phase == "stalk" then
        local dist = Utils.dist(self.x, self.y, hx, hy)

        if dist < 50 then 
            self.light = math.min(self.light + self.light_rate, 1)
            self.light_threshold = math.min(self.light_threshold + self.light_rate, 1)

            if (self.phase_timer % 3) == 0 then
                self.light_damage = 0.12
            end

            if self.light >= 1 then
                self:beginDeath()
            end

            if self.light_threshold > 0.5 and self.light < 1 then
                self:beginReposition()
            end

            if love.math.random(1, 3) == 1 then
                self:spawnFleeParticle()
            end
        end
    end
end

function Darkshape:updateSuddenReposition()
    self.phase_timer = self.phase_timer + 1 * DTMULT

    if self.phase_timer == 15 then
        Game.battle.timer:tween(0.33, self, { box_distance = 180 }, "in-quad")
    end

    if self.phase_timer == 25 then
        Game.battle.timer:tween(1.07, self, { box_distance = 100 }, "out-quad")

        local angle_change = love.math.random(0, 1) == 1 and 240 or -240
        Game.battle.timer:tween(1.07, self, { box_angle = self.box_angle + angle_change }, "out-quad")
    end

    if self.phase_timer > 25 and self.phase_timer < 47 then
        -- Screen shake would go here
    end

    if ((self.phase_timer - 25) % 4) == 0 and (self.phase_timer - 25) > 4 and (self.phase_timer - 25) < 28 then
        self:fireTrailBullet()
    end

    if (self.phase_timer - 25) == 32 then
        self.image_s = 0.25
        self.image_d = 0
        self.image_max = 4
        self.image_min = 2
        self.phase_timer = 0
        self.phase = "stalk"
    end
end

function Darkshape:updateStalk()
    self.phase_timer = self.phase_timer + 1 * DTMULT

    if self.phase_timer == -15 then
        self.image_s = 0.25
        self.image_d = 0
        self.image_max = 4
        self.image_min = 2
        self.phase_timer = 15
    end

    if self.phase_timer == 15 then
        self.shakeme = true
    end

    if self.phase_timer == 40 or self.phase_timer == 60 or self.phase_timer == 80 then
        self:fireBulletSpread(self.phase_timer == 60 and 5 or 3)
    end

    if self.phase_timer == 50 or self.phase_timer == 70 or self.phase_timer == 90 then
        self.image_d = 2
        self.image_s = 0.25
        self.image_max = 4
        self.image_min = 2
    end

    if self.phase_timer == 120 then
        self.phase_timer = 0
        self.phase = "sudden reposition"
    end
end

function Darkshape:updateEncircle()
    self.phase_timer = self.phase_timer + 1 * DTMULT

    if self.phase_timer == 1 then
        self.light_threshold = self.light_threshold * 0.5
        local angle_change = love.math.random(0, 1) == 1 and -120 or 120
        Game.battle.timer:tween(0.8, self, { box_angle = self.box_angle + angle_change }, "out-quad")
    end

    if self.phase_timer == 40 then
        self.phase_timer = 0
        self.phase = "stalk"
    end
end

function Darkshape:updateDeath()
    self.phase_timer = self.phase_timer + 1 * DTMULT
    self.big_shrink = math.max(self.big_shrink - 0.020833333333333332, 0)

    self:spawnDeathParticle()

    if self.phase_timer == 16 or self.phase_timer == 32 then
        local move_dist = 50
        self.death_dir = self.death_dir + (love.math.random(0, 1) == 1 and -100 or 100)
        self:slideTo(
            self.x + math.cos(math.rad(self.death_dir)) * move_dist,
            self.y + math.sin(math.rad(self.death_dir)) * move_dist,
            0.4, "out-quad"
        )
        self:spawnExplosion(false)
    end

    if self.phase_timer == 48 then
        self:spawnExplosion(true)
        self:remove()
    end
end

function Darkshape:fireBulletSpread(count)
    self.shakeme = false
    self.image_min = 0
    self.image_max = 4
    self.image_d = 2.99
    self.image_s = -0.5

    local soul = Game.battle.soul
    if not soul then return end

    local base_angle = Utils.angle(self.x, self.y, soul.x, soul.y)

    for i = 0, count - 1 do
        local angle = base_angle - (math.rad(15) * (count - 1)) + (math.rad(30) * i)
        local speed_mod = math.abs(i - (count * 0.5)) * 1.5

        local bullet = self.wave:spawnBullet("smallbullet", self.x, self.y, angle, 3)
        if bullet then
            -- bullet.physics.direction = math.rad(angle)
            bullet.physics.speed = 8 - speed_mod
            bullet:setSprite("bullets/darkspace/spr_darkshape_spawnbullet")
            bullet.graphics.spin = 0.2

            Game.battle.timer:tween(0.4, bullet.physics, { speed = 5 - (speed_mod * 0.65) }, "linear")



            bullet.scale_x = 2
            bullet.scale_y = 2

            Game.battle.timer:tween(0.4, bullet, { scale_x = 0.75 }, "linear")
            Game.battle.timer:tween(0.4, bullet, { scale_y = 0.75 }, "linear")
        end
    end
end

function Darkshape:fireTrailBullet()
    local angle = Utils.angle(self.x, self.y, self.last_x or self.x, self.last_y or self.y)
    --[[local bullet = self.wave:spawnBullet("smallbullet", self.x, self.y)
    if bullet then
        bullet.physics.direction = angle
        bullet.physics.speed = 4
        Game.battle.timer:tween(0.4, bullet.physics, { speed = 2 }, "linear")

        bullet.scale_x = 2
        bullet.scale_y = 2
        Game.battle.timer:tween(0.4, bullet, { scale_x = 1.25 }, "linear")
        Game.battle.timer:tween(0.4, bullet, { scale_y = 1.25 }, "linear")
    end]]


    local selection = { { "", false, 2.25, "redshape" }, { "default", true, 3, "darkspawn" }, { "mine", true, 2.25, "blown_bullet" } }


    local list = Utils.pick(selection)

    local spawn = self.wave:spawnBullet(list[4], self.x,
        self.y, list[1])

    spawn.max_speed = list[3]
    spawn.slow_track = list[2]
    self.last_x = self.x
    self.last_y = self.y
end



function Darkshape:spawnFleeParticle()
end

function Darkshape:spawnDeathParticle()
end

function Darkshape:spawnExplosion(final)
end

function Darkshape:beginDeath()
    self.shakeme = false
    local arena = Game.battle.arena
    self.death_dir = Utils.angle(arena.x, arena.y, self.x, self.y)

    local move_dist = 100
    self:slideTo(
        self.x + math.cos(math.rad(self.death_dir)) * move_dist,
        self.y + math.sin(math.rad(self.death_dir)) * move_dist,
        0.53, "out-quad"
    )

    self.death_dir = self.death_dir + (love.math.random(0, 1) == 1 and -100 or 100)
    self.phase_timer = 0
    self.phase = "death"
end

function Darkshape:beginReposition()
    self.shakeme = false
    Game.battle.timer:tween(0.5, self, { box_distance = 220 }, "out-quad")

    self.light_threshold = 0
    self.phase_timer = 0
    self.phase = "sudden reposition"
end

function Darkshape:draw()
    super.draw(self)


    love.graphics.setFont(Assets.getFont("main_mono"))

    if DEBUG_RENDER then
        love.graphics.print("box_distance:" .. tostring(self.box_angle), 0, 15)
        love.graphics.print("box_angle:" .. tostring(self.box_distance), 0, 30)
        love.graphics.print(
            "base_angle:" .. tostring(Utils.angle(self.x, self.y, Game.battle.soul.x, Game.battle.soul.y)), 0, 45)
        love.graphics.print("light:" .. tostring(self.light), 0, 65)

        love.graphics.print("phase:" .. tostring(self.phase), 0, 85)
    end
end

return Darkshape
