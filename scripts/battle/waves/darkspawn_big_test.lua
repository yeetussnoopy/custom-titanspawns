local SpawnTest, super = Class(Wave)
function SpawnTest:init()
    super.init(self)
    self.time = 30
end


function SpawnTest:onStart()
        Game.battle.soul.toggle = true



    self:spawnBullet("darkshape_big", 200, 100)

        --self:spawnBullet("shockwave_track", 319, 58)

end

return SpawnTest
