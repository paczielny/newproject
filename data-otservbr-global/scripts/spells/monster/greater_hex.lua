local combat = Combat()  
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MORTAREA)  
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, true)  
  
local condition = Condition(CONDITION_GREATERHEX)  
condition:setParameter(CONDITION_PARAM_TICKS, 10000) -- 10 segundos  
condition:setParameter(CONDITION_PARAM_BUFF_HEALINGRECEIVED, 50) -- 50% curación reducida  
condition:setParameter(CONDITION_PARAM_BUFF_DAMAGEDEALT, 50) -- 50% daño reducido  
condition:setParameter(CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT, 60) -- 60% HP máximo (40% reducción)  
  
combat:addCondition(condition)  
  
local spell = Spell("instant")  
  
function spell.onCastSpell(creature, variant)  
    return combat:execute(creature, variant)  
end  
  
spell:name("monster greater hex")  
spell:words("###8003")  
spell:isAggressive(true)  
spell:blockWalls(true)  
spell:needTarget(true)  
spell:needLearn(true)  
spell:register()