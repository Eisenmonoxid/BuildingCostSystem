# BuildingCostSystem (BCS)

BCS is a extension lua script for the game "The Settlers 6" and can be embedded into a usermap.

### Usage
Include the file `main/bcs_local.lua` in your map folder and load it into your local map script. You can either use Script.Load() or the designated function from the [QSB](https://github.com/Siedelwood/Swift).
After you've loaded the file you call `OwnBuildingCostSystem.InitializeOwnBuildingCostSystem()` . After that, you can use the exported functions to set up your own BuildingCosts. For examples, take a look at the `main/bcs_costs.lua` file, which contains every possible function and every possible good. 
