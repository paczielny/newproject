local combat = Combat()  
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)  
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, true)  
  
local condition = Condition(CONDITION_LESSERHEX)  
condition:setParameter(CONDITION_PARAM_TICKS, 8000) -- 8 segundos  
condition:setParameter(CONDITION_PARAM_BUFF_HEALINGRECEIVED, 50) -- 50% curación reducida  
  
combat:addCondition(condition)  
  
local spell = Spell("instant")  
  
function spell.onCastSpell(creature, variant)  
    return combat:execute(creature, variant)  
end  
  
spell:name("monster lesser hex")  
spell:words("###8001")  
spell:isAggressive(true)  
spell:blockWalls(true)  
spell:needTarget(true)  
spell:needLearn(true)  
spell:register()