function SetMyBuildingCosts()
	--[[
		-> This function has to be called from the local script after OwnBuildingCostSystem.InitializeOwnBuildingCostSystem()
		-> You can change all costs at every time in the game. 
		-> The first good amount has to be equal or higher than the original costs.
		-> The second good and amount can be chosen freely.
		
		-> Diese Funktion muss aus dem lokalen Skript aufgerufen werden nach OwnBuildingCostSystem.InitializeOwnBuildingCostSystem()
		-> Es können alle Gebäudekosten zu jedem Zeitpunkt im Spiel geändert werden.
		-> Die Höhe der ersten Ware muss gleich oder höher dem Originalwert liegen!
		-> Die zweite Ware und ihre Höhe können frei festgelegt werden.
	]]--

	--Gatherer - Farms
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.CattleFarm, 15, Goods.G_Salt, 12)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.GrainFarm, 15, Goods.G_Olibanum, 12)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.SheepFarm, 15, Goods.G_Dye, 12)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.Beekeeper, 15, Goods.G_Medicine, 15)
	--Gatherer - Normal
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.Woodcutter, 12, Goods.G_Broom, 10)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.HuntersHut, 12, Goods.G_Grain, 12)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.FishingHut, 12, Goods.G_Gold, 85)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.StoneQuarry, 15, Goods.G_Gold, 95)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.HerbGatherer, 15, Goods.G_Grain, 15)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.IronMine, 15, Goods.G_Milk, 15)
	--CityBuildings - Food
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.Butcher, 15, Goods.G_Carcass, 12)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.Bakery, 15, Goods.G_Grain, 12)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.Dairy, 15, Goods.G_Milk, 12)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.SmokeHouse, 15, Goods.G_RawFish, 12)
	--CityBuildings - Clothing
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.Weaver, 8, Goods.G_Carcass, 12)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.Tanner, 8, Goods.G_Wool, 12)
	--CityBuildings - Hygiene	
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.BroomMaker, 12, Goods.G_Salt, 12)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.Soapmaker, 12, Goods.G_Dye, 12)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.Pharmacy, 10, Goods.G_Honeycomb, 25)
	--CityBuildings - Entertainment
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.Tavern, 10, Goods.G_Salt, 12)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.Theatre, 25, Goods.G_Dye, 12)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.Baths, 16, Goods.G_Olibanum, 12)
	--CityBuildings - Decoration
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.Blacksmith, 15, Goods.G_MusicalInstrument, 12)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.CandleMaker, 15, Goods.G_MusicalInstrument, 12)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.Carpenter, 15, Goods.G_MusicalInstrument, 12)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.BannerMaker, 15, Goods.G_MusicalInstrument, 12)
	--Military
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.Barracks, 25, Goods.G_Bread, 20)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.BarracksBow, 25, Goods.G_Stone, 20)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.SwordSmith, 12, Goods.G_Iron, 18)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.BowMaker, 12, Goods.G_Iron, 18)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.SiegeEngineWorkshop, 25, Goods.G_Iron, 35)
	--Other
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.Cistern, 12, Goods.G_Olibanum, 15)
	--Fields
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.GrainField_SouthEurope, 8, Goods.G_Dye, 6) --Replace SouthEurope with your climate zone! / Ersetze SouthEurope mit deiner derzeitigen Klimazone!
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.CattlePasture, 8, Goods.G_Olibanum, 6)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.SheepPasture, 8, Goods.G_Medicine, 6)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.BeeHive, 8, Goods.G_Herb, 8)
	--Palisade/Wall - Gates
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.PalisadeGate, 10, Goods.G_Dye, 6)
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.WallGate_SouthEurope, 16, Goods.G_Olibanum, 6) --Replace SouthEurope with your climate zone! / Ersetze SouthEurope mit deiner derzeitigen Klimazone!
	--Buildings without fixed cost
	OwnBuildingCostSystem.EditWallCosts(4.2, Goods.G_Grain, 3) --Wallcosts/Mauerkosten (No production goods/Keine Verbrauchsgüter)
	OwnBuildingCostSystem.EditPalisadeCosts(3.5, Goods.G_Gems, 5) --Palisadecosts/Palisadenkosten (No production goods/Keine Verbrauchsgüter)
	OwnBuildingCostSystem.EditRoadCosts(3, Goods.G_Gems, 1.8) --Roadcosts/Straßenkosten (No production goods/Keine Verbrauchsgüter)
	OwnBuildingCostSystem.EditTrailCosts(Goods.G_Herb, 1.5, Goods.G_Wood, 1) --Streetcosts/Wegkosten (No production goods/Keine Verbrauchsgüter)
	
	OwnBuildingCostSystem.EditFestivalCosts(1.5, Goods.G_Gems, 15) --Festivalcosts/Festkosten (No production goods/Keine Verbrauchsgüter)
	--The first arguments here are multiplicators, that means that 1.5 f.e means 1.5 times the original cost
	--Die ersten Argumente hier sind Multiplikatoren, das bedeutet das 1.5 heißt: 1.5 Mal die originalen Kosten
	
	OwnBuildingCostSystem.ActivateHuntableAnimals(true) --The hunter can hunt lifestock as well! / Der Jäger kann auch Weidetiere jagen!
	
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
	OwnBuildingCostSystem.SetKnockDownFactor(0.2, 0.5)
	
	--This function here sets whether city goods (Goods.G_Sausage, etc.) will be refunded at knock down.
	
	--Diese Funktion hier entscheidet, ob Verbrauchsgüter (Goods.G_Sausage, etc.) beim Abriss zurückerstattet werden.
	OwnBuildingCostSystem.SetRefundCityGoods(true)
	
	--This function here sets whether city goods (Goods.G_Sausage, etc.) on the marketplace are counted towards the costs.
	
	--Diese Funktion hier entscheidet, ob Verbrauchsgüter (Goods.G_Sausage, etc.) als Karren auf dem Marktplatz zu den Kosten zählen.
	OwnBuildingCostSystem.SetCountGoodsOnMarketplace(true)
end

function ResetMyBuildingCosts()
	--Reset costs / Kosten zurücksetzen
	OwnBuildingCostSystem.EditBuildingCosts(UpgradeCategories.BeeHive, nil)
	OwnBuildingCostSystem.EditTrailCosts(nil)
end