
local f = CreateFrame("Frame")
local name, mod = ...
local L = mod.L
local colorTbl = mod.c
local myID = UnitGUID("player")
local startBar, stopBar = mod.startBar, mod.stopBar
local flameFissureTime = 15
local printLit = "|cFF33FF99LegionInvasionTimer|r:"
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

	f:RegisterEvent("SCENARIO_UPDATE")
	f:RegisterEvent("SCENARIO_COMPLETED")
	f:RegisterEvent("CHAT_MSG_CURRENCY")
	f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:ZONE_CHANGED_NEW_AREA()
	self:SCENARIO_UPDATE()
end

function mod:SCENARIO_UPDATE()
	if self.f.db.hideBossWarnings then return end
	local _,_,_,_,_,_,_,_,_,rewardQuestID = C_Scenario.GetStepInfo()
	local _,currentStage = C_Scenario.GetInfo()

	for i = 3, 8 do
		local _,_, rewardQuestIDInv = GetInvasionInfo(i)
		if rewardQuestID == rewardQuestIDInv and currentStage == 4 then
			myID = UnitGUID("player")
			flameFissureTime = 15
			f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- Boss is coming up, register
			stopBar(nil, true)
		end
	end
end

do
	local texString = ":15:15:0:0:64:64:4:60:4:60|t "
	local text = {
		SPELL_CAST_START = {
			[219112] = {"|T".. GetSpellTexture(219112) ..texString.. L.runToBoss.. " (".. GetSpellInfo(219112) ..")", -- Eye of Darkness
				{
					[106891] = 34, -- Darkmagus Drazzok
					[107122] = 34, -- Harbinger Drel'nathar
					[107124] = 50, -- Harbinger Faraleth
					[106892] = 45, -- Darkmagus Falo'reth
				},
			},
			[219110] = {"|T".. GetSpellTexture(219110) ..texString.. L.runAwayFromBoss.. " (".. GetSpellInfo(219110).. ")", -- Shadow Nova
				{
					[106891] = 34, -- Darkmagus Drazzok
					[107122] = 34, -- Harbinger Drel'nathar
					[107124] = 50, -- Harbinger Faraleth
				},
			},
			[219960] = {"|T".. GetSpellTexture(219960) ..texString.. L.frontConeDmg.. " (".. GetSpellInfo(219960).. ")", 32}, -- Breath of Shadows
			[217946] = {"|T".. GetSpellTexture(217946) ..texString.. L.frontConeDmg.. " (".. GetSpellInfo(217946).. ")", 25}, -- Fel Breath
			[219441] = {"|T".. GetSpellTexture(219441) ..texString.. L.frontConeDmg.. " (".. GetSpellInfo(219441).. ")", 40}, -- Flame Breath
			[217958] = {"|T".. GetSpellTexture(217958) ..texString.. L.frontConeDmg.. " (".. GetSpellInfo(217958).. ")", 15}, -- Chaos Wave
			[217098] = {"|T".. GetSpellTexture(217098) ..texString.. L.frontConeDmg.. " (".. GetSpellInfo(217098).. ")", 16}, -- Carrion Swarm
			[216916] = {"|T".. GetSpellTexture(216916) ..texString.. L.frontConeDmg.. " (".. GetSpellInfo(216916).. ")", 35}, -- Waves of Dread
			[217134] = {"|T".. GetSpellTexture(217134) ..texString.. L.frontalCleave.. " (".. GetSpellInfo(217134).. ")", 33}, -- Vampiric Cleave
			[217939] = {"|T".. GetSpellTexture(217939) ..texString.. L.frontalCleaveWipe.. " (".. GetSpellInfo(217939).. ")", 31}, -- Fel Slash
			[219957] = {"|T".. GetSpellTexture(219957) ..texString.. L.debuffInc.. " (".. GetSpellInfo(219957).. ")", 46}, -- Mark of Baldrazar
			[217093] = {"|T".. GetSpellTexture(217093) ..texString.. L.mindControlInc.. " (".. GetSpellInfo(217093).. ")", 48}, -- Shadow Madness
			[217040] = {"|T".. GetSpellTexture(217040) ..texString.. L.threatWipeSpawnAdd.. " (".. GetSpellInfo(217040).. ")", 35}, -- Shadow Illusion
			[219469] = {"|T".. GetSpellTexture(219469) ..texString.. L.killOrbsFast.. " (".. GetSpellInfo(219469).. ")", 42}, -- Summon Explosive Orbs
			[217949] = {"|T".. GetSpellTexture(217949) ..texString.. L.sharedCleave.. " (".. GetSpellInfo(217949).. ")", 25}, -- Meteor Slash
			[213890] = {"|T".. GetSpellTexture(213890) ..texString.. L.runAwayFromBoss.. " (".. GetSpellInfo(213890).. ")", 33}, -- Carrion Storm
		},
		SPELL_AURA_REMOVED = {
			[219112] = {"|T".. GetSpellTexture(219112) ..texString.. L.finished:format((GetSpellInfo(219112)))}, -- Eye of Darkness
			[213890] = {"|T".. GetSpellTexture(213890) ..texString.. L.finished:format((GetSpellInfo(213890)))}, -- Carrion Storm
		},
		SPELL_CAST_SUCCESS = {
			[218146] = {"|T".. GetSpellTexture(218311) ..texString.. L.watchOut:format((GetSpellInfo(218311))), 30, 218311}, -- Fel Spike
			[219048] = {"|T".. GetSpellTexture(219059) ..texString.. L.watchOut:format((GetSpellInfo(219059))), -1, 219059}, -- Flame Fissure spell, casted by NPC "Flame Fissure", but the timer changes depending on what boss summoned that NPC.
			[218940] = {false, 11}, -- Fel Lightning
			[218659] = {false, 52}, -- Charred Flesh
			[219411] = {false, 31}, -- Fel Stomp
			[219310] = {false, 23}, -- Cripple
			[218637] = {false, 15}, -- Pyrogenics, bar here, warning in APPLIED
			[225268] = {false, 34}, -- Legion's Flames, bar here, warning in APPLIED
		},
	}
	function mod:COMBAT_LOG_EVENT_UNFILTERED(_, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName)
		local msg = text[event] and text[event][spellId]
		if msg then
			if msg[2] then
				local timer
				local _, _, _, _, _, id = strsplit("-", sourceGUID)
				id = tonumber(id) or 1

				if id == 107115 then
					-- There's no SPELL_SUMMON we can use :(
					-- If any spell is casted by Flameweaver Verathix (107115) then
					-- save the ID and use it to set the timer for Flame Fissure.
					-- Coding for WoW bosses has never been the cleanest experience.
					flameFissureTime = 40
				end

				if type(msg[2]) == "table" then
					timer = msg[2][id]
					if not timer then
						print("|cFF33FF99LegionInvasionTimer|r: No timer for ", spellId, id, sourceName)
						return
					end
				else
					timer = msg[2]
					if timer == -1 then -- Flame Fissure
						-- If summoned by Arch Magus Velysra, NPC ID 106893, then 15 sec (default)
						-- If summoned by Flameweaver Verathix, NPC ID 107115, then 40 sec (changed earlier)
						timer = flameFissureTime
					end
				end

				startBar(spellName, timer, 0, GetSpellTexture(msg[3] or spellId))
			end
			if msg[1] then
				print(printLit, msg[1])
				RaidNotice_AddMessage(RaidBossEmoteFrame, msg[1], colorTbl, 5)
				PlaySound("RaidWarning", "Master")
			end
		end

		if event == "SPELL_AURA_APPLIED" then
			if spellId == 219176 then -- Secrete Shadows 31-41s
				local s = GetSpecialization()
				if s and GetSpecializationRole(s) == "TANK" then-- 10 sec debuff on tank
					local msg = "|T".. GetSpellTexture(spellId) ..texString.. L.changeTank:format(spellName, (gsub(destName, "%-.+", "*")))
					print(printLit, msg)
					RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 4)
					PlaySound("RaidWarning", "Master")
				end
			elseif spellId == 218637 and destGUID:find("Creature", nil, true) then -- Pyrogenics, buff on boss
				-- Mass Dispel (Priest), Dispel Magic (Priest), Purge (Shaman), Spellsteal (Mage)
				if IsSpellKnown(32375) or IsSpellKnown(528) or IsSpellKnown(370) or IsSpellKnown(30449) then
					local msg = "|T".. GetSpellTexture(spellId) ..texString.. L.dispelBoss.. " (".. spellName ..")"
					print(printLit, msg)
					RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 5)
					PlaySound("RaidWarning", "Master")
				end
			elseif spellId == 219958 and destGUID == myID then -- Mark of Baldrazar
				-- 20 sec debuff, explosion on damage taken
				local msg = "|T".. GetSpellTexture(spellId) ..texString.. L.damageMark.. " (".. spellName ..")"
				print(printLit, msg)
				RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 4)
				PlaySound("RaidWarning", "Master")
			elseif spellId == 218350 and destGUID == myID then -- Bound by Fel
				-- 20 sec debuff, chains you to another player
				local msg = "|T".. GetSpellTexture(spellId) ..texString.. L.runToLink.. " (".. spellName ..")"
				print(printLit, msg)
				RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 5)
				PlaySound("RaidWarning", "Master")
			elseif spellId == 218657 and destGUID == myID then -- Charred Flesh
				-- 20 sec debuff, chains you to another player
				local msg = "|T".. GetSpellTexture(spellId) ..texString.. L.healYourself.. " (".. spellName ..")"
				print(printLit, msg)
				RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 4)
				PlaySound("RaidWarning", "Master")
			elseif spellId == 217559 and destGUID == myID then -- Creeping Doom
				-- 15 sec debuff, damages you if you stay still
				local msg = "|T".. GetSpellTexture(spellId) ..texString.. L.keepMoving:format(spellName)
				print(printLit, msg)
				RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 4)
				PlaySound("RaidWarning", "Master")
			elseif spellId == 217530 and destGUID == myID then -- Fel Burn
				-- 12 sec debuff, makes you drop fire patches every 3 sec
				local msg = "|T".. GetSpellTexture(spellId) ..texString.. L.firePatches.. " (".. spellName ..")"
				print(printLit, msg)
				RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 4)
				PlaySound("RaidWarning", "Master")
			elseif spellId == 225269 and destGUID == myID then -- Legion's Flames
				-- 12 sec debuff, explode allies within 10yd after expiration
				local msg = "|T".. GetSpellTexture(spellId) ..texString.. L.fireBomb.. " (".. spellName ..")"
				print(printLit, msg)
				RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 4)
				PlaySound("RaidWarning", "Master")
			elseif spellId == 218368 and destGUID == myID then -- Fixated
				-- 15 sec debuff, the ball (Fragment of Argus) chases the player and explodes on impact
				local msg = "|T".. GetSpellTexture(spellId) ..texString.. L.ballOnYou.. " (".. spellName ..")"
				print(printLit, msg)
				RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 4)
				PlaySound("RaidWarning", "Master")
			elseif (spellId == 219367 or spellId == 207576 or spellId == 217549) and destGUID == myID then -- Rain of Fire / Fel Fire / Fel Flames
				local msg = "|T".. GetSpellTexture(spellId) ..texString.. L.runOut:format(spellName)
				print(printLit, msg)
				RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 3)
				PlaySound("RaidWarning", "Master")
			end
		end
	end
