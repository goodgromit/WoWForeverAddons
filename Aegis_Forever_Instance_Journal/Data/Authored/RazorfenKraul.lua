local _, ns = ...

--[[
	Razorfen Kraul, written by hand over the generated data.
	Facts from warcraft.wiki.gg, "Razorfen Kraul (Classic)" (CC BY-SA 4.0), in our own words.
]]

ns.AmendInstance("RazorfenKraul", {
	description = "Where the demigod Agamaggan fell, his blood grew into a sprawl of giant thorns, and the quilboar "
		.. "made it their sacred home. Undead envoys have lately been seen among them, and Charlga Razorflank "
		.. "rules the Kraul from its heart.",

	bosses = {
		["Charlga Razorflank"] = {
			notes = { "The Kraul's leader, at the end of the thorn maze." },
		},
		-- Razorfen Spearhide is no boss, rare or fight of its own: "2 of them are guards of Overlord Ramtusk" (the
		-- owner, 2026-11-13). So no entry, map spot, run-block circle or loot list of its own: the two are among
		-- Ramtusk's adds, with the spells the recording of 2026-11-12 saw them cast in his fight (2776), and its
		-- Armor Piercer (6679) is with the trash drops, where the site's list already has it. Dev/build_data.py makes
		-- an entry only for a boss named in Data/Instances (or an addBosses list here): do not list the Spearhide
		-- there again, or the next rebuild gives it Ramtusk's fight and its own page back (Dev/test_build_bosses.py).
		-- Its model (display 6078, what its entry showed) stays on Ramtusk's Model tab, beside his own.
		["Overlord Ramtusk"] = {
			addModels = { [4438] = 6078 },
		},
	},
})
