
local f = CreateFrame("Frame")
local name, mod = ...
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

	for i = 1, 10 do
		local _,_, rewardQuestIDInv = GetInvasionInfo(i)
		if rewardQuestID == rewardQuestIDInv and currentStage == 4 then
			f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- Boss is coming up, register
		end
	end
end

function mod:COMBAT_LOG_EVENT_UNFILTERED(_, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, _, extraSpellId, amount)
	if event == "SPELL_CAST_START" then
		if spellId == 219112 then -- Eye of Darkness 45s
			print("LegionInvasionTimer", spellName, "RUN TO BOSS")
		elseif spellId == 219960 then -- Breath of Shadows 32s
			print("LegionInvasionTimer", spellName, "FRONTAL CONE")
		elseif spellId == 219957 then -- Mark of Baldrazar 46s
			print("LegionInvasionTimer", spellName, "INCOMING")
		end
	elseif event == "SPELL_AURA_APPLIED" then
		if spellId == 219176 then -- Secrete Shadows 31-41s
			print("LegionInvasionTimer", spellName, destName, "TANK SWAP") -- 10 sec debuff on tank
		elseif spellId == 219958 and destGUID == UnitGUID("player") then -- Mark of Baldrazar
			print("LegionInvasionTimer", spellName, "ON YOU AVOID TAKING DAMAGE") -- 20 sec debuff, explosion on damage taken
		end
	elseif event == "SPELL_AURA_REMOVED" then
		if spellId == 219112 then -- Eye of Darkness
			print("LegionInvasionTimer", spellName, "FINISHED") -- 10 sec debuff on tank
		end
	end
end

function mod:SCENARIO_COMPLETED()
	local _,_,_,_,_,_,_,_,_,scenarioType = C_Scenario.GetInfo()
	if scenarioType == 4 then -- LE_SCENARIO_TYPE_LEGION_INVASION = 4
		f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- Boss killed, unregister
	end
end


