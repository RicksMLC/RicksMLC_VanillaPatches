-- Craft Patches
--
--  1. Fix CraftRecipeCode errors: The item:getMaintenanceMod() can't work as the "item" is nil at this point in the code.
--
-- Override and just don't call the "local skill = " as the called GenericFixer() function calls it anyway after setting the item.
require "CraftRecipeCode/CraftRecipe_algol"

function CraftRecipeCode.GenericFixing.OnCreate(craftRecipeData, player)
    --local skill  = math.max(craftRecipeData:getRecipe():getHighestRelevantSkillLevel(player), item:getMaintenanceMod(false, player)/2)
    CraftRecipeCode.GenericFixer(craftRecipeData, player, 1, craftRecipeData:getFirstInputItemWithFlag("IsDamaged"), skill, false)
end

function CraftRecipeCode.GenericBetterFixing.OnCreate(craftRecipeData, player)
    --local skill  = math.max(craftRecipeData:getRecipe():getHighestRelevantSkillLevel(player), item:getMaintenanceMod(false, player)/2)
    CraftRecipeCode.GenericFixer(craftRecipeData, player, 2, craftRecipeData:getFirstInputItemWithFlag("IsDamaged"), skill, false)
end

function CraftRecipeCode.GenericEvenBetterFixing.OnCreate(craftRecipeData, player)
    --local skill  = math.max(craftRecipeData:getRecipe():getHighestRelevantSkillLevel(player), item:getMaintenanceMod(false, player)/2)
    CraftRecipeCode.GenericFixer(craftRecipeData, player, 3, craftRecipeData:getFirstInputItemWithFlag("IsDamaged"), skill, false)
end