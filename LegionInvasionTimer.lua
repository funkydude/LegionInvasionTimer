
local name, mod = ...
local L = mod.L
local candy = LibStub("LibCandyBar-3.0")
local media = LibStub("LibSharedMedia-3.0")
local Timer = C_Timer.After
mod.c = {r=1,g=1,b=1}
local bars = {}

local frame = CreateFrame("Frame", name, UIParent)
mod.f = frame
frame:SetPoint("CENTER", UIParent, "CENTER")
frame:SetWidth(180)
frame:SetHeight(15)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetClampedToScreen(true)
frame:Hide()
frame:RegisterEvent("PLAYER_LOGIN")
frame.bars = bars

local OnEnter, ShowTip
do
	local id = 11544 -- Defender of the Broken Isles
	local GameTooltip = GameTooltip
	local FormatShortDate = FormatShortDate
	ShowTip = function(tip)
		local _, name, _, _, month, day, year, description, _, _, _, _, wasEarnedByMe = GetAchievementInfo(id)
		if wasEarnedByMe then
			tip:AddDoubleLine(name, FormatShortDate(day, month, year), nil, nil, nil, .5, .5, .5)
		else
			tip:AddLine(name, nil, nil, nil, .5, .5, .5)
		end
		tip:AddLine(description, 1, 1, 1, true)
		for i = 1, GetAchievementNumCriteria(id) do
			local criteriaString, criteriaType, completed = GetAchievementCriteriaInfo(id, i)
			if completed == false then
				criteriaString = "|CFF808080 - " .. criteriaString .. "|r"
			else
				criteriaString = "|CFF00FF00 - " .. criteriaString .. "|r"
			end
			tip:AddLine(criteriaString)
		end
		tip:AddLine(" ")

		local nName, nAmount, nIcon = GetCurrencyInfo(1226) -- Nethershard
		local sName, sAmount, sIcon = GetCurrencyInfo(1342) -- Legionfall War Supplies
		tip:AddDoubleLine(nName, ("|T%s:15:15:0:0:64:64:4:60:4:60|t %d"):format(nIcon, nAmount), 1, 1, 1, 1, 1, 1)
		tip:AddDoubleLine(sName, ("|T%s:15:15:0:0:64:64:4:60:4:60|t %d"):format(sIcon, sAmount), 1, 1, 1, 1, 1, 1)
		tip:AddLine(" ")

		-- 18hrs * 60min = 1,080min = +30min = 1,110min = *60sec = 66,600sec
		local elapsed = time() - legionTimerDB.prev
		while elapsed > 66600 do
			elapsed = elapsed - 66600
		end
		local t = 66600-elapsed
		t = t+time()
		tip:AddLine(L.nextInvasions)
		tip:AddDoubleLine(date("%A %H:%M", t), date("%A %H:%M", t+66600), 1, 1, 1, 1, 1, 1)
		for i = 1, 3 do
			t = t + 66600 + 66600
			tip:AddDoubleLine(date("%A %H:%M", t), date("%A %H:%M", t+66600), 1, 1, 1, 1, 1, 1)
		end
	end
	OnEnter = function(f)
		GameTooltip:SetOwner(f, "ANCHOR_NONE")
		GameTooltip:SetPoint("BOTTOM", f, "TOP")
		ShowTip(GameTooltip)
		GameTooltip:Show()
	end
end

local rearrangeBars
do
	-- Ripped from BigWigs bar sorter
	local function barSorter(a, b)
		return a.remaining < b.remaining and true or false
	end
	local tmp = {}
	rearrangeBars = function()
		wipe(tmp)
		for bar in next, bars do
			tmp[#tmp + 1] = bar
		end
		table.sort(tmp, barSorter)
		local lastBar = nil
		local up = legionTimerDB.growUp
		for i, bar in next, tmp do
			local spacing = legionTimerDB.spacing
			bar:ClearAllPoints()
			if up then
				if lastBar then -- Growing from a bar
					bar:SetPoint("BOTTOMLEFT", lastBar, "TOPLEFT", 0, spacing)
					bar:SetPoint("BOTTOMRIGHT", lastBar, "TOPRIGHT", 0, spacing)
				else -- Growing from the anchor
					bar:SetPoint("BOTTOM", frame, "TOP")
				end
				lastBar = bar
			else
				if lastBar then -- Growing from a bar
					bar:SetPoint("TOPLEFT", lastBar, "BOTTOMLEFT", 0, -spacing)
					bar:SetPoint("TOPRIGHT", lastBar, "BOTTOMRIGHT", 0, -spacing)
				else -- Growing from the anchor
					bar:SetPoint("TOP", frame, "BOTTOM")
				end
				lastBar = bar
			end
		end
	end
	frame.rearrangeBars = rearrangeBars
end

local function stopBar(text, stopAll)
	for bar in next, bars do
		if stopAll then
			bar:Stop(true)
		elseif bar:GetLabel() == text then
			bar:Stop(true)
		end
	end
end
mod.stopBar = stopBar

local startBar, startBroker
local hiddenBars = false
do
	startBar = function(text, timeLeft, rewardQuestID, icon, paused)
		stopBar(text)
		local bar = candy:New(media:Fetch("statusbar", legionTimerDB.barTexture), legionTimerDB.width, legionTimerDB.height)
		bars[bar] = true

		bar:SetScript("OnEnter", OnEnter)
		bar:SetScript("OnLeave", GameTooltip_Hide)
		bar:SetParent(frame)
		bar:SetLabel(text)
		bar.candyBarLabel:SetJustifyH(legionTimerDB.alignZone)
		bar.candyBarDuration:SetJustifyH(legionTimerDB.alignTime)
		bar:SetDuration(timeLeft)
		if rewardQuestID > 0 then
			if IsQuestFlaggedCompleted(rewardQuestID) then
				bar:SetColor(unpack(legionTimerDB.colorComplete))
				bar:Set("LegionInvasionTimer:complete", 1)
			else
				bar:SetColor(unpack(legionTimerDB.colorIncomplete))
				bar:Set("LegionInvasionTimer:complete", 0)
			end
		end
		bar.candyBarBackground:SetVertexColor(unpack(legionTimerDB.colorBarBackground))
		bar:SetTextColor(unpack(legionTimerDB.colorText))
		if legionTimerDB.icon then
			bar:SetIcon(icon)
		end
		bar:SetTimeVisibility(legionTimerDB.timeText)
		bar:SetFill(legionTimerDB.fill)
		local flags = nil
		if legionTimerDB.monochrome and legionTimerDB.outline ~= "NONE" then
			flags = "MONOCHROME," .. legionTimerDB.outline
		elseif legionTimerDB.monochrome then
			flags = "MONOCHROME"
		elseif legionTimerDB.outline ~= "NONE" then
			flags = legionTimerDB.outline
		end
		bar.candyBarLabel:SetFont(media:Fetch("font", legionTimerDB.font), legionTimerDB.fontSize, flags)
		bar.candyBarDuration:SetFont(media:Fetch("font", legionTimerDB.font), legionTimerDB.fontSize, flags)
		if paused then -- Searching bars
			bar:Start()
			bar:Pause()
			bar:SetTimeVisibility(false)
		elseif rewardQuestID > 0 then -- Invasion duration bars
			bar:Start(21600) -- 6hrs = 60*6 = 360min = 360*60 = 21,600sec
		else -- Next invasion bars
			bar:Start()
		end
		rearrangeBars()
		if hiddenBars then
			bar:Hide()
		end
	end
	mod.startBar = startBar
end

do
	local obj
	local prevTime, label, repeater = 0, "", false
	local function update()
		prevTime = prevTime - 60
		obj.text = label..": ".. SecondsToTime(prevTime, true)
	end
	startBroker = function(text, timeLeft, icon)
		if not obj then
			local ls = LibStub("LibDataBroker-1.1", true)
			if ls then
				obj = ls:NewDataObject("LegionInvasionTimer", {type = "data source", icon = icon, text = text..": ".. SecondsToTime(timeLeft, true)})
				function obj.OnTooltipShow(tooltip)
					if not tooltip or not tooltip.AddLine or not tooltip.AddDoubleLine then return end
					ShowTip(tooltip)
				end
			end
		end
		if obj then
			obj.icon = icon
			obj.text = text..": ".. SecondsToTime(timeLeft, true)
			prevTime = timeLeft
			label = text
			if repeater then repeater:Cancel() end
			repeater = C_Timer.NewTicker(60, update)
		end
	end
end

local GetAreaPOITimeLeft = C_WorldMap.GetAreaPOITimeLeft
local justLoggedIn, isWaiting = true, false
local zonePOIIds = {5177, 5178, 5210, 5175}
local zoneNames = {1024, 1017, 1018, 1015}
local questIds = {45840, 45839, 45812, 45838}
-- 5177 Highmountain 1024 45840
-- 5178 Stormheim 1017 45839
-- 5210 Val'Sharah 1018 45812
-- 5175 Azsuna 1015 45838
local function FindInvasion()
	local mode = legionTimerDB.mode
	local found = false

	for i = 1, #zonePOIIds do
		local timeLeftMinutes = GetAreaPOITimeLeft(zonePOIIds[i])
		if timeLeftMinutes and timeLeftMinutes > 0 and timeLeftMinutes < 361 then -- On some realms timeLeftMinutes can return massive values during the initialization of a new event
			stopBar(NEXT)
			stopBar(L.waiting)
			local t = timeLeftMinutes * 60
			if mode == 1 then
				startBar(GetMapNameByID(zoneNames[i]), t, questIds[i], 236292) -- 236292 = Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
			else
				startBroker(GetMapNameByID(zoneNames[i]), t, 236292) -- 236292 = Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
			end
			Timer(t+60, FindInvasion)
			found = true
			if not IsEncounterInProgress() and not justLoggedIn and timeLeftMinutes > 110 then -- Not fighting a boss, didn't just log in, has just spawned (safety)
				FlashClientIcon()
				local text = "|T236292:15:15:0:0:64:64:4:60:4:60|t ".. ZONE_UNDER_ATTACK:format(GetMapNameByID(zoneNames[i]))
				print("|cFF33FF99LegionInvasionTimer|r:", text)
				RaidNotice_AddMessage(RaidBossEmoteFrame, text, mod.c)
				PlaySoundFile("Sound\\Interface\\RaidWarning.ogg", "Master")
			end
			justLoggedIn = false

			local t = time()
			local elapsed = 360-timeLeftMinutes
			t = t - (elapsed * 60)
			legionTimerDB.prev = t
		end
	end

	if not found then
		if legionTimerDB.prev then
			-- 18hrs * 60min = 1,080min = +30min = 1,110min = *60sec = 66,600sec
			local elapsed = time() - legionTimerDB.prev
			while elapsed > 66600 do
				elapsed = elapsed - 66600
			end
			local t = 66600-elapsed

			if t > 45000 then -- 12hrs * 60min = 720min = +30min = 750min = *60sec = 45,000sec
				-- If it's longer than 45k then an invasion is currently active.
				-- Loop every second until GetAreaPOITimeLeft responds with valid results.
				Timer(1, FindInvasion)
				if not isWaiting then
					isWaiting = true
					if mode == 1 then
						startBar(L.waiting, t, 0, 132177, true) -- 132177 = Interface\\Icons\\Ability_Hunter_MasterMarksman
					else
						startBroker(L.waiting, 0, 132177) -- 132177 = Interface\\Icons\\Ability_Hunter_MasterMarksman
					end
				end
				return
			end

			if mode == 1 then
				startBar(NEXT, t, 0, 132177) -- 132177 = Interface\\Icons\\Ability_Hunter_MasterMarksman
			else
				startBroker(NEXT, t, 132177) -- 132177 = Interface\\Icons\\Ability_Hunter_MasterMarksman
			end

			Timer(t + 5, FindInvasion)
		else
			Timer(60, FindInvasion)
		end
	end

	if isWaiting then
		isWaiting = false
	end
end

local function CheckIfInRaid()
	if legionTimerDB.hideInRaid then
		local _, _, _, _, _, _, _, instanceId = GetInstanceInfo()
		if instanceId == 1676 or instanceId == 1530 or instanceId == 1648 or instanceId == 1520 then -- Tomb of Sargeras, Nighthold, Trial of Valor, Emerald Nightmare
			hiddenBars = true
			for bar in next, bars do
				if bar then
					bar:Hide()
				end
			end
		elseif hiddenBars then
			hiddenBars = false
			for bar in next, bars do
				if bar then
					bar:Show()
				end
			end
		end
	end
end

frame:SetScript("OnEvent", function(f)
	f:UnregisterEvent("PLAYER_LOGIN")

	if type(legionTimerDB) ~= "table" or not legionTimerDB.colorText then
		legionTimerDB = {
			fontSize = 10,
			barTexture = "Blizzard Raid Bar",
			outline = "NONE",
			font = media:GetDefault("font"),
			width = 200,
			height = 20,
			icon = true,
			timeText = true,
			spacing = 0,
			alignZone = "LEFT",
			alignTime = "RIGHT",
			colorText = {1,1,1,1},
			colorComplete = {0,1,0,1},
			colorIncomplete = {1,0,0,1},
			colorBarBackground = {0,0,0,0.75},
			mode = 1,
		}
	end
	if legionTimerDB.texture then -- Cleanup old texture DB entry
		if legionTimerDB.texture == "BantoBar" then
			legionTimerDB.barTexture = "Blizzard Raid Bar"
		else
			legionTimerDB.barTexture = legionTimerDB.texture
		end
		legionTimerDB.texture = nil
	end
	if not legionTimerDB.colorBarBackground then -- add new Bar Background Value to legionTimerDB
		legionTimerDB.colorBarBackground = {0,0,0,0.75}
	end
	if not legionTimerDB.mode then
		legionTimerDB.mode = 1
	end
	legionTimerDB.hideBossWarnings = nil

	f:Show()
	f:SetScript("OnDragStart", function(f) f:StartMoving() end)
	f:SetScript("OnDragStop", function(f) f:StopMovingOrSizing() end)
	SlashCmdList[name] = function() LoadAddOn("LegionInvasionTimer_Options") LibStub("AceConfigDialog-3.0"):Open(name) end
	SLASH_LegionInvasionTimer1 = "/lit"
	SLASH_LegionInvasionTimer2 = "/legioninvasiontimer"
	f:SetScript("OnMouseUp", function(f, btn)
		if btn == "RightButton" then
			SlashCmdList[name]()
		end
	end)
	f:SetScript("OnEnter", function(f)
		GameTooltip:SetOwner(f, "ANCHOR_NONE")
		GameTooltip:SetPoint("BOTTOM", f, "TOP")
		GameTooltip:AddLine(L.tooltipClick, 0.2, 1, 0.2, 1)
		GameTooltip:AddLine(L.tooltipClickOptions, 0.2, 1, 0.2, 1)
		GameTooltip:Show()
	end)
	f:SetScript("OnLeave", GameTooltip_Hide)
	local bg = f:CreateTexture(nil, "PARENT")
	bg:SetAllPoints(f)
	bg:SetColorTexture(0, 1, 0, 0.3)
	f.bg = bg
	local header = f:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	header:SetAllPoints(f)
	header:SetText(name)
	f.header = header
	f.db = legionTimerDB

	if legionTimerDB.lock then
		f:EnableMouse(false)
		f.bg:Hide()
		f.header:Hide()
	end

	candy.RegisterCallback(name, "LibCandyBar_Stop", function(_, bar)
		if bars[bar] then
			bars[bar] = nil
			rearrangeBars()
		end
	end)

	-- Force an update, needed for the very first login
	local function update()
		for i = 1, #zonePOIIds do
			GetAreaPOITimeLeft(zonePOIIds[i])
		end
	end
	Timer(1, FindInvasion)

	Timer(15, function()
		justLoggedIn = false
		if not legionTimerDB.prev then
			print("|cFF33FF99LegionInvasionTimer|r:", L.firstRunWarning)
		end
	end)

	CheckIfInRaid()
	f:SetScript("OnEvent", CheckIfInRaid)
	f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end)

