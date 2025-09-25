local combat = Combat()  
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_RED)  
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, true)  
  
local condition = Condition(CONDITION_INTENSEHEX)  
condition:setParameter(CONDITION_PARAM_TICKS, 9000) -- 9 segundos  
condition:setParameter(CONDITION_PARAM_BUFF_HEALINGRECEIVED, 50) -- 50% curación reducida  
condition:setParameter(CONDITION_PARAM_BUFF_DAMAGEDEALT, 50) -- 50% daño reducido  
  
combat:addCondition(condition)  
  
local spell = Spell("instant")  
  
function spell.onCastSpell(creature, variant)  
    return combat:execute(creature, variant)  
end  
  
spell:name("monster intense hex")  
spell:words("###8002")  
spell:isAggressive(true)  
spell:blockWalls(true)  
spell:needTarget(true)  
spell:needLearn(true)  
spell:register()