----------------------------------------------------------------------------------------------------------------------
-----------------------------**BuildingCostSystem (BCS) Created By Eisenmonoxid**-------------------------------------
-----------------**Find the newest version here: https://github.com/Eisenmonoxid/S6CostSystem**-----------------------
----------------------------------------------------------------------------------------------------------------------

BCS = {

	BuildingCosts = {}, -- Contains all new costs
	BuildingIDTable = {}, -- Contains Building IDs and the corresponding costs

	RoadMultiplier = {
		First = 1,
		Second = 1,
		CurrentActualCost = 1,
	},

	StreetMultiplier = {
		First = 1,
		Second = 1,
		CurrentX = 1,
		CurrentY = 1,
	},

	RoadCosts = nil,
	TrailCosts = nil,
	PalisadeCosts = nil,
	WallCosts = nil,
	CurrentFestivalCosts = nil,

	CurrentExpectedBuildingType = nil, -- Used for KnockDown saving
	CurrentKnockDownFactor = 0.5, -- Half the new good cost is refunded at knock down
	CurrentOriginalGoodKnockDownFactor = 0.2,
	IsInWallOrPalisadeContinueState = false,
	MarketplaceGoodsCount = false,
	RefundCityGoods = true,
	CurrentWallTypeForClimate = nil, -- Save climate zone wall type here
	OverlayWidget = "/EndScreen",
	OverlayIsCurrentlyShown = false,
	CurrentPlayerID = 1;
	
	CurrentBCSVersion = "4.3 - 01.05.2023 01:09",
};

-- Global variables from the original lua game script --
StartTurretX = 1 
StartTurretY = 1

EndTurretX = 1
EndTurretY = 1

----------------------------------------------------------------------------------------------------------------------
--These functions are exported to userspace---------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

BCS.EditBuildingCosts = function(_upgradeCategory, _originalCostAmount, _newGood, _newGoodAmount)
	-- Check for unloaded script
	assert(type(BCS.GetEntityTypeFullCost) == "function")
	-- Check for valid UpgradeCategory (Beautification_VictoryColumn == 97, the highest Category)
	assert(_upgradeCategory > 0 and _upgradeCategory <= UpgradeCategories.Beautification_VictoryColumn)

	if _originalCostAmount == nil then
		BCS.BuildingCosts[_upgradeCategory] = nil
		return;
	end
	
	-- Check for invalid GoodAmount
	-- Support only changing the original value without adding a new good
	if _newGood ~= nil then
		assert(_newGoodAmount > 0)
		-- Check for valid Good (T_Shovel01 == 178, the highest Good)
		assert(_newGood > 0 and _newGood <= Goods.T_Shovel01)
	end
	
	local AmountOfTypes, FirstBuildingType = Logic.GetBuildingTypesInUpgradeCategory(_upgradeCategory)
	local Costs = {BCS.GetEntityTypeFullCost(FirstBuildingType)}
	assert(_originalCostAmount >= Costs[2])

	-- Insert/Update table entry
	BCS.BuildingCosts[_upgradeCategory] = {_originalCostAmount, _newGood, _newGoodAmount}
end

BCS.EditRoadCosts = function(_originalCostFactor, _newGood, _newGoodFactor)
	assert(type(BCS.GetEntityTypeFullCost) == "function")
	if _originalCostFactor == nil then
		BCS.RoadCosts = nil
		return;
	end
	assert(_originalCostFactor >= 3)
	-- Check for valid Good (T_Shovel01 == 178, the highest Good)
	assert(_newGood > 0 and _newGood <= Goods.T_Shovel01)
	
	BCS.RoadCosts = {Goods.G_Stone, _originalCostFactor, _newGood, _newGoodFactor}
end

BCS.EditWallCosts = function(_originalCostFactor, _newGood, _newGoodFactor)
	assert(type(BCS.GetEntityTypeFullCost) == "function")
	if _originalCostFactor == nil then
		BCS.WallCosts = nil
		return;
	end
	assert(_originalCostFactor >= 3)
	-- Check for valid Good (T_Shovel01 == 178, the highest Good)
	assert(_newGood > 0 and _newGood <= Goods.T_Shovel01)
	
	BCS.WallCosts = {Goods.G_Stone, _originalCostFactor, _newGood, _newGoodFactor}
end

BCS.EditPalisadeCosts = function(_originalCostFactor, _newGood, _newGoodFactor)
	assert(type(BCS.GetEntityTypeFullCost) == "function")
	if _originalCostFactor == nil then
		BCS.PalisadeCosts = nil
		return;
	end
	assert(_originalCostFactor >= 3)
	-- Check for valid Good (T_Shovel01 == 178, the highest Good)
	assert(_newGood > 0 and _newGood <= Goods.T_Shovel01)
	
	BCS.PalisadeCosts = {Goods.G_Wood, _originalCostFactor, _newGood, _newGoodFactor}
end

BCS.EditTrailCosts = function(_firstGood, _originalCostFactor, _secondGood, _newGoodFactor)
	assert(type(BCS.GetEntityTypeFullCost) == "function")
	if _firstGood == nil then
		BCS.TrailCosts = nil
		return;
	end
	-- Check for valid Good (T_Shovel01 == 178, the highest Good)
	assert((_firstGood > 0 and _secondGood > 0) and (_firstGood <= Goods.T_Shovel01 and _secondGood <= Goods.T_Shovel01))
	
	BCS.TrailCosts = {_firstGood, _originalCostFactor, _secondGood, _newGoodFactor}
end

BCS.SetKnockDownFactor = function(_factorOriginalGood, _factorNewGood) --0.5 is half of the cost
	assert(type(BCS.GetEntityTypeFullCost) == "function")
	assert(_factorOriginalGood <= 1 and _factorNewGood <= 1)
	
	BCS.CurrentKnockDownFactor = _factorNewGood
	BCS.CurrentOriginalGoodKnockDownFactor = _factorOriginalGood
end

BCS.EditFestivalCosts = function(_originalCostFactor, _secondGood, _newGoodFactor)
	assert(type(BCS.GetEntityTypeFullCost) == "function")
	if _originalCostFactor == nil then
		BCS.CurrentFestivalCosts = nil
		return;
	end
	
	assert(_originalCostFactor >= 1)
	assert(_secondGood > 0 and _secondGood <= Goods.T_Shovel01)
	
	BCS.CurrentFestivalCosts = {Goods.G_Gold, _originalCostFactor, _secondGood, _newGoodFactor}
end

BCS.SetRefundCityGoods = function(_flag)
	BCS.RefundCityGoods = _flag
end

BCS.SetCountGoodsOnMarketplace = function(_flag)
	BCS.MarketplaceGoodsCount = _flag
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[
		The following methods handle the table management. There are two main tables used: 
		'BCS.BuildingCosts' and 'BCS.BuildingIDTable'.
		
		The first one has the UpgradeCategory as Key and the corresponding new costs as Value.
		The second one stores every individual entityID with the costs that were used to build the entity.
		
		This second table allows us to refund the costs for every building individually, even if the costs
		of the corresponding UpgradeCategory were changed or reset in the meantime.
		
		Since Walls and Palisades can be made up of multiple segments and currently we have no way of getting
		every worker, refund for those is disabled.
		
		WallGates and PalisadeGates should work fine though.
]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------

BCS.GetCostByCostTable = function(_upgradeCategory)
	if _upgradeCategory == nil or _upgradeCategory == 0 then
		return;
	end
	
	return BCS.BuildingCosts[_upgradeCategory];
end

BCS.GetCostByBuildingIDTable = function(_entityID)
	if _entityID == nil or _entityID == 0 then
		return;
	end
	
	for Type, CurrentCostTable in pairs(BCS.BuildingIDTable) do 
		if (CurrentCostTable[1] == _entityID) then
			return CurrentCostTable, Type;
		end
	end
	
	return nil;
end

BCS.AddBuildingToIDTable = function(_entityID)
	local FGood, FAmount, SGood, SAmount = Logic.GetEntityTypeFullCost(Logic.GetEntityType(_entityID))
	if FGood ~= nil and FGood ~= 0 then
		table.insert(BCS.BuildingIDTable, {_entityID, FGood, FAmount, SGood, SAmount})
	else
		Framework.WriteToLog("BCS: AddBuildingToIDTable() -> FGood was nil/0! Nothing was added!")
	end
end

----------------------------------------------------------------------------------------------------------------------
--These functions handle the ingame resource management---------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

