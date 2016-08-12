
local f = CreateFrame("Frame")
local name, mod = ...
local colorTbl = {r=1,g=1,b=1}
f:SetScript("OnEvent", function(frame, event, ...)
	mod[event](...)
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
end

function mod:SCENARIO_UPDATE()
	local _,_,_,_,_,_,_,_,_,rewardQuestID = C_Scenario.GetStepInfo()
	local _,currentStage = C_Scenario.GetInfo()

	for i = 2, 8 do
		local _,_, rewardQuestIDInv = GetInvasionInfo(i)
		if rewardQuestID == rewardQuestIDInv and currentStage == 4 then
			f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- Boss is coming up, register
		end
	end
end

do
	local texString = ":15:15:0:0:64:64:4:60:4:60|t "
	local text = {
		SPELL_CAST_START = {
			[219112] = "|T".. GetSpellTexture(219112) ..texString.. GetSpellInfo(219112).. " (RUN TO BOSS)", -- Eye of Darkness 45s
			[219960] = "|T".. GetSpellTexture(219960) ..texString.. GetSpellInfo(219960).. " (FRONTAL CONE DAMAGE)", -- Breath of Shadows 32s
			[219957] = "|T".. GetSpellTexture(219957) ..texString.. GetSpellInfo(219957).. " (DEBUFF INCOMING)", -- Mark of Baldrazar 46s
			[217093] = "|T".. GetSpellTexture(217093) ..texString.. GetSpellInfo(217093).. " (AoE MC INCOMING)", -- Shadow Madness 48s
			[217098] = "|T".. GetSpellTexture(217098) ..texString.. GetSpellInfo(217098).. " (FRONTAL CONE DAMAGE)", -- Carrion Swarm 16s
			[217134] = "|T".. GetSpellTexture(217134) ..texString.. GetSpellInfo(217134).. " (FRONTAL CLEAVE)", -- Vampiric Cleave 33s
			[217040] = "|T".. GetSpellTexture(217040) ..texString.. GetSpellInfo(217040).. " (THREAT WIPE - SPAWN ADD)", -- Shadow Illusion 35s
			[216916] = "|T".. GetSpellTexture(216916) ..texString.. GetSpellInfo(216916).. " (FRONTAL CONE DAMAGE)", -- Waves of Dread 35s
		},
		SPELL_AURA_REMOVED = {
			[219112] = "|T".. GetSpellTexture(219112) ..texString.. GetSpellInfo(219112).. " (FINISHED)", -- Eye of Darkness 45s
		},
	}
	function mod:COMBAT_LOG_EVENT_UNFILTERED(_, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName)
		local msg = text[event] and text[event][spellId]
		if msg then
			print("|cFF33FF99LegionInvasionTimer|r:", msg)
			RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 3)
		end

		if event == "SPELL_AURA_APPLIED" then
			if spellId == 219176 then -- Secrete Shadows 31-41s
				 -- 10 sec debuff on tank
				local msg = "|T".. GetSpellTexture(spellId) ..texString.. spellName.. ": ".. gsub(destName, "%-.+", "*") .."(TANK SWAP)"
				print("|cFF33FF99LegionInvasionTimer|r:", msg)
				RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 3)
			elseif spellId == 219958 and destGUID == UnitGUID("player") then -- Mark of Baldrazar
				 -- 20 sec debuff, explosion on damage taken
				local msg = "|T".. GetSpellTexture(spellId) ..texString.. spellName .."(ON YOU, AVOID TAKING DAMAGE)"
				print("|cFF33FF99LegionInvasionTimer|r:", msg)
				RaidNotice_AddMessage(RaidBossEmoteFrame, msg, colorTbl, 3)
			end
		end
	end
end

function mod:SCENARIO_COMPLETED()
	local _,_,_,_,_,_,_,_,_,scenarioType = C_Scenario.GetInfo()
	if scenarioType == 4 then -- LE_SCENARIO_TYPE_LEGION_INVASION = 4
		f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- Boss killed, unregister
	end
end


