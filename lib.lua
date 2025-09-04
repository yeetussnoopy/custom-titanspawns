local lib = {}

function lib:init()
   
end
function lib:postInit(new_file)
    if new_file then
        Game:setFlag("purified", 0)
        Game:setFlag("slain", 0)
   end
end

return lib