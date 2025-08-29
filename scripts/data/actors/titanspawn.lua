local actor, super = Class(Actor, "titanspawn")

function actor:init()
    super.init(self)

    self.name = "Titan Spawn"

    self.width = 35
    self.height = 40

    --self.hitbox = {3, 24, 24, 16}

    self.flip = "right"

    self.path = "bullets/darkspace"
    self.default = "idle_desperate"

    self.animations = {
        ["idle_desperate"] = { "spr_darkshape_desperate_animated", 0.25, true },
        ["idle_evolving"] = { "spr_darkshape_evolving_animated", 0.25, true },
        ["idle_default"] = { "titanspawn_original_idle/spr_titan_spawn_idle", 0.25, true },
    }
end

return actor
