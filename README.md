# BuildingCostSystem (BCS)

BCS is an lua script extension for the game "The Settlers 6" and can be embedded into a usermap.

### Usage
Include the files `bcs.bin` (lua source code is in `bcs_local_raw.lua`) and `bcs_costs.lua` in your map folder and load them into your local map script. You can either use Script.Load() or the designated function from the [QSB](https://github.com/Siedelwood/Revision).

Then you call `SetMyBuildingCosts()`. After that, you can use the exported functions to set up your own BuildingCosts. For examples, take a look at the `bcs_costs.lua` file, which contains every possible function and every possible good. 

### Features

- Most buildings in the game can have new costs (see the exact possibilities and limitations in the `bcs_costs.lua` file).
- Walls, Roads, Trails and Palisades can use the new costs too.
- Festivals can have own costs.
- A few minor bug fixes in the game.

If errors occur, please notify me so i can fix them. ;)
