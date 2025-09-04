local TPBlob, super = Class(Bullet)

function TPBlob:init(x, y)
    super.init(self, x, y, "effects/spr_darkshape_transform")


    self:setColor(COLORS.white)
    self.image_speed = 0.5;
    self.size = 2;
    self.damage = 90;
    self.prime_speed = 4;
    self.max_speed = 5;
    self.acc = 20;
    self.active_move = false

    self.sprite:play(1 / 15, true)

    self.grazed = true
    self.layer = BATTLE_LAYERS["top"]
    self.tension_amount = 1
    self:setScale(1, 1)
end

function TPBlob:onAdd(parent)
    super.onAdd(self, parent)


    Assets.playSound("noise")


    self.physics.direction = Utils.angle(self.x, self.y, Game.battle.soul.x, Game.battle.soul.y) + math.rad(180)
    self.physics.speed = self.prime_speed


    Game.battle.timer:tween(20 / 30, self, { scale_x = 0.4, scale_y = 0.4, color = { 1, 1, 0 } }, "linear", function()
        self.active_move = true
    end)
end

function TPBlob:update()
    --Kristal.Console:log("timer: "..tostring(self.wave.timer))
    self.physics.speed = self.physics.speed * 0.85;
    if self.active_move then
        local accel = self.acc / Utils.dist(self.x, self.y, Game.battle.soul.x + 10, Game.battle.soul.y + 10);
        self.physics.direction = Utils.angle(self.x, self.y, Game.battle.soul.x, Game.battle.soul.y);
        self.physics.speed = Utils.approach(self.physics.speed, self.max_speed, accel)
    end

    --[[if (Utils.dist(self.x, self.y, Game.battle.soul.x + 10, Game.battle.soul.y + 10) <= 20 and self.active_move) then
        self:remove()
    end]]

    super.update(self)
end

function TPBlob:onCollide()
    Assets.playSound("swallow", self.size * 0.2)
    Assets.playSound("snd_eye_telegraph", self.size * 0.2, 2)
    self:flashsparestars()
    Game.battle.tension_bar:addChild(TensionBarGlow())
    Game:giveTension(self.tension_amount)
    self:finishexplosion()
    self:remove()
end

function TPBlob:finishexplosion()
    local boom_sprite = Sprite("effects/spr_finisher_explosion", self.x, self.y)
    boom_sprite:setOrigin(0.5, 0.5)
    boom_sprite:setScale(0.0625, 0.0625)
    boom_sprite:setFrame(3)
    Game.battle.timer:tween(4/30, boom_sprite, {scale_x = 0.0625 * 3, scale_y = 0.0625 * 3})
    boom_sprite.layer = self.layer  +1
    boom_sprite:setColor(COLORS.yellow)
    boom_sprite:play(1 / 30, false, function()
        boom_sprite:remove()
    end)
    Game.battle:addChild(boom_sprite)
    --[[Game.battle.timer:after(5/30, function ()
        boom_sprite:remove()
    end)]]

end

function TPBlob:flashsparestars()
    for i = 1, (3 + love.math.random(0, 2)) do
        local bar = Game.battle.tension_bar

        local x = love.math.random(0, 25)
        local y = 40 + love.math.random(0, 160)

        local star = bar:addChild(Sprite("effects/spare/star", x, y))
        star:setOrigin(0.5, 0.5)
        local dur = 10 + love.math.random(0, 5)

        star:play(5 / dur)
        star.layer = 999
        star.alpha = 1

        star.physics = {
            speed = 3 + love.math.random() * 3,
            direction = -math.rad(90)
        }
        Game.battle.timer:tween(dur / 30, star.physics, { speed = 0 }, "linear")
        Game.battle.timer:tween(dur / 30, star, { alpha = 0.25 }, "linear", function()
            star:remove()
        end)
    end
end

return TPBlob
