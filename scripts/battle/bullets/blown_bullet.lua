local blown_bullet, super = Class(Bullet)

function blown_bullet:init(x, y, sprite)
    -- super.init(self, x, y, "bullets/darkspace/spr_darkshape_" .. sprite .. "_5")
    super.init(self, x, y, "bullets/darkspace/custom_mine/mine1")



    self:setScale(1, 1)

    -- Move the bullet in dir radians (0 = right, pi = left, clockwise rotation)
    -- self.physics.direction = dir
    -- Speed the bullet moves (pixels per frame at 30FPS)
    --self.speed_calc = speed


    self.grazed = true

    self.sprite:play(1 / 15, true)
    self.layer = BATTLE_LAYERS["top"]

    self:setColor(COLORS.orange)

    self.graphics.spin = 0.05 * Utils.randomSign()


    self.colormask = self:addFX(ColorMaskFX())
    self.colormask.color = { 1, 1, 1 }
    self.colormask.amount = 0

    self.dist = 0
    self.image = 0

    self.image_size = 0

    self.grazed = true

    self.light = 0

    self.collidable = false


    --  self.frames_shrink = Assets.getFrames("bullets/darkspace/spr_darkshape_" .. sprite)


    --self.normal_frames = Assets.getTexture("bullets/darkspace/spr_darkshape_" .. sprite .. "_animated_1")


    self.tracking_val = 16

    self.updateimageangle = false

    self.true_timer = 0

    self.speed_calc = 1

    self.acc = 4
    self.max_speed = 2.25
    self.speed_max_multiplier = 0.8;

    self.accel = 0.15


    self.light_recover = 0.01
    self.light_rate = 0.05
    self.speedfactor = 1

    self.ypush = 0


    self.image_alpha = 0
    self.image_speed = 0
    self.fast_timer = false
    self.fast_val = 0
    self.timer_track = 0


    self.shakeme = true
    self.xoff = 0
    self.yoff = 0
    self.alpha = 0

    self.toggle_active = false

    self.shakeme = true

    self.slow_track = true

    self.inaccurate_distance_calculation_variable = Game.battle.soul.radius_goal


    self.tracking_val2 = 1

    self.switch_value = 1
end

function blown_bullet:lengthdir_x(len, dir)
    return len * math.cos(dir)
end

function blown_bullet:lengthdir_y(len, dir)
    return len * math.sin(dir)
end

function blown_bullet:onAdd()
    Assets.playSound("snd_dark_odd", Kristal:getVolume(), 0.35 + Utils.random(0.35))
end