end

function mod:SCENARIO_COMPLETED()
	if self.f.db.hideBossWarnings then return end
	local _,_,_,_,_,_,_,_,_,scenarioType = C_Scenario.GetInfo()
	if scenarioType == 4 then -- LE_SCENARIO_TYPE_LEGION_INVASION = 4
		flameFissureTime = 15
		f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- Boss killed, unregister
		stopBar(nil, true)
	end
end

function mod:ZONE_CHANGED_NEW_AREA()
	if self.f.db.hideInRaid then
		local _, _, _, _, _, _, _, instanceId = GetInstanceInfo()
		if instanceId == 1228 or instanceId == 1205 or instanceId == 1448 then -- Highmaul, Blackrock Foundry, Hellfire Citadel
			self.f:Hide()
		elseif not self.f:IsShown() then
			self.f:Show()
		end
	end
end

function mod:CHAT_MSG_CURRENCY(msg)
	if msg:find("|Hcurrency:1226|h", nil, true) then -- Wish there was a cleaner way to detect gaining Nethershards
		local cName, amount = GetCurrencyInfo(1226) -- Nethershard
		if amount > 1900 then
			print(printLit, ("|T132775:15:15:0:0:64:64:4:60:4:60|t |cFFFF0000%d/2000|r"):format(amount))
		end
	end
end

