local soulScourgePositions = {  
    Position(33452, 31472, 13),  
    Position(33461, 31472, 13)  
}  
  
-- Variables globales para controlar el sistema  
local systemInitialized = false  
local lastUsedPosition = 0  
local pendingRespawns = 0 -- Contador de respawns pendientes  
  
local function spawnSoulScourgeWithEffect(position)  
    -- Efecto de advertencia  
    position:sendMagicEffect(CONST_ME_TELEPORT)  
      
    -- Crear la criatura después del efecto  
    addEvent(function()  
        local monster = Game.createMonster("Soul Scourge", position)  
        if monster then  
            monster:registerEvent("SoulScourgeRespawn")  
            position:sendMagicEffect(CONST_ME_ENERGYHIT)  
        end  
        pendingRespawns = pendingRespawns - 1 -- Decrementar contador  
    end, 2000)  
end  
  
local function getSoulScourgeCount()  
    local area = {  
        from = Position(33450, 31470, 13),  
        to = Position(33465, 31475, 13)  
    }  
      
    local count = 0  
    for x = area.from.x, area.to.x do  
        for y = area.from.y, area.to.y do  
            local tile = Tile(Position(x, y, area.from.z))  
            if tile then  
                local creature = tile:getTopCreature()  
                if creature and creature:isMonster() and creature:getName():lower() == "soul scourge" then  
                    count = count + 1  
                end  
            end  
        end  
    end  
    return count  
end  
  
local function getNextAvailablePosition()  
    for i = 1, #soulScourgePositions do  
        lastUsedPosition = (lastUsedPosition % #soulScourgePositions) + 1  
        local pos = soulScourgePositions[lastUsedPosition]  
        local tile = Tile(pos)  
        if tile and not tile:getTopCreature() then  
            return pos  
        end  
    end  
    return nil  
end  
  
-- CreatureEvent para cuando muere un Soul Scourge  
local soulScourgeRespawn = CreatureEvent("SoulScourgeRespawn")  
function soulScourgeRespawn.onDeath(creature)  
    if not creature or creature:getName():lower() ~= "soul scourge" then  
        return true  
    end  
      
    -- Incrementar contador de respawns pendientes  
    pendingRespawns = pendingRespawns + 1  
      
    -- Respawn individual después de 8-12 segundos  
    addEvent(function()  
        local currentCount = getSoulScourgeCount()  
        local totalNeeded = currentCount + pendingRespawns  
          
        if totalNeeded < 4 then  
            local availablePos = getNextAvailablePosition()  
            if availablePos then  
                spawnSoulScourgeWithEffect(availablePos)  
            else  
                pendingRespawns = pendingRespawns - 1 -- Si no hay posición, decrementar  
            end  
        else  
            pendingRespawns = pendingRespawns - 1 -- Si ya hay suficientes, decrementar  
        end  
    end, math.random(8000, 12000))  
      
    return true  
end  
  
soulScourgeRespawn:register()  
  
-- CreatureEvent para Duke Krule - SOLO INICIALIZACIÓN  
local dukeKruleThink = CreatureEvent("DukeKruleThink")  
function dukeKruleThink.onThink(creature)  
    if not creature or not creature:isMonster() then  
        return true  
    end  
      
    if creature:getName():lower() ~= "duke krule" then  
        return true  
    end  
      
    -- Solo inicializar una vez al comienzo de la pelea  
    if not systemInitialized then  
        systemInitialized = true  
          
        -- Crear los 4 Soul Scourge iniciales con delays más largos  
        for i = 1, 4 do  
            local posIndex = ((i-1) % 2) + 1  
            local pos = soulScourgePositions[posIndex]  
            addEvent(function()  
                pendingRespawns = pendingRespawns + 1  
                spawnSoulScourgeWithEffect(pos)  
            end, i * 8000)  
        end  
    end  
      
    return true  
end  
  
dukeKruleThink:register()