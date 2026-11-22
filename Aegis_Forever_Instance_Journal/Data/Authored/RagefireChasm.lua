local _, ns = ...

--[[
	Ragefire Chasm, written by hand over the generated data.
	Facts from warcraft.wiki.gg, "Ragefire Chasm (Classic)" (CC BY-SA 4.0), in our own words.

	Its lore, and each of its four bosses', is Spoken's story, word for word (Core/SpokenLore.lua; the owner's
	decision of 2026-11-14: Spoken tells Ragefire Chasm and all four of its bosses).
]]

ns.AmendInstance("RagefireChasm", {
	bosses = {
		["Oggleflint"] = {
			notes = { "A trogg brute on the main path; a straightforward fight if no other packs join in." },
		},
		["Taragaman the Hungerer"] = {
			notes = {
				"A felguard standing in the middle of the lava lake, and the hardest-hitting boss here.",
				"His Uppercut can throw a player back into lava or into nearby enemies.",
			},
			spellFlags = { [18072] = { "Tank", "Important" }, [11970] = { "Healer" } },
		},
		["Jergosh the Invoker"] = {
			notes = { "A Searing Blade warlock; clear the cultists around him first." },
			spellFlags = { [20800] = { "Healer", "Magic" } },
		},
		["Bazzalan"] = {
			notes = { "A satyr on the walkway above Jergosh's chamber." },
		},
	},
})
