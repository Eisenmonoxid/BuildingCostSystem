function SetMyBuildingCosts()
	--[[
	
		-> This function has to be called from the local script after the bcs_local.lua was loaded.
		-> You can change all costs at every time in the game. 
		-> The first good amount has to be equal or higher than the original costs.
		-> The second good and amount can be chosen freely.
		
		-> Diese Funktion muss aus dem lokalen Skript aufgerufen werden nachdem bcs_local.lua geladen wurde.
		-> Es können alle Gebäudekosten zu jedem Zeitpunkt im Spiel geändert werden.
		-> Die Höhe der ersten Ware muss gleich oder höher dem Originalwert liegen!
		-> Die zweite Ware und ihre Höhe können frei festgelegt werden.
		
		Example call from the local lua script:
		
		function Mission_LocalOnMapStart()
			Script.Load("C:\\Path\\bcs_local.lua")
			Script.Load("C:\\Path\\bcs_costs.lua")

			SetMyBuildingCosts() -- Set Custom Costs
		end
		
	]]--
	
	-- Initialize BCS --
	if BCS ~= nil then
		-- Init System
		BCS.InitializeBuildingCostSystem()
		-- Add Savegame when QSB is present
		if (API and QSB) then
			-- Register Savegame
			if API.AddSaveGameAction then -- QSB-S 2.x
				GUI.SendScriptCommand([[
					API.AddSaveGameAction(function()
						Logic.ExecuteInLuaLocalState('BCS.InitializeBuildingCostSystem()')
					end)
				]])
				Framework.WriteToLog("BCS: QSB-S 2.x found! AddSaveGameAction for Savegame registered!")
			elseif API.AddScriptEventListener and QSB.ScriptEvents ~= nil then -- QSB-S 3.x
				API.AddScriptEventListener(QSB.ScriptEvents.SaveGameLoaded, BCS.InitializeBuildingCostSystem)
				API.AddScriptEventListener(QSB.ScriptEvents.BriefingEnded, BCS.OverwriteEndScreenCallback)
				Framework.WriteToLog("BCS: QSB-S 3.x found! ScriptEventListener for Savegame and BriefingEnded registered!")
			else
				Framework.WriteToLog("BCS: QSB-S found, but no Savegame registered. Has to be done manually!")
			end
		else
			Framework.WriteToLog("BCS: QSB-S NOT found! Savegamehandling has to be done manually!")
		end
		
		-- If you don't use the QSB-S, you have to overwrite the Mission_OnSaveGameLoaded() in the global script.
		-- And call Logic.ExecuteInLuaLocalState('BCS.InitializeBuildingCostSystem()') from there.
		-- Otherwise all costs are gone after Saveload and the script will not work!
		
		-- Sollte die QSB-S nicht verwendet werden, muss Mission_OnSaveGameLoaded() im globalen Skript manuell überschrieben werden.
		-- Dort muss dann Logic.ExecuteInLuaLocalState('BCS.InitializeBuildingCostSystem()') aufgerufen werden.
		-- Ansonsten sind nach Saveload alle Kosten weg und das Skript wird nicht funktionieren!
	else
		local ErrorMessage = "ERROR: Could not load BuildingCostSystem!"
		Framework.WriteToLog(ErrorMessage)
		assert(false, ErrorMessage)
		return;
	end
	-- Done --
	
	--< Set your own BuildingCosts here! / Setze deine eigenen Gebäudekosten hier! >--
	--Gatherer - Farms
	BCS.EditBuildingCosts(UpgradeCategories.CattleFarm, 15, Goods.G_Salt, 12)
	BCS.EditBuildingCosts(UpgradeCategories.GrainFarm, 15, Goods.G_Olibanum, 12)
	BCS.EditBuildingCosts(UpgradeCategories.SheepFarm, 15, Goods.G_Dye, 12)
	BCS.EditBuildingCosts(UpgradeCategories.Beekeeper, 15, Goods.G_Medicine, 15)
	--Gatherer - Normal
	BCS.EditBuildingCosts(UpgradeCategories.Woodcutter, 12, Goods.G_Broom, 10)
	BCS.EditBuildingCosts(UpgradeCategories.HuntersHut, 12, Goods.G_Grain, 12)
	BCS.EditBuildingCosts(UpgradeCategories.FishingHut, 12, Goods.G_Gold, 85)
	BCS.EditBuildingCosts(UpgradeCategories.StoneQuarry, 15, Goods.G_Gold, 95)
	BCS.EditBuildingCosts(UpgradeCategories.HerbGatherer, 15, Goods.G_Grain, 15)
	BCS.EditBuildingCosts(UpgradeCategories.IronMine, 15, Goods.G_Milk, 15)
	--CityBuildings - Food
	BCS.EditBuildingCosts(UpgradeCategories.Butcher, 15, Goods.G_Carcass, 12)
	BCS.EditBuildingCosts(UpgradeCategories.Bakery, 15, Goods.G_Grain, 12)
	BCS.EditBuildingCosts(UpgradeCategories.Dairy, 15, Goods.G_Milk, 12)
	BCS.EditBuildingCosts(UpgradeCategories.SmokeHouse, 15, Goods.G_RawFish, 12)
	--CityBuildings - Clothing
	BCS.EditBuildingCosts(UpgradeCategories.Weaver, 8, Goods.G_Carcass, 12)
	BCS.EditBuildingCosts(UpgradeCategories.Tanner, 8, Goods.G_Wool, 12)
	--CityBuildings - Hygiene	
	BCS.EditBuildingCosts(UpgradeCategories.BroomMaker, 12, Goods.G_Salt, 12)
	BCS.EditBuildingCosts(UpgradeCategories.Soapmaker, 12, Goods.G_Dye, 12)
	BCS.EditBuildingCosts(UpgradeCategories.Pharmacy, 10, Goods.G_Honeycomb, 25)
	--CityBuildings - Entertainment
	BCS.EditBuildingCosts(UpgradeCategories.Tavern, 10, Goods.G_Salt, 12)
	BCS.EditBuildingCosts(UpgradeCategories.Theatre, 25, Goods.G_PoorSword, 12)
	BCS.EditBuildingCosts(UpgradeCategories.Baths, 16, Goods.G_Olibanum, 12)
	--CityBuildings - Decoration
	BCS.EditBuildingCosts(UpgradeCategories.Blacksmith, 15, Goods.G_MusicalInstrument, 12)
	BCS.EditBuildingCosts(UpgradeCategories.CandleMaker, 15, Goods.G_MusicalInstrument, 12)
	BCS.EditBuildingCosts(UpgradeCategories.Carpenter, 15, Goods.G_MusicalInstrument, 12)
	BCS.EditBuildingCosts(UpgradeCategories.BannerMaker, 15, Goods.G_MusicalInstrument, 12)
	--Military
	BCS.EditBuildingCosts(UpgradeCategories.Barracks, 25, Goods.G_Bread, 20)
	BCS.EditBuildingCosts(UpgradeCategories.BarracksBow, 25, Goods.G_Stone, 20)
	BCS.EditBuildingCosts(UpgradeCategories.SwordSmith, 12, Goods.G_Iron, 18)
	BCS.EditBuildingCosts(UpgradeCategories.BowMaker, 12, Goods.G_Iron, 18)
	BCS.EditBuildingCosts(UpgradeCategories.SiegeEngineWorkshop, 25, Goods.G_Iron, 35)
	--Other
	BCS.EditBuildingCosts(UpgradeCategories.Cistern, 12, Goods.G_Olibanum, 15)
	--Fields
	BCS.EditBuildingCosts(GetUpgradeCategoryForClimatezone("GrainField"), 8, Goods.G_Dye, 6)
	BCS.EditBuildingCosts(UpgradeCategories.CattlePasture, 8, Goods.G_Olibanum, 6)
	BCS.EditBuildingCosts(UpgradeCategories.SheepPasture, 8, Goods.G_Medicine, 6)
	BCS.EditBuildingCosts(UpgradeCategories.BeeHive, 8, Goods.G_Herb, 8)
	--Palisade/Wall - Gates
	BCS.EditBuildingCosts(UpgradeCategories.PalisadeGate, 10, Goods.G_Herb, 6)
	BCS.EditBuildingCosts(GetUpgradeCategoryForClimatezone("WallGate"), 16, Goods.G_Grain, 6)
	--Buildings without fixed cost
	BCS.EditWallCosts(3.2, Goods.G_Grain, 2.7) --Wallcosts/Mauerkosten (!NO REFUND)
	BCS.EditPalisadeCosts(3.5, Goods.G_Carcass, 1.2) --Palisadecosts/Palisadenkosten (!NO REFUND)
	BCS.EditRoadCosts(3, Goods.G_Leather, 1.8) --Roadcosts/Straßenkosten
	BCS.EditTrailCosts(Goods.G_Herb, 1.5, Goods.G_Sausage, 1.1) --Streetcosts/Wegkosten
	
	BCS.EditFestivalCosts(1.5, Goods.G_Sausage, 15) --Festivalcosts/Festkosten
	--The arguments here are multiplicators, that means: 1.5 -> 1.5 times the original cost
	--Die Argumente hier sind Multiplikatoren, heißt: 1.5 -> 1.5 mal den Originalbetrag
	
	--[[
	
	These are the possible goods you can use as building costs! / Dies sind die möglichen Waren die als Gebäudekosten verwendet werden können!
	
	Goods.G_Gold,
	Goods.G_RawFish, Goods.G_Grain, Goods.G_Wood, Goods.G_Iron, Goods.G_Carcass, Goods.G_Stone, Goods.G_Herb, Goods.G_Honeycomb, Goods.G_Wool, Goods.G_Milk,
	Goods.G_Gems, Goods.G_Dye, Goods.G_Salt, Goods.G_Olibanum, Goods.G_MusicalInstrument
	
	Including ALL City Goods from City Buildings, e.g. ... 
	Inkludierend ALLER Verbrauchsgüter von Stadtgebäuden, zum Beispiel ...
	
	Goods.G_Beer, Goods.G_Bread, Goods.G_Broom, Goods.G_Cheese, Goods.G_Clothes, Goods.G_Leather, Goods.G_Medicine,
	Goods.G_PoorBow, Goods.G_PoorSword, Goods.G_Sausage, Goods.G_SmokedFish, Goods.G_Soap, etc ...

	-> For a full list of goods look in the _G - list!
	-> Eine vollständige Auflistung aller Güter findet sich in der _G - Liste!

	]]--
	
	--This function here sets the amount of goods that are refunded when the building is knocked down.
	--Standard is 20% of the original good and half of the new good.
	--If you want to return f.e. 80 percent of the new good, then replace 0.5 with 0.8
	--Refunding does not work with walls and palisades.
	
	--Diese Funktion hier setzt die Höhe der Rückerstattung bei Abriss des Gebäudes.
	--Standardmäßig sind 20% Rückerstattung der originalen Ware und die Hälfte der neuen Ware eingestellt.
	--Wenn man z.B 80% der neuen Ware rückerstatten lassen will, ersetzt man 0.5 durch 0.8
	--Rückerstattung funktioniert nicht bei Mauern und Palisaden.
	BCS.SetKnockDownFactor(0.2, 0.5)
	
	--This function here sets whether city goods (Goods.G_Sausage, etc.) will be refunded at knock down.
	
	--Diese Funktion hier entscheidet, ob Verbrauchsgüter (Goods.G_Sausage, etc.) beim Abriss zurückerstattet werden.
	BCS.SetRefundCityGoods(true)
	
	--This function here sets whether city goods (Goods.G_Sausage, etc.) on the marketplace are counted towards the costs.
	
	--Diese Funktion hier entscheidet, ob Verbrauchsgüter (Goods.G_Sausage, etc.) als Karren auf dem Marktplatz zu den Kosten zählen.
	BCS.SetCountGoodsOnMarketplace(true)
end

function ResetMyBuildingCosts()
	-- Reset costs / Kosten zurücksetzen
	-- Just example calls / Nur Beispielaufrufe
	
	BCS.EditBuildingCosts(UpgradeCategories.BeeHive, nil)
	BCS.EditTrailCosts(nil)
	BCS.EditFestivalCosts(nil)
end
--#EOF