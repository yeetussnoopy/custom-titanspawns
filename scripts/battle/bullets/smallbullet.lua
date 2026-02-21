local SmallBullet, super = Class(Bullet)

function SmallBullet:init(x, y, dir, speed)
    -- Last argument = sprite path
    super.init(self, x, y, "bullets/smallbullet")

    self.physics.direction = dir
    self.physics.speed = speed

    self.timer = 0
    self.afim_toggle = false

        self.color = COLORS.white

end

function SmallBullet:update()

    super.update(self)



end

return SmallBullet