BCS.RemoveCostsFromOutStock = function(_upgradeCategory)
	local AmountOfTypes, FirstBuildingType = Logic.GetBuildingTypesInUpgradeCategory(_upgradeCategory)
	local Costs = {Logic.GetEntityTypeFullCost(FirstBuildingType)}
	local OriginalCosts = {BCS.GetEntityTypeFullCost(FirstBuildingType)}
	
	local FAmountToRemove = (Costs[2] - OriginalCosts[2])

	local CurrentID = BCS.GetEntityIDToAddToOutStock(Costs[1])
	if CurrentID == false then
		BCS.RemoveCostsFromOutStockCityGoods(Costs[1], FAmountToRemove, BCS.CurrentPlayerID, BCS.MarketplaceGoodsCount)
	else
		local FGoodCurrentAmount = Logic.GetAmountOnOutStockByGoodType(CurrentID, Costs[1])
		if FGoodCurrentAmount < FAmountToRemove then
			GUI.RemoveGoodFromStock(CurrentID, Costs[1], FGoodCurrentAmount)
		else
			GUI.RemoveGoodFromStock(CurrentID, Costs[1], FAmountToRemove)
		end
	end
	
	if Costs[3] ~= nil and Costs[3] ~= 0 then
		if OriginalCosts[4] == nil then
			OriginalCosts[4] = 0;
		end
		local SAmountToRemove = (Costs[4] - OriginalCosts[4])
		
		CurrentID = BCS.GetEntityIDToAddToOutStock(Costs[3])
		if CurrentID == false then
			BCS.RemoveCostsFromOutStockCityGoods(Costs[3], SAmountToRemove, BCS.CurrentPlayerID, BCS.MarketplaceGoodsCount)
		else
			local SGoodCurrentAmount = Logic.GetAmountOnOutStockByGoodType(CurrentID, Costs[3])
			if SGoodCurrentAmount < SAmountToRemove then
				GUI.RemoveGoodFromStock(CurrentID, Costs[3], SGoodCurrentAmount)
			else
				GUI.RemoveGoodFromStock(CurrentID, Costs[3], SAmountToRemove)
			end	
		end
	end
end

BCS.GetAmountOfGoodsInSettlement = function(_goodType, _playerID, _countMarketplace)
	local CurrentID = BCS.GetEntityIDToAddToOutStock(_goodType)
	
	if CurrentID ~= false then
		return Logic.GetAmountOnOutStockByGoodType(CurrentID, _goodType)	
	end
	
	local Amount = 0
	local BuildingTypes = {Logic.GetBuildingTypesProducingGood(_goodType)}
	local Buildings = GetPlayerEntities(_playerID, BuildingTypes[1])

    for i = 1, #Buildings, 1 do
		Amount = Amount + Logic.GetAmountOnOutStockByGoodType(Buildings[i], _goodType)
    end
	
	if _countMarketplace == true then
		local MarketSlots = {Logic.GetPlayerEntities(_playerID, Entities.B_Marketslot, 5, 0)}
        for j = 2, #MarketSlots, 1 do
            if Logic.GetIndexOnOutStockByGoodType(MarketSlots[j], _goodType) ~= -1 then
                local GoodAmountOnMarketplace = Logic.GetAmountOnOutStockByGoodType(MarketSlots[j], _goodType)
				Amount = Amount + GoodAmountOnMarketplace
            end
        end
	end
	
	return Amount
end

BCS.RemoveCostsFromOutStockCityGoods = function(_goodType, _goodAmount, _playerID, _countMarketplace)
	local PlayerID = _playerID
	local AmountToRemove = _goodAmount
	local BuildingTypes, Buildings
	
	BuildingTypes = {Logic.GetBuildingTypesProducingGood(_goodType)}
	Buildings = GetPlayerEntities(PlayerID, BuildingTypes[1])

	local CurrentOutStock = 0
    for i = 1, #Buildings, 1 do
		CurrentOutStock = Logic.GetAmountOnOutStockByGoodType(Buildings[i], _goodType)
		if CurrentOutStock < AmountToRemove then
			GUI.RemoveGoodFromStock(Buildings[i], _goodType, CurrentOutStock)
			AmountToRemove = AmountToRemove - CurrentOutStock
		else
			GUI.RemoveGoodFromStock(Buildings[i], _goodType, AmountToRemove)
			AmountToRemove = 0
			break;
		end
    end
	
	if _countMarketplace == true and AmountToRemove > 0 then
		local MarketSlots = {Logic.GetPlayerEntities(_playerID, Entities.B_Marketslot, 5, 0)}
        for j = 2, #MarketSlots, 1 do
            if Logic.GetIndexOnOutStockByGoodType(MarketSlots[j], _goodType) ~= -1 then
                CurrentOutStock = Logic.GetAmountOnOutStockByGoodType(MarketSlots[j], _goodType)
				if CurrentOutStock < AmountToRemove then
					GUI.RemoveGoodFromStock(MarketSlots[j], _goodType, CurrentOutStock)
					AmountToRemove = AmountToRemove - CurrentOutStock
				else
					GUI.RemoveGoodFromStock(MarketSlots[j], _goodType, AmountToRemove)
					AmountToRemove = 0
					break;
				end
            end
        end
	end
end

