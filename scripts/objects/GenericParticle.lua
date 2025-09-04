---@class GenericParticle : Object
local GenericParticle, super = Class(Object)

function GenericParticle:init(x, y)
    super.init(self, x, y)


    self:addChild(Sprite("effects/spr_pixel_white"))

    self.fade_rate = 0
    self.shrink_rate = 0
    self.acceleration_type = 0
    self.acceleration_rate = 0
    self.acceleration_goal = 0

    self:setScale(1,1)

    self:setColor({ 1, 77 / 255, 253 / 255 })
end

function GenericParticle:onAdd()
Kristal.Console:log("added")

end

function GenericParticle:update()
    super.update(self)

    self.alpha = Utils.approach(self.alpha, 0, self.fade_rate * DTMULT)
    self.scale_x = Utils.approach(self.scale_x, 0, self.shrink_rate * DTMULT)
    self.scale_y = Utils.approach(self.scale_y, 0, self.shrink_rate* DTMULT)

    if self.acceleration_rate ~= 0 then
        if self.acceleration_type == 0 then
            self.physics.speed = Utils.approach(self.physics.speed, self.acceleration_goal, self.acceleration_rate * DTMULT)
        elseif self.acceleration_type == 1 then
            self.physics.speed = self.physics.speed * self.acceleration_rate
        end
    end

    if self.scale_x == 0 or self.scale_y == 0 or self.alpha == 0 then
        self:remove()
    end
end

return GenericParticle
