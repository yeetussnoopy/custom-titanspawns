local Soul, super = Class(Soul)

function Soul:init(x, y, color)
    super.init(self, x, y, color)
    self.timer = 0
    self.radius = 0
    self.toggle = false
    self.radius_goal = Game.battle.encounter.light_size or 48
end


function Soul:draw()
    if self.toggle then
    self.timer = self.timer + (1 * DTMULT)

    self.radius = Utils.approach(self.radius, self.radius_goal, (math.abs(self.radius_goal - self.radius) * 0.1))

    local i = 0.25
    while i <= 0.5 do
        local step = math.max(0.025, (0.1 - (((i * 10) ^ 1.035) / 10 - 0.25) / 3))
        local alpha = (0.5 - i * 0.5) * 0.5

        love.graphics.setColor(1, 1, 1, alpha)     
        local r = self.radius * i * 2 + math.sin(self.timer) * 0.5
        love.graphics.circle("fill", 0, 0, r)

        i = i + step
    end

    love.graphics.setColor(1, 1, 1, 1)    



        
end

    super.draw(self)
end

return Soul
