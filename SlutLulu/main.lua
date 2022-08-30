local function is_in_range(target, pos, range)
    return target.position:distanceSqr(pos) < range ^ 2
end

local function get_best_target_priority(target_list, priority_list, range)

end

local function get_min_dist_target(target_list, main_target, range)
    local min_dist = math.huge
    local min_target = nil

    if type(target_list[1]) == "table" then
        for _, list in ipairs(target_list) do
            for _, target in ipairs(list) do 
                if target.networkId ~= main_target.networkId and is_in_range(target, objManager.player.position, range) then
                    local curr_dist = target.position:distanceSqr(main_target.position)
                    if curr_dist < min_dist then
                        min_dist = curr_dist
                        min_target = target
                    end
                end
            end
        end
    else 
        for _, target in ipairs(target_list) do
            if target.networkId ~= main_target.networkId and is_in_range(target, objManager.player.position, range) then
                local curr_dist = target.position:distanceSqr(main_target.position)
                if curr_dist < min_dist then
                    min_dist = curr_dist
                    min_target = target
                end
            end
        end
    end

    return min_target
end

cb.add(cb.load, function() 
    if player.skinName ~= "Lulu" then return end

    print("[Slut Lulu] Loaded")
    local Lulu = {}
    local Master = nil
    local listName = {'None'}
    local supermanKey = nil
    local masterOnly = nil
    local masterSelected = nil
    local fixedPriority = nil

    local HitchanceMenu = { [0] = HitChance.Impossible, HitChance.VeryLow, HitChance.Low, HitChance.Medium, HitChance.High, HitChance.VeryHigh, HitChance.DashingMidAir }

    function Lulu:DebugPrint(...)
        if not self.LuluMenu.misc.debug_print:get() then return end
        print("[Slut Lulu] ".. ...)
    end

    function Lulu:__init()

        self.Pix = nil

        self.qData = {
            delay = 0.25,
            type = spellType.linear,
            speed = 1500,
            range = 925,
            radius = 60,
            boundingRadiusMod = true
        }

        self.LuluMenu = self.CreateMenu()
        self.LuluPermashow = self.CreatePermashow()

        if self.LuluMenu.core.carry.carryOnly:get() then self.LuluMenu.core.carry.carryOnly:set(false) end

        cb.add(cb.tick,function(...) self:OnTick(...) end)
        cb.add(cb.draw,function(...) self:OnDraw(...) end)
        --cb.add(cb.buff,function(...) self:OnBuff(...) end)
        --cb.add(cb.processSpell,function(...) self:OnCastSpell(...) end)

        print("[Slut Lulu] Initiliazed")
    end
    
    function Lulu:CreateMenu()
        local mm = menu.create('slut_lulu', 'Slut Lulu')


        mm:spacer('name', "BDSM AIO by Lx")

        mm:header('core', "Core Settings")
        mm.core:header('carry', "Select your Master")
        mm.core:header('priority_list', "Fixed priority list")
        masterOnly = mm.core.carry:boolean('carryOnly', "Carry only your master?", false, function(menu_item, new_val) Lulu:GoodGirl(menu_item, new_val) end)
        mm.core.priority_list:spacer('dontcrashfuck', "1 = Minor Priority / 5 = Highest Priority\n                      0 = Disabled")
        fixedPriority = mm.core.priority_list:boolean('uselist', "Use fixed priority list?", false)
        local ally = objManager.heroes.allies.list
        for i, ally in ipairs(ally) do
            table.insert(listName, ally.skinName)
            if 
                ally.skinName == "Twitch" and 
                ally.skinName == "KogMaw" and
                ally.skinName == "Tristana" and
                ally.skinName == "Ashe" and
                ally.skinName == "Vayne" and
                ally.skinName == "Varus" and
                ally.skinName == "Xayah" and
                ally.skinName == "Lucian" and
                ally.skinName == "Sivir" and
                ally.skinName == "Draven" and
                ally.skinName == "Kalista" and
                ally.skinName == "Caitlyn" and
                ally.skinName == "Jinx" and
                ally.skinName == "Ezreal"
            then
                mm.core.priority_list:list("priority_"..ally.skinHash, ally.skinName.." Priority", {0, 1, 2, 3, 4, 5}, 4)
            elseif 
                ally.skinName ~= "Lulu" 
            then
                mm.core.priority_list:list("priority_"..ally.skinHash, ally.skinName.." Priority", {0, 1, 2, 3, 4, 5}, 1)
            elseif ally.skinName == "Lulu"
            then
                mm.core.priority_list:list("priority_"..ally.skinHash, ally.skinName.." Priority", {0, 1, 2, 3, 4, 5}, 0)
            end
        end
        masterSelected = mm.core.carry:list('listt', "Selected Master", listName, 0, function(menu_item, new_val) Lulu:GoodGirl(menu_item, new_val) end)

        mm:header('combo', "Combo Mode")
        mm.combo:spacer("qsettings", "Q Settings")
        mm.combo:boolean('qcombo', "Use Q in combo", true)
        mm.combo:slider('qrange', "^ Max. Range", 700, 100, 925, 10)
        mm.combo:list('qhitchance', "Q Hitchance", { 'Low', 'Medium', 'High', 'Very High', 'Undodgeable' }, 3)
        mm.combo:boolean('qpix', "Use Q Pix Extended", false)
        mm.combo:list('qpixhitchance', "Q Pix Hitchance", { 'Low', 'Medium', 'High', 'Very High', 'Undodgeable' }, 2)

        mm.combo:spacer("wsettings", "W Settings")
        mm.combo:boolean('wcomboenemy', "Use W in Combo on Enemy", false)
        mm.combo:header('wenemyblacklist', "W Blacklist for Enemy")
        local enemies = objManager.heroes.enemies.list
        for i, enemy in ipairs(enemies) do
            mm.combo.wenemyblacklist:boolean(enemy.skinHash, "Don't use on: "..enemy.skinName, false)
        end

        mm.combo:boolean('use_r', 'Use R', true)
        mm.combo:slider('rknock', '^ only if knockup (X) enemys', 2, 1, 5, 1)

        mm:header('support', "Support")
        mm.support:boolean('autor', "Auto R", true)
        mm.support:slider('rlife', "^ only if ally health <= (X)", 15, 1, 100, 5)

        mm:header('superman', "Superman")
        mm.superman:spacer('moan', "Give your master's mind a moan buff")
        supermanKey = mm.superman:keybind('key', "Superman Hotkey", 0x53, false, false)
        mm.superman:boolean('usew', "Use W", true)
        mm.superman:boolean('usee', "Use E", true)
        mm.superman:boolean('user', "Use R", false)
        mm.superman:slider('rlife', "^ only if ally heal <= (X)", 40, 100, 1, 5)
        mm.superman:boolean('useready', "Buff only if has W and E ready", false)

        mm:header('misc', "Misc")
        mm.misc:boolean('debug_print', 'Debug Print', true)

        return mm
    end

    function Lulu:CreatePermashow(menu)
        local pp = permaShow.create('lulululu', 'Window Title', vec2(minimap.position.x-300, minimap.position.y))

        pp:add('Superman', supermanKey)
        pp:add('Only peel your master?', masterOnly)
        pp:add('Master', masterSelected)
        pp:add('Use fixed priority list?', fixedPriority)

        return pp
    end

    local timer = 0
    function Lulu:OnTick()
        Time = os.clock()

        if os.clock() > timer then
            for _, minion in ipairs(objManager.minions.list) do
                if minion.name == "RobotBuddy" then
                    self.Pix = minion
                    timer = os.clock() + 10
                end
            end
        end

        if player.isDead or player.teleportType ~= TeleportType.Null then return end
 
        if self.LuluMenu.superman.key:get() then self:Superman() end

        self:Support()

        self:Combo()
    end

    function Lulu:GoodGirl(menu_item, new_val)
        if menu_item.__type.name == "Corrupt::MenuSDK::CheckBox" then
            if new_val then
                local val = self.LuluMenu.core.carry.listt.value
                if val ~= 0 then
                    Master = championManager.getChampion(listName[val+1])
                    self:DebugPrint("Your new Master is: ".. Master.name)
                else
                    Master = nil
                    self.LuluMenu.core.carry.carryOnly:set(false)
                    self:DebugPrint("You need to select a master")
                end
            else
                Master = nil
                self.LuluMenu.core.carry.carryOnly:set(false)
                self:DebugPrint("You don't have any Master anymore")
            end
        else
            if not self.LuluMenu.core.carry.carryOnly:get() then return end
            if new_val ~= 0 then
                Master = championManager.getChampion(listName[val+1])
                    self:DebugPrint("Your new Master is: ".. Master.name)
            else 
                Master = nil
                self.LuluMenu.core.carry.carryOnly:set(false)
                self:DebugPrint("You don't have any Master anymore")
            end
        end

    end

    function Lulu:Superman()
        local ally = nil
        player:move(vec3(game.cursorPos.x, game.cursorPos.y, game.cursorPos.z), false)
        if Master then ally = Master end
        if not ally then ally = get_min_dist_target(objManager.heroes.allies.list, player, 650) end

        if ally then
            
            if self.LuluMenu.superman.usew:get() and player:spellSlot(1).state == 0 then
                if self.LuluMenu.superman.useready:get() and player:spellSlot(2).state ~= 0 then return end
                player:castSpell(SpellSlot.W, ally, false, true)
            end
    
    
            if self.LuluMenu.superman.usee:get() and player:spellSlot(2).state == 0 then
                if self.LuluMenu.superman.useready:get() and player:spellSlot(1).state ~= 0 then return end
                player:castSpell(SpellSlot.E, ally, false, true)
            end
    
        
            if self.LuluMenu.superman.user:get() and player:spellSlot(3).state == 0 and ally.healthPercent <= self.LuluMenu.superman.rlife:get() then
                if self.LuluMenu.superman.useready:get() and player:spellSlot(1).state ~= 0 and player:spellSlot(2).state ~= 0 then return end
                player:castSpell(SpellSlot.R, ally, false, true)
            end
        end
    end

    function Lulu:Combo()
        if orb.isComboActive == false then return end

        self:CastQ()
        self:RKnockup()
    end

    function Lulu:Support()
        local ally = nil
        if Master then ally = Master end

        self:AutoR(ally)
    end

local ELevelDamage = {80, 110, 104, 170, 200}
function Lulu:EDamage(target)
	local damage = 0
	if player:spellSlot(2).level > 0 then
		damage =
        damageLib.magical(player, target, (ELevelDamage[player:spellSlot(2).level])) -- ELevelDamage + (magic * .4)
	end
	return damage
end

    function Lulu:CastQ()
        if self.LuluMenu.combo.qcombo:get() then
            if player:spellSlot(0).state == 0 then
                local target = ts.getInRange(self.qData.range)
                if self.Pix.position:dist(player.pos) >= 300 then
                    for _, enemy in ipairs(objManager.heroes.enemies.list) do
                        if not is_in_range(enemy, self.Pix.position, self.qData.range) then goto continue end
                        target = enemy
                        ::continue::
                    end
                    if target then
                        if target:isValidTarget(self.qData.range, true, self.Pix.pos) then
                            local pos = pred.getPrediction(target, {self.qData, rangeFrom = self.Pix.pos, from = self.Pix.pos})
                            local posLulu = pred.getPrediction(target, self.qData)
                            if posLulu and posLulu.hitChance > pos.hitChance then pos = posLulu end 
                            if pos and pos.distance <= self.LuluMenu.combo.qrange:get() and pos.hitChance >= HitchanceMenu[self.LuluMenu.combo.qpixhitchance:get()] then
                                player:castSpell(SpellSlot.Q, vec3(pos.castPosition.x, game.cursorPos.y, pos.castPosition.z), false, true)
                            end
                        end
                    end
                else
                    if not target and self.LuluMenu.combo.qpix:get() then self:CastPixQ() return end
                    if target then 
                        if target:isValidTarget(self.qData.range, true, player.pos) then
                            local pos = pred.getPrediction(target, self.qData)
                            local posPix = pred.getPrediction(target, {self.qData, rangeFrom = self.Pix.pos, from = self.Pix.pos})
                            if posPix.hitChance > pos.hitChance then pos = posPix end
                            if pos and pos.distance <= self.LuluMenu.combo.qrange:get() and pos.hitChance >= HitchanceMenu[self.LuluMenu.combo.qhitchance:get()] then
                                player:castSpell(SpellSlot.Q, vec3(pos.castPosition.x, game.cursorPos.y, pos.castPosition.z), false, true)
                            end
                        end
                    end
                end
            end
        end
    end

    function Lulu:CastPixQ()
        if self.LuluMenu.combo.qpix:get() then
            if player:spellSlot(0).state == 0 and player:spellSlot(2).state == 0 then
                local target = ts.getInRange(self.qData.range + 650)
                if target and target.isVisible then
                    if target:isValidTarget(self.qData.range + 650, true, player.pos) then
                        local eTargets = {}
                        table.insert(eTargets, objManager.minions.list)
                        table.insert(eTargets, objManager.heroes.list)
                        local eTarget = get_min_dist_target(eTargets, target, 650)
                        if eTarget and is_in_range(target, eTarget.position, self.qData.range) and eTarget.isTargetable then 
                            local pos = pred.getPrediction(target, {self.qData, rangeFrom = eTarget.position})
                            if pos and pos.distance <= self.LuluMenu.combo.qrange:get() and pos.hitChance >= HitchanceMenu[self.LuluMenu.combo.qpixhitchance:get()] then
                                if player:castSpell(SpellSlot.E, eTarget, false, false) then
                                    player:castSpell(SpellSlot.Q, vec3(pos.castPosition.x, game.cursorPos.y, pos.castPosition.z), false, true)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    function Lulu:RKnockup()
        if not self.LuluMenu.combo.use_r:get() then return end
        if player:spellSlot(3).state ~= 0 then return end
        local ally = nil
        if self.LuluMenu.core.carry.carryOnly:get() and Master then ally = Master end

        if not ally then
            for _, allyy in ipairs(objManager.heroes.allies.list) do
                if is_in_range(allyy, player.pos, 900) then
                    local enemiesInRange = 0
                    for _, enemy in ipairs(objManager.heroes.enemies.list) do
                        if is_in_range(enemy, allyy.pos, 400) then enemiesInRange = enemiesInRange + 1 end
                    end
                    if enemiesInRange >= self.LuluMenu.combo.rknock:get() then ally = allyy end
                end
            end
        end
        if ally then
            local enemiesInRange = 0
            for _, enemy in ipairs(objManager.heroes.enemies.list) do
                if is_in_range(enemy, ally.pos, 400) and enemy.isVisible then enemiesInRange = enemiesInRange + 1 end
            end
            if enemiesInRange >= self.LuluMenu.combo.rknock:get() then
                player:castSpell(SpellSlot.R, ally, false, true)
            end
        end
    end

    function Lulu:AutoR(ally)
        if self.LuluMenu.support.autor:get() and player:spellSlot(3).state == 0 then
            if ally and ally.position:dist(player.pos) > 900 then return end
            if not ally then 
                for _, allie in ipairs(objManager.heroes.allies.list) do
                    if allie.position:dist(player.pos) <= 900 and allie.healthPercent <= self.LuluMenu.support.rlife:get() then
                            player:castSpell(SpellSlot.R, allie, false, true)
                    end
                end
            end
        end
    end
    

    function Lulu:OnDraw() 
        if player.isOnScreen then
            graphics.drawCircle(player.pos, self.qData.range, 2, graphics.argb(255, 255, 255, 255))

            if self.LuluMenu.superman.key:get() then graphics.drawText("Superman ON", 20, vec3(player.pos.x - 135, player.pos.y - 100, player.pos.z), graphics.argb(255, 0, 255, 0)) end
        end
        if self.Pix then
            graphics.drawCircle(self.Pix.pos, 40, 2, graphics.argb(255, 255, 255, 255))
            --graphics.drawText(self.Pix.position:dist(player.pos), 20, self.Pix.position, graphics.argb(255, 0, 0, 0))
        end
    end

    print("[Slut Lulu] Initializing")
    Lulu:__init()
end)

cb.add(cb.unload, function()
    menu.delete('slut_lulu')
    permaShow.delete('lulululu')
end)