function blown_bullet:update()
    if self.light == 1 then
        --local bullet = self.wave:spawnBullet("GreenBlob", self.x, self.y)

        Assets.playSound("snd_explosion_mmx", 1.2, 0.8)
        Assets.playSound("ui_spooky_action", 1, 1.9)


        local boom_sprite = Sprite("effects/spr_shockwave_explosive", self.x, self.y)
        boom_sprite:setOrigin(0.5, 0.5)
        boom_sprite.layer = self.layer + 1
        boom_sprite:play(1 / 12, false, function()
            boom_sprite:remove()
        end)
        Game.battle:addChild(boom_sprite)

        for i = 1, 30 do
            -- pick a random angle around the circle
            local angle = love.math.random() * math.pi * 2
            local r = math.sqrt(love.math.random()) * 50


            local bx = self.x + math.cos(angle) * r
            local by = self.y + math.sin(angle) * r


            local bullet = self.wave:spawnBullet("eye_fade_area_denial", bx, by)
            bullet:setColor(self.color)

            bullet.physics.speed = 0
            bullet.physics.friction = 0
        end

        --[[for aa = 0, 4 do
            local angle = Utils.angle(self.x, self.y, Game.battle.soul.x, Game.battle.soul.y) - 60 + (30 * aa) + Utils.random(-5, 5)
            local speed = 1.5 + Utils.random(1.5)

            -- spawnBullet arguments: (bullet_id, x, y, angle, speed)
            local bullet =  self.wave:spawnBullet("eye_fade_area_denial", self.x, self.y)
            bullet.physics.direction = angle
            bullet.physics.speed = speed

            bullet.sprite:setScale(0.25, Utils.pick({4, -4}))
    end]]








        self:remove()
    elseif self.light > 0.90 then
    elseif self.light > 0.8 then
        self.image = 5
    elseif self.light > 0.6 then
        self.image = 4
    elseif self.light > 0.4 then
        self.image = 3
    elseif self.light > 0.2 then
        self.image = 2
    else
        self.image = 1
    end




    if (self.physics.speed > 2) then
        local afterimage = AfterImage(self.sprite, 0.3)
        afterimage.layer = self.sprite.layer - 20
        self:addChild(afterimage)
    end



    self.y = self.y + self.ypush
    self.ypush = self.ypush * 0.9

    if self.fast_timer then
        self.timer_track = self.timer_track + self.fastval
        self.fast_timer = self.fast_timer - 1
    else
        self.timer_track = self.timer_track + (1 * DTMULT)
    end


    self:setScale(self.scale_x * (1 - self.light), self.scale_y * (1 - self.light))



    if self.alpha ~= 1 then
        self.alpha = Utils.approach(self.alpha, 1, 0.025)

        if self.alpha == 1 then
            self.physics.direction = Utils.angle(self.x, self.y, Game.battle.soul.x, Game.battle.soul.y)
        end
    end



    if self.alpha == 1 then
        self:setScale(0.55, 0.55)
    else
        local scale = self.alpha + ((self.timer_track) % 2) * 0.1
        self:setScale(scale / 2, scale / 2)
    end


    if self.alpha == 1 then
        self.toggle_active = true
    end

    --[[    if self.light == 0 then
        self.sprite.alpha = 1
    else
        self.sprite.alpha = 0
    end]]

    self.dist = Utils.dist(self.x, self.y, Game.battle.soul.x, Game.battle.soul.y)
    if (self.dist < self.inaccurate_distance_calculation_variable + 8) then
        self.light = Utils.approach(self.light, 1, self.light_rate);
        self.speed_calc = Utils.approach(self.speed_calc, 0.7 + (1 - self.light),
            0.15 * self.speedfactor * self.speed_max_multiplier);
        self.image_size = 1
    else
        self.speed_calc = Utils.approach(self.speed_calc, self.max_speed * self.speed_max_multiplier,
            self.accel * self.speed_max_multiplier * (1 - self.light));
        self.light = Utils.approach(self.light, 0, self.light_recover);
    end

    self.colormask.amount = self.light


    self.true_timer = self.true_timer + (1 * DTMULT)


    if (self.tracking_val2 > 0) then
        self.tracking_val2 = Utils.approach(self.tracking_val2, 0, 0.015)
    end



    if self.toggle_active and self.tracking_val2 ~= 0 then
        if self.slow_track then
            self.physics.direction = Utils.angle(self.x, self.y, Game.battle.soul.x, Game.battle.soul.y);
            self.physics.speed = self.speed_calc
        else
            self.tracking_val = Utils.approach(self.tracking_val, 16, 0.025);


            local eff_speed = self.speed_calc * (1 + (math.sin(self.true_timer * 0.15) * 0.6))

            local hx = Game.battle.soul.x + 10
            local hy = Game.battle.soul.y + 10


            self.x = self.x + self:lengthdir_x(eff_speed * 1, self.physics.direction);
            self.y = self.y + self:lengthdir_y(eff_speed * 1, self.physics.direction);

            if self.updateimageangle then
                self.rotation = self.physics.direction
            end

            local turning_mult = 0.5 - (math.sin(self.true_timer * 0.15) * 0.5)
            local anglediff = Utils.angleDiff(self.physics.direction, Utils.angle(self.x, self.y, hx, hy))
            local turn = Utils.clamp(Utils.sign(anglediff) * self.tracking_val * turning_mult, -math.abs(anglediff),
                math.abs(anglediff))

            self.physics.direction = self.physics.direction - turn
        end
    end



    if self.shakeme then
        self.xoff = Utils.pick { -1, 0, 1 }
        self.yoff = Utils.pick { -1, 0, 1 }
    end




    super.update(self)
end

function blown_bullet:draw()
    super.draw(self)


    -- Draw.setColor(COLORS.white)
    love.graphics.setFont(Assets.getFont("main_mono"))

    if DEBUG_RENDER then
        love.graphics.print("dist:" .. tostring(self.physics.direction), 0, 30)



        love.graphics.print("x:" .. tostring(self.x), 0, 60)


        love.graphics.print("u:" .. tostring(self.y), 0, 90)


        love.graphics.print("u:" .. tostring(self.alpha), 0, 120)
    end



    --Draw.draw(self.frames_shrink[self.image], 0, 0, 0, self.image_size, self.image_size, 0, 0)

    if self.timer_track % 15 == 0 then
        self.switch_value = (self.switch_value % 2) + 1
    end
    self:setSprite("bullets/darkspace/custom_mine/mine" .. self.image .. "_" .. self.switch_value)






    love.graphics.setColor(1, 1, 1, self.image_alpha)



    love.graphics.setColor(1, 1, 1, self.alpha)

    --[[ for a = 0, 45 do
        local side = 1
        local shift = math.sin((a + self.timer_track) * 1) * (4 - (self.alpha * 4)) * side


        love.graphics.newQuad(0, a, 46, 1,  self.sprite2:getDimensions())

        Draw.draw(self.sprite2, love.graphics.newQuad(0, a, 46, 1, self.canvas:getDimensions()), (0 - 22) + shift + self.xoff, (0 - 23) + a + self.yoff)
    end]]



    --love.graphics.push("all")
    --love.graphics.setBlendMode("alpha", "premultiplied")
end

return blown_bullet
