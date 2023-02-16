# BuildingCostSystem (BCS)

BCS is an lua script extension for the game "The Settlers 6" and can be embedded into a usermap.

### Usage
Include the file `bcs_local.lua` in your map folder and load it into your local map script. You can either use Script.Load() or the designated function from the [QSB](https://github.com/Siedelwood/Swift).

After you've loaded the file you call `BCS.InitializeBuildingCostSystem()` . After that, you can use the exported functions to set up your own BuildingCosts. For examples, take a look at the `bcs_costs.lua` file, which contains every possible function and every possible good. 

### Features

- Most buildings in the game can have new costs (see the exact possibilities and limitations in the `bcs_costs.lua` file).
- Walls, Roads, Trails and Palisades can use the new costs too.
- Festivals can have own costs.
- A few minor bug fixes in the game.
