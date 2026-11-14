local _, ns = ...

--[[
	Factions as the journal shows them: the player's standing with one, each standing's
	colour and badge, and a faction's crest.

	Badges are Blizzard's handshake icons, one colour per standing. Crests come from
	Data/Authored/Factions.lua; where the client lacks the named icon, the faction's best
	reward stands in, so a card is never blank.
]]

local Reputation = {}
ns.Reputation = Reputation

local ICONS = "Interface\\Icons\\"

-- FACTION_BAR_COLORS, for a client without it.
local FALLBACK_COLORS = {
	{ 0.8, 0.3, 0.22 }, { 0.8, 0.3, 0.22 }, { 0.75, 0.27, 0 }, { 0.9, 0.7, 0 },
	{ 0, 0.6, 0.1 }, { 0, 0.6, 0.1 }, { 0, 0.6, 0.1 }, { 0, 0.6, 0.1 },
}

-- The handshake whose colour goes with each standing: red when hostile, gold at Neutral,
-- then Friendly green, Honored blue, Revered purple and Exalted orange.
local BADGES = {
	"Achievement_Reputation_03", "Achievement_Reputation_03", "Achievement_Reputation_03",
	"Achievement_Reputation_01", "Achievement_Reputation_06", "Achievement_Reputation_05",
	"Achievement_Reputation_02", "Achievement_Reputation_07",
}

-- The friendly standings in their badges' colours; Blizzard's bars make all four green.
local STANDING_COLORS = {
	[5] = { 0.1, 0.7, 0.15 }, [6] = { 0.15, 0.55, 0.95 }, [7] = { 0.65, 0.35, 0.95 }, [8] = { 1, 0.5, 0.1 },
}
local LAST_RESORT = ICONS .. "INV_Misc_QuestionMark"

local exists = {}
local function Exists(path)
	if exists[path] == nil then exists[path] = ns.FileExists(path) end
	return exists[path]
end

function Reputation:Label(reaction, fallback)
	return _G["FACTION_STANDING_LABEL" .. tostring(reaction)] or fallback or "?"
end

function Reputation:Color(reaction)
	local own = STANDING_COLORS[reaction]
	if own then return own[1], own[2], own[3] end
	local color = FACTION_BAR_COLORS and FACTION_BAR_COLORS[reaction]
	if type(color) == "table" and color.r then return color.r, color.g, color.b end
	color = FALLBACK_COLORS[reaction] or { 0.6, 0.6, 0.6 }
	return color[1], color[2], color[3]
end

-- The standing's handshake, or nil when the client has no such icon. Wares that need no standing
-- ("Any standing", ns.ANY_STANDING) take Neutral's gold one.
function Reputation:Badge(reaction)
	local name = BADGES[reaction] or (reaction == ns.ANY_STANDING and BADGES[4]) or nil
	if not name then return nil end
	local path = ICONS .. name
	return Exists(path) and path or nil
end

--[[
	The player's standing: { reaction, value, max, description }, value and max counted
	within the current standing. Nil for a faction the client knows nothing about.
]]
function Reputation:Player(factionID)
	if C_Reputation and C_Reputation.GetFactionDataByID then
		local ok, data = pcall(C_Reputation.GetFactionDataByID, factionID)
		local reaction = ok and data and ns.Readable(data.reaction)
		if type(reaction) == "number" and reaction > 0 then
			local low, high = data.currentReactionThreshold or 0, data.nextReactionThreshold or 0
			return {
				reaction = reaction,
				value = (data.currentStanding or low) - low,
				max = high - low,
				description = data.description ~= "" and data.description or nil,
			}
		end
	end
	if type(GetFactionInfoByID) == "function" then
		local ok, name, description, reaction, low, high, value = pcall(GetFactionInfoByID, factionID)
		if ok and name and type(reaction) == "number" and reaction > 0 then
			return { reaction = reaction, value = (value or 0) - (low or 0), max = (high or 0) - (low or 0),
				description = description ~= "" and description or nil }
		end
	end
	return nil
end

--[[
	The faction's name as the client writes it, by its id; nil where the client gives none (an id it
	does not know). Whether it names a faction the player has not met yet is still to be checked in
	game; where it does not, the callers fall back to the journal's own name.
]]
function Reputation:ClientName(factionID)
	if type(factionID) ~= "number" then return nil end
	local name
	if C_Reputation and C_Reputation.GetFactionDataByID then
		local ok, data = pcall(C_Reputation.GetFactionDataByID, factionID)
		name = ok and type(data) == "table" and ns.Readable(data.name) or nil
	end
	if (type(name) ~= "string" or name == "") and type(GetFactionInfoByID) == "function" then
		local ok, infoName = pcall(GetFactionInfoByID, factionID)
		name = ok and ns.Readable(infoName) or nil
	end
	if type(name) ~= "string" or name == "" then return nil end
	return name
end

--[[
	A quest reward's faction, named as the data writes it in English ("Undercity"): the client's own
	name for it, by its id (Data/Authored/Factions.lua's ns.QUEST_FACTION_IDS); else the Reputation
	tab's, in the journal's language; else the English. A name the data does not know (one the
	player's own recording kept, in the client's words) is given back as it is.
]]
function Reputation:QuestFactionName(name)
	local factionID = ns.QUEST_FACTION_IDS and ns.QUEST_FACTION_IDS[name]
	if not factionID then return name end
	local client = self:ClientName(factionID)
	if client then return client end
	local tab = ns.GetInstance("Faction" .. factionID)
	return tab and tab.name or name
end

-- Whether the player has reached a standing with the faction.
function Reputation:Reached(faction, reaction)
	local standing = self:Player(faction.factionID)
	return standing ~= nil and standing.reaction >= reaction
end

-- The faction's crest: the first authored icon this client has, else its best reward's icon.
function Reputation:Crest(faction)
	if faction.crest then return faction.crest end
	for _, path in ipairs(faction.icons or {}) do
		if Exists(path) then
			faction.crest = path
			return path
		end
	end
	for index = #faction.bosses, 1, -1 do
		for _, row in ipairs(faction.bosses[index].loot or {}) do
			local icon = ns.Items:Icon(row.itemID)
			if icon then
				faction.crest = icon
				return icon
			end
		end
	end
	return self:Badge(8) or LAST_RESORT
end

-- How many different items the faction rewards.
function Reputation:RewardCount(faction)
	if not faction.rewardCount then
		local seen, count = {}, 0
		for _, standing in ipairs(faction.bosses) do
			for _, row in ipairs(standing.loot or {}) do
				if not seen[row.itemID] then
					seen[row.itemID] = true
					count = count + 1
				end
			end
		end
		faction.rewardCount = count
	end
	return faction.rewardCount
end

-- The faction's card colour.
local DEFAULT_COLOR = { 0.55, 0.45, 0.25 }
function Reputation:CardColor(faction)
	return faction.color or DEFAULT_COLOR
end
