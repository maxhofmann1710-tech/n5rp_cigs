Credits:  Sunny_Cigs
----------------------------------------------------------------------

This Script is a Remake of Sunny_cigs.

----------------------------------------------------------------------


i added:
--------------------
Animations for Throw.
More Smoke.
Nikotin Bar.
Nikotin Overdose.
--------------------------------------------------------------------
its all server.sided this means everyone can see the same.

FREE TO USE SCRIPT NO LICENSE REQUIRED.  !!!!!!!!!!!!!!!!!

----------------------------------------------------------------------

DEPENDENCY:  Ox_Lib

----------------------------------------------------------------------

IMPORTANT !!! : PLEASE ENSURE OX_LIB AND THIS SCRIPT LIKE THIS

----------------------------------------------------------------------

ensure Ox_Lib
ensure n5rp_cigs


and dont forget to put this line in your Ox_Inventory/data/items.lua
just at the end of the items.lua
copy/paste!!!

----------------------------------------------------------------------

[ox_inventory/data/items.lua] - Copy this code put it at the end !!!

----------------------------------------------------------------------

['cigarette'] = {
    label = 'Cigarette',
    consume = 0, -- IMPORTANT: Must be 0 so we handle removal manually
    weight = 10,
    stack = true,
    close = true,
    description = 'A single use cancer stick',
    client = {
        event = 'n5rp_cigs:cigarettes:client:UseCigarette'
    },
},

----------------------------------------------------------------------

feel free and rename it. or change what u want. its a free script. no license required. !!!
