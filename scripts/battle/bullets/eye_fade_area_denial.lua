local eye_fade_area_denial, super = Class(Bullet)

function eye_fade_area_denial:init(x, y)
    super.init(self, x, y, "bullets/darkspace/spr_blown_bullet_eye")
    --points: x1, y1, x2, y2, x3, y3


    self.damage = 120
    self:setScale(0, 0)
    self.alpha = 1
end

function eye_fade_area_denial:onAdd(parent)
    super.onAdd(self, parent)

    Game.battle.timer:tween(Utils.random(0.1, 0.4), self, { scale_x = 1, scale_y = 1, alpha = 1 }, "in-quint", function()
        self:fadeOutAndRemove(0.3)
    end)

    -- Game.battle.timer:tween(10/30, self, {scale_x=1, scale_y=1})
    -- Game.battle.timer:tween(30/30, self.physics, {speed = self.physics.speed * 4})
end

return eye_fade_area_denial
