Hey everyone!

I’m excited to release n5rp_cigs completely for free! [ Remake of Sunny_Cigs ]

[CREDITS TO: Sunny_Cigs - Owner]

This script brings the cigarette experience to a whole new level of immersion and realism. No more boring default animations or weak smoke – we went all-in on quality and detail so your players can finally enjoy smoking like it should feel in a real roleplay world.

Main Features:

Brand new, smooth smoking animation

Fresh cigarette discard / throwing away animation

Significantly increased and beautiful smoke particles – that real “WOW” realism effect everyone loves

Nicotine level display (HUD) so players can see their addiction level

Realistic dehydration effect when nicotine consumption gets too high (actual consequence for chain-smoking)

Perfect for any serious RP server that wants that extra layer of depth and immersion.

Dependencies:

ox_lib is REQUIRED and must be started BEFORE n5rp_cigs!

Download: 

Installation Guide:

Simply add this to your server.cfg:

cfg:

ensure ox_libensure n5rp_cigs

Important – Ox_Inventory Item:

You need to add the cigarette item to your inventory.

Add the following code to your ox_inventory/data/items.lua:

text:

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

(Just simply put this code, at the end of your ox_inventory / data / items.lua )

Support:I’ll try to help with small issues, but please make sure you followed the installation steps first.

Enjoy the script and make your server a bit more realistic! 🔥Feedback and screenshots of your players smoking are always welcome!
