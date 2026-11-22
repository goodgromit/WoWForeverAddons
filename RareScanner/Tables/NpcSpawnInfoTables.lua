-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------
local FOLDER_NAME, private = ...

---============================================================================
-- NPC Spawn Information Database
-- 
-- Supported fields for each NPC entry:
--   min    (number): Minimum respawn time in seconds (e.g. 1800 = 30m).
--   max    (number): Maximum respawn time in seconds (e.g. 3600 = 1h).
--   exact  (number): Exact fixed respawn time in seconds (translated as min=exact, max=exact).
--   event  (boolean): True if the NPC requires a manual trigger/summon/event/puzzle to spawn.
--   final  (boolean): True if the information of the NPC is definitive. The telemetry stops learning it (it doesn't save,
--            send or receive samples of the NPC). Without it, the telemetry keeps refining the NPC, but it discards the
--            samples that are far from min/max (less than min / 2 or more than max * 2).
--   onTime (number|table): Server clock schedule.
--            number: Period in minutes aligned to the hour (e.g. 15, 30, 60), or specific minute mark (e.g. 0 -> :00; 45 -> :45).
--            table: Explicit clock minutes within the hour (e.g. { 0, 15, 30, 45 } or { 10, 40 })
--                   or structured definition with server hours / weekdays:
--                   { minutes = { 0 }, hours = { 12, 18, 20 } }
--                   { minutes = { 0 }, hours = { 20 }, weekdays = { 4 } } -- Wednesday 20:00 server time
---============================================================================

private.NPC_SPAWN_INFO = {
	-- [npcID] = { min = 1800, max = 3600 },
	-- [npcID] = { exact = 900 },
	-- [npcID] = { event = true },
	-- [npcID] = { onTime = 30 },
	-- [npcID] = { onTime = 0 },
	-- [npcID] = { onTime = { hours = { 19, 21 }, minutes = { 0 } } },
	[247032] = { event = true },
	[5830] = { min = 1200, max = 2280 }, -- Sister Rathtalon
	[14272] = { min = 1200, max = 2760 }, -- Snarlflare
	[79] = { min = 900, max = 2340 }, -- Narg the Taskmaster
	[1132] = { min = 1140, max = 1920 }, -- Timber
	[5831] = { min = 3900, max = 5760 }, -- Swiftmane
	[5837] = { min = 1260, max = 2460 }, -- Stonearm
	[573] = { min = 1200, max = 2580 }, -- Foe Reaper 4000
	[5827] = { min = 60, max = 180 }, -- Brontus
	[5835] = { min = 1260, max = 2340 }, -- Foreman Grills
	[5863] = { min = 1200, max = 2760 }, -- Geopriest Gukk'rok
	[259758] = { min = 7320, max = 10500 }, -- Gul'gash
	[271080] = { min = 300, max = 660 }, -- Blightsculler
	[2453] = { min = 5400, max = 6600 }, -- Lo'Grosh
	[3270] = { min = 1200, max = 3240 }, -- Elder Mystic Razorsnout
	[3295] = { min = 1200, max = 2760 }, -- Sludge Beast
}
