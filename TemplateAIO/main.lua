local champs = { ["Yuumi"] = require "Champions/Template", ["Lulu"] = require "Champions/Template" }

cb.add(
        cb.load,
        function()
            local champ = champs[player.skinName]
            print("Loading " .. player.skinName)

            champ.Load()

            for index, value in pairs(champ.callbacks[1]) do
                cb.add(value, champ.callbacks[2][index])
            end
        end
)

cb.add(
        cb.unload,
        function()
            local champ = champs[player.skinName]
            print("Unloading " .. player.skinName)

            champ.Unload()

            for index, value in pairs(champ.callbacks[1]) do
                cb.remove(value, champ.callbacks[2][index])
            end
        end
)