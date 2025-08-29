local DarkShapeBullet, super = Class(Bullet)

function DarkShapeBullet:init(x, y, texture)
    super.init(self, x, y, texture)

    self.grazed = true

    self.light = 0
    


    self.colormask = self:addFX(ColorMaskFX())
    self.colormask.color = { 1, 1, 1 }
    self.colormask.amount = 0

    self.grazed = true

    self.tracking_val = 16

    self.updateimageangle = false

    self.true_timer = 0

    self.speed_calc = 1

    self.acc = 4
    self.max_speed = self.physics.speed
    self.speed_max_multiplier = 0.8;

    self.accel = 0.15


    self.light_recover = 0.01
    self.light_rate = 0.02
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
   -- self.alpha = 0

    self.toggle_active = false

    self.shakeme = true

    self.slow_track = true

    self.inaccurate_distance_calculation_variable = Game.battle.encounter.light_size or 43

    
end

function DarkShapeBullet:update()
    if self.light > 0.6 then
        local bullet = self.wave:spawnBullet("GreenBlob", self.x, self.y)
        bullet:setScale(0, 0)
        self:remove()
    end

    if self.fast_timer then
        self.timer_track = self.timer_track + self.fastval
        self.fast_timer = self.fast_timer - 1
    else
        self.timer_track = self.timer_track + (1 * DTMULT)
    end

    if self.alpha == 1 then
        self.toggle_active = true
    end


    self:setScale(self.scale_x * (1 - self.light), self.scale_y * (1 - self.light))

    self.dist = Utils.dist(self.x, self.y, Game.battle.soul.x, Game.battle.soul.y)
    if (self.dist < self.inaccurate_distance_calculation_variable) then
        self.light = Utils.approach(self.light, 1.01, self.light_rate);
        self.physics.speed = Utils.approach(self.physics.speed, 0.7 + (1 - self.light),
                                         0.15 * self.speedfactor * self.speed_max_multiplier);
        self.image_size = 1
    else
        self.physics.speed = Utils.approach(self.physics.speed, self.max_speed * self.speed_max_multiplier, self.accel * self.speed_max_multiplier * (1 - self.light));
        self.light = Utils.approach(self.light, 0, self.light_recover);
    end

    self.colormask.amount = self.light

    super.update(self)
end

function DarkShapeBullet:draw()
        love.graphics.setFont(Assets.getFont("main_mono"))

    love.graphics.print("light:" .. tostring(self.light), 0, 30)

    super.draw(self)
end

return DarkShapeBullet
