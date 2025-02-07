-- Activate the Wash menu on rain collectors

require "ISBaseObject"
RicksMLC_SinkWrapper = {}

RicksMLC_SinkWrapper = ISBaseObject:derive("RicksMLC_SinkWrapper");

function RicksMLC_SinkWrapper:new(rainCollectorBarrel)
	local o = {}
	setmetatable(o, self)
	self.__index = self

    o.rainCollectorBarrel = rainCollectorBarrel

    return o
end

function RicksMLC_SinkWrapper:getSquare()
    return self.rainCollectorBarrel:getSquare()
end

function RicksMLC_SinkWrapper:getWaterAmount()
    local fluidContainer = self.rainCollectorBarrel:getFluidContainer() 
    local amt = fluidContainer:getAmount()
    return amt
end

function RicksMLC_SinkWrapper:hasWater()
    local amt = self:getWaterAmount()
    return amt > 0
end

function RicksMLC_SinkWrapper:useWater(amount)
    local fluidContainer = self.rainCollectorBarrel:getFluidContainer() 
    local rainCatcher = fluidContainer:getRainCatcher()
    local fcAmount = fluidContainer:getAmount()
    if fcAmount < amount then
        fluidContainer:removeFluid(fcAmount)
        return fcAmount
    end
    fluidContainer:removeFluid(amount)
    return amount
end

function RicksMLC_SinkWrapper:transmitModData()
    self.rainCollectorBarrel:transmitModData()
end

-- FIXME: This does not work at all - I can't fool java into thinking the sink wrapper is legit
function RicksMLC_SinkWrapper:getFacingPositionAlt(tempo) -- whatever tempo is: in the java it a Vector2
    return self.rainCollectorBarrel:getFacingPositionAlt(tempo)
end

------------------------------------
-- The ISWashClothing and ISWashYourself timed actions call the faceThisObjectAlt(IsoObject) which fails
-- if I pass in the rain collector.  I don't know why, as I would expect the derived object from IsoObject would work.
-- So we just skip the functionality.

require "TimedActions/ISWashClothing"
local origISWashClothingUpdate = ISWashClothing.update
function ISWashClothing:update()
    if self.sink.rainCollectorBarrel then
        -- Copied from the vanilla ISWashClothing:update to remove the faceThisObjectAlt(IsoObject) call as the rain collctor is an IsoThumpable.
        self.item:setJobDelta(self:getJobDelta())
	    --self.character:faceThisObjectAlt(self.sink)
        self.character:setMetabolicTarget(Metabolics.HeavyDomestic);
        return
    end
    -- It is not a rain collector, so just do the vanilla code
    origISWashClothingUpdate(self)
end

require "TimedActions/ISWashYourself"
local origISWashYourselfUpdate = ISWashYourself.update
function ISWashYourself:update()
    if self.sink.rainCollectorBarrel then
        -- Copied from the vanilla ISWashYourself:update to remove the faceThisObjectAlt(IsoObject) call as the rain collctor is an IsoThumpable.
        self.character:setMetabolicTarget(Metabolics.LightDomestic);
        return
    end
    -- It is not a rain collector, so just do the vanilla code
    origISWashYourselfUpdate(self)
end

-------------------------------------
-- Sneak the Wash menu in via the ISWorldObjectContextMenu.doFillWaterMenu call
RicksMLC_ISWOCM_Fix = {}

function RicksMLC_ISWOCM_Fix.addWashingMenus(player, context, rainCollectorBarrel)

    -- Make the rainCollectorBarrel work like a sink:
    -- sink:getSquare()
    -- sink:hasWater()
    -- sink:getWaterAmount() 
    -- sink:useWater()
    local sink = RicksMLC_SinkWrapper:new(rainCollectorBarrel)

    ISWorldObjectContextMenu.doWashClothingMenu(sink, player, context)
    -- TODO: Enable the recipies in a later phase, like when I need to use them :) 
    -- ISWorldObjectContextMenu.doRecipeUsingWaterMenu(sink, player, context);

end

function RicksMLC_ISWOCM_Fix.SneakInWashingMenus(player, context)
    local rainCollectorBarrel = ISWorldObjectContextMenu.fetchVars.rainCollectorBarrel
	if rainCollectorBarrel then 
        local sq = rainCollectorBarrel:getSquare()
        local playerObj = getSpecificPlayer(player)
        if rainCollectorBarrel:getSquare():getBuilding() ~= playerObj:getBuilding() then return end;
	    if rainCollectorBarrel and playerObj:DistToSquared(rainCollectorBarrel:getX() + 0.5, rainCollectorBarrel:getY() + 0.5) < 2 * 2 then
	        RicksMLC_ISWOCM_Fix.addWashingMenus(player, context, rainCollectorBarrel)
        end
    end
end


require "ISUI/ISWorldObjectContextMenu"
-- Override the doFillWaterMenu method to sneak in the Wash menu.  I tried using the event, but could not get the context right
-- for the "Collector" menu.  I think the menu storage map changes as it is built or something that makes the sub menu context incorrect.
local origISWorldObjectContextMenudoFillWaterMenu = ISWorldObjectContextMenu.doFillWaterMenu
function ISWorldObjectContextMenu.doFillWaterMenu(fetch_fluidcontainer, player, context)
    origISWorldObjectContextMenudoFillWaterMenu(fetch_fluidcontainer, player, context)
    -- Now add our own menu after the Fill Water menu:
    RicksMLC_ISWOCM_Fix.SneakInWashingMenus(player, context)
end
