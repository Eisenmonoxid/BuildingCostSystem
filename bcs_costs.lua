function SetMyBuildingCosts()
	--[[
		-> This function has to be called from the local script after BCS.InitializeBuildingCostSystem()
		-> You can change all costs at every time in the game. 
		-> The first good amount has to be equal or higher than the original costs.
		-> The second good and amount can be chosen freely.
		
		-> Diese Funktion muss aus dem lokalen Skript aufgerufen werden nach BCS.InitializeBuildingCostSystem()
		-> Es können alle Gebäudekosten zu jedem Zeitpunkt im Spiel geändert werden.
		-> Die Höhe der ersten Ware muss gleich oder höher dem Originalwert liegen!
		-> Die zweite Ware und ihre Höhe können frei festgelegt werden.
		
		Example call from the local lua script:
		
		function Mission_LocalOnMapStart()
			Script.Load("C:\\Path\\bcs_local.lua")
			Script.Load("C:\\Path\\bcs_costs.lua")
	
			if BCS ~= nil then
				BCS.InitializeBuildingCostSystem() -- Init system
				SetMyBuildingCosts() -- Set Custom Costs
			else
				Framework.WriteToLog("ERROR: Could not load BuildingCostSystem!")
				Game.LevelStop()
				Framework.CloseGame()
			end
		end
		
	]]--

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
	BCS.EditBuildingCosts(UpgradeCategories.Theatre, 25, Goods.G_Dye, 12)
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
	BCS.EditBuildingCosts(UpgradeCategories.GrainField_SouthEurope, 8, Goods.G_Dye, 6) --Replace SouthEurope with your climate zone! / Ersetze SouthEurope mit deiner derzeitigen Klimazone!
	BCS.EditBuildingCosts(UpgradeCategories.CattlePasture, 8, Goods.G_Olibanum, 6)
	BCS.EditBuildingCosts(UpgradeCategories.SheepPasture, 8, Goods.G_Medicine, 6)
	BCS.EditBuildingCosts(UpgradeCategories.BeeHive, 8, Goods.G_Herb, 8)
	--Palisade/Wall - Gates
	BCS.EditBuildingCosts(UpgradeCategories.PalisadeGate, 10, Goods.G_Dye, 6)
	BCS.EditBuildingCosts(UpgradeCategories.WallGate_SouthEurope, 16, Goods.G_Olibanum, 6) --Replace SouthEurope with your climate zone! / Ersetze SouthEurope mit deiner derzeitigen Klimazone!
	--Buildings without fixed cost
	BCS.EditWallCosts(4.2, Goods.G_Grain, 3) --Wallcosts/Mauerkosten (No production goods/Keine Verbrauchsgüter)
	BCS.EditPalisadeCosts(3.5, Goods.G_Gems, 5) --Palisadecosts/Palisadenkosten (No production goods/Keine Verbrauchsgüter)
	BCS.EditRoadCosts(3, Goods.G_Gems, 1.8) --Roadcosts/Straßenkosten (No production goods/Keine Verbrauchsgüter)
	BCS.EditTrailCosts(Goods.G_Herb, 1.5, Goods.G_Wood, 1) --Streetcosts/Wegkosten (No production goods/Keine Verbrauchsgüter)
	
	BCS.EditFestivalCosts(1.5, Goods.G_Sausage, 15) --Festivalcosts/Festkosten
	--The first arguments here are multiplicators, that means that 1.5 f.e means 1.5 times the original cost
	--Die ersten Argumente hier sind Multiplikatoren, das bedeutet das 1.5 heißt: 1.5 Mal die originalen Kosten
	
	BCS.ActivateHuntableAnimals(true) --The hunter can hunt lifestock as well! / Der Jäger kann auch Weidetiere jagen!
	
	--[[
	
	These are the possible goods you can use as building costs! / Dies sind die möglichen Waren die als Gebäudekosten verwendet werden können!
	
	Goods.G_Gold,
	Goods.G_RawFish, Goods.G_Grain, Goods.G_Wood, Goods.G_Iron, Goods.G_Carcass, Goods.G_Stone, Goods.G_Herb, Goods.G_Honeycomb, Goods.G_Wool, Goods.G_Milk,
	Goods.G_Gems, Goods.G_Dye, Goods.G_Salt, Goods.G_Olibanum, Goods.G_MusicalInstrument
	
	Including ALL City Goods from City Buildings, e.g. ... (!THESE GOODS DO NOT WORK WITH VARIABLE COST BUILDINGS like Wall, Palisade, Road and Trail and Festival)
	Inkludierend ALLER Verbrauchsgüter von Stadtgebäuden, zum Beispiel ... (!Diese Güter funktionieren nicht bei variablen Kostengebäuden wie Mauer, Palisade, Straße und Weg und Fest)
	
	Goods.G_Beer, Goods.G_Bread, Goods.G_Broom, Goods.G_Cheese, Goods.G_Clothes, Goods.G_Leather, Goods.G_Medicine,
	Goods.G_PoorBow, Goods.G_PoorSword, Goods.G_Sausage, Goods.G_SmokedFish, Goods.G_Soap, etc ...

	]]--
	
	--This function here sets the amount of goods that are returned when the building is knocked down!
	--Standard is 20% of the original good and half of the new good.
	--If you want to return f.e. 80 percent of the new good, then replace 0.5 with 0.8
	
	--Diese Funktion hier setzt die Höhe der Rückerstattung bei Abriss des Gebäudes!
	--Standardmäßig sind 20% Rückerstattung der originalen Ware und die Hälfte der neuen Ware eingestellt.
	--Wenn man z.B 80% der neuen Ware rückerstatten lassen will, ersetzt man 0.5 durch 0.8
	BCS.SetKnockDownFactor(0.2, 0.5)
	
	--This function here sets whether city goods (Goods.G_Sausage, etc.) will be refunded at knock down.
	
	--Diese Funktion hier entscheidet, ob Verbrauchsgüter (Goods.G_Sausage, etc.) beim Abriss zurückerstattet werden.
	BCS.SetRefundCityGoods(true)
	
	--This function here sets whether city goods (Goods.G_Sausage, etc.) on the marketplace are counted towards the costs.
	
	--Diese Funktion hier entscheidet, ob Verbrauchsgüter (Goods.G_Sausage, etc.) als Karren auf dem Marktplatz zu den Kosten zählen.
	BCS.SetCountGoodsOnMarketplace(true)
end

function ResetMyBuildingCosts()
	--Reset costs / Kosten zurücksetzen
	BCS.EditBuildingCosts(UpgradeCategories.BeeHive, nil)
	BCS.EditTrailCosts(nil)
end