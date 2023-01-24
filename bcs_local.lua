----------------------------------------------------------------------------------------------------------------------
-----------------------------**BuildingCostSystem (BCS) Created By Eisenmonoxid**-------------------------------------
----------------------------------------------------------------------------------------------------------------------
OwnBuildingCostSystem = {}

OwnBuildingCostSystem.BuildingCosts = {} -- Contains all new costs
OwnBuildingCostSystem.BuildingIDTable = {} -- Contains Building IDs and the corresponding costs

OwnBuildingCostSystem.RoadMultiplier = {}
OwnBuildingCostSystem.RoadMultiplier.First = 1
OwnBuildingCostSystem.RoadMultiplier.Second = 1
OwnBuildingCostSystem.RoadMultiplier.CurrentActualCost = 1

OwnBuildingCostSystem.StreetMultiplier = {}
OwnBuildingCostSystem.StreetMultiplier.First = 1
OwnBuildingCostSystem.StreetMultiplier.Second = 1
OwnBuildingCostSystem.StreetMultiplier.CurrentX = 1
OwnBuildingCostSystem.StreetMultiplier.CurrentY = 1

OwnBuildingCostSystem.RoadCosts = nil
OwnBuildingCostSystem.TrailCosts = nil
OwnBuildingCostSystem.PalisadeCosts = nil
OwnBuildingCostSystem.WallCosts = nil

OwnBuildingCostSystem.IsCurrentBuildingInCostTable = false
OwnBuildingCostSystem.CurrentExpectedBuildingType = nil
OwnBuildingCostSystem.CurrentKnockDownFactor = 0.5 -- Half the new good cost is refunded at knock down
OwnBuildingCostSystem.CurrentOriginalGoodKnockDownFactor = 0.2
OwnBuildingCostSystem.IsInWallOrPalisadeContinueState = false
OwnBuildingCostSystem.MarketplaceGoodsCount = true -- Changing this is not yet implemented
OwnBuildingCostSystem.RefundCityGoods = true

StartTurretX = 1 -- Variables from the Original Lua Game Script
StartTurretY = 1

EndTurretX = 1
EndTurretY = 1

OwnBuildingCostSystem.CurrentFestivalCosts = nil
OwnBuildingCostSystem.HuntableAnimals = false
OwnBuildingCostSystem.HunterButtonID = nil

OwnBuildingCostSystem.OverlayWidget = "/EndScreen"
OwnBuildingCostSystem.OverlayIsCurrentlyShown = false
OwnBuildingCostSystem.EnsuredQuestSystemBehaviorCompatibility = false
OwnBuildingCostSystem.CurrentBCSVersion = "3.2 - 24.01.2023 23:22"

----------------------------------------------------------------------------------------------------------------------
--These functions are exported to Userspace---------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

OwnBuildingCostSystem.EditBuildingCosts = function(_upgradeCategory, _originalCostAmount, _newGood, _newGoodAmount)
	if _originalCostAmount == nil then
		OwnBuildingCostSystem.UpdateCostsInCostTable(_upgradeCategory, nil)
		return;
	end
	
	--Check for Unloaded Script
	assert(type(OwnBuildingCostSystem.GetEntityTypeFullCost) == "function")
	
	--Check for Invalid GoodAmount
	assert(_newGoodAmount >= 1)
	local AmountOfTypes, FirstBuildingType = Logic.GetBuildingTypesInUpgradeCategory(_upgradeCategory)
	local Costs = {OwnBuildingCostSystem.GetEntityTypeFullCost(FirstBuildingType)}
	assert(_originalCostAmount >= Costs[2])
	
	local CurrentBuildingCost = {_upgradeCategory, _originalCostAmount, _newGood, _newGoodAmount}
	local CostTable = OwnBuildingCostSystem.GetCostByCostTable(_upgradeCategory);
	if (CostTable == nil) then
		table.insert(OwnBuildingCostSystem.BuildingCosts, CurrentBuildingCost)
	else
		OwnBuildingCostSystem.UpdateCostsInCostTable(_upgradeCategory, CurrentBuildingCost)
	end
end

OwnBuildingCostSystem.EditRoadCosts = function(_originalCostFactor, _newGood, _newGoodFactor)
	if _originalCostFactor == nil then
		OwnBuildingCostSystem.RoadCosts = nil
		return;
	end
	assert(_originalCostFactor >= 3)
	OwnBuildingCostSystem.RoadCosts = {Goods.G_Stone, _originalCostFactor, _newGood, _newGoodFactor}
end

OwnBuildingCostSystem.EditWallCosts = function(_originalCostFactor, _newGood, _newGoodFactor)
	if _originalCostFactor == nil then
		OwnBuildingCostSystem.WallCosts = nil
		return;
	end
	assert(_originalCostFactor >= 3)
	OwnBuildingCostSystem.WallCosts = {Goods.G_Stone, _originalCostFactor, _newGood, _newGoodFactor}
end

OwnBuildingCostSystem.EditPalisadeCosts = function(_originalCostFactor, _newGood, _newGoodFactor)
	if _originalCostFactor == nil then
		OwnBuildingCostSystem.PalisadeCosts = nil
		return;
	end
	assert(_originalCostFactor >= 3)
	OwnBuildingCostSystem.PalisadeCosts = {Goods.G_Wood, _originalCostFactor, _newGood, _newGoodFactor}
end

OwnBuildingCostSystem.EditTrailCosts = function(_firstGood, _originalCostFactor, _secondGood, _newGoodFactor)
	if _originalCostFactor == nil then
		OwnBuildingCostSystem.TrailCosts = nil
		return;
	end
	OwnBuildingCostSystem.TrailCosts = {_firstGood, _originalCostFactor, _secondGood, _newGoodFactor}
end

OwnBuildingCostSystem.SetKnockDownFactor = function(_factorOriginalGood, _factorNewGood) --0.5 is half of the cost
	assert(_factorOriginalGood < 1 and _factorNewGood < 1)
	OwnBuildingCostSystem.CurrentKnockDownFactor = _factorNewGood
	OwnBuildingCostSystem.CurrentOriginalGoodKnockDownFactor = _factorOriginalGood
end

OwnBuildingCostSystem.EditFestivalCosts = function(_originalCostFactor, _secondGood, _newGoodFactor)
	if _originalCostFactor == nil then
		OwnBuildingCostSystem.CurrentFestivalCosts = nil
		return;
	end
	assert(_originalCostFactor > 1)
	OwnBuildingCostSystem.CurrentFestivalCosts = {Goods.G_Gold, _originalCostFactor, _secondGood, _newGoodFactor}
end

OwnBuildingCostSystem.ActivateHuntableAnimals = function(_flag)
	OwnBuildingCostSystem.HuntableAnimals = _flag
end

OwnBuildingCostSystem.SetUseMarketplaceGoodsAsCosts = function(_flag)
	--OwnBuildingCostSystem.MarketplaceGoodsCount = _flag --> Not yet implemented
	return; 
end

OwnBuildingCostSystem.SetRefundCityGoods = function(_flag)
	OwnBuildingCostSystem.RefundCityGoods = _flag
end

----------------------------------------------------------------------------------------------------------------------
--These functions are used internally and should not be called by the User--------------------------------------------
----------------------------------------------------------------------------------------------------------------------

OwnBuildingCostSystem.GetCostByCostTable = function(_buildingType)
	for Type, CurrentCostTable in pairs(OwnBuildingCostSystem.BuildingCosts) do 
		if (CurrentCostTable[1] == _buildingType) then
			return CurrentCostTable;
		end
	end
	return nil
end

OwnBuildingCostSystem.UpdateCostsInCostTable = function(_buildingType, _newCostTable)
	for Type, CurrentCostTable in pairs(OwnBuildingCostSystem.BuildingCosts) do 
		if (CurrentCostTable[1] == _buildingType) then
			if _newCostTable == nil then
				OwnBuildingCostSystem.BuildingCosts[Type] = nil
			else
				OwnBuildingCostSystem.BuildingCosts[Type] = {_newCostTable[1], _newCostTable[2], _newCostTable[3], _newCostTable[4]}
			end
			break;
		end
	end
end

OwnBuildingCostSystem.GetCostByBuildingIDTable = function(_EntityID)
	for Type, CurrentCostTable in pairs(OwnBuildingCostSystem.BuildingIDTable) do 
		if (CurrentCostTable[1] == _EntityID) then
			return CurrentCostTable, Type;
		end
	end
	return nil
end

OwnBuildingCostSystem.AddBuildingToIDTable = function(_EntityID, _upgradeCategory)
	local AmountOfTypes, FirstBuildingType = Logic.GetBuildingTypesInUpgradeCategory(_upgradeCategory)
	local FGood, FAmount, SGood, SAmount = Logic.GetEntityTypeFullCost(FirstBuildingType)
	table.insert(OwnBuildingCostSystem.BuildingIDTable, {_EntityID, FGood, FAmount, SGood, SAmount})
end

----------------------------------------------------------------------------------------------------------------------
--These functions handle the Ingame Resource Management---------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

OwnBuildingCostSystem.RemoveCostsFromOutStock = function(_buildingType)
	local PlayerID = GUI.GetPlayerID()
	local AmountOfTypes, FirstBuildingType = Logic.GetBuildingTypesInUpgradeCategory(_buildingType)
	local FGood, FAmount, SGood, SAmount = Logic.GetEntityTypeFullCost(FirstBuildingType)
	local OrigFGood, OrigFAmount, OrigSGood, OrigSAmount = OwnBuildingCostSystem.GetEntityTypeFullCost(FirstBuildingType)
	
	if OrigSAmount == nil then OrigSAmount = 0 end
	
	local FAmountToRemove = (FAmount - OrigFAmount)
	local SAmountToRemove = (SAmount - OrigSAmount)
	local FGoodCurrentAmount, SGoodCurrentAmount

	local CurrentID = OwnBuildingCostSystem.GetEntityIDToAddToOutStock(FGood)
	if CurrentID == false then
		OwnBuildingCostSystem.RemoveCostsFromOutStockCityGoods(FGood, FAmountToRemove)
	else
		FGoodCurrentAmount = Logic.GetAmountOnOutStockByGoodType(CurrentID, FGood)
		if FGoodCurrentAmount < FAmountToRemove then
			GUI.RemoveGoodFromStock(CurrentID, FGood, FGoodCurrentAmount)
		else
			GUI.RemoveGoodFromStock(CurrentID, FGood, FAmountToRemove)
		end
	end
	
	CurrentID = OwnBuildingCostSystem.GetEntityIDToAddToOutStock(SGood)
	if CurrentID == false then
		OwnBuildingCostSystem.RemoveCostsFromOutStockCityGoods(SGood, SAmountToRemove)
	else
		SGoodCurrentAmount = Logic.GetAmountOnOutStockByGoodType(CurrentID, SGood)
		if SGoodCurrentAmount < SAmountToRemove then
			GUI.RemoveGoodFromStock(CurrentID, SGood, SGoodCurrentAmount)
		else
			GUI.RemoveGoodFromStock(CurrentID, SGood, SAmountToRemove)
		end	
	end
end

OwnBuildingCostSystem.RemoveCostsFromOutStockCityGoods = function(_goodType, _goodAmount)
	local PlayerID = GUI.GetPlayerID()
	local AmountToRemove = _goodAmount
	local BuildingTypes, Buildings
	
	BuildingTypes = {Logic.GetBuildingTypesProducingGood(_goodType)}
	Buildings = GetPlayerEntities(PlayerID, BuildingTypes[1])

	local CurrentOutStock = 0
    for i = 1, #Buildings, 1 do
		CurrentOutStock = Logic.GetAmountOnOutStockByGoodType(Buildings[i], _goodType)
		if CurrentOutStock <= AmountToRemove then
			GUI.RemoveGoodFromStock(Buildings[i], _goodType, CurrentOutStock)
			AmountToRemove = AmountToRemove - CurrentOutStock
		else
			GUI.RemoveGoodFromStock(Buildings[i], _goodType, AmountToRemove)
			break;
		end
    end
end

OwnBuildingCostSystem.AreResourcesAvailable = function(_upgradeCategory, _FGoodAmount, _SGoodAmount)
	local PlayerID = GUI.GetPlayerID()
	local AmountOfTypes, FirstBuildingType, Costs
	
	if _FGoodAmount ~= nil and _SGoodAmount ~= nil then
		if _upgradeCategory == 1 then --Road
			Costs = OwnBuildingCostSystem.RoadCosts
		elseif _upgradeCategory == 2 then--Wall
			Costs = OwnBuildingCostSystem.WallCosts
		elseif _upgradeCategory == 3 then --Palisade
			Costs = OwnBuildingCostSystem.PalisadeCosts
		else --Street/Trail
			Costs = OwnBuildingCostSystem.TrailCosts
		end
	else --Normal Buildings
		AmountOfTypes, FirstBuildingType = Logic.GetBuildingTypesInUpgradeCategory(_upgradeCategory)
		Costs = {Logic.GetEntityTypeFullCost(FirstBuildingType)}
		_FGoodAmount = Costs[2]
		_SGoodAmount = Costs[4]
	end
	
	local AmountOfFirstGood, AmountOfSecondGood
	AmountOfFirstGood = GetPlayerGoodsInSettlement(Costs[1], PlayerID, OwnBuildingCostSystem.MarketplaceGoodsCount)
	AmountOfSecondGood = GetPlayerGoodsInSettlement(Costs[3], PlayerID, OwnBuildingCostSystem.MarketplaceGoodsCount)
	
	if (AmountOfFirstGood < _FGoodAmount or AmountOfSecondGood < _SGoodAmount) then
		return false
	else
		return true
	end
end

OwnBuildingCostSystem.RefundKnockDown = function(_entityID)
	local PlayerID = GUI.GetPlayerID()
	local CostTable, Type = OwnBuildingCostSystem.GetCostByBuildingIDTable(_entityID) --Normal Building or Wall/PalisadeGate

	if CostTable == nil then -- Building has no costs
		return
	end
	
	local IDFirstGood = OwnBuildingCostSystem.GetEntityIDToAddToOutStock(CostTable[2])
	local IDSecondGood = OwnBuildingCostSystem.GetEntityIDToAddToOutStock(CostTable[4])

	
	if IDFirstGood == false then -- CityGood
		if OwnBuildingCostSystem.RefundCityGoods == true then
			OwnBuildingCostSystem.RefundKnockDownForCityGoods(CostTable[2], (Round(CostTable[3] * OwnBuildingCostSystem.CurrentOriginalGoodKnockDownFactor)))
		end
	else
		GUI.SendScriptCommand([[
			Logic.AddGoodToStock(]]..IDFirstGood..[[, ]]..CostTable[2]..[[, ]]..(Round(CostTable[3] * OwnBuildingCostSystem.CurrentOriginalGoodKnockDownFactor))..[[)	
		]])
	end
	if IDSecondGood == false then -- CityGood
		if OwnBuildingCostSystem.RefundCityGoods == true then
			OwnBuildingCostSystem.RefundKnockDownForCityGoods(CostTable[4], (Round(CostTable[5] * OwnBuildingCostSystem.CurrentKnockDownFactor)))
		end
	else
		GUI.SendScriptCommand([[
			Logic.AddGoodToStock(]]..IDSecondGood..[[, ]]..CostTable[4]..[[, ]]..(Round(CostTable[5] * OwnBuildingCostSystem.CurrentKnockDownFactor))..[[)	
		]])
	end
	
	OwnBuildingCostSystem.BuildingIDTable[Type] = nil -- Delete the Entity ID from the table
	
	Framework.WriteToLog("BCS: KnockDown for Building "..tostring(_entityID).." done! Size of KnockDownList: "..tostring(#OwnBuildingCostSystem.BuildingIDTable))
end

OwnBuildingCostSystem.RefundKnockDownForCityGoods = function(_goodType, _goodAmount)
	local PlayerID = GUI.GetPlayerID()
	local AmountToRemove = _goodAmount
	local BuildingTypes, Buildings
	
	BuildingTypes = {Logic.GetBuildingTypesProducingGood(_goodType)}
	Buildings = GetPlayerEntities(PlayerID, BuildingTypes[1])

	local CurrentOutStock, CurrentMaxOutStock = 0, 0
    for i = 1, #Buildings, 1 do
		CurrentOutStock = Logic.GetAmountOnOutStockByGoodType(Buildings[i], _goodType)
		CurrentMaxOutStock = Logic.GetMaxAmountOnStock(Buildings[i])
		if CurrentOutStock < CurrentMaxOutStock then
			local FreeStock = CurrentMaxOutStock - CurrentOutStock
			if FreeStock > AmountToRemove then
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

OwnBuildingCostSystem.GetEntityIDToAddToOutStock = function(_goodType)
	local PlayerID = GUI.GetPlayerID()
	
	if _goodType == Goods.G_Gold then 
		return Logic.GetHeadquarters(PlayerID) 
	end
	
	if Logic.GetIndexOnOutStockByGoodType(Logic.GetStoreHouse(PlayerID), _goodType) ~= -1 then
		return Logic.GetStoreHouse(PlayerID)
	end
	
	--Check here for Buildings, when player uses production goods as building material
	if Logic.GetGoodCategoryForGoodType(_goodType) ~= GoodCategories.GC_Resource then
		return false	
	end
	
	return nil
end

OwnBuildingCostSystem.GetCurrentlyGlobalBuilding = function(_EntityID)
	Framework.WriteToLog("BCS: Job "..tostring(_EntityID).." Created!")
	local WorkPlaceID = Logic.GetSettlersWorkBuilding(_EntityID)
	if WorkPlaceID ~= 0 and WorkPlaceID ~= nil then
		Framework.WriteToLog("BCS: Job "..tostring(_EntityID).." has BuildingType: " ..tostring(Logic.GetEntityType(WorkPlaceID)) .." - Expected: "..tostring(OwnBuildingCostSystem.CurrentExpectedBuildingType))
		if OwnBuildingCostSystem.CurrentExpectedBuildingType ~= nil and Logic.GetEntityType(WorkPlaceID) == OwnBuildingCostSystem.CurrentExpectedBuildingType then
			local UpgradeCategory = Logic.GetUpgradeCategoryByBuildingType(Logic.GetEntityType(WorkPlaceID))
			if UpgradeCategory == g_LastPlacedParam then
				OwnBuildingCostSystem.AddBuildingToIDTable(WorkPlaceID, UpgradeCategory)
				OwnBuildingCostSystem.CurrentExpectedBuildingType = nil
				Framework.WriteToLog("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: Building Added To ID Table: " ..tostring(WorkPlaceID))
				return true
			else
				Framework.WriteToLog("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: UpgradeCategory was not the same as g_LastPlacedParam!")
				return true
			end
		else
			Framework.WriteToLog("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: CurrentExpectedBuildingType either nil or ~= WorkplaceID-Type!")
			return true
		end
	end
	if not IsExisting(_EntityID) then
		Framework.WriteToLog("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: Worker Entity was deleted!")
		return true
	elseif string.find(Logic.GetEntityTypeName(Logic.GetEntityType(_EntityID)), 'NPC') then
		Framework.WriteToLog("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: Worker was an NPC - Settler!")
		return true
	elseif Logic.GetTaskHistoryEntry(_EntityID, 0) ~= 1 and Logic.GetTaskHistoryEntry(_EntityID, 0) ~= 9 then
		Framework.WriteToLog("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: TaskHistoryEntry was not 1 or 9 (Just Spawned/BuildingPhase)")
		return true
	elseif OwnBuildingCostSystem.CurrentExpectedBuildingType == nil then
		Framework.WriteToLog("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: CurrentExpectedBuildingType was nil!")
		return true
	end
end

----------------------------------------------------------------------------------------------------------------------
--Hacking the game functions here-------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

OwnBuildingCostSystem.HasCurrentBuildingOwnBuildingCosts = function(_BuildingType)
	local CostTable = OwnBuildingCostSystem.GetCostByCostTable(_BuildingType)
	if (CostTable == nil) then
		OwnBuildingCostSystem.SetAwaitingVariable(false)
		OwnBuildingCostSystem.CurrentExpectedBuildingType = nil
	else
		local AmountOfTypes, FirstBuildingType = Logic.GetBuildingTypesInUpgradeCategory(_BuildingType)
		OwnBuildingCostSystem.CurrentExpectedBuildingType = FirstBuildingType
		OwnBuildingCostSystem.SetAwaitingVariable(true)
		Framework.WriteToLog("BCS: Building Custom with Type: "..tostring(FirstBuildingType))
	end
end
OwnBuildingCostSystem.SetAwaitingVariable = function(_isAwaiting)
	OwnBuildingCostSystem.IsCurrentBuildingInCostTable = _isAwaiting
end
OwnBuildingCostSystem.GetAwaitingVariable = function()
	return OwnBuildingCostSystem.IsCurrentBuildingInCostTable
end

OwnBuildingCostSystem.OverwriteAfterPlacement = function()
	if OwnBuildingCostSystem.GameCallback_GUI_AfterBuildingPlacement == nil then
		OwnBuildingCostSystem.GameCallback_GUI_AfterBuildingPlacement = GameCallback_GUI_AfterBuildingPlacement;
	end
    GameCallback_GUI_AfterBuildingPlacement = function()
		if (OwnBuildingCostSystem.GetAwaitingVariable() == true) then
			OwnBuildingCostSystem.RemoveCostsFromOutStock(g_LastPlacedParam)
			OwnBuildingCostSystem.SetAwaitingVariable(false)
		end
        OwnBuildingCostSystem.GameCallback_GUI_AfterBuildingPlacement();
    end
	
	if OwnBuildingCostSystem.GameCallback_GUI_AfterWallGatePlacement == nil then
		OwnBuildingCostSystem.GameCallback_GUI_AfterWallGatePlacement = GameCallback_GUI_AfterWallGatePlacement;
	end
    GameCallback_GUI_AfterWallGatePlacement = function()
		if (OwnBuildingCostSystem.GetAwaitingVariable() == true) then
			OwnBuildingCostSystem.RemoveCostsFromOutStock(g_LastPlacedParam);
			OwnBuildingCostSystem.SetAwaitingVariable(false)
		end
        OwnBuildingCostSystem.GameCallback_GUI_AfterWallGatePlacement();
    end
	
	if OwnBuildingCostSystem.GameCallback_GUI_AfterRoadPlacement == nil then
		OwnBuildingCostSystem.GameCallback_GUI_AfterRoadPlacement = GameCallback_GUI_AfterRoadPlacement;
	end
    GameCallback_GUI_AfterRoadPlacement = function()
		if g_LastPlacedParam == false then --Road
			if (OwnBuildingCostSystem.RoadCosts ~= nil) then
				GUI.RemoveGoodFromStock(OwnBuildingCostSystem.GetEntityIDToAddToOutStock(OwnBuildingCostSystem.RoadCosts[1]), OwnBuildingCostSystem.RoadCosts[1], OwnBuildingCostSystem.RoadMultiplier.First - OwnBuildingCostSystem.RoadMultiplier.CurrentActualCost)
				GUI.RemoveGoodFromStock(OwnBuildingCostSystem.GetEntityIDToAddToOutStock(OwnBuildingCostSystem.RoadCosts[3]), OwnBuildingCostSystem.RoadCosts[3], OwnBuildingCostSystem.RoadMultiplier.Second)	
			end
		else --Trail
			if (OwnBuildingCostSystem.TrailCosts ~= nil) then
				GUI.RemoveGoodFromStock(OwnBuildingCostSystem.GetEntityIDToAddToOutStock(OwnBuildingCostSystem.TrailCosts[1]), OwnBuildingCostSystem.TrailCosts[1], OwnBuildingCostSystem.StreetMultiplier.First)
				GUI.RemoveGoodFromStock(OwnBuildingCostSystem.GetEntityIDToAddToOutStock(OwnBuildingCostSystem.TrailCosts[3]), OwnBuildingCostSystem.TrailCosts[3], OwnBuildingCostSystem.StreetMultiplier.Second)	
			end
		end
		OwnBuildingCostSystem.ResetTrailAndRoadCosts()
        OwnBuildingCostSystem.GameCallback_GUI_AfterRoadPlacement();
    end
	
	if OwnBuildingCostSystem.GameCallback_GUI_AfterWallPlacement == nil then
		OwnBuildingCostSystem.GameCallback_GUI_AfterWallPlacement = GameCallback_GUI_AfterWallPlacement;
	end
    GameCallback_GUI_AfterWallPlacement = function()
		if g_LastPlacedParam == 49 then --Palisade
			if (OwnBuildingCostSystem.PalisadeCosts ~= nil) then
				local Costs = {Logic.GetCostForWall(113, 110, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
				local OriginalCosts = {OwnBuildingCostSystem.GetCostForWall(113, 110, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
				GUI.RemoveGoodFromStock(OwnBuildingCostSystem.GetEntityIDToAddToOutStock(OwnBuildingCostSystem.PalisadeCosts[1]), OwnBuildingCostSystem.PalisadeCosts[1], Costs[2] - OriginalCosts[2])
				GUI.RemoveGoodFromStock(OwnBuildingCostSystem.GetEntityIDToAddToOutStock(OwnBuildingCostSystem.PalisadeCosts[3]), OwnBuildingCostSystem.PalisadeCosts[3], Costs[4])	
			end
		else --Wall
			if (OwnBuildingCostSystem.WallCosts ~= nil) then
				local Costs = {Logic.GetCostForWall(140, 141, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
				local OriginalCosts = {OwnBuildingCostSystem.GetCostForWall(140, 141, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
				GUI.RemoveGoodFromStock(OwnBuildingCostSystem.GetEntityIDToAddToOutStock(OwnBuildingCostSystem.WallCosts[1]), OwnBuildingCostSystem.WallCosts[1], Costs[2] - OriginalCosts[2])
				GUI.RemoveGoodFromStock(OwnBuildingCostSystem.GetEntityIDToAddToOutStock(OwnBuildingCostSystem.WallCosts[3]), OwnBuildingCostSystem.WallCosts[3], Costs[4])	
			end
		end
		OwnBuildingCostSystem.ResetWallTurretPositions()
		OwnBuildingCostSystem.IsInWallOrPalisadeContinueState = false
        OwnBuildingCostSystem.GameCallback_GUI_AfterWallPlacement();
    end
end
OwnBuildingCostSystem.OverwriteBuildClicked = function()
	if OwnBuildingCostSystem.BuildClicked == nil then
		OwnBuildingCostSystem.BuildClicked = GUI_Construction.BuildClicked;
	end	
	GUI_Construction.BuildClicked = function(_BuildingType)
		GUI.CancelState()
		OwnBuildingCostSystem.HasCurrentBuildingOwnBuildingCosts(_BuildingType)
		g_LastPlacedParam = _BuildingType
		OwnBuildingCostSystem.IsInWallOrPalisadeContinueState = false
		OwnBuildingCostSystem.BuildClicked(_BuildingType)
	end
	
	if OwnBuildingCostSystem.BuildWallClicked == nil then
		OwnBuildingCostSystem.BuildWallClicked = GUI_Construction.BuildWallClicked;
	end	
	GUI_Construction.BuildWallClicked = function(_BuildingType)
	    if _BuildingType == nil then
			_BuildingType = GetUpgradeCategoryForClimatezone("WallSegment")
		end
		GUI.CancelState()
		OwnBuildingCostSystem.ResetWallTurretPositions()
		g_LastPlacedParam = _BuildingType
		OwnBuildingCostSystem.IsInWallOrPalisadeContinueState = false
		OwnBuildingCostSystem.BuildWallClicked(_BuildingType)
	end
	
	if OwnBuildingCostSystem.BuildWallGateClicked == nil then
		OwnBuildingCostSystem.BuildWallGateClicked = GUI_Construction.BuildWallGateClicked;
	end	
	GUI_Construction.BuildWallGateClicked = function(_BuildingType)
	    if _BuildingType == nil then
			_BuildingType = GetUpgradeCategoryForClimatezone("WallGate")
		end
		GUI.CancelState()
		OwnBuildingCostSystem.HasCurrentBuildingOwnBuildingCosts(_BuildingType)
		g_LastPlacedParam = _BuildingType
		OwnBuildingCostSystem.BuildWallGateClicked(_BuildingType)
	end
	
	if OwnBuildingCostSystem.BuildStreetClicked == nil then
		OwnBuildingCostSystem.BuildStreetClicked = GUI_Construction.BuildStreetClicked;
	end	
	GUI_Construction.BuildStreetClicked = function(_IsTrail)
		OwnBuildingCostSystem.ResetTrailAndRoadCosts()
	    if _IsTrail == nil then
			_IsTrail = false
		end
		GUI.CancelState()
		OwnBuildingCostSystem.SetAwaitingVariable(false)
		g_LastPlacedParam = _IsTrail
		OwnBuildingCostSystem.BuildStreetClicked(_IsTrail)
	end
	
	if OwnBuildingCostSystem.ContinueWallClicked == nil then
		OwnBuildingCostSystem.ContinueWallClicked = GUI_BuildingButtons.ContinueWallClicked;
	end	
	GUI_BuildingButtons.ContinueWallClicked = function()
		GUI.CancelState()
		OwnBuildingCostSystem.ResetWallTurretPositions()
		
		local TurretID = GUI.GetSelectedEntity()
		local TurretType = Logic.GetEntityType(TurretID)
		local UpgradeCategory = UpgradeCategories.PalisadeSegment

		if TurretType ~= Entities.B_PalisadeTurret
			and TurretType ~= Entities.B_PalisadeGate_Turret_L
			and TurretType ~= Entities.B_PalisadeGate_Turret_R then
				UpgradeCategory = GetUpgradeCategoryForClimatezone("WallSegment")
		end
		g_LastPlacedParam = UpgradeCategory
		OwnBuildingCostSystem.IsInWallOrPalisadeContinueState = true
		
		OwnBuildingCostSystem.ContinueWallClicked()
	end
end
OwnBuildingCostSystem.OverwriteBuildAbort = function()
	if OwnBuildingCostSystem.ConstructWallAbort == nil then
		OwnBuildingCostSystem.ConstructWallAbort = GameCallBack_GUI_ConstructWallAbort;
	end	
	GameCallBack_GUI_ConstructWallAbort = function()
		OwnBuildingCostSystem.ResetWallTurretPositions()
		OwnBuildingCostSystem.IsInWallOrPalisadeContinueState = false
		OwnBuildingCostSystem.ConstructWallAbort()
	end
	
	if OwnBuildingCostSystem.ConstructRoadAbort == nil then
		OwnBuildingCostSystem.ConstructRoadAbort = GameCallback_GUI_ConstructRoadAbort;
	end	
	GameCallback_GUI_ConstructRoadAbort = function()
		OwnBuildingCostSystem.ResetTrailAndRoadCosts()
		OwnBuildingCostSystem.ConstructRoadAbort()
	end
end
OwnBuildingCostSystem.OverwriteGetCostLogics = function()
	if OwnBuildingCostSystem.GetEntityTypeFullCost == nil then
		OwnBuildingCostSystem.GetEntityTypeFullCost = Logic.GetEntityTypeFullCost;
	end	
	Logic.GetEntityTypeFullCost = function(_buildingType)
		local CostTable = OwnBuildingCostSystem.GetCostByCostTable(Logic.GetUpgradeCategoryByBuildingType(_buildingType));
		if (CostTable == nil) then
			return OwnBuildingCostSystem.GetEntityTypeFullCost(_buildingType)
		else
			local Costs = {OwnBuildingCostSystem.GetEntityTypeFullCost(_buildingType)}
			return Costs[1], CostTable[2], CostTable[3], CostTable[4]
		end
	end
	if OwnBuildingCostSystem.GetCostForWall == nil then
		OwnBuildingCostSystem.GetCostForWall = Logic.GetCostForWall;
	end	
	Logic.GetCostForWall = function(_SegmentType, _TurretType, StartTurretX, StartTurretY, EndTurretX, EndTurretY)
		--113 110 --Palisade
		--140 141 --Wall_ME
		--Using Wall_ME since all Walls have the same costs anyway so no reason to differentiate between climate zones
		if _SegmentType == 113 and _TurretType == 110 then --PalisadeSegement and PalisadeTurret
			if (OwnBuildingCostSystem.PalisadeCosts == nil) then
				return OwnBuildingCostSystem.GetCostForWall(_SegmentType, _TurretType, StartTurretX, StartTurretY, EndTurretX, EndTurretY)
			else
				local Distance = OwnBuildingCostSystem.CalculateWallOrPalisadeCosts()
				return OwnBuildingCostSystem.PalisadeCosts[1], math.floor(Distance*OwnBuildingCostSystem.PalisadeCosts[2]), OwnBuildingCostSystem.PalisadeCosts[3], math.floor(Distance*OwnBuildingCostSystem.PalisadeCosts[4])
			end	
		else
			if (OwnBuildingCostSystem.WallCosts == nil) then
				return OwnBuildingCostSystem.GetCostForWall(_SegmentType, _TurretType, StartTurretX, StartTurretY, EndTurretX, EndTurretY)
			else
				local Distance = OwnBuildingCostSystem.CalculateWallOrPalisadeCosts()
				return OwnBuildingCostSystem.WallCosts[1], math.floor(Distance*OwnBuildingCostSystem.WallCosts[2]), OwnBuildingCostSystem.WallCosts[3], math.floor(Distance*OwnBuildingCostSystem.WallCosts[4])
			end		
		end
	end
end
OwnBuildingCostSystem.OverwriteVariableCostBuildings = function()
	if OwnBuildingCostSystem.GameCallBack_GUI_BuildRoadCostChanged == nil then
		OwnBuildingCostSystem.GameCallBack_GUI_BuildRoadCostChanged = GameCallBack_GUI_BuildRoadCostChanged;
	end	
    GameCallBack_GUI_BuildRoadCostChanged = function(_Length)
		if OwnBuildingCostSystem.RoadCosts == nil then
			OwnBuildingCostSystem.GameCallBack_GUI_BuildRoadCostChanged(_Length)
		else
			local Meters = _Length / 100
			local MetersPerUnit = Logic.GetRoadMetersPerRoadUnit()
			local AmountFirstGood = math.floor(OwnBuildingCostSystem.RoadCosts[2] * (Meters / MetersPerUnit))
			local AmountSecondGood = math.floor(OwnBuildingCostSystem.RoadCosts[4] * (Meters / MetersPerUnit))

			if AmountFirstGood == 0 then
				AmountFirstGood = 1
			end
			if AmountSecondGood == 0 then
				AmountSecondGood = 1
			end
			
		    GUI_Tooltip.TooltipCostsOnly({Goods.G_Stone, AmountFirstGood, OwnBuildingCostSystem.RoadCosts[3], AmountSecondGood})
			XGUIEng.ShowWidget("/InGame/Root/Normal/TooltipCostsOnly", 1)
			
			OwnBuildingCostSystem.RoadMultiplier.First = AmountFirstGood;
			OwnBuildingCostSystem.RoadMultiplier.Second = AmountSecondGood;

			local Costs = {Logic.GetRoadCostPerRoadUnit()}
			for i = 2, table.getn(Costs), 2 do
				Costs[i] = math.ceil(Costs[i] * (Meters / MetersPerUnit))
				if Costs[i] == 0 then
					Costs[i] = 1
				end
			end
			OwnBuildingCostSystem.RoadMultiplier.CurrentActualCost = Costs[2]
		end
    end
	
	if OwnBuildingCostSystem.GameCallBack_GUI_ConstructWallSegmentCountChanged == nil then
		OwnBuildingCostSystem.GameCallBack_GUI_ConstructWallSegmentCountChanged = GameCallBack_GUI_ConstructWallSegmentCountChanged;
	end	
	GameCallBack_GUI_ConstructWallSegmentCountChanged = function(_SegmentType, _TurretType)
		if _SegmentType == 113 and _TurretType == 110 then --PalisadeSegement and PalisadeTurret
			if OwnBuildingCostSystem.PalisadeCosts == nil then
				OwnBuildingCostSystem.GameCallBack_GUI_ConstructWallSegmentCountChanged(_SegmentType, _TurretType)
			else
				local Costs = {Logic.GetCostForWall(_SegmentType, _TurretType, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
				GUI_Tooltip.TooltipCostsOnly(Costs)
				XGUIEng.ShowWidget("/InGame/Root/Normal/TooltipCostsOnly", 1)
			end
		else
			if OwnBuildingCostSystem.WallCosts == nil then
				OwnBuildingCostSystem.GameCallBack_GUI_ConstructWallSegmentCountChanged(_SegmentType, _TurretType)
			else
				local Costs = {Logic.GetCostForWall(_SegmentType, _TurretType, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
				GUI_Tooltip.TooltipCostsOnly(Costs)
				XGUIEng.ShowWidget("/InGame/Root/Normal/TooltipCostsOnly", 1)
			end
		end
	end
	
	if OwnBuildingCostSystem.GameCallback_GUI_Street_Started == nil then
		OwnBuildingCostSystem.GameCallback_GUI_Street_Started = GameCallback_GUI_Street_Started;
	end	
	GameCallback_GUI_Street_Started = function(_PlayerID, _X, _Y)
		OwnBuildingCostSystem.GameCallback_GUI_Street_Started(_PlayerID, _X, _Y)
		if OwnBuildingCostSystem.TrailCosts ~= nil and _PlayerID == 1 then
			OwnBuildingCostSystem.StreetMultiplier.CurrentX = _X
			OwnBuildingCostSystem.StreetMultiplier.CurrentY = _Y
		end
	end
	
	if OwnBuildingCostSystem.GameCallback_Street_Placed_Local == nil then
		OwnBuildingCostSystem.GameCallback_Street_Placed_Local = GameCallback_Street_Placed_Local;
	end	
	GameCallback_Street_Placed_Local = function(_PlayerID, _X, _Y)
		OwnBuildingCostSystem.GameCallback_Street_Placed_Local(_PlayerID, _X, _Y)
		if OwnBuildingCostSystem.TrailCosts ~= nil and _PlayerID == 1 then
			OwnBuildingCostSystem.StreetMultiplier.CurrentX = _X
			OwnBuildingCostSystem.StreetMultiplier.CurrentY = _Y
		end
	end
end

OwnBuildingCostSystem.InitializeOwnBuildingCostSystem = function()

	OwnBuildingCostSystem.OverwriteAfterPlacement()
	OwnBuildingCostSystem.OverwriteBuildClicked()
	OwnBuildingCostSystem.OverwriteBuildAbort()
	OwnBuildingCostSystem.OverwriteGetCostLogics()
	OwnBuildingCostSystem.OverwriteVariableCostBuildings()
	OwnBuildingCostSystem.OverwriteEndScreenCallback()
	OwnBuildingCostSystem.FestivalCostsHandler()
	
	OwnBuildingCostSystem.OverwriteOptionalBugfixFunctions() --Not needed, just nice to have
	OwnBuildingCostSystem.EnsureQuestSystemBehaviorCompatibility() --For QSB compatibility	

	if OwnBuildingCostSystem.PlacementUpdate == nil then
		OwnBuildingCostSystem.PlacementUpdate = GUI_Construction.PlacementUpdate;
	end	
	GUI_Construction.PlacementUpdate = function()		
		if g_LastPlacedParam == false then --Road
			if (OwnBuildingCostSystem.RoadCosts ~= nil) then
				if not OwnBuildingCostSystem.AreResourcesAvailable(1, OwnBuildingCostSystem.RoadMultiplier.First, OwnBuildingCostSystem.RoadMultiplier.Second)
				and (OwnBuildingCostSystem.StreetMultiplier.CurrentX ~= 1 and OwnBuildingCostSystem.StreetMultiplier.CurrentY ~= 1) then
					OwnBuildingCostSystem.ShowOverlayWidget(true)
				else
					OwnBuildingCostSystem.ShowOverlayWidget(false)
				end
			end	
		elseif g_LastPlacedParam == true then
			if (OwnBuildingCostSystem.TrailCosts ~= nil) then
				local First, Second = OwnBuildingCostSystem.CalculateStreetCosts()
				
				GUI_Tooltip.TooltipCostsOnly({OwnBuildingCostSystem.TrailCosts[1], First, OwnBuildingCostSystem.TrailCosts[3], Second})
				XGUIEng.ShowWidget("/InGame/Root/Normal/TooltipCostsOnly", 1)
				OwnBuildingCostSystem.StreetMultiplier.First = First
				OwnBuildingCostSystem.StreetMultiplier.Second = Second
				
				if not OwnBuildingCostSystem.AreResourcesAvailable(4, First, Second)
				and (OwnBuildingCostSystem.StreetMultiplier.CurrentX ~= 1 and OwnBuildingCostSystem.StreetMultiplier.CurrentY ~= 1) then
					OwnBuildingCostSystem.ShowOverlayWidget(true)
				else
					OwnBuildingCostSystem.ShowOverlayWidget(false)
				end
			end
		elseif g_LastPlacedParam == 49 then --Palisade
			if OwnBuildingCostSystem.PalisadeCosts ~= nil then
				local Costs = {Logic.GetCostForWall(113, 110, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
				if not OwnBuildingCostSystem.AreResourcesAvailable(3, Costs[2], Costs[4]) and (StartTurretX ~= 1 and StartTurretY ~= 1) then
					OwnBuildingCostSystem.ShowOverlayWidget(true)
				else
					OwnBuildingCostSystem.ShowOverlayWidget(false)
				end	
			end	
		elseif g_LastPlacedParam == GetUpgradeCategoryForClimatezone("WallSegment") then
			if OwnBuildingCostSystem.WallCosts ~= nil then
				local Costs = {Logic.GetCostForWall(140, 141, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
				if not OwnBuildingCostSystem.AreResourcesAvailable(2, Costs[2], Costs[4]) and (StartTurretX ~= 1 and StartTurretY ~= 1) then
					OwnBuildingCostSystem.ShowOverlayWidget(true)
				else
					OwnBuildingCostSystem.ShowOverlayWidget(false)
				end	
			end
		else
			if (OwnBuildingCostSystem.GetAwaitingVariable() == true) then
				if not (OwnBuildingCostSystem.AreResourcesAvailable(g_LastPlacedParam)) then
					OwnBuildingCostSystem.ShowOverlayWidget(true)
				else
					OwnBuildingCostSystem.ShowOverlayWidget(false)
				end
			end	
		end
		OwnBuildingCostSystem.PlacementUpdate()	
	end
	
	if OwnBuildingCostSystem.GameCallback_GUI_PlacementState == nil then
		OwnBuildingCostSystem.GameCallback_GUI_PlacementState = GameCallback_GUI_PlacementState;
	end	
	GameCallback_GUI_PlacementState = function(_State, _Type)
		--This is needed because for some reason the Wall/Palisade Continue State does not call PlacementUpdate ?
		if OwnBuildingCostSystem.IsInWallOrPalisadeContinueState == true then
			if g_LastPlacedParam == 49 then --Palisade
				if OwnBuildingCostSystem.PalisadeCosts ~= nil then
					local Costs = {Logic.GetCostForWall(113, 110, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
					if not OwnBuildingCostSystem.AreResourcesAvailable(3, Costs[2], Costs[4]) and (StartTurretX ~= 1 and StartTurretY ~= 1) then
						OwnBuildingCostSystem.ShowOverlayWidget(true)
					else
						OwnBuildingCostSystem.ShowOverlayWidget(false)
					end	
				end	
			elseif g_LastPlacedParam == GetUpgradeCategoryForClimatezone("WallSegment") then
				if OwnBuildingCostSystem.WallCosts ~= nil then
					local Costs = {Logic.GetCostForWall(140, 141, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
					if not OwnBuildingCostSystem.AreResourcesAvailable(2, Costs[2], Costs[4]) and (StartTurretX ~= 1 and StartTurretY ~= 1) then
						OwnBuildingCostSystem.ShowOverlayWidget(true)
					else
						OwnBuildingCostSystem.ShowOverlayWidget(false)
					end	
				end
			end
		end
		OwnBuildingCostSystem.GameCallback_GUI_PlacementState()
	end
	
	if OwnBuildingCostSystem.GUI_StateChanged == nil then
		OwnBuildingCostSystem.GUI_StateChanged = GameCallback_GUI_StateChanged;
	end	
	GameCallback_GUI_StateChanged = function(_StateNameID, _Armed)
		OwnBuildingCostSystem.GUI_StateChanged(_StateNameID, _Armed)
		if ((_StateNameID ~= GUI.GetStateNameByID("PlaceBuilding")) 
			and (_StateNameID ~= GUI.GetStateNameByID("PlaceWallGate"))
			and (_StateNameID ~= GUI.GetStateNameByID("PlaceWall"))
			and (_StateNameID ~= GUI.GetStateNameByID("PlaceRoad"))) then
				OwnBuildingCostSystem.SetAwaitingVariable(false)
				OwnBuildingCostSystem.ShowOverlayWidget(false)
				OwnBuildingCostSystem.ResetWallTurretPositions()
				OwnBuildingCostSystem.ResetTrailAndRoadCosts()
				GUI.SendScriptCommand([[OwnBuildingCostSystem.AreBuildingCostsAvailable = nil]])
		end
	end

	if OwnBuildingCostSystem.AreCostsAffordable == nil then
		OwnBuildingCostSystem.AreCostsAffordable = AreCostsAffordable;
	end	
	AreCostsAffordable = function(_Costs, _GoodsInSettlementBoolean)
		local CanBuyBoolean, CanNotBuyStringTableText = OwnBuildingCostSystem.AreCostsAffordable(_Costs, _GoodsInSettlementBoolean)
		if (OwnBuildingCostSystem.GetAwaitingVariable() == true) then
			if (OwnBuildingCostSystem.AreResourcesAvailable(g_LastPlacedParam) == false) then
				CanBuyBoolean = false
				OwnBuildingCostSystem.CurrentExpectedBuildingType = nil
				OwnBuildingCostSystem.SetAwaitingVariable(false)
			else
				CanBuyBoolean = true
			end
		end
		return CanBuyBoolean, CanNotBuyStringTableText
	end
	
	if OwnBuildingCostSystem.SetCosts == nil then
		OwnBuildingCostSystem.SetCosts = GUI_Tooltip.SetCosts;
	end		
	GUI_Tooltip.SetCosts = function(_TooltipCostsContainer, _Costs, _GoodsInSettlementBoolean)
		local Name = XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID())
		if Name == "Street" and OwnBuildingCostSystem.RoadCosts ~= nil then
			_Costs = {OwnBuildingCostSystem.RoadCosts[1], -1, OwnBuildingCostSystem.RoadCosts[3], -1}
		elseif Name == "Trail" and OwnBuildingCostSystem.TrailCosts ~= nil then
			_Costs = {OwnBuildingCostSystem.TrailCosts[1], -1, OwnBuildingCostSystem.TrailCosts[3], -1}	
		elseif Name == "Palisade" and OwnBuildingCostSystem.PalisadeCosts ~= nil then
			_Costs = {OwnBuildingCostSystem.PalisadeCosts[1], -1, OwnBuildingCostSystem.PalisadeCosts[3], -1}		
		elseif Name == "Wall" and OwnBuildingCostSystem.WallCosts ~= nil then
			_Costs = {OwnBuildingCostSystem.WallCosts[1], -1, OwnBuildingCostSystem.WallCosts[3], -1}					
		end
		OwnBuildingCostSystem.SetCosts(_TooltipCostsContainer, _Costs, _GoodsInSettlementBoolean)
	end
		
	GUI.SendScriptCommand([[
		if OwnBuildingCostSystem == nil then
			OwnBuildingCostSystem = {}
			OwnBuildingCostSystem.AreBuildingCostsAvailable = nil
		end
		if OwnBuildingCostSystem.GameCallback_SettlerSpawned == nil then
			OwnBuildingCostSystem.GameCallback_SettlerSpawned = GameCallback_SettlerSpawned;
		end
		GameCallback_SettlerSpawned = function(_PlayerID, _EntityID)
			OwnBuildingCostSystem.GameCallback_SettlerSpawned(_PlayerID, _EntityID)	
			if (_PlayerID == 1) then
				if (Logic.IsEntityInCategory(_EntityID, EntityCategories.Worker) == 1) 
				or (Logic.GetEntityType(_EntityID) == Entities.U_OutpostConstructionWorker) 
				or (Logic.GetEntityType(_EntityID) == Entities.U_WallConstructionWorker) then
					local WorkPlaceID = Logic.GetSettlersWorkBuilding(_EntityID)
					if WorkPlaceID ~= 0 and WorkPlaceID ~= nil and Logic.GetUpgradeLevel(_EntityID) > 0 then
						return;
					else
						Logic.ExecuteInLuaLocalState("StartSimpleHiResJobEx(OwnBuildingCostSystem.GetCurrentlyGlobalBuilding, ".._EntityID..")")
					end
				end
			end
		end	
	
		if OwnBuildingCostSystem.GameCallback_BuildingDestroyed == nil then
			OwnBuildingCostSystem.GameCallback_BuildingDestroyed = GameCallback_BuildingDestroyed;
		end
		GameCallback_BuildingDestroyed = function(_EntityID, _PlayerID, _KnockedDown)
			OwnBuildingCostSystem.GameCallback_BuildingDestroyed(_EntityID, _PlayerID, _KnockedDown)
			if (_KnockedDown == 1) and (_PlayerID == 1) then
				Logic.ExecuteInLuaLocalState("OwnBuildingCostSystem.RefundKnockDown(".._EntityID..")")
			end
		end
		
		if OwnBuildingCostSystem.GameCallback_CanPlayerPlaceBuilding == nil then
			OwnBuildingCostSystem.GameCallback_CanPlayerPlaceBuilding = GameCallback_CanPlayerPlaceBuilding;
		end
		GameCallback_CanPlayerPlaceBuilding = function(_PlayerID, _Type, _X, _Y)
			if OwnBuildingCostSystem.AreBuildingCostsAvailable ~= nil then
				return OwnBuildingCostSystem.AreBuildingCostsAvailable
			else
				return OwnBuildingCostSystem.GameCallback_CanPlayerPlaceBuilding(_PlayerID, _Type, _X, _Y)
			end
		end
	]])
	
	Framework.WriteToLog("BCS: Initialization Done! Version: "..OwnBuildingCostSystem.CurrentBCSVersion)
end

OwnBuildingCostSystem.OverwriteEndScreenCallback = function()
	if OwnBuildingCostSystem.EndScreen_ExitGame == nil then
		OwnBuildingCostSystem.EndScreen_ExitGame = EndScreen_ExitGame;
	end	
	EndScreen_ExitGame = function()
		GUI.CancelState()
		OwnBuildingCostSystem.CurrentExpectedBuildingType = nil
		Message(XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_Resources"))
		Framework.WriteToLog("BCS: Resources Ran Out!")
	end
end

OwnBuildingCostSystem.ShowOverlayWidget = function(_flag)
	if _flag == true then
		if OwnBuildingCostSystem.OverlayIsCurrentlyShown == false then
			local ScreenSizeX, ScreenSizeY = GUI.GetScreenSize()
			XGUIEng.SetWidgetSize(OwnBuildingCostSystem.OverlayWidget, ScreenSizeX * 2, ScreenSizeY * 2)
			XGUIEng.PushPage(OwnBuildingCostSystem.OverlayWidget, false)
			XGUIEng.ShowAllSubWidgets(OwnBuildingCostSystem.OverlayWidget, 1)
			XGUIEng.ShowWidget(OwnBuildingCostSystem.OverlayWidget, 1)
			XGUIEng.ShowWidget('/EndScreen/EndScreen/Background', 0)
			XGUIEng.ShowWidget('/EndScreen/EndScreen/BG', 1)
			XGUIEng.SetMaterialColor("/EndScreen/EndScreen/BG", 0, 0, 0, 0, 0);
			XGUIEng.SetWidgetScreenPosition(OwnBuildingCostSystem.OverlayWidget, -100, -100) --To be on the safe side ^^
			
			OwnBuildingCostSystem.OverlayIsCurrentlyShown = true
			
			GUI.SendScriptCommand([[OwnBuildingCostSystem.AreBuildingCostsAvailable = false]])
		end
	else
		if OwnBuildingCostSystem.OverlayIsCurrentlyShown == true then
			XGUIEng.ShowAllSubWidgets(OwnBuildingCostSystem.OverlayWidget, 0)
			XGUIEng.ShowWidget(OwnBuildingCostSystem.OverlayWidget, 0)
			OwnBuildingCostSystem.OverlayIsCurrentlyShown = false
			GUI.SendScriptCommand([[OwnBuildingCostSystem.AreBuildingCostsAvailable = true]])
		end
	end
end

OwnBuildingCostSystem.CalculateStreetCosts = function()
	local posX, posY = GUI.Debug_GetMapPositionUnderMouse()
	if OwnBuildingCostSystem.StreetMultiplier.CurrentX ~= 1 and OwnBuildingCostSystem.StreetMultiplier.CurrentY ~= 1 then
		local xDistance = math.abs(posX - OwnBuildingCostSystem.StreetMultiplier.CurrentX);
		local yDistance = math.abs(posY - OwnBuildingCostSystem.StreetMultiplier.CurrentY);
		local Distance = (math.sqrt((xDistance ^ 2) + (yDistance ^ 2))) / 1000
		local FirstCostDistance = math.floor(Distance * OwnBuildingCostSystem.TrailCosts[2])
		local SecondCostDistance = math.floor(Distance * OwnBuildingCostSystem.TrailCosts[4])
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

OwnBuildingCostSystem.CalculateWallOrPalisadeCosts = function()
	local xDistance = math.abs(StartTurretX - EndTurretX);
	local yDistance = math.abs(StartTurretY - EndTurretY);
	local Distance = (math.sqrt((xDistance ^ 2) + (yDistance ^2 ))) / 1000
	return Distance;
end

OwnBuildingCostSystem.ResetTrailAndRoadCosts = function()
	OwnBuildingCostSystem.StreetMultiplier.First = 1
	OwnBuildingCostSystem.StreetMultiplier.Second = 1

	OwnBuildingCostSystem.StreetMultiplier.CurrentX = 1
	OwnBuildingCostSystem.StreetMultiplier.CurrentY = 1
	
	OwnBuildingCostSystem.RoadMultiplier.First = 1
	OwnBuildingCostSystem.RoadMultiplier.Second = 1
	
	OwnBuildingCostSystem.RoadMultiplier.CurrentActualCost = 1
end

OwnBuildingCostSystem.ResetWallTurretPositions = function()
	StartTurretX = 1 
	StartTurretY = 1
	
	EndTurretX = 1
	EndTurretY = 1
end

OwnBuildingCostSystem.OverwriteOptionalBugfixFunctions = function()
	if OwnBuildingCostSystem.BuildingNameUpdate == nil then
		OwnBuildingCostSystem.BuildingNameUpdate = GUI_BuildingInfo.BuildingNameUpdate;	
	end
	GUI_BuildingInfo.BuildingNameUpdate = function()
		OwnBuildingCostSystem.BuildingNameUpdate()
		local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
		if XGUIEng.GetText(CurrentWidgetID) == "{center}B_Cathedral_Big" then
			XGUIEng.SetText(CurrentWidgetID, "{center}Kathedrale")
		end
	end
end

OwnBuildingCostSystem.EnsureQuestSystemBehaviorCompatibility = function()
	if (API and QSB) and not OwnBuildingCostSystem.EnsuredQuestSystemBehaviorCompatibility then
		if QSB.ScriptEvents ~= nil then
			API.AddScriptEventListener(QSB.ScriptEvents.BriefingEnded, OwnBuildingCostSystem.OverwriteEndScreenCallback)
			OwnBuildingCostSystem.EnsuredQuestSystemBehaviorCompatibility = true
		end
	end
	
	if (API and QSB) and (QSB.ScriptEvents ~= nil and ModuleInterfaceCore ~= nil) then
		OwnBuildingCostSystem.HuntableLifestockHandlerQSBCompatibility()
	else
		OwnBuildingCostSystem.HuntableLifestockHandler()
	end
end

OwnBuildingCostSystem.FestivalCostsHandler = function()

	if OwnBuildingCostSystem.GetFestivalCost == nil then
		OwnBuildingCostSystem.GetFestivalCost = Logic.GetFestivalCost;	
	end
	Logic.GetFestivalCost = function(_PlayerID, _FestivalIndex)
		if OwnBuildingCostSystem.CurrentFestivalCosts == nil then
			return OwnBuildingCostSystem.GetFestivalCost(_PlayerID, _FestivalIndex)
		else
			local Costs = {OwnBuildingCostSystem.GetFestivalCost(_PlayerID, _FestivalIndex)}
			return OwnBuildingCostSystem.CurrentFestivalCosts[1], Round(Costs[2] * OwnBuildingCostSystem.CurrentFestivalCosts[2]), OwnBuildingCostSystem.CurrentFestivalCosts[3], OwnBuildingCostSystem.CurrentFestivalCosts[4]
		end
	end

	if OwnBuildingCostSystem.StartFestivalClicked == nil then
		OwnBuildingCostSystem.StartFestivalClicked = GUI_BuildingButtons.StartFestivalClicked;	
	end
	GUI_BuildingButtons.StartFestivalClicked = function(_FestivalIndex)
		if OwnBuildingCostSystem.CurrentFestivalCosts == nil then
			OwnBuildingCostSystem.StartFestivalClicked(_FestivalIndex)
		else
			local PlayerID = GUI.GetPlayerID()
			local CanBuyBoolean = OwnBuildingCostSystem.AreFestivalResourcesAvailable(PlayerID, _FestivalIndex)
			local MarketID = GUI.GetSelectedEntity()
	
			if MarketID ~= Logic.GetMarketplace(PlayerID) then
				return
			end

			if CanBuyBoolean == true then
				Sound.FXPlay2DSound("ui\\menu_click")
				
				local Type, OriginalAmount = OwnBuildingCostSystem.GetFestivalCost(PlayerID, _FestivalIndex)
				local Amount = Round(OriginalAmount * OwnBuildingCostSystem.CurrentFestivalCosts[2])
				
				Amount = Amount - OriginalAmount
				
				GUI.RemoveGoodFromStock(OwnBuildingCostSystem.GetEntityIDToAddToOutStock(Goods.G_Gold), Goods.G_Gold, Amount)
				GUI.RemoveGoodFromStock(OwnBuildingCostSystem.GetEntityIDToAddToOutStock(OwnBuildingCostSystem.CurrentFestivalCosts[3]), OwnBuildingCostSystem.CurrentFestivalCosts[3], OwnBuildingCostSystem.CurrentFestivalCosts[4])

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
OwnBuildingCostSystem.AreFestivalResourcesAvailable = function(_PlayerID, _FestivalIndex)
	local AmountOfFirstGood, AmountOfSecondGood;
	local Costs = {OwnBuildingCostSystem.GetFestivalCost(_PlayerID, _FestivalIndex)}

	AmountOfFirstGood = Logic.GetAmountOnOutStockByGoodType(OwnBuildingCostSystem.GetEntityIDToAddToOutStock(OwnBuildingCostSystem.CurrentFestivalCosts[1]), OwnBuildingCostSystem.CurrentFestivalCosts[1])
	AmountOfSecondGood = Logic.GetAmountOnOutStockByGoodType(OwnBuildingCostSystem.GetEntityIDToAddToOutStock(OwnBuildingCostSystem.CurrentFestivalCosts[3]), OwnBuildingCostSystem.CurrentFestivalCosts[3])

	if (AmountOfFirstGood < Round(Costs[2] * OwnBuildingCostSystem.CurrentFestivalCosts[2]) or AmountOfSecondGood < OwnBuildingCostSystem.CurrentFestivalCosts[4]) then
		return false
	else
		return true
	end
end

OwnBuildingCostSystem.HuntableLifestockHandler = function()

	if OwnBuildingCostSystem.StartSermonClicked == nil then
		OwnBuildingCostSystem.StartSermonClicked = GUI_BuildingButtons.StartSermonClicked;	
	end
	GUI_BuildingButtons.StartSermonClicked = function()		
		local PlayerID = GUI.GetPlayerID()
		local EntityID = GUI.GetSelectedEntity()
		if EntityID == Logic.GetCathedral(PlayerID) then
			OwnBuildingCostSystem.StartSermonClicked()
		else
			if OwnBuildingCostSystem.HuntableAnimals == true then
				local Type = Logic.GetEntityType(EntityID)
				if Type == Entities.B_HuntersHut then
					OwnBuildingCostSystem.HuntableLifestockChangedIndex(EntityID)
				end
			end
		end
	end
	
	if OwnBuildingCostSystem.StartSermonUpdate == nil then
		OwnBuildingCostSystem.StartSermonUpdate = GUI_BuildingButtons.StartSermonUpdate;	
	end
	GUI_BuildingButtons.StartSermonUpdate = function()
		local PlayerID = GUI.GetPlayerID()
		local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
		local EntityID = GUI.GetSelectedEntity()
		
		if EntityID == Logic.GetCathedral(PlayerID) then
			SetIcon(CurrentWidgetID, {4, 14})
			OwnBuildingCostSystem.StartSermonUpdate()
			return;
		end

		local EntityType = Logic.GetEntityType(EntityID)
		if EntityType == Entities.B_HuntersHut and OwnBuildingCostSystem.HuntableAnimals == true then
			XGUIEng.ShowWidget(CurrentWidgetID, 1)
			XGUIEng.DisableButton(CurrentWidgetID, 0)
			
			OwnBuildingCostSystem.HuntableLifestockHandleUpdateButton(CurrentWidgetID, EntityID)	
		else
			XGUIEng.ShowWidget(CurrentWidgetID, 0)
			return;
		end
	end
	
	if OwnBuildingCostSystem.SetNameAndDescription == nil then
		OwnBuildingCostSystem.SetNameAndDescription = GUI_Tooltip.SetNameAndDescription;	
	end
	GUI_Tooltip.SetNameAndDescription = function(_TooltipNameWidget, _TooltipDescriptionWidget, _OptionalTextKeyName, _OptionalDisabledTextKeyName, _OptionalMissionTextFileBoolean)
		if OwnBuildingCostSystem.HuntableAnimals == true and (_TooltipNameWidget) == 98 then --StartSermon
			if Logic.GetEntityType(GUI.GetSelectedEntity()) == Entities.B_HuntersHut then
				local Entity = GUI.GetSelectedEntity()
				local HuntCowsAllowed = Logic.GetOptionalHuntableState(Entity, 2)
				local HuntSheepAllowed = Logic.GetOptionalHuntableState(Entity, 1)
				local ToolTipText = ""
				if HuntCowsAllowed == true then
					ToolTipText = "Kühe"
				elseif HuntSheepAllowed == true then
					ToolTipText = "Schafe"
				else
					ToolTipText = "keine Weidetiere"
				end
				OwnBuildingCostSystem.SetUserTooltip("Jagd auf Weidetiere", "Gebt Schafe und Kühe zur Jagd frei!{cr}{@color:0,128,0,255}Momentan werden "..ToolTipText.." gejagt!", _TooltipNameWidget, _TooltipDescriptionWidget)
				return;
			end
		end
		OwnBuildingCostSystem.SetNameAndDescription(_TooltipNameWidget, _TooltipDescriptionWidget, _OptionalTextKeyName, _OptionalDisabledTextKeyName, _OptionalMissionTextFileBoolean)
	end
end

OwnBuildingCostSystem.HuntableLifestockHandlerQSBCompatibility = function()
	if OwnBuildingCostSystem.HunterButtonID == nil then
		OwnBuildingCostSystem.HunterButtonID = API.AddBuildingButton(
		function(_WidgetID, _BuildingID)
			OwnBuildingCostSystem.HuntableLifestockChangedIndex(_BuildingID)
		end,
		function(_WidgetID, _BuildingID)
			local HuntCowsAllowed = Logic.GetOptionalHuntableState(_BuildingID, 2)
			local HuntSheepAllowed = Logic.GetOptionalHuntableState(_BuildingID, 1)
			local ToolTipText = ""
			if HuntCowsAllowed == true then
				ToolTipText = "Kühe"
			elseif HuntSheepAllowed == true then
				ToolTipText = "Schafe"
			else
				ToolTipText = "keine Weidetiere"
			end
			API.SetTooltipCosts("Jagd auf Weidetiere", "Gebt Schafe und Kühe zur Jagd frei!{cr}{@color:0,128,0,255}Momentan werden "..ToolTipText.." gejagt!", "Momentan nicht möglich");
		end,
		-- Update
		function(_WidgetID, _BuildingID)
			if Logic.GetEntityType(_BuildingID) == Entities.B_HuntersHut and OwnBuildingCostSystem.HuntableAnimals == true then
				XGUIEng.ShowWidget(_WidgetID, 1)
				OwnBuildingCostSystem.HuntableLifestockHandleUpdateButton(_WidgetID, _BuildingID)	
			else
				XGUIEng.ShowWidget(_WidgetID, 0)	
			end
		end);
	end
end

OwnBuildingCostSystem.HuntableLifestockHandleUpdateButton = function(_WidgetID, _BuildingID)	
	local HuntCowsAllowed = Logic.GetOptionalHuntableState(_BuildingID, 2)
	local HuntSheepAllowed = Logic.GetOptionalHuntableState(_BuildingID, 1)	
	
	if HuntCowsAllowed == true then
		SetIcon(_WidgetID, {4, 1});
	elseif HuntSheepAllowed == true then
		SetIcon(_WidgetID, {4, 2});
	else
		SetIcon(_WidgetID, {3, 16});			
	end
end
OwnBuildingCostSystem.HuntableLifestockChangedIndex = function(_BuildingID)
	local HuntCowsAllowed = Logic.GetOptionalHuntableState(_BuildingID, 2)
	local HuntSheepAllowed = Logic.GetOptionalHuntableState(_BuildingID, 1)
	
	if HuntCowsAllowed == true then
		GUI.SetOptionalHuntableState(_BuildingID, 2, false)
		GUI.SetOptionalHuntableState(_BuildingID, 1, true)
		Message("Es werden Schafe gejagt!")
	elseif HuntSheepAllowed == true then
		GUI.SetOptionalHuntableState(_BuildingID, 2, false)
		GUI.SetOptionalHuntableState(_BuildingID, 1, false)
		Message("Es werden keine Weidetiere gejagt!")
	else
		GUI.SetOptionalHuntableState(_BuildingID, 2, true)
		GUI.SetOptionalHuntableState(_BuildingID, 1, false)
		Message("Es werden Kühe gejagt!")
	end
	Sound.FXPlay2DSound("ui\\menu_click")
	Framework.WriteToLog("BCS: Changed Huntable Category at Building "..tostring(_BuildingID).."!")
end
OwnBuildingCostSystem.SetUserTooltip = function(_Name, _Description, _TooltipNameWidget, _TooltipDescriptionWidget)
	XGUIEng.SetText(_TooltipNameWidget, "{center}" .. _Name)
	XGUIEng.SetText(_TooltipDescriptionWidget, "{center}" .. _Description)
    
	local Height = XGUIEng.GetTextHeight(_TooltipDescriptionWidget, true)
	local W, H = XGUIEng.GetWidgetSize(_TooltipDescriptionWidget)
    
	XGUIEng.SetWidgetSize(_TooltipDescriptionWidget, W, Height)
end


--Simplify HiRes Usage--
if StartSimpleHiResJobEx == nil then
	function StartSimpleHiResJobEx(_Func, ...)
		assert(type(_Func) == "function")

		g_SimpleHiResJobExJobs = g_SimpleHiResJobExJobs or {}
		g_StartSimpleHiResJobExJob = g_StartSimpleHiResJobExJob or StartSimpleHiResJob("StartSimpleHiResJobExHandler")
		table.insert(g_SimpleHiResJobExJobs, {_Func, {...}})
		return #g_SimpleHiResJobExJobs
	end

	function StartSimpleHiResJobExHandler()
		for i = #g_SimpleHiResJobExJobs, 1, -1 do
			local Entry = g_SimpleHiResJobExJobs[i]
			if Entry[1](unpack(Entry[2])) then
				table.remove(g_SimpleHiResJobExJobs, i)
			end
		end
    
		if #g_SimpleHiResJobExJobs == 0 then
			g_StartSimpleHiResJobExJob = nil
			return true
		end
	end
end
--#EOF--