-- Rick's MLC VehiclePatches
--
-- Note: https://pzwiki.net/wiki/Category:Lua_Events

-- Patch vehical mechanics: Remove tyre should not set the Item to nil before transferring the tyre capacity.

require "Vehicles/TimedActions/ISUninstallVehiclePart"

local origISUninstallVehiclePart_complete = ISUninstallVehiclePart.complete

function ISUninstallVehiclePart:complete()

	-- Copy the item container amount before running the vanilla complete
	local item = nil
	local containerAmount = nil
	if self.vehicle and self.part then
		-- assume success and prepare to patch the value
		item = self.part:getInventoryItem()
		containerAmount = self.part:getContainerContentAmount()
	end
	local willDrop = not self.character:getInventory():hasRoomFor(self.character, item)

	local retVal = origISUninstallVehiclePart_complete(self)

	-- Put the correct container amount into the item
	if item then
		if containerAmount then
			if willDrop then
				local gs = self.character:getCurrentSquare()
				local worldItems = gs:getWorldObjects() --  returns an ArrayList<IsoWorldInventoryObject>
				for i=0, worldItems:size()-1 do
					local isoWorldInventoryObject = worldItems:get(i)
					local worldItem = isoWorldInventoryObject:getItem()
					if worldItem then
						--DebugLog.log(DebugType.Mod, "worldItem: ID " .. tostring(worldItem:getID()) .. " item: ID " .. tostring(item:getID()))
						if worldItem:getID() == item:getID() and worldItem:getItemCapacity() == 0 then
							--DebugLog.log(DebugType.Mod, "worldItem: matches.  Setting to " .. tostring(containerAmount))
							worldItem:setItemCapacity(containerAmount)
							break
						end
					end
				end
			else
				item:setItemCapacity(containerAmount)
			end
		end
	end
	return retVal
end

-- Fixing this code: These lines should be switched :  nil clears the container amt before transferring
--     		self.part:setInventoryItem(nil)
--     		item:setItemCapacity(self.part:getContainerContentAmount());
--
-- function ISUninstallVehiclePart:complete()
-- 	local perksTable = VehicleUtils.getPerksTableForChr(self.part:getTable("install").skills, self.character)
--     if self.vehicle then
--     	if not self.part then
--     		print('no such part '..tostring(self.part))
--     		return false
--     	end
--     	local keyvalues = self.part:getTable("install");
--     	local perks = keyvalues.skills;
--     	local success, failure = VehicleUtils.calculateInstallationSuccess(perks, self.character, perksTable);
--     	local item = self.part:getInventoryItem()
--     	if not item then
--     		print('part already uninstalled ', self.part)
--     		return false
--     	end
--     	if instanceof(item, "Radio") and item:getDeviceData() ~= nil then
--     		local presets = self.part:getDeviceData():getDevicePresets()
--     		item:getDeviceData():cloneDevicePresets(presets)
--     	end
--     	if ZombRand(100) < success then
--     		self.part:setInventoryItem(nil)
--     		item:setItemCapacity(self.part:getContainerContentAmount());
--     		local tbl = self.part:getTable("uninstall")
--     		if tbl and tbl.complete then
--         		VehicleUtils.callLua(tbl.complete, self.vehicle, self.part, item)
--     		end
--     		self.vehicle:transmitPartItem(self.part)
--     		-- this is so player don't go over inventory capacity when removing parts
--     		if self.character:getInventory():hasRoomFor(self.character, item) then
--     			self.character:getInventory():AddItem(item);
--     			sendAddItemToContainer(self.character:getInventory(), item);
--     		else
--     			local square = self.character:getCurrentSquare()
--     			local dropX,dropY,dropZ = ISTransferAction.GetDropItemOffset(self.character, square, item)
--     			self.character:getCurrentSquare():AddWorldInventoryItem(item, dropX, dropY, dropZ);
--    				ISInventoryPage.renderDirty = true
--    			end
--    			self.character:sendObjectChange('mechanicActionDone', { success = true})
--    			self.character:addMechanicsItem(item:getID() .. self.vehicle:getMechanicalID() .. "0", self.part, getGameTime():getCalender():getTimeInMillis());
--    		elseif ZombRand(failure) < 100 then
--    			self.part:setCondition(self.part:getCondition() - ZombRand(5,10));
--    			self.vehicle:transmitPartCondition(self.part)
--    			playServerSound("PZ_MetalSnap", self.character:getCurrentSquare());
--    			self.character:sendObjectChange('mechanicActionDone', { success = false})
--    			addXp(self.character, Perks.Mechanics, 1);
--    		end
--    	else
--    		print('no such vehicle id=', self.vehicle)
--    	end

-- 	return true
-- end

