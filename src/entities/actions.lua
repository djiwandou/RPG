--[[
    GD50 
    Final Project

    Author: Daniel Schwartz
    daniel.schwartz.music@gmail.com

    -- actions --

    This is a collections of functions that serve as an action a player can take during battle.

]]

ACTIONS = {
-- basic attack function, called in attack menu and enemy turn
['attack'] = 
    function(owner, target, Number, callback)
        local callback = callback or function() end
        local dmg = round(owner.stats:get('str') * (MAX_DFN - target.stats:get('dfn')) / MAX_DFN + 1)

        gSfx['hit']:play()
        Timer.tween(0.05, {
            [owner] = {x = math.floor(owner.x + owner.width / 2)}
        }):finish(function ()
            Timer.tween(0.05, {
                [owner] = {x = math.floor(owner.x - owner.width / 2)}
            }):finish(function ()
                target.currentHP = target.currentHP - dmg
                Number:setNum(dmg, target.x + target.width / 2, 
                    target.y - gFonts['small']:getHeight())
                
                gSfx['hurt']:play()
                Timer.every(0.1, function()
                    target.opacity = target.opacity == 0 and 255 or 0
                end):limit(8):finish(function()
                    target.opacity = 255
                    callback()
                end)   
            end)
        end)  
    end,

['defend'] =
    function(owner, callback)

    end,

['run'] = 
    function(owner, target, callback)
        local callback = callback or function() end
        local escapeChance 
        if target.boss then
            escapeChance = 0
        elseif owner.level >= target.level then
            escapeChance = 2
        else
            escapeChance = 6
        end
        --print(escapeChance)
        if math.random(escapeChance) == 1 and escapeChance > 0 then
            gSfx['step']:play()
            gStateStack:push(BattleMessageState('You got away safely.', 
            function()
                -- pop off the battle menu
                gStateStack:pop()
                callback()
            end))
        else
            gSfx['fail']:play()
            gStateStack:push(BattleMessageState("Can't escape!", 
            function()
                gStateStack:pop()
            end))
        end
    end,

-- magic actions
['element_spell'] = 
    function(spell, owner, target, Number, callback)
        local callback = callback or function() end
        local dmg 
        local index = 1

        if target.weak == spell.element then
            index = 2
        end

        if target.currentHP > 0 then
            dmg = round((spell.base_dmg[index] * owner.stats:get('int')) 
                * (MAX_DFN - target.stats:get('int')) / MAX_DFN + 1)
            target.currentHP = math.max(0, target.currentHP - dmg)
        end

        owner.currentMP = owner.currentMP - spell.mp_cost
        
        Number:setNum(dmg, target.x + target.width / 2, 
            target.y - gFonts['small']:getHeight())
        
        gSfx['elemental']:play()
        gSfx['hurt']:play()
        Timer.every(0.1, function()
            target.opacity = target.opacity == 0 and 255 or 0
        end):limit(8):finish(function()
            target.opacity = 255
            callback()
        end)   
    end,

['hp_restore_spell'] =
    function(spell, owner, target, Number, callback)
        local callback = callback or function() end
        local restore

        if target.currentHP > 0 then
            restore = spell.base_heal
            target.currentHP = math.min(target.stats:get('HP'), target.currentHP + restore)
        end

        owner.currentMP = owner.currentMP - spell.mp_cost
        
        Number:setNum(restore, target.x + target.width / 2, 
            target.y - gFonts['small']:getHeight())

        gSfx['heal']:play()
        Timer.every(0.1, function()
            target.opacity = target.opacity == 0 and 255 or 0
        end):limit(8):finish(function()
            target.opacity = 255
            callback()
        end)   
    end,

['buff_spell'] =
    function(spell, owner, target, __, callback)
        local callback = callback or function() end

        target.stats:addMod(spell.name, spell.mod)

        owner.currentMP = owner.currentMP - spell.mp_cost

        gSfx['heal']:play()
        Timer.every(0.1, function()
            target.opacity = target.opacity == 0 and 255 or 0
        end):limit(8):finish(function()
            target.opacity = 255
            gStateStack:push(BattleMessageState(target.name .. "'s defense rose!",
            function()
                TurnCounter:after(spell.duration + math.random(3), function()
                    if not target.dead and target then
                        target.stats:rmMod(spell.name)
                        gStateStack:push(BattleMessageState(target.name .. "'s defense returned to normal."))
                    end
                end)

                callback()
            end)) 
        end)   
    end,

-- item actions

['item_restoreHP'] =
    function(item, owner, target, Number, callback)
        local callback = callback or function() end

        if target.currentHP > 0 then
            target.currentHP = math.min(target.stats:get('HP'), target.currentHP + item.restore)
        end
        
        Number:setNum(item.restore, target.x + target.width / 2, 
            target.y - gFonts['small']:getHeight())
            
        gSfx['heal']:play()
        Timer.every(0.1, function()
            target.opacity = target.opacity == 0 and 255 or 0
        end):limit(8):finish(function()
            target.opacity = 255
            callback()
        end)   
    end,


['item_revive'] = 
    function(item, owner, target, Number, callback)
        local callback = callback or function() end

        if target.dead then
            target.currentHP = math.min(target.stats:get('HP'), target.currentHP + item.restore)         
            target.dead = false
        end

        Number:setNum(item.restore, target.x + target.width / 2, 
            target.y - gFonts['small']:getHeight())

        gSfx['heal']:play()
        Timer.every(0.1, function()
            target.opacity = target.opacity == 0 and 255 or 0
        end):limit(8):finish(function()
            target.opacity = 255
            callback()
        end)   
    end,

['item_restoreMP'] =
    function(item, owner, target, Number, callback)
        local callback = callback or function() end

        if target.currentHP > 0 then -- Assuming you can only restore MP if the character is alive
            target.currentMP = math.min(target.stats:get('MP'), target.currentMP + item.restore)
        end
        
        Number:setNum(item.restore, target.x + target.width / 2, 
            target.y - gFonts['small']:getHeight())
            
        gSfx['heal']:play() -- Assuming a heal sound for MP restoration
        Timer.every(0.1, function()
            target.opacity = target.opacity == 0 and 255 or 0
        end):limit(8):finish(function()
            target.opacity = 255
            callback()
        end)   
    end

}