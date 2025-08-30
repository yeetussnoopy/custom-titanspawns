local RedShape, super = Class(Bullet)

function RedShape:init(x, y)
    super.init(self, x, y, "bullets/darkspace/spr_darkshape_red")


    self.darkshape_red = Assets.getTexture("bullets/darkspace/spr_darkshape_red")
    self.darkshape_eye = Assets.getTexture("bullets/darkspace/spr_darkshape_eye")
    self.darkshape_iris = Assets.getTexture("bullets/darkspace/spr_darkshape_iris")


    self.darkshape_eye = Sprite("bullets/darkspace/spr_darkshape_eye")
    self:addChild(self.darkshape_eye)

    -- self:setScale(1, 1)

    -- Move the bullet in dir radians (0 = right, pi = left, clockwise rotation)
    -- self.physics.direction = dir
    -- Speed the bullet moves (pixels per frame at 30FPS)
    --self.speed_calc = speed

    self.sprite:setRotationOrigin(0.5, 0.5)

    self.grazed = true

    --self.sprite.alpha = 0
    self.light = 0
    self.tracking_val2 = 1
    self.destroy_on_hit = false
    self.image_angle = 0
    self.image_size = 1
    self.true_timer = 0

    self.alpha = 0


    self.light_recover = 0.01
    self.light_rate = 0.05

    self.acc = 4
    self.max_speed = 2.25 * 1.5
    self.speed_max_multiplier = 1;

    self.inaccurate_distance_calculation_variable = Game.battle.soul.radius_goal

    self.alpha = 0
    self.toggle_active = false

    self.skip_spawn = false

    self.rate_spawn = 0.025
 


    --self:setScale(5, 5)
end

function RedShape:lengthdir_x(len, dir)
    return len * math.cos(dir)
end

function RedShape:lengthdir_y(len, dir)
    return len * math.sin(dir)
end

function RedShape:angle_lerp(arg0, arg1, arg2)
    local _diff = Utils.angleDiff(arg1, arg0)
    return arg0 + Utils.lerp(0, _diff, arg2)
end

function RedShape:onAdd()
    Assets.playSound("snd_dark_odd", Kristal:getVolume(), 0.35 + Utils.random(0.35))
end

function RedShape:update()
    super.update(self)

    if self.skip_spawn then
        self.rate_spawn = 0.34
    end


    if self.alpha ~= 1 then
        self.alpha = Utils.approach(self.alpha, 1,  self.rate_spawn)

        if self.alpha == 1 then
            self.physics.direction = Utils.angle(self.x, self.y, Game.battle.soul.x, Game.battle.soul.y)
        end
    end






    self.sprite.rotation = self.sprite.rotation + math.rad(2.8125);

    if (self.tracking_val2 > 0) then
        self.tracking_val2 = Utils.approach(self.tracking_val2, 0, 0.00875)
    end

    if (self.physics.speed > 2) then
        local afterimage = AfterImage(self.sprite, 0.3)
        afterimage.layer = self.sprite.layer - 20
        self:addChild(afterimage)
    end


    if self.alpha == 1 then
        self:setScale(self.alpha, self.alpha)
        self.toggle_active = true
    else
        local scale = self.alpha + ((self.true_timer) % 2) * 0.1
        self:setScale(scale, scale)
    end


    self.true_timer = self.true_timer + (1 * DTMULT)
    -- self.sprite.rotation = self.true_timer * 0.05


    if self.toggle_active  then
        self.dist = Utils.dist(self.x, self.y, Game.battle.soul.x + 10, Game.battle.soul.y + 10)
        if (self.dist < self.inaccurate_distance_calculation_variable + 8) then
            --self.light = Utils.approach(self.light, 1, self.light_rate);
            self.physics.speed = Utils.approach(self.physics.speed, self.max_speed * self.speed_max_multiplier * 0.5,
                self.physics.speed * 0.25)
        else
            self.physics.speed = Utils.approach(self.physics.speed, self.max_speed * self.speed_max_multiplier,
                self.acc * self.speed_max_multiplier * (1 - self.light))
            --self.light = Utils.approach(self.light, 0, self.light_recover);
        end
    end

    if (self.tracking_val2 > 0) then
        self.physics.direction = self:angle_lerp(self.physics.direction,
            Utils.angle(self.x, self.y, Game.battle.soul.x + 10, Game.battle.soul.y + 10), self.tracking_val2 * 0.3);
    end
end

function RedShape:draw()
    super.draw(self)


    if DEBUG_RENDER then
        love.graphics.setFont(Assets.getFont("main_mono"))

        love.graphics.print("dist:" .. tostring(self.physics.direction), 0, 30)



        love.graphics.print("x:" .. tostring(self.x), 0, 60)


        love.graphics.print("u:" .. tostring(self.y), 0, 90)


        love.graphics.print("speed:" .. tostring(self.physics.speed), 0, 120)
    end



    love.graphics.setColor(1, 1, 1, 1)
    local hdir = Utils.angle(self.x, self.y, Game.battle.soul.x + 10, Game.battle.soul.y + 10)
    Draw.draw(self.darkshape_iris, 23 + self:lengthdir_x(2, hdir), 23 + self:lengthdir_y(2, hdir) + 1, 0, 1, 1, 0, 0)

    love.graphics.setColor(1, 1, 1, 1)
end


return RedShape
