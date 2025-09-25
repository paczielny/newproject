local damagedPlayers = {}  
local transformedPlayers = {} 
  
function onTargetTileWater(creature, position)    
    local tile = Tile(position)    
    if not tile then    
        return true    
    end    
        
    local target = tile:getTopCreature()    
    if not target or not target:isPlayer() then    
        return true    
    end    
        
    if target:getOutfit().lookType == 49 then    
        local playerId = target:getId()    
        if not damagedPlayers[playerId] then    
            damagedPlayers[playerId] = true    
            doTargetCombatHealth(0, target, COMBAT_ICEDAMAGE, -2000, -1400, CONST_ME_ICEATTACK)  
        end    
    end    
        
    return true    
end    
  
function onTargetTileFire(creature, position)    
    local tile = Tile(position)    
    if not tile then    
        return true    
    end    
        
    local target = tile:getTopCreature()    
    if not target or not target:isPlayer() then    
        return true    
    end    
        
    if target:getOutfit().lookType == 286 then    
        local playerId = target:getId()    
        if not damagedPlayers[playerId] then    
            damagedPlayers[playerId] = true    
            doTargetCombatHealth(0, target, COMBAT_FIREDAMAGE, -2000, -1400, CONST_ME_HITBYFIRE)  
        end    
    end    
        
    return true    
end  
  
local ultimateExplosionArea = {    
    {0, 0, 1, 1, 1, 0, 0},    
    {0, 1, 1, 1, 1, 1, 0},    
    {1, 1, 1, 1, 1, 1, 1},    
    {1, 1, 1, 3, 1, 1, 1},    
    {1, 1, 1, 1, 1, 1, 1},    
    {0, 1, 1, 1, 1, 1, 0},    
    {0, 0, 1, 1, 1, 0, 0}    
}    
  
local duke_water = Combat()    
duke_water:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO)    
duke_water:setArea(createCombatArea(ultimateExplosionArea))    
duke_water:setCallback(CALLBACK_PARAM_TARGETTILE, "onTargetTileWater")    
  
local duke_fire = Combat()    
duke_fire:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_FIREAREA)    
duke_fire:setArea(createCombatArea(ultimateExplosionArea))    
duke_fire:setCallback(CALLBACK_PARAM_TARGETTILE, "onTargetTileFire")    
  
local config = {    
    centerRoom = Position(33456, 31472, 13),    
    transformDuration = 8000,  
    transformInterval = 10000,  
    explosionInterval = 2000,  
    x = 10,    
    y = 10    
}    
  
local lastTransformTime = 0  
local explosionEventId = nil  

local function createExplosions()    
    local duke = Creature("Duke Krule")  
    if not duke then  
        return  
    end  
      
    damagedPlayers = {}    
    local hasTransformedPlayers = false  
        
    local spectators = Game.getSpectators(config.centerRoom, false, true, config.x, config.x, config.y, config.y)    
        
    for _, player in pairs(spectators) do    
        if player:isPlayer() then    
            local outfit = player:getOutfit()  
            if outfit.lookType == 286 then -- Agua  
                hasTransformedPlayers = true  
                local variant = Variant(player:getPosition())  
                duke_water:execute(player, variant)  
            elseif outfit.lookType == 49 then -- Fuego    
                hasTransformedPlayers = true  
                local variant = Variant(player:getPosition())  
                duke_fire:execute(player, variant)  
            end  
        end    
    end    
    if hasTransformedPlayers then  
        explosionEventId = addEvent(createExplosions, config.explosionInterval)  
    end  
end  
  
local function transformPlayers()      
    local duke = Creature("Duke Krule")    
    if not duke then    
        return    
    end    
        
    local spectators = Game.getSpectators(config.centerRoom, false, true, config.x, config.x, config.y, config.y)      
          
    for _, player in ipairs(spectators) do      
        if player:isPlayer() then      
            local element = math.random(1, 2)      
            local outfit = player:getOutfit()    
            local playerId = player:getId()   
            local originalLookType = outfit.lookType  
                  
            if element == 1 then      
                outfit.lookType = 286      
                player:setOutfit(outfit)  
            else      
                outfit.lookType = 49      
                player:setOutfit(outfit)   
            end      
            addEvent(function()      
                local p = Player(playerId)      
                if p then      
                    local currentOutfit = p:getOutfit()    
                    currentOutfit.lookType = originalLookType  
                    p:setOutfit(currentOutfit)      
                    p:getPosition():sendMagicEffect(CONST_ME_POFF)    
                end      
            end, config.transformDuration)      
        end      
    end        
      
    addEvent(function()      
        createExplosions()      
    end, 1000)      
end   
  
local dukeKruleElemental = CreatureEvent("DukeKruleMechanics")    
  
function dukeKruleElemental.onThink(creature)    
    if not creature or not creature:isMonster() then    
        return true    
    end    
        
    if creature:getName() ~= "Duke Krule" then    
        return true    
    end    
        
    local currentTime = os.time() * 1000    
        
    if currentTime - lastTransformTime >= config.transformInterval then    
        lastTransformTime = currentTime    
        transformPlayers()    
    end    
        
    return true    
end    
  
local dukeKruleDeath = CreatureEvent("DukeKruleDeath")  
  
function dukeKruleDeath.onDeath(creature, corpse, killer, mostDamageKiller)  
    if creature:getName() ~= "Duke Krule" then  
        return true  
    end  
      
    if explosionEventId then  
        stopEvent(explosionEventId)  
        explosionEventId = nil  
    end  
    for playerId, originalData in pairs(transformedPlayers) do  
        local player = Player(playerId)  
        if player then  
            local outfit = player:getOutfit()  
            outfit.lookType = originalData.originalLookType  
            outfit.lookHead = originalData.originalHead  
            outfit.lookBody = originalData.originalBody  
            outfit.lookLegs = originalData.originalLegs  
            outfit.lookFeet = originalData.originalFeet  
            outfit.lookAddons = originalData.originalAddons  
            player:setOutfit(outfit)  
            player:getPosition():sendMagicEffect(CONST_ME_POFF)  
        end  
    end  
      
    transformedPlayers = {}  
    return true  
end  
  
dukeKruleElemental:register()  
dukeKruleDeath:register()