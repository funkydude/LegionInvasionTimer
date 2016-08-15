
local f = CreateFrame("Frame")
local name, mod = ...
local colorTbl = {r=1,g=1,b=1}
local myID = UnitGUID("player")
local startBar = nil
local bar1Used, bar2Used = nil, nil
f:SetScript("OnEvent", function(frame, event, ...)
	mod[event](mod, ...)
end)
f:RegisterEvent("PLAYER_LOGIN")

function mod:PLAYER_LOGIN()
	local weekday, month, day, year = CalendarGetDate()
	if month ~= 8 or year ~= 2016 then
		f:SetScript("OnEvent", nil)
		mod = nil
		return -- Good times come to an end
	end

	startBar = LegionInvasionTimer.startBar
	f:RegisterEvent("SCENARIO_UPDATE")
	f:RegisterEvent("SCENARIO_COMPLETED")
end

function mod:SCENARIO_UPDATE()
	local _,_,_,_,_,_,_,_,_,rewardQuestID = C_Scenario.GetStepInfo()
	local _,currentStage = C_Scenario.GetInfo()

	for i = 3, 8 do
		local _,_, rewardQuestIDInv = GetInvasionInfo(i)
		if rewardQuestID == rewardQuestIDInv and currentStage == 4 then
			myID = UnitGUID("player")
			bar1Used, bar2Used = nil, nil
			f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- Boss is coming up, register
		end
	end
end

do
	local texString = ":15:15:0:0:64:64:4:60:4:60|t "
	local text = {
		SPELL_CAST_START = {
			[219112] = {"|T".. GetSpellTexture(219112) ..texString.. GetSpellInfo(219112).. " (RUN TO BOSS)", -- Eye of Darkness
				{
					[106891] = 34, -- Darkmagus Drazzok
					[107122] = 34, -- Harbinger Drel'nathar
					[107124] = 50, -- Harbinger Faraleth
					[106892] = 45, -- Darkmagus Falo'reth
				},
			},
			[219110] = {"|T".. GetSpellTexture(219110) ..texString.. GetSpellInfo(219110).. " (RUN AWAY FROM BOSS)", -- Shadow Nova
				{
					[106891] = 34, -- Darkmagus Drazzok
					[107122] = 34, -- Harbinger Drel'nathar
					[107124] = 50, -- Harbinger Faraleth
				},
			},
			[219960] = {"|T".. GetSpellTexture(219960) ..texString.. GetSpellInfo(219960).. " (FRONTAL CONE DMG)", 32}, -- Breath of Shadows
			[219957] = {"|T".. GetSpellTexture(219957) ..texString.. GetSpellInfo(219957).. " (DEBUFF INC)", 46}, -- Mark of Baldrazar
			[217093] = {"|T".. GetSpellTexture(217093) ..texString.. GetSpellInfo(217093).. " (MIND CONTROL INC)", 48}, -- Shadow Madness
			[217098] = {"|T".. GetSpellTexture(217098) ..texString.. GetSpellInfo(217098).. " (FRONTAL CONE DMG)", 16}, -- Carrion Swarm
			[217134] = {"|T".. GetSpellTexture(217134) ..texString.. GetSpellInfo(217134).. " (FRONTAL CLEAVE)", 33}, -- Vampiric Cleave
			[217040] = {"|T".. GetSpellTexture(217040) ..texString.. GetSpellInfo(217040).. " (THREAT WIPE - SPAWN ADD)", 35}, -- Shadow Illusion
			[216916] = {"|T".. GetSpellTexture(216916) ..texString.. GetSpellInfo(216916).. " (FRONTAL CONE DMG)", 35}, -- Waves of Dread
			[219469] = {"|T".. GetSpellTexture(219469) ..texString.. GetSpellInfo(219469).. " (KILL THEM FAST)", 42}, -- Summon Explosive Orbs
			[217939] = {"|T".. GetSpellTexture(217939) ..texString.. GetSpellInfo(217939).. " (FRONTAL CLEAVE - THREAT WIPE)", 31}, -- Fel Slash
			[217949] = {"|T".. GetSpellTexture(217949) ..texString.. GetSpellInfo(217949).. " (SHARED CLEAVE - HUG FRONT OF BOSS)", 25}, -- Meteor Slash
			[217946] = {"|T".. GetSpellTexture(217946) ..texString.. GetSpellInfo(217946).. " (FRONTAL CONE DMG)", 25}, -- Fel Breath
			[219441] = {"|T".. GetSpellTexture(219441) ..texString.. GetSpellInfo(219441).. " (FRONTAL CONE DMG)", 40}, -- Flame Breath
			[217958] = {"|T".. GetSpellTexture(217958) ..texString.. GetSpellInfo(217958).. " (FRONTAL CONE DMG)", 15}, -- Chaos Wave
			[213890] = {"|T".. GetSpellTexture(213890) ..texString.. GetSpellInfo(213890).. " (RUN AWAY FROM BOSS)", 33}, -- Carrion Storm
		},
		SPELL_AURA_REMOVED = {
			[219112] = {"|T".. GetSpellTexture(219112) ..texString.. GetSpellInfo(219112).. " (FINISHED)"}, -- Eye of Darkness
			[213890] = {"|T".. GetSpellTexture(213890) ..texString.. GetSpellInfo(213890).. " (FINISHED)"}, -- Carrion Storm
		},
		SPELL_CAST_SUCCESS = {
			[218637] = {"|T".. GetSpellTexture(218637) ..texString.. GetSpellInfo(218637).. " (DISPEL BOSS)", 15}, -- Pyrogenics
			[218146] = {"|T".. GetSpellTexture(218311) ..texString.. GetSpellInfo(218311).. " (STAY CLEAR)", 30, 218311}, -- Fel Spike
			[219048] = {"|T".. GetSpellTexture(219059) ..texString.. GetSpellInfo(219059).. " (STAY CLEAR)", 40, 219059}, -- Flame Fissure
			[218940] = {false, 11}, -- Fel Lightning
			[218659] = {false, 52}, -- Charred Flesh
		},
	}
	function mod:COMBAT_LOG_EVENT_UNFILTERED(_, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName)
		local msg = text[event] and text[event][spellId]
		if msg then
			if msg[2] then
				local timer
				if type(msg[2]) == "table" then
					local _, _, _, _, _, id = strsplit("-", sourceGUID)
					id = tonumber(id) or 1
					timer = msg[2][id]
					if not timer then
						timer = 45
						print("|cFF33FF99LegionInvasionTimer|r: No timer for ", spellId, id, sourceName)
					end
				else
					timer = msg[2]
				end
				if not bar1Used or bar1Used == spellId then
					bar1Used = spellId
					startBar(spellName, timer, 0, GetSpellTexture(msg[3] or spellId), true)
				elseif not bar2Used or bar2Used == spellId then
					bar2Used = spellId
					startBar(spellName, timer, 0, GetSpellTexture(msg[3] or spellId), false)
				end
			end
			if msg[1] then
				print("|cFF33FF99LegionInvasionTimer|r:", msg[1])
				RaidNotice_AddMessage(RaidBossEmoteFrame, msg[1], colorTbl, 4)
				PlaySound("RaidWarning", "Master")
			end
		end

		if event == "SPELL_AURA_APPLIED" then
			if spellId == 219176 then -- Secrete Shadows 31-41s
				-- 10 sec debuff on tank
				local msg = "|T".. GetSpellTexture(spellId) ..texString.. spellName.. ": ".. gsub(destName, "%-.+", "*") .." (TANK SWAP)"
				print("|cFF33FF99LegionInvasionTimer|r:", msg)
				RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 4)
				PlaySound("RaidWarning", "Master")
			elseif spellId == 219958 and destGUID == myID then -- Mark of Baldrazar
				-- 20 sec debuff, explosion on damage taken
				local msg = "|T".. GetSpellTexture(spellId) ..texString.. spellName .." (ON YOU, AVOID DAMAGE)"
				print("|cFF33FF99LegionInvasionTimer|r:", msg)
				RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 4)
				PlaySound("RaidWarning", "Master")
			elseif spellId == 218350 and destGUID == myID then -- Bound by Fel
				-- 20 sec debuff, chains you to another player
				local msg = "|T".. GetSpellTexture(spellId) ..texString.. spellName .." (ON YOU, RUN TO OTHER PLAYER)"
				print("|cFF33FF99LegionInvasionTimer|r:", msg)
				RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 4)
				PlaySound("RaidWarning", "Master")
			elseif spellId == 218657 and destGUID == myID then -- Charred Flesh
				-- 20 sec debuff, chains you to another player
				local msg = "|T".. GetSpellTexture(spellId) ..texString.. spellName .." (ON YOU, HEAL YOURSELF)"
				print("|cFF33FF99LegionInvasionTimer|r:", msg)
				RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 4)
				PlaySound("RaidWarning", "Master")
			elseif (spellId == 219367 or spellId == 207576 or spellId == 217549) and destGUID == myID then -- Rain of Fire / Fel Fire / Fel Flames
				local msg = "|T".. GetSpellTexture(spellId) ..texString.. spellName .." (ON YOU, GET OUT)"
				print("|cFF33FF99LegionInvasionTimer|r:", msg)
				RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 4)
				PlaySound("RaidWarning", "Master")
			end
		end
	end
end

function mod:SCENARIO_COMPLETED()
	local _,_,_,_,_,_,_,_,_,scenarioType = C_Scenario.GetInfo()
	if scenarioType == 4 then -- LE_SCENARIO_TYPE_LEGION_INVASION = 4
		bar1Used, bar2Used = nil, nil
		f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- Boss killed, unregister
	end
end


