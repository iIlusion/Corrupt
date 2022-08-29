local Champion = {}

function Champion.Load()
    
    function Champion:Init()
        -- check pred.getPrediction() example input in https://docs.corrupt.gg/libraries/#pred
        self.q = {
            range = 100
        }

        self.w = {
            range = 200
        }

        self.e = {
            range = 300
        }

        self.r = {
            range = 400
        }

        self.menu = self:CreateMenu()
        self.permashow = self:CreatePermashow()

        self.callbacks = { { }, { }}

        -- all credits to torben for this callback handler
        table.insert(self.callbacks[1], cb.tick)
        table.insert(self.callbacks[2], function(...) Champion:OnTick(...) end)
        table.insert(self.callbacks[1], cb.draw)
        table.insert(self.callbacks[2], function(...) Champion:OnDraw(...) end)
        --table.insert(self.callbacks[1], cb.create)
        --table.insert(self.callbacks[2], function(...) Champion:OnCreate(...) end)
    end

    local permashowItemBool = nil
    local permashowItemList = nil
    local permashowItemKeyHold = nil
    local permashowItemKeyToggle = nil

    function Champion:CreateMenu()
        local mm = menu.create('menuKey', "Menu Name")

        mm:spacer('spacerKey', "Plugin AIO Template")
        --mm.spacerKey:tooltip('Made By: Dev\nVersion: 1.0')

        mm:header('combo', "Combo")
        mm.combo:boolean('q', "Use Q", true)
        mm.combo:boolean('w', "Use W", true)
        mm.combo:boolean('e', "Use E", true)
        mm.combo:boolean('r', "Use R", true)

        mm:header('harass', "Harass")
        mm.harass:boolean('q', "Use Q", true)
        mm.harass:boolean('w', "Use W", true)
        mm.harass:boolean('e', "Use E", true)
        --mm.harass:boolean('r', "Use R")

        -- not finished yet
        --mm:header('ks', "KS")
        --mm.ks:boolean('enable', "Enable KS", true)
        --mm.ks:boolean('q', "Use Q", true)
        --mm.ks:boolean('w', "Use W", true)
        --mm.ks:boolean('e', "Use E", true)
        --mm.ks:boolean('r', "Use R", true)

        mm:header('misc', "Misc")
        permashowItemBool = mm.misc:boolean('permaBool', "Active Me", false)
        permashowItemList = mm.misc:list("permaList", "Select List", {"First value from table (0)", "Default value set by you", "Another value"}, 1)
        permashowItemKeyHold = mm.misc:keybind('permaKeyHold', "Press and hold", 0x53, false, false)
        permashowItemKeyToggle = mm.misc:keybind('permaKeyToggle', "Press me to turn on", 0x54, false, true)
        mm.misc:slider('slider', "Slider", 100, 0, 100, 5) -- last value is the amount of increase/decrease with each slide

        mm:header('draw', "Draw")
        mm.draw:header('qmenu', "Q", true)
        mm.draw.qmenu:boolean('draw', "Draw Q Range")
        mm.draw.qmenu:color('colors', "Q Color", graphics.argb(255, 255, 192, 203))
        mm.draw:header('wmenu', "W", true)
        mm.draw.wmenu:boolean('draw', "Draw W Range")
        mm.draw.wmenu:color('colors', "w Color", graphics.argb(255, 255, 105, 180))
        mm.draw:header('emenu', "E", true)
        mm.draw.emenu:boolean('draw', "Draw E Range")
        mm.draw.emenu:color('colors', "E Color", graphics.argb(255, 219, 112, 147))
        mm.draw:header('rmenu', "R", true)
        mm.draw.rmenu:boolean('draw', "Draw R Range")
        mm.draw.rmenu:color('colors', "R Color", graphics.argb(255, 199, 21, 133))
        mm.draw:boolean('ready', "Draw only ready spells", true)

        return mm
    end

    function Champion:CreatePermashow()
        local pp = permaShow.create('permashowKey', "Permashow Name", vec2(minimap.position.x-300, minimap.position.y))

        pp:add('Boolean', permashowItemBool)
        pp:add('List', permashowItemList)
        pp:add('Key Hold', permashowItemKeyHold)
        pp:add('Key Toggle', permashowItemKeyToggle)
    end

    function Champion:OnTick()
        -- 24 times per second

        if player.isDead or player.teleportType ~= TeleportType.Null then return end

        if orb.comboIsActive then self:Combo() end
        if orb.harassKeyDown then self:Harass() end
    end

    function Champion:OnDraw()
        -- each frame to draw above everything

        if player.isDead then return end

        if self.menu.draw.qmenu.draw:get() then
            if not self.menu.draw.ready:get() or self.menu.draw.ready:get() and player:spellSlot(SpellSlot.Q).state == 0 then
                graphics.drawCircle(player.pos, self.q.range, 2, self.menu.draw.qmenu.colors:get())
            end
        end

        if self.menu.draw.wmenu.draw:get() then
            if not self.menu.draw.ready:get() or self.menu.draw.ready:get() and player:spellSlot(SpellSlot.W).state == 0 then
                graphics.drawCircle(player.pos, self.w.range, 2, self.menu.draw.wmenu.colors:get())
            end
        end

        if self.menu.draw.emenu.draw:get() then
            if not self.menu.draw.ready:get() or self.menu.draw.ready:get() and player:spellSlot(SpellSlot.E).state == 0 then
                graphics.drawCircle(player.pos, self.e.range, 2, self.menu.draw.emenu.colors:get())
            end
        end

        if self.menu.draw.rmenu.draw:get() then
            if not self.menu.draw.ready:get() or self.menu.draw.ready:get() and player:spellSlot(SpellSlot.R).state == 0 then
                graphics.drawCircle(player.pos, self.r.range, 2, self.menu.draw.rmenu.colors:get())
            end
        end
    end

    function Champion:Combo()
        self:CastQ('combo')
        self:CastW('combo')
        self:CastE('combo')
        self:CastR('combo')
    end

    function Champion:Harass()
        self:CastQ('harass')
        self:CastW('harass')
        self:CastE('harass')
        --self:CastR('harass')
    end

    function Champion:CastQ(mode)
        if player:spellSlot(SpellSlot.Q).state ~= 0 then return end
        if not self.menu[mode].q:get() then return end
    end

    function Champion:CastW(mode)
        if player:spellSlot(SpellSlot.W).state ~= 0 then return end
        if not self.menu[mode].w:get() then return end
    end

    function Champion:CastE(mode)
        if player:spellSlot(SpellSlot.E).state ~= 0 then return end
        if not self.menu[mode].e:get() then return end
    end

    function Champion:CastR(mode)
        if player:spellSlot(SpellSlot.R).state ~= 0 then return end
        if not self.menu[mode].r:get() then return end
    end

    Champion:Init()
end

function Champion.Unload()
    menu.delete('menuKey')
    permaShow.delete('permashowKey')
end

return Champion

