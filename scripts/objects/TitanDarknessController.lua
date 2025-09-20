local TitanDarknessController, super = Class(Object)

function TitanDarknessController:init()
    super.init(self)
    self:setPosition(0, 0)
    self.layer= 999
    self.timer = 0
    self.spawn_speed = 7
    self.spawn_timer = self.spawn_speed

    self.alpha_gain = 0

    self.fumes = {}
    self:addFX(ShaderFX('pixelate', {
        size = { SCREEN_WIDTH, SCREEN_HEIGHT },
        factor = 2
    }))
    for i = 1, 40 do
        table.insert(self.fumes,
            { -5 + i * 25, 330, Utils.random(20, 40), self.timer +
            Utils.random(-30, 30), false })
    end

    for i = 1, 40 do
        table.insert(self.fumes,
            { -5 + i * 25, -10, Utils.random(20, 40), self.timer +
            Utils.random(-30, 30), false })
    end

    for i = 1, 40 do
        table.insert(self.fumes,
            { -10, -5 + i * 25, Utils.random(20, 40), self.timer +
            Utils.random(-30, 30), false })
    end


    for i = 1, 40 do
        table.insert(self.fumes,
            { 655, -5 + i * 25, Utils.random(20, 40), self.timer +
            Utils.random(-30, 30), false })
    end


    self.allow_weaken_fight = false
    self.toggle_lessen = false
    self.total_enemies = 0
end

function TitanDarknessController:update()
    super.update(self)
    self:setLayer(BATTLE_LAYERS["bottom"])
    self.timer = self.timer + DTMULT
    self.spawn_timer = self.spawn_timer - DTMULT

    if self.toggle_lessen and self.allow_weaken_fight then
        self.alpha_gain = Utils.approach(self.alpha_gain, #Game.battle.encounter:getDefeatedEnemies()/self.total_enemies, 0.06* DTMULT)
    else
    self.alpha_gain = self.alpha_gain + (0.03* DTMULT)
    end

    if self.spawn_timer < 0 then
        self.spawn_timer = self.spawn_timer + self.spawn_speed
        table.insert(self.fumes,
            { Utils.random(0, SCREEN_WIDTH), SCREEN_HEIGHT + 30, Utils.random(10, 40), self.timer, true })
    end



    local to_remove = {}
    for index, fume in ipairs(self.fumes) do
        local x, y, radius = self:getFumeInformation(index)
        if y < -(radius + 30) or radius < 0 then table.insert(to_remove, fume) end
    end

    for _, fume in ipairs(to_remove) do
        Utils.removeFromTable(self.fumes, fume)
    end
end

function TitanDarknessController:getFumeInformation(index)
    local x, y, radius, time, shrink_move = Utils.unpack(self.fumes[index])
    if shrink_move then
        time = self.timer - time
        x = x + math.sin(time / 4) * 4
        y = y - time * 1.9
        radius = radius - time * 0.1
    else
        time = self.timer - time
        y = y + math.sin(time / 4) * 4
    end
    return x, y, radius, time
end

function TitanDarknessController:draw()
    super.draw(self)

    Draw.setColor(0.2, 0.2, 0.2, self.alpha_gain)
    for index, _ in ipairs(self.fumes) do
        local x, y, radius = self:getFumeInformation(index)
        love.graphics.setLineWidth(4)
        love.graphics.circle("line", x, y, radius)
    end

    Draw.setColor(COLORS.black, self.alpha_gain)
    for index, _ in ipairs(self.fumes) do
        local x, y, radius = self:getFumeInformation(index)
        love.graphics.circle("fill", x, y, radius - 2)
    end
end

return TitanDarknessController