BCS.RemoveVariableCostsFromOutStock = function(_type)
	-- 1 = Palisade, 2 = Wall, 3 = Trail, 4 = Road
	local CostTable, OriginalCosts, CurrentID
	local Costs = {0,0,0,0} -- Just to be sure
	
	if _type == 1 then -- Palisade
		CostTable = BCS.PalisadeCosts
		Costs = {Logic.GetCostForWall(Entities.B_PalisadeSegment, Entities.B_PalisadeTurret, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
		OriginalCosts = {BCS.GetCostForWall(Entities.B_PalisadeSegment, Entities.B_PalisadeTurret, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
		OriginalCosts = OriginalCosts[2]
	elseif _type == 2 then -- Wall
		CostTable = BCS.WallCosts
		Costs = {Logic.GetCostForWall(Entities.B_WallSegment_ME, Entities.B_WallTurret_ME, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
		OriginalCosts = {BCS.GetCostForWall(Entities.B_WallSegment_ME, Entities.B_WallTurret_ME, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
		OriginalCosts = OriginalCosts[2]
	elseif _type == 3 then -- Trail
		CostTable = BCS.TrailCosts
		Costs[2] = BCS.StreetMultiplier.First
		Costs[4] = BCS.StreetMultiplier.Second
		OriginalCosts = 0 -- Trail has no costs in base game
	elseif _type == 4 then -- Road
		CostTable = BCS.RoadCosts
		Costs[2] = BCS.RoadMultiplier.First
		Costs[4] = BCS.RoadMultiplier.Second
		OriginalCosts = BCS.RoadMultiplier.CurrentActualCost
	else
		return; -- No valid type, so remove nothing
	end
	
	CurrentID = BCS.GetEntityIDToAddToOutStock(CostTable[1])
	if CurrentID == false then
		BCS.RemoveCostsFromOutStockCityGoods(CostTable[1], Costs[2] - OriginalCosts, BCS.CurrentPlayerID, BCS.MarketplaceGoodsCount)
	else
		GUI.RemoveGoodFromStock(CurrentID, CostTable[1], Costs[2] - OriginalCosts)
	end
	
	if CostTable[3] ~= nil and CostTable[3] ~= 0 then
		CurrentID = BCS.GetEntityIDToAddToOutStock(CostTable[3])
		if CurrentID == false then
			BCS.RemoveCostsFromOutStockCityGoods(CostTable[3], Costs[4], BCS.CurrentPlayerID, BCS.MarketplaceGoodsCount)
		else
			GUI.RemoveGoodFromStock(CurrentID, CostTable[3], Costs[4])
		end
	end
end

BCS.AreResourcesAvailable = function(_upgradeCategory, _FGoodAmount, _SGoodAmount)
	local AmountOfTypes, FirstBuildingType, Costs
	
	if _FGoodAmount ~= nil and _SGoodAmount ~= nil then
		if _upgradeCategory == 1 then --Road
			Costs = BCS.RoadCosts
		elseif _upgradeCategory == 2 then--Wall
			Costs = BCS.WallCosts
		elseif _upgradeCategory == 3 then --Palisade
			Costs = BCS.PalisadeCosts
		else --Street/Trail
			Costs = BCS.TrailCosts
		end
	else --Normal Buildings
		AmountOfTypes, FirstBuildingType = Logic.GetBuildingTypesInUpgradeCategory(_upgradeCategory)
		Costs = {Logic.GetEntityTypeFullCost(FirstBuildingType)}
		_FGoodAmount = Costs[2]
		_SGoodAmount = Costs[4]
	end
	
	local AmountOfFirstGood = 0
	local AmountOfSecondGood = 0
	
	AmountOfFirstGood = BCS.GetAmountOfGoodsInSettlement(Costs[1], BCS.CurrentPlayerID, BCS.MarketplaceGoodsCount)
	if Costs[3] ~= nil and Costs[3] ~= 0 then
		AmountOfSecondGood = BCS.GetAmountOfGoodsInSettlement(Costs[3], BCS.CurrentPlayerID, BCS.MarketplaceGoodsCount)
	else
		_SGoodAmount = 0
	end
	
	if (AmountOfFirstGood < _FGoodAmount or AmountOfSecondGood < _SGoodAmount) then
		return false
	else
		return true
	end
end

BCS.RefundKnockDown = function(_entityID)
	-- WARNING: _entityID is not valid here anymore! DO NOT USE ON GAME FUNCTIONS!
	-- -> Just used to get the corresponding table index
	local CostTable, Type = BCS.GetCostByBuildingIDTable(_entityID)

	if CostTable == nil then -- Building has no costs
		return;
	end
	
	local IDFirstGood = BCS.GetEntityIDToAddToOutStock(CostTable[2])
	local IDSecondGood = BCS.GetEntityIDToAddToOutStock(CostTable[4])
	
	if IDFirstGood == false then -- CityGood
		if BCS.RefundCityGoods == true then
			BCS.RefundKnockDownForCityGoods(CostTable[2], (math.ceil(CostTable[3] * BCS.CurrentOriginalGoodKnockDownFactor)))
		end
	else
		GUI.SendScriptCommand([[
			Logic.AddGoodToStock(]]..IDFirstGood..[[, ]]..CostTable[2]..[[, ]]..(math.ceil(CostTable[3] * BCS.CurrentOriginalGoodKnockDownFactor))..[[)	
		]])
	end
	if IDSecondGood ~= nil then
		if IDSecondGood == false then -- CityGood
			if BCS.RefundCityGoods == true then
				BCS.RefundKnockDownForCityGoods(CostTable[4], (math.ceil(CostTable[5] * BCS.CurrentKnockDownFactor)))
			end
		else
			GUI.SendScriptCommand([[
				Logic.AddGoodToStock(]]..IDSecondGood..[[, ]]..CostTable[4]..[[, ]]..(math.ceil(CostTable[5] * BCS.CurrentKnockDownFactor))..[[)	
			]])
		end
	end
	
	BCS.BuildingIDTable[Type] = nil -- Delete the Entity ID from the table
	
	Framework.WriteToLog("BCS: KnockDown for Building "..tostring(_entityID).." done! Size of KnockDownList: "..tostring(#BCS.BuildingIDTable))
end

BCS.RefundKnockDownForCityGoods = function(_goodType, _goodAmount)
	local AmountToRemove = _goodAmount
	local BuildingTypes, Buildings
	
	BuildingTypes = {Logic.GetBuildingTypesProducingGood(_goodType)}
	Buildings = GetPlayerEntities(BCS.CurrentPlayerID, BuildingTypes[1])

	local CurrentOutStock, CurrentMaxOutStock = 0, 0
    for i = 1, #Buildings, 1 do
		if Logic.IsBuilding(Buildings[i]) == 1 and Logic.IsConstructionComplete(Buildings[i]) == 1 then
			CurrentOutStock = Logic.GetAmountOnOutStockByGoodType(Buildings[i], _goodType)
			CurrentMaxOutStock = Logic.GetMaxAmountOnStock(Buildings[i])
			if CurrentOutStock < CurrentMaxOutStock then
				local FreeStock = CurrentMaxOutStock - CurrentOutStock
				if FreeStock >= AmountToRemove then
					GUI.SendScriptCommand([[
						Logic.AddGoodToStock(]]..Buildings[i]..[[, ]].._goodType..[[, ]]..AmountToRemove..[[)	
					]])
					break;
				else
					AmountToRemove = AmountToRemove - FreeStock
					GUI.SendScriptCommand([[
						Logic.AddGoodToStock(]]..Buildings[i]..[[, ]].._goodType..[[, ]]..FreeStock..[[)	
					]])
				end
			end
		end
    end
	
	Framework.WriteToLog("BCS: Refunded City Goods with type ".._goodType.." and amount ".._goodAmount..". Amount Lost: "..AmountToRemove)
end

BCS.GetEntityIDToAddToOutStock = function(_goodType)
	if _goodType == nil then 
		return nil 
	end
	
	if _goodType == Goods.G_Gold then 
		return Logic.GetHeadquarters(BCS.CurrentPlayerID) 
	end
	
	if Logic.GetIndexOnOutStockByGoodType(Logic.GetStoreHouse(BCS.CurrentPlayerID), _goodType) ~= -1 then
		return Logic.GetStoreHouse(BCS.CurrentPlayerID)
	end
	
	--Check here for Buildings, when player uses production goods as building material
	if Logic.GetGoodCategoryForGoodType(_goodType) ~= GoodCategories.GC_Resource then
		return false	
	end
	
	return nil -- This should never happen
end

BCS.GetLastPlacedBuildingIDForKnockDown = function(_EntityID)
	Framework.WriteToLog("BCS: Job "..tostring(_EntityID).." Created!")
	-- Are we even waiting on something?
	if BCS.CurrentExpectedBuildingType == nil then
		Framework.WriteToLog("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: CurrentExpectedBuildingType was nil!")
		return true;
	end
	if not IsExisting(_EntityID) then
		Framework.WriteToLog("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: Worker Entity was deleted!")
		return true;
	elseif string.find(Logic.GetEntityTypeName(Logic.GetEntityType(_EntityID)), 'NPC') then
		Framework.WriteToLog("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: Worker was an NPC - Settler!")
		return true;
	elseif Logic.GetTaskHistoryEntry(_EntityID, 0) ~= 1 and Logic.GetTaskHistoryEntry(_EntityID, 0) ~= 9 then
		Framework.WriteToLog("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: TaskHistoryEntry was not 1 or 9 (Just Spawned/BuildingPhase)")
		return true;
	end
	-- Here, we expect that a building was being placed recently
	local WorkPlaceID = Logic.GetSettlersWorkBuilding(_EntityID)
	if WorkPlaceID ~= 0 and WorkPlaceID ~= nil then
		local Type = Logic.GetEntityType(WorkPlaceID)
		Framework.WriteToLog("BCS: Job "..tostring(_EntityID).." has BuildingType: " ..tostring(Type) .." - Expected: "..tostring(BCS.CurrentExpectedBuildingType))	
		if Type == BCS.CurrentExpectedBuildingType then
			
			BCS.AddBuildingToIDTable(WorkPlaceID)
			BCS.CurrentExpectedBuildingType = nil
			Framework.WriteToLog("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: Building Added To ID Table: " ..tostring(WorkPlaceID))
			
			return true;
		else
			Framework.WriteToLog("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: CurrentExpectedBuildingType ~= WorkplaceID-Type!")
			return true;
		end
	end
end

----------------------------------------------------------------------------------------------------------------------
--Hacking the game functions here-------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

BCS.OverwriteAfterPlacement = function()
	if BCS.GameCallback_GUI_AfterBuildingPlacement == nil then
		BCS.GameCallback_GUI_AfterBuildingPlacement = GameCallback_GUI_AfterBuildingPlacement;
	end
    GameCallback_GUI_AfterBuildingPlacement = function()
	
		local CostTable = BCS.GetCostByCostTable(g_LastPlacedParam)
		if (CostTable ~= nil and CostTable ~= 0) then
			local AmountOfTypes, FirstBuildingType = Logic.GetBuildingTypesInUpgradeCategory(g_LastPlacedParam)
			BCS.CurrentExpectedBuildingType = FirstBuildingType
			BCS.RemoveCostsFromOutStock(g_LastPlacedParam)
		end
		
        BCS.GameCallback_GUI_AfterBuildingPlacement();
    end
	
	if BCS.GameCallback_GUI_AfterWallGatePlacement == nil then
		BCS.GameCallback_GUI_AfterWallGatePlacement = GameCallback_GUI_AfterWallGatePlacement;
	end
    GameCallback_GUI_AfterWallGatePlacement = function()
	
		local CostTable = BCS.GetCostByCostTable(g_LastPlacedParam)
		if (CostTable ~= nil and CostTable ~= 0) then
			local AmountOfTypes, FirstBuildingType = Logic.GetBuildingTypesInUpgradeCategory(g_LastPlacedParam)
			BCS.CurrentExpectedBuildingType = FirstBuildingType
			BCS.RemoveCostsFromOutStock(g_LastPlacedParam)
		end
		
        BCS.GameCallback_GUI_AfterWallGatePlacement();
    end
	
	if BCS.GameCallback_GUI_AfterRoadPlacement == nil then
		BCS.GameCallback_GUI_AfterRoadPlacement = GameCallback_GUI_AfterRoadPlacement;
	end
    GameCallback_GUI_AfterRoadPlacement = function()
		if g_LastPlacedParam == false then --Road
			if (BCS.RoadCosts ~= nil) then
				BCS.RemoveVariableCostsFromOutStock(4)
			end
		else --Trail
			if (BCS.TrailCosts ~= nil) then
				BCS.RemoveVariableCostsFromOutStock(3)
			end
		end
		
		BCS.ResetTrailAndRoadCosts()
        BCS.GameCallback_GUI_AfterRoadPlacement();
    end
	
	if BCS.GameCallback_GUI_AfterWallPlacement == nil then
		BCS.GameCallback_GUI_AfterWallPlacement = GameCallback_GUI_AfterWallPlacement;
	end
    GameCallback_GUI_AfterWallPlacement = function()
		if g_LastPlacedParam == UpgradeCategories.PalisadeSegment then --Palisade
			if (BCS.PalisadeCosts ~= nil) then
				BCS.RemoveVariableCostsFromOutStock(1)
				
				if BCS.IsCurrentStateABuildingState(GUI.GetCurrentStateID()) == true then
					GUI.CancelState()
				end
				
			end
		elseif g_LastPlacedParam == BCS.CurrentWallTypeForClimate then --Wall
			if (BCS.WallCosts ~= nil) then
				BCS.RemoveVariableCostsFromOutStock(2)
				
				if BCS.IsCurrentStateABuildingState(GUI.GetCurrentStateID()) == true then
					GUI.CancelState()
				end
			end			
		end
		
		BCS.IsInWallOrPalisadeContinueState = false
		BCS.ResetWallTurretPositions()
		
        BCS.GameCallback_GUI_AfterWallPlacement();
    end
end

BCS.CustomBuildClicked = function(_upgradeCategory, _isWallOrPalisadeGate)
	PlacementState = 0
    XGUIEng.UnHighLightGroup("/InGame", "Construction")

    if not GUI_Construction.TestSettlerLimit(_upgradeCategory) and _isWallOrPalisadeGate == false then
        return;
    end

    local CanPlace = BCS.AreResourcesAvailable(_upgradeCategory)
	
    if CanPlace == false then
        Message(XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_Resources"))
    else
        Sound.FXPlay2DSound( "ui\\menu_select")
		
		-- save last placement
		BCS.IsInWallOrPalisadeContinueState = false
        g_LastPlacedParam = _upgradeCategory
		
		if _isWallOrPalisadeGate == true then
			GUI.ActivatePlaceWallGateState(_upgradeCategory)
		else
			GUI.ActivatePlaceBuildingState(_upgradeCategory)			
		end

        XGUIEng.ShowWidget("/Ingame/Root/Normal/PlacementStatus",1)
        GUI_Construction.CloseContextSensitiveMenu()
    end
end
BCS.CustomBuildWallOrStreetClicked = function(_upgradeCategory, _isTrail)
    Sound.FXPlay2DSound( "ui\\menu_select")
    PlacementState = 0

    GUI.ClearSelection()
	
	-- save last placement
	BCS.IsInWallOrPalisadeContinueState = false
    g_LastPlacedParam = _upgradeCategory
	
	if _upgradeCategory == nil and _IsTrail ~= nil then
		g_LastPlacedParam = _IsTrail
		GUI.ActivatePlaceRoadState(_IsTrail)
	else
		GUI.ActivatePlaceWallState(_upgradeCategory)
	end
	
    XGUIEng.ShowWidget("/Ingame/Root/Normal/PlacementStatus", 1)
    GUI_Construction.CloseContextSensitiveMenu()
end

BCS.OverwriteBuildClicked = function()
	if BCS.BuildClicked == nil then
		BCS.BuildClicked = GUI_Construction.BuildClicked;
	end	
	GUI_Construction.BuildClicked = function(_upgradeCategory)
		local CostTable = BCS.GetCostByCostTable(_upgradeCategory)
		if (CostTable ~= nil and CostTable ~= 0) then
			-- Custom Building
			GUI.CancelState()
			BCS.CustomBuildClicked(_upgradeCategory)
		else
			-- Original Building
			BCS.BuildClicked(_upgradeCategory)
		end
		
		g_LastPlacedFunction = GUI_Construction.BuildClicked
	end
	
	if BCS.BuildWallClicked == nil then
		BCS.BuildWallClicked = GUI_Construction.BuildWallClicked;
	end	
	GUI_Construction.BuildWallClicked = function(_upgradeCategory)
		BCS.ResetWallTurretPositions()
		
		if _upgradeCategory == nil then
			_upgradeCategory = GetUpgradeCategoryForClimatezone("WallSegment")
			BCS.CurrentWallTypeForClimate = _upgradeCategory
		end
		
		if _upgradeCategory == UpgradeCategories.PalisadeSegment and BCS.PalisadeCosts ~= nil then
			GUI.CancelState()
			BCS.CustomBuildWallOrStreetClicked(_upgradeCategory, nil)
		elseif BCS.WallCosts ~= nil then
			GUI.CancelState()
			BCS.CustomBuildWallOrStreetClicked(_upgradeCategory, nil)
		else
			BCS.BuildWallClicked(_upgradeCategory)
		end
		
		g_LastPlacedFunction = GUI_Construction.BuildWallClicked
	end
	
	if BCS.BuildWallGateClicked == nil then
		BCS.BuildWallGateClicked = GUI_Construction.BuildWallGateClicked;
	end	
	GUI_Construction.BuildWallGateClicked = function(_upgradeCategory)		
	    if _upgradeCategory == nil then
			_upgradeCategory = GetUpgradeCategoryForClimatezone("WallGate")
		end
		
		local CostTable = BCS.GetCostByCostTable(_upgradeCategory)
		if (CostTable ~= nil and CostTable ~= 0) then
			-- Custom WallGate
			GUI.CancelState()
			BCS.CustomBuildClicked(_upgradeCategory)
		else
			-- Original WallGate
			BCS.BuildWallGateClicked(_upgradeCategory)
		end
		
		g_LastPlacedFunction = GUI_Construction.BuildWallGateClicked
	end
	
	if BCS.BuildStreetClicked == nil then
		BCS.BuildStreetClicked = GUI_Construction.BuildStreetClicked;
	end	
	GUI_Construction.BuildStreetClicked = function(_IsTrail)
		BCS.ResetTrailAndRoadCosts()
		
	    if _IsTrail == nil then
			_IsTrail = false
		end
		
		if _IsTrail == false and BCS.RoadCosts ~= nil then
			GUI.CancelState()
			BCS.CustomBuildWallOrStreetClicked(nil, _IsTrail)
		elseif BCS.TrailCosts ~= nil then
			GUI.CancelState()
			BCS.CustomBuildWallOrStreetClicked(nil, _IsTrail)
		else
			BCS.BuildStreetClicked(_IsTrail)
		end
		
		g_LastPlacedFunction = GUI_Construction.BuildStreetClicked
	end
	
	if BCS.ContinueWallClicked == nil then
		BCS.ContinueWallClicked = GUI_BuildingButtons.ContinueWallClicked;
	end	
	GUI_BuildingButtons.ContinueWallClicked = function()
		if BCS.IsCurrentStateABuildingState(GUI.GetCurrentStateID()) == true then
			GUI.CancelState()
		end
		BCS.ResetWallTurretPositions()
		
		local TurretID = GUI.GetSelectedEntity()
		local TurretType = Logic.GetEntityType(TurretID)
		local UpgradeCategory = UpgradeCategories.PalisadeSegment

		if TurretType ~= Entities.B_PalisadeTurret
			and TurretType ~= Entities.B_PalisadeGate_Turret_L
			and TurretType ~= Entities.B_PalisadeGate_Turret_R then
				UpgradeCategory = GetUpgradeCategoryForClimatezone("WallSegment")
				BCS.CurrentWallTypeForClimate = UpgradeCategory
		end
		
		g_LastPlacedParam = UpgradeCategory
		BCS.IsInWallOrPalisadeContinueState = true
		
		BCS.ContinueWallClicked()
	end

	if BCS.ContinueWallMouseOver == nil then
		BCS.ContinueWallMouseOver = GUI_BuildingButtons.ContinueWallMouseOver;
	end	
	GUI_BuildingButtons.ContinueWallMouseOver = function()
		local TurretID = GUI.GetSelectedEntity()
		local WeaponSlotID = Logic.GetWeaponHolder(TurretID)

		if WeaponSlotID ~= nil then
			TurretID = WeaponSlotID
		end

		local TurretType = Logic.GetEntityType(TurretID)
		local Costs
		local TooltipTextKey

		if TurretType == Entities.B_PalisadeTurret
        or TurretType == Entities.B_PalisadeGate_Turret_L
        or TurretType == Entities.B_PalisadeGate_Turret_R then
			TooltipTextKey = "ContinuePalisade"
		
			if BCS.PalisadeCosts ~= nil then
				Costs = {BCS.PalisadeCosts[1], -1, BCS.PalisadeCosts[3], -1}	
			else
				Costs = {Goods.G_Wood, -1}
			end
		else
			TooltipTextKey = "ContinueWall"
			if BCS.WallCosts ~= nil then
				Costs = {BCS.WallCosts[1], -1, BCS.WallCosts[3], -1}	
			else
				Costs = {Goods.G_Stone, -1}
			end
		end
		
		GUI_Tooltip.TooltipBuy(Costs, TooltipTextKey)
	end
end

BCS.OverwriteGetCostLogics = function()
	if BCS.GetEntityTypeFullCost == nil then
		BCS.GetEntityTypeFullCost = Logic.GetEntityTypeFullCost;
	end	
	Logic.GetEntityTypeFullCost = function(_buildingType)
		local Costs = BCS.GetCostByCostTable(Logic.GetUpgradeCategoryByBuildingType(_buildingType))
		if (Costs == nil or Costs == 0) then
			return BCS.GetEntityTypeFullCost(_buildingType);
		else
			local OriginalCosts = {BCS.GetEntityTypeFullCost(_buildingType)}
			return OriginalCosts[1], Costs[1], Costs[2], Costs[3];
		end
	end
	
	if BCS.GetCostForWall == nil then
		BCS.GetCostForWall = Logic.GetCostForWall;
	end	
	Logic.GetCostForWall = function(_SegmentType, _TurretType, _StartTurretX, _StartTurretY, _EndTurretX, _EndTurretY)
		if _SegmentType == Entities.B_PalisadeSegment and _TurretType == Entities.B_PalisadeTurret then -- Palisade
			if (BCS.PalisadeCosts == nil) then
				return BCS.GetCostForWall(_SegmentType, _TurretType, _StartTurretX, _StartTurretY, _EndTurretX, _EndTurretY)
			else
				local Distance = BCS.CalculateVariableCosts(_StartTurretX, _StartTurretY, _EndTurretX, _EndTurretY)
				return BCS.PalisadeCosts[1], math.ceil(Distance * BCS.PalisadeCosts[2]), BCS.PalisadeCosts[3], math.ceil(Distance * BCS.PalisadeCosts[4])
			end	
		else -- Wall
			if (BCS.WallCosts == nil) then
				return BCS.GetCostForWall(_SegmentType, _TurretType, _StartTurretX, _StartTurretY, _EndTurretX, _EndTurretY)
			else
				local Distance = BCS.CalculateVariableCosts(_StartTurretX, _StartTurretY, _EndTurretX, _EndTurretY)
				return BCS.WallCosts[1], math.ceil(Distance * BCS.WallCosts[2]), BCS.WallCosts[3], math.ceil(Distance * BCS.WallCosts[4])
			end		
		end
	end
end

BCS.OverwriteVariableCostBuildings = function()
	if BCS.GameCallBack_GUI_BuildRoadCostChanged == nil then
		BCS.GameCallBack_GUI_BuildRoadCostChanged = GameCallBack_GUI_BuildRoadCostChanged;
	end	
    GameCallBack_GUI_BuildRoadCostChanged = function(_Length)
		if BCS.RoadCosts == nil then
			BCS.GameCallBack_GUI_BuildRoadCostChanged(_Length)
		else
			local Meters = _Length / 100
			local MetersPerUnit = Logic.GetRoadMetersPerRoadUnit()
			local AmountFirstGood = math.ceil(BCS.RoadCosts[2] * (Meters / MetersPerUnit))
			local AmountSecondGood = math.ceil(BCS.RoadCosts[4] * (Meters / MetersPerUnit))

			if AmountFirstGood == 0 then
				AmountFirstGood = 1
			end
			if AmountSecondGood == 0 then
				AmountSecondGood = 1
			end

			BCS.ShowTooltipCostsOnly({Goods.G_Stone, AmountFirstGood, BCS.RoadCosts[3], AmountSecondGood})
			
			BCS.RoadMultiplier.First = AmountFirstGood;
			BCS.RoadMultiplier.Second = AmountSecondGood;

			local Costs = {Logic.GetRoadCostPerRoadUnit()}
			for i = 2, table.getn(Costs), 2 do
				Costs[i] = math.ceil(Costs[i] * (Meters / MetersPerUnit))
				if Costs[i] == 0 then
					Costs[i] = 1
				end
			end
			BCS.RoadMultiplier.CurrentActualCost = Costs[2]
		end
    end
	
	if BCS.GameCallBack_GUI_ConstructWallSegmentCountChanged == nil then
		BCS.GameCallBack_GUI_ConstructWallSegmentCountChanged = GameCallBack_GUI_ConstructWallSegmentCountChanged;
	end	
	GameCallBack_GUI_ConstructWallSegmentCountChanged = function(_SegmentType, _TurretType)
		if _SegmentType == Entities.B_PalisadeSegment and _TurretType == Entities.B_PalisadeTurret then -- Palisade
			if BCS.PalisadeCosts == nil then
				BCS.GameCallBack_GUI_ConstructWallSegmentCountChanged(_SegmentType, _TurretType)
			else
				local Costs = {Logic.GetCostForWall(_SegmentType, _TurretType, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
				BCS.ShowTooltipCostsOnly(Costs)
			end
		else
			if BCS.WallCosts == nil then
				BCS.GameCallBack_GUI_ConstructWallSegmentCountChanged(_SegmentType, _TurretType)
			else
				local Costs = {Logic.GetCostForWall(_SegmentType, _TurretType, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
				BCS.ShowTooltipCostsOnly(Costs)
			end
		end
	end
	
	if BCS.GameCallback_GUI_Street_Started == nil then
		BCS.GameCallback_GUI_Street_Started = GameCallback_GUI_Street_Started;
	end	
	GameCallback_GUI_Street_Started = function(_PlayerID, _X, _Y)
		BCS.GameCallback_GUI_Street_Started(_PlayerID, _X, _Y)
		if BCS.TrailCosts ~= nil and _PlayerID == 1 then
			BCS.StreetMultiplier.CurrentX = _X
			BCS.StreetMultiplier.CurrentY = _Y
		end
	end
	
	if BCS.GameCallback_Street_Placed_Local == nil then
		BCS.GameCallback_Street_Placed_Local = GameCallback_Street_Placed_Local;
	end	
	GameCallback_Street_Placed_Local = function(_PlayerID, _X, _Y)
		BCS.GameCallback_Street_Placed_Local(_PlayerID, _X, _Y)
		if BCS.TrailCosts ~= nil and _PlayerID == 1 then
			BCS.StreetMultiplier.CurrentX = _X
			BCS.StreetMultiplier.CurrentY = _Y
		end
	end
end

BCS.ShowTooltipCostsOnly = function(_Costs)
    local TooltipContainerPath = "/InGame/Root/Normal/TooltipCostsOnly"
    local TooltipContainer = XGUIEng.GetWidgetID(TooltipContainerPath)
    local TooltipCostsContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/Costs")

	BCS.SetCustomToolTipCosts(TooltipCostsContainer, _Costs, false, true)
	local TooltipContainerSizeWidgets = {TooltipCostsContainer}
    GUI_Tooltip.SetPosition(TooltipContainer, TooltipContainerSizeWidgets, nil, nil)
	XGUIEng.ShowWidget(TooltipContainerPath, 1)
end

BCS.OverwriteTooltipHandling = function()
	function GUI_Tooltip.SetCosts(_TooltipCostsContainer, _Costs, _GoodsInSettlementBoolean)
		local UseBCSCosts = false
		
		local Name = XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID())
		if Name == "Street" and BCS.RoadCosts ~= nil then
			_Costs = {BCS.RoadCosts[1], -1, BCS.RoadCosts[3], -1}
		elseif Name == "Trail" and BCS.TrailCosts ~= nil then
			_Costs = {BCS.TrailCosts[1], -1, BCS.TrailCosts[3], -1}	
		elseif Name == "Palisade" and BCS.PalisadeCosts ~= nil then
			_Costs = {BCS.PalisadeCosts[1], -1, BCS.PalisadeCosts[3], -1}		
		elseif Name == "Wall" and BCS.WallCosts ~= nil then
			_Costs = {BCS.WallCosts[1], -1, BCS.WallCosts[3], -1}	
		elseif Name == "StartFestival" and BCS.CurrentFestivalCosts ~= nil then
			UseBCSCosts = true
		elseif Name == "PlaceField" then
			local EntityType = Logic.GetEntityType(GUI.GetSelectedEntity())
			local UpgradeCategory

			if EntityType == Entities.B_GrainFarm then
				UpgradeCategory = GetUpgradeCategoryForClimatezone("GrainField")
			elseif EntityType == Entities.B_Beekeeper then
				UpgradeCategory = UpgradeCategories.BeeHive
			elseif EntityType == Entities.B_CattleFarm then
				UpgradeCategory = UpgradeCategories.CattlePasture
			elseif EntityType == Entities.B_SheepFarm then
				UpgradeCategory = UpgradeCategories.SheepPasture
			end
			local CostTable = BCS.GetCostByCostTable(UpgradeCategory)
			if (CostTable ~= nil) then
				UseBCSCosts = true
			end
		else
			local Entity = Entities[Name]
			if Entity ~= 0 and Entity ~= nil then
				local CostTable = BCS.GetCostByCostTable(Logic.GetUpgradeCategoryByBuildingType(Entity))
				if (CostTable ~= nil) then
					UseBCSCosts = true
				end
			end
		end
			
		BCS.SetCustomToolTipCosts(_TooltipCostsContainer, _Costs, _GoodsInSettlementBoolean, UseBCSCosts)
	end
end

BCS.SetCustomToolTipCosts = function(_TooltipCostsContainer, _Costs, _GoodsInSettlementBoolean, _UseBCSCosts)
	local TooltipCostsContainerPath = XGUIEng.GetWidgetPathByID(_TooltipCostsContainer)
	local Good1ContainerPath = TooltipCostsContainerPath .. "/1Good"
	local Goods2ContainerPath = TooltipCostsContainerPath .. "/2Goods"
	local NumberOfValidAmounts, Good1Path, Good2Path = 0, 0, 0
	
	for i = 2, #_Costs, 2 do
		if _Costs[i] ~= 0 then
			NumberOfValidAmounts = NumberOfValidAmounts + 1
		end
	end

	if NumberOfValidAmounts == 0 then
		XGUIEng.ShowWidget(Good1ContainerPath, 0)
		XGUIEng.ShowWidget(Goods2ContainerPath, 0)
		return;
	elseif NumberOfValidAmounts == 1 then
		XGUIEng.ShowWidget(Good1ContainerPath, 1)
		XGUIEng.ShowWidget(Goods2ContainerPath, 0)
		Good1Path = Good1ContainerPath .. "/Good1Of1"
	elseif NumberOfValidAmounts == 2 then
		XGUIEng.ShowWidget(Good1ContainerPath, 0)
		XGUIEng.ShowWidget(Goods2ContainerPath, 1)
		Good1Path = Goods2ContainerPath .. "/Good1Of2"
		Good2Path = Goods2ContainerPath .. "/Good2Of2"
	elseif NumberOfValidAmounts > 2 then
		GUI.AddNote("Debug: Invalid Costs table. Not more than 2 GoodTypes allowed.")
	end

	local ContainerIndex = 1

	for i = 1, #_Costs, 2 do
		if _Costs[i + 1] ~= 0 then
			local CostsGoodType = _Costs[i]
			local CostsGoodAmount = _Costs[i + 1]     
			local IconWidget, AmountWidget
            
			if ContainerIndex == 1 then
				IconWidget = Good1Path .. "/Icon"
				AmountWidget = Good1Path .. "/Amount"
			else
				IconWidget = Good2Path .. "/Icon"
				AmountWidget = Good2Path .. "/Amount"
			end
            
			SetIcon(IconWidget, g_TexturePositions.Goods[CostsGoodType], 44)
            
			local PlayersGoodAmount
			local ID = BCS.GetEntityIDToAddToOutStock(CostsGoodType)
				
			if _UseBCSCosts == true then
				PlayersGoodAmount = BCS.GetAmountOfGoodsInSettlement(CostsGoodType, BCS.CurrentPlayerID, BCS.MarketplaceGoodsCount)
			elseif _GoodsInSettlementBoolean == true then
				PlayersGoodAmount = GetPlayerGoodsInSettlement(CostsGoodType, BCS.CurrentPlayerID, true)
			else 
				local IsInOutStock, BuildingID           
				if CostsGoodType == Goods.G_Gold then
					BuildingID = Logic.GetHeadquarters(BCS.CurrentPlayerID)
					IsInOutStock = Logic.GetIndexOnOutStockByGoodType(BuildingID, CostsGoodType)
				else
					BuildingID = Logic.GetStoreHouse(BCS.CurrentPlayerID)
					IsInOutStock = Logic.GetIndexOnOutStockByGoodType(BuildingID, CostsGoodType)
				end
                
				if IsInOutStock ~= -1 then
					PlayersGoodAmount = Logic.GetAmountOnOutStockByGoodType(BuildingID, CostsGoodType)
				else
					BuildingID = GUI.GetSelectedEntity()
                    
					if BuildingID ~= nil then
						if Logic.GetIndexOnOutStockByGoodType(BuildingID, CostsGoodType) == nil then
							BuildingID = Logic.GetRefillerID(GUI.GetSelectedEntity())
						end
                        
						PlayersGoodAmount = Logic.GetAmountOnOutStockByGoodType(BuildingID, CostsGoodType)
					else
						PlayersGoodAmount = 0
					end
				end
			end		
			if PlayersGoodAmount == nil then
				PlayersGoodAmount = 0
			end
      
			local Color = ""           
			if PlayersGoodAmount < CostsGoodAmount then
				Color = "{@script:ColorRed}"
			end
            
			if CostsGoodAmount > 0 then
				XGUIEng.SetText(AmountWidget, "{center}" .. Color .. CostsGoodAmount)
			else
				XGUIEng.SetText(AmountWidget, "")
			end
			ContainerIndex = ContainerIndex + 1
		end
	end
end

BCS.HandlePlacementModeUpdate = function(_currentUpgradeCategory)
	local LastPlaced = _currentUpgradeCategory
	local Available = false
	
	if (LastPlaced == false) and (BCS.RoadCosts ~= nil) then --Road
		Available = BCS.AreResourcesAvailable(1, BCS.RoadMultiplier.First, BCS.RoadMultiplier.Second)
		if (Available == false) and (BCS.StreetMultiplier.CurrentX ~= 1 and BCS.StreetMultiplier.CurrentY ~= 1) then
			BCS.ShowOverlayWidget(true)
		else
			BCS.ShowOverlayWidget(false)
		end
	elseif (LastPlaced == true) and (BCS.TrailCosts ~= nil) then --Trail
		local CurrentAmountOfFirstGood, CurrentAmountOfSecondGood = BCS.CalculateStreetCosts()	
		
		BCS.ShowTooltipCostsOnly({BCS.TrailCosts[1], CurrentAmountOfFirstGood, BCS.TrailCosts[3], CurrentAmountOfSecondGood})
		-- Trail has no costs in original game, so we have to show the tooltip manually
		
		BCS.StreetMultiplier.First = CurrentAmountOfFirstGood
		BCS.StreetMultiplier.Second = CurrentAmountOfSecondGood
		
		Available = BCS.AreResourcesAvailable(4, CurrentAmountOfFirstGood, CurrentAmountOfSecondGood)

		if (Available == false) and (BCS.StreetMultiplier.CurrentX ~= 1 and BCS.StreetMultiplier.CurrentY ~= 1) then
			BCS.ShowOverlayWidget(true)
		else
			BCS.ShowOverlayWidget(false)
		end	
	elseif (LastPlaced == UpgradeCategories.PalisadeSegment) and (BCS.PalisadeCosts ~= nil) then 
		local Costs = {Logic.GetCostForWall(Entities.B_PalisadeSegment, Entities.B_PalisadeTurret, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
		
		Available = BCS.AreResourcesAvailable(3, Costs[2], Costs[4])
		if (Available == false) and (StartTurretX ~= 1 and StartTurretY ~= 1) then
			BCS.ShowOverlayWidget(true)
		else
			BCS.ShowOverlayWidget(false)
		end	
	elseif (LastPlaced == BCS.CurrentWallTypeForClimate) and (BCS.WallCosts ~= nil) then
		-- Just check for ME since all climate zones have the same costs anyway
		local Costs = {Logic.GetCostForWall(Entities.B_WallSegment_ME, Entities.B_WallTurret_ME, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
		Available = BCS.AreResourcesAvailable(2, Costs[2], Costs[4])
		if (Available == false) and (StartTurretX ~= 1 and StartTurretY ~= 1) then
			BCS.ShowOverlayWidget(true)
		else
			BCS.ShowOverlayWidget(false)
		end	
	else	
		local CostTable = BCS.GetCostByCostTable(LastPlaced)
		if (CostTable ~= nil and CostTable ~= 0) then
			if not (BCS.AreResourcesAvailable(LastPlaced)) then
				BCS.ShowOverlayWidget(true)
			else
				BCS.ShowOverlayWidget(false)
			end
		end	
	end
end

BCS.IsCurrentStateABuildingState = function(_StateNameID)
	local CurrentStateID = _StateNameID

	if ((CurrentStateID == GUI.GetStateNameByID("PlaceBuilding")) 
		or (CurrentStateID == GUI.GetStateNameByID("PlaceWallGate"))
		or (CurrentStateID == GUI.GetStateNameByID("PlaceWall"))
		or (CurrentStateID == GUI.GetStateNameByID("PlaceRoad"))) then
			return true;
	else
		return false;
	end
end

-- [[
	-- > This here is the function that initializes the whole Building Cost System
	-- > Has to be called before everything else
-- ]]

BCS.InitializeBuildingCostSystem = function()

	BCS.CurrentPlayerID = GUI.GetPlayerID();

	BCS.OverwriteAfterPlacement()
	BCS.OverwriteBuildClicked()
	BCS.OverwriteGetCostLogics()
	BCS.OverwriteVariableCostBuildings()
	BCS.OverwriteEndScreenCallback()
	BCS.FestivalCostsHandler()
	BCS.OverwriteTooltipHandling()
	BCS.OverwriteOptionalBugfixFunctions() --Not needed, just nice to have
	
	BCS.CurrentWallTypeForClimate = GetUpgradeCategoryForClimatezone("WallSegment")
	
	if BCS.PlacementUpdate == nil then
		BCS.PlacementUpdate = GUI_Construction.PlacementUpdate;
	end	
	GUI_Construction.PlacementUpdate = function()	
		BCS.HandlePlacementModeUpdate(g_LastPlacedParam)
		BCS.PlacementUpdate()	
	end
	
	if BCS.GameCallback_GUI_PlacementState == nil then
		BCS.GameCallback_GUI_PlacementState = GameCallback_GUI_PlacementState;
	end	
	GameCallback_GUI_PlacementState = function(_State, _Type)
		-- _Type = Building, Road, Wall, ...
		-- _State = Current Blocking State
		
		--This is needed because for some reason the Wall/Palisade Continue State does not call PlacementUpdate ?
		if BCS.IsInWallOrPalisadeContinueState == true then
			BCS.HandlePlacementModeUpdate(g_LastPlacedParam)
		end
		BCS.GameCallback_GUI_PlacementState(_State, _Type)
	end
	
	if BCS.GUI_StateChanged == nil then
		BCS.GUI_StateChanged = GameCallback_GUI_StateChanged;
	end	
	GameCallback_GUI_StateChanged = function(_StateNameID, _Armed)
		if not BCS.IsCurrentStateABuildingState(_StateNameID) then
			BCS.ShowOverlayWidget(false)		
			BCS.IsInWallOrPalisadeContinueState = false
			
			BCS.ResetTrailAndRoadCosts()
			BCS.ResetWallTurretPositions()
		end
		BCS.GUI_StateChanged(_StateNameID, _Armed)
	end
		
	-- Trails don't work when called directly 
	function KeyBindings_BuildLastPlaced()
		if g_LastPlacedFunction ~= nil and g_LastPlacedParam == true then -- Trail
			KeyBindings_BuildTrail()
		elseif g_LastPlacedFunction ~= nil and g_LastPlacedParam == false then -- Road
			KeyBindings_BuildStreet()
		elseif g_LastPlacedFunction ~= nil then
			g_LastPlacedFunction(g_LastPlacedParam)
		end
	end
		
	GUI.SendScriptCommand([[
		if BCS == nil then
			BCS = {}
			BCS.AreBuildingCostsAvailable = nil
		end
		
		if BCS.GameCallback_SettlerSpawned == nil then
			BCS.GameCallback_SettlerSpawned = GameCallback_SettlerSpawned;
		end
		GameCallback_SettlerSpawned = function(_PlayerID, _EntityID)
			BCS.GameCallback_SettlerSpawned(_PlayerID, _EntityID)	
			
			if (_PlayerID == ]]..BCS.CurrentPlayerID..[[) then
				if (Logic.IsEntityInCategory(_EntityID, EntityCategories.Worker) == 1) 
				or (Logic.GetEntityType(_EntityID) == Entities.U_OutpostConstructionWorker) 
				or (Logic.GetEntityType(_EntityID) == Entities.U_WallConstructionWorker) then
					Logic.ExecuteInLuaLocalState("BCS.GetLastPlacedBuildingIDForKnockDown(".._EntityID..")")
				end
			end
			
		end	
	
		if BCS.GameCallback_BuildingDestroyed == nil then
			BCS.GameCallback_BuildingDestroyed = GameCallback_BuildingDestroyed;
		end
		GameCallback_BuildingDestroyed = function(_EntityID, _PlayerID, _KnockedDown)
			BCS.GameCallback_BuildingDestroyed(_EntityID, _PlayerID, _KnockedDown)
			if (_KnockedDown == 1) and (_PlayerID == ]]..BCS.CurrentPlayerID..[[) then

				local IsReachable = CanEntityReachTarget(_PlayerID, Logic.GetStoreHouse(_PlayerID), _EntityID, nil, PlayerSectorTypes.Civil)
				-- Return nothing in case the building is not reachable
				if IsReachable == false then
					return;
				end

				Logic.ExecuteInLuaLocalState("BCS.RefundKnockDown(".._EntityID..")")
			end
		end
		
		if BCS.GameCallback_CanPlayerPlaceBuilding == nil then
			BCS.GameCallback_CanPlayerPlaceBuilding = GameCallback_CanPlayerPlaceBuilding;
		end
		GameCallback_CanPlayerPlaceBuilding = function(_PlayerID, _Type, _X, _Y)
			if (_PlayerID == ]]..BCS.CurrentPlayerID..[[) then
				if BCS.AreBuildingCostsAvailable ~= nil then
					return BCS.AreBuildingCostsAvailable
				else
					return BCS.GameCallback_CanPlayerPlaceBuilding(_PlayerID, _Type, _X, _Y)
				end
			else
				return BCS.GameCallback_CanPlayerPlaceBuilding(_PlayerID, _Type, _X, _Y)
			end
		end
	]])
	
	Framework.WriteToLog("BCS: Initialization Done! Version: "..BCS.CurrentBCSVersion)
end

BCS.OverwriteEndScreenCallback = function()
	if BCS.EndScreen_ExitGame == nil then
		BCS.EndScreen_ExitGame = EndScreen_ExitGame;
	end	
	EndScreen_ExitGame = function()
		GUI.CancelState()
		Message(XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_Resources"))
		Framework.WriteToLog("BCS: Resources Ran Out!")
	end
end

BCS.ShowOverlayWidget = function(_flag)
	if _flag == true then
		if (BCS.OverlayIsCurrentlyShown == false) or (XGUIEng.IsWidgetShownEx(BCS.OverlayWidget) == 0) then
			local ScreenSizeX, ScreenSizeY = GUI.GetScreenSize()
			XGUIEng.SetWidgetSize(BCS.OverlayWidget, ScreenSizeX * 2, ScreenSizeY * 2)
			XGUIEng.PushPage(BCS.OverlayWidget, false)
			XGUIEng.ShowAllSubWidgets(BCS.OverlayWidget, 1)
			XGUIEng.ShowWidget(BCS.OverlayWidget, 1)
			XGUIEng.ShowWidget('/EndScreen/EndScreen/Background', 0)
			XGUIEng.ShowWidget('/EndScreen/EndScreen/BG', 1)
			XGUIEng.SetMaterialColor("/EndScreen/EndScreen/BG", 0, 0, 0, 0, 0);
			XGUIEng.SetWidgetScreenPosition(BCS.OverlayWidget, -100, -100) --To be on the safe side ^^
			
			BCS.OverlayIsCurrentlyShown = true
			
			GUI.SendScriptCommand([[BCS.AreBuildingCostsAvailable = false]])
		end
	else
		if BCS.OverlayIsCurrentlyShown == true or (XGUIEng.IsWidgetShownEx(BCS.OverlayWidget) == 1) then
			XGUIEng.ShowAllSubWidgets(BCS.OverlayWidget, 0)
			XGUIEng.ShowWidget(BCS.OverlayWidget, 0)
			BCS.OverlayIsCurrentlyShown = false
			GUI.SendScriptCommand([[BCS.AreBuildingCostsAvailable = nil]])
		end
	end
end

BCS.CalculateVariableCosts = function(_startX, _startY, _endX, _endY)
	local xDistance = math.abs(_startX - _endX)
	local yDistance = math.abs(_startY - _endY)
	return ((math.sqrt((xDistance ^ 2) + (yDistance ^ 2))) / 1000)
end

BCS.CalculateStreetCosts = function()
	local posX, posY = GUI.Debug_GetMapPositionUnderMouse()
	if BCS.StreetMultiplier.CurrentX ~= 1 and BCS.StreetMultiplier.CurrentY ~= 1 then
		local Distance = BCS.CalculateVariableCosts(posX, posY, BCS.StreetMultiplier.CurrentX, BCS.StreetMultiplier.CurrentY)
		local FirstCostDistance = math.ceil(Distance * BCS.TrailCosts[2])
		local SecondCostDistance = math.ceil(Distance * BCS.TrailCosts[4])
		if FirstCostDistance < 1 then
			FirstCostDistance = 1
		end
		if SecondCostDistance < 1 then
			SecondCostDistance = 1
		end
		return FirstCostDistance, SecondCostDistance
	else
		return 1, 1
	end
end

BCS.ResetTrailAndRoadCosts = function()
	BCS.StreetMultiplier.First = 1
	BCS.StreetMultiplier.Second = 1

	BCS.StreetMultiplier.CurrentX = 1
	BCS.StreetMultiplier.CurrentY = 1
	
	BCS.RoadMultiplier.First = 1
	BCS.RoadMultiplier.Second = 1
	
	BCS.RoadMultiplier.CurrentActualCost = 1
end

BCS.ResetWallTurretPositions = function()
	StartTurretX = 1 
	StartTurretY = 1
	
	EndTurretX = 1
	EndTurretY = 1
end

BCS.OverwriteOptionalBugfixFunctions = function()
	if BCS.BuildingNameUpdate == nil then
		BCS.BuildingNameUpdate = GUI_BuildingInfo.BuildingNameUpdate;	
	end
	GUI_BuildingInfo.BuildingNameUpdate = function()
		BCS.BuildingNameUpdate()
		local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
		if XGUIEng.GetText(CurrentWidgetID) == "{center}B_Cathedral_Big" then
			local CurrentLanguage = Network.GetDesiredLanguage()
			if CurrentLanguage == "de" then
				XGUIEng.SetText(CurrentWidgetID, "{center}Kathedrale")
			else
				XGUIEng.SetText(CurrentWidgetID, "{center}Cathedral")
			end
		end
	end
end

BCS.FestivalCostsHandler = function()

	if BCS.GetFestivalCost == nil then
		BCS.GetFestivalCost = Logic.GetFestivalCost;	
	end
	Logic.GetFestivalCost = function(_PlayerID, _FestivalIndex)
		if BCS.CurrentFestivalCosts == nil then
			return BCS.GetFestivalCost(_PlayerID, _FestivalIndex)
		else
			local Costs = {BCS.GetFestivalCost(_PlayerID, _FestivalIndex)}
			return BCS.CurrentFestivalCosts[1], math.ceil(Costs[2] * BCS.CurrentFestivalCosts[2]), BCS.CurrentFestivalCosts[3], BCS.CurrentFestivalCosts[4]
		end
	end

	if BCS.StartFestivalClicked == nil then
		BCS.StartFestivalClicked = GUI_BuildingButtons.StartFestivalClicked;	
	end
	GUI_BuildingButtons.StartFestivalClicked = function(_FestivalIndex)
		if BCS.CurrentFestivalCosts == nil then
			BCS.StartFestivalClicked(_FestivalIndex)
		else
			local PlayerID = BCS.CurrentPlayerID;
			local MarketID = GUI.GetSelectedEntity()
	
			if MarketID ~= Logic.GetMarketplace(PlayerID) then
				BCS.StartFestivalClicked(_FestivalIndex)
				return;
			end
			
			local CanBuyBoolean = BCS.AreFestivalResourcesAvailable(PlayerID, _FestivalIndex)

			if CanBuyBoolean == true then
				Sound.FXPlay2DSound("ui\\menu_click")
				
				local Type, OriginalAmount = BCS.GetFestivalCost(PlayerID, _FestivalIndex)
				local Amount = math.ceil(OriginalAmount * BCS.CurrentFestivalCosts[2])
				
				Amount = Amount - OriginalAmount
				
				GUI.RemoveGoodFromStock(BCS.GetEntityIDToAddToOutStock(Goods.G_Gold), Goods.G_Gold, Amount)	

				-- Can be city goods too
				local CurrentID = BCS.GetEntityIDToAddToOutStock(BCS.CurrentFestivalCosts[3])
				if CurrentID == false then
					BCS.RemoveCostsFromOutStockCityGoods(BCS.CurrentFestivalCosts[3], BCS.CurrentFestivalCosts[4], PlayerID, false)
				else
					GUI.RemoveGoodFromStock(CurrentID, BCS.CurrentFestivalCosts[3], BCS.CurrentFestivalCosts[4])				
				end
			
				GUI.StartFestival(PlayerID, _FestivalIndex)
				StartEventMusic(MusicSystem.EventFestivalMusic, PlayerID)
				StartKnightVoiceForPermanentSpecialAbility(Entities.U_KnightSong)
				GUI.AddBuff(Buffs.Buff_Festival)
				
				Framework.WriteToLog("BCS: Festival Started! Gold Amount: "..tostring(Amount))
			else
				Message(XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_Resources"))
			end
		end
	end
end

BCS.AreFestivalResourcesAvailable = function(_PlayerID, _FestivalIndex)
	local AmountOfFirstGood, AmountOfSecondGood;
	local Costs = {BCS.GetFestivalCost(_PlayerID, _FestivalIndex)}
	
	-- First one is always gold
	AmountOfFirstGood = Logic.GetAmountOnOutStockByGoodType(BCS.GetEntityIDToAddToOutStock(BCS.CurrentFestivalCosts[1]), BCS.CurrentFestivalCosts[1])
	
	local CurrentID = BCS.GetEntityIDToAddToOutStock(BCS.CurrentFestivalCosts[3])
	if CurrentID == false then
		AmountOfSecondGood = BCS.GetAmountOfGoodsInSettlement(BCS.CurrentFestivalCosts[3], _PlayerID, false)
	else
		AmountOfSecondGood = Logic.GetAmountOnOutStockByGoodType(CurrentID, BCS.CurrentFestivalCosts[3])
	end
	
	if (AmountOfFirstGood < math.ceil(Costs[2] * BCS.CurrentFestivalCosts[2]) or AmountOfSecondGood < BCS.CurrentFestivalCosts[4]) then
		return false
	else
		return true
	end
end
--#EOF--