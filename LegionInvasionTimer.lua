
local name, mod = ...
local L = mod.L
local candy = LibStub("LibCandyBar-3.0")
local media = LibStub("LibSharedMedia-3.0")
local Timer = C_Timer.After
local bars = {}

local frame = CreateFrame("Frame", name, UIParent)
frame:SetPoint("CENTER", UIParent, "CENTER")
frame:SetWidth(180)
frame:SetHeight(15)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetClampedToScreen(true)
frame:Show()
frame:SetScript("OnDragStart", function(f) f:StartMoving() end)
frame:SetScript("OnDragStop", function(f)
	f:StopMovingOrSizing()
	local a, _, b, c, d = f:GetPoint()
	f.db.profile.position[1] = a
	f.db.profile.position[2] = b
	f.db.profile.position[3] = c
	f.db.profile.position[4] = d
end)
do
	local function openOpts()
		EnableAddOn("LegionInvasionTimer_Options") -- Make sure it wasn't left disabled for whatever reason
		LoadAddOn("LegionInvasionTimer_Options")
		LibStub("AceConfigDialog-3.0"):Open(name)
	end
	SlashCmdList[name] = openOpts
	SLASH_LegionInvasionTimer1 = "/lit"
	SLASH_LegionInvasionTimer2 = "/legioninvasiontimer"
	frame:SetScript("OnMouseUp", function(_, btn)
		if btn == "RightButton" then
			openOpts()
		end
	end)
	frame:RegisterEvent("PLAYER_LOGIN")
	frame.bars = bars
end

local OnEnter, ShowTip, HideTip
do
	local id = 11544 -- Defender of the Broken Isles
	local GameTooltip, WorldMapTooltip = GameTooltip, WorldMapTooltip
	local FormatShortDate = FormatShortDate
	ShowTip = function(tip)
		local _, name, _, _, month, day, year, description, _, _, _, _, wasEarnedByMe = GetAchievementInfo(id)
		if not wasEarnedByMe or not frame.db.profile.tooltipHideAchiev then
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
		end

		local splitLine = false
		if not frame.db.profile.tooltipHideNethershard then
			splitLine = true
			local nName, nAmount, nIcon = GetCurrencyInfo(1226) -- Nethershard
			tip:AddDoubleLine(nName, ("|T%d:15:15:0:0:64:64:4:60:4:60|t %d"):format(nIcon, nAmount), 1, 1, 1, 1, 1, 1)
		end
		if not frame.db.profile.tooltipHideWarSupplies then
			splitLine = true
			local sName, sAmount, sIcon = GetCurrencyInfo(1342) -- Legionfall War Supplies
			tip:AddDoubleLine(sName, ("|T%d:15:15:0:0:64:64:4:60:4:60|t %d"):format(sIcon, sAmount), 1, 1, 1, 1, 1, 1)
		end

		if splitLine then
			tip:AddLine(" ")
		end

		tip:AddLine(L.nextInvasions)
		if LegionInvasionTime then -- Have we seen our first invasion?
			-- 18hrs * 60min = 1,080min = +30min = 1,110min = *60sec = 66,600sec
			local elapsed = time() - LegionInvasionTime
			while elapsed > 66600 do
				elapsed = elapsed - 66600
			end
			local t = 66600-elapsed
			t = t+time()
			local upper, date = string.upper, date
			local check = date("%M", t)
			if check == "29" or check == "59" then
				t = t + 60 -- Round up to 00min/30min if we're at 29min/59min
			end
			if frame.db.profile.tooltip12hr then
				for i = 1, 4 do
					tip:AddDoubleLine(
						_G["WEEKDAY_"..upper(date("%A", t))].." "..date("%I:%M", t) .. _G["TIMEMANAGER_"..upper(date("%p", t))],
						_G["WEEKDAY_"..upper(date("%A", t+66600))].." "..date("%I:%M", t+66600) .. _G["TIMEMANAGER_"..upper(date("%p", t+66600))],
						1, 1, 1, 1, 1, 1
					)
					t = t + 66600 + 66600
				end
			else
				for i = 1, 4 do
					tip:AddDoubleLine(
						_G["WEEKDAY_"..upper(date("%A", t))].." "..date("%H:%M", t),
						_G["WEEKDAY_"..upper(date("%A", t+66600))].." "..date("%H:%M", t+66600),
						1, 1, 1, 1, 1, 1
					)
					t = t + 66600 + 66600
				end
			end
		else
			tip:AddLine(L.waiting, 1, 1, 1)
		end
	end
	HideTip = function()
		if frame.db.profile.mode == 3 then
			WorldMapTooltip:Hide()
		else
			GameTooltip:Hide()
		end
	end
	OnEnter = function(f)
		local tip = frame.db.profile.mode == 3 and WorldMapTooltip or GameTooltip
		tip:SetOwner(f, "ANCHOR_NONE")
		tip:SetPoint("BOTTOM", f, "TOP")
		ShowTip(tip)
		tip:Show()
	end
end

local RearrangeBars
do
	-- Ripped from BigWigs bar sorter
	local function barSorter(a, b)
		return a.remaining < b.remaining and true or false
	end
	local tmp = {}
	RearrangeBars = function()
		wipe(tmp)
		for bar in next, bars do
			tmp[#tmp + 1] = bar
		end
		table.sort(tmp, barSorter)
		local lastBar = nil
		local up = frame.db.profile.growUp
		for i, bar in next, tmp do
			local spacing = frame.db.profile.spacing
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
	frame.RearrangeBars = RearrangeBars
end

local function StopBar(text)
	for bar in next, bars do
		if bar:GetLabel() == text then
			bar:Stop()
		end
	end
end

local ChangeBarColor
do
	-- We use different quest ids here.
	-- The invasion is split into 2 quests. The quest to complete 4 world quests, and the quest to complete the scenario.
	-- These are the ids for the scenario, because we don't want to mark the bar green until that is done.
	-- We use the other ids when creating the bar/login/reload ui/etc because these ids don't seem to reset, they stay marked as completed.
	-- So if we did use these ids for bar creation, they would always show up as green.
	local quests = {
		[46182] = true, -- Highmountain
		[46110] = true, -- Stormheim
		[45856] = true, -- Val'Sharah
		[46199] = true, -- Azsuna
	}
	ChangeBarColor = function(id)
		if quests[id] then
			for bar in next, bars do
				bar:Set("LegionInvasionTimer:complete", 1)
				bar:SetColor(unpack(frame.db.profile.colorComplete))
			end
		end
	end
end

local StartBar
local hiddenBars = false
do
	StartBar = function(text, timeLeft, rewardQuestID, icon, paused)
		StopBar(text)
		local bar = candy:New(media:Fetch("statusbar", frame.db.profile.barTexture), frame.db.profile.width, frame.db.profile.height)
		bars[bar] = true

		bar:SetScript("OnEnter", OnEnter)
		bar:SetScript("OnLeave", HideTip)
		bar:SetParent(frame)
		bar:SetLabel(text)
		bar.candyBarLabel:SetJustifyH(frame.db.profile.alignText)
		bar.candyBarDuration:SetJustifyH(frame.db.profile.alignTime)
		bar:SetDuration(timeLeft)
		if rewardQuestID > 0 then
			if IsQuestFlaggedCompleted(rewardQuestID) then
				bar:SetColor(unpack(frame.db.profile.colorComplete))
				bar:Set("LegionInvasionTimer:complete", 1)
			else
				bar:SetColor(unpack(frame.db.profile.colorIncomplete))
				bar:Set("LegionInvasionTimer:complete", 0)
			end
		else
			bar:SetColor(unpack(frame.db.profile.colorNext))
		end
		bar.candyBarBackground:SetVertexColor(unpack(frame.db.profile.colorBarBackground))
		bar:SetTextColor(unpack(frame.db.profile.colorText))
		if frame.db.profile.icon then
			bar:SetIcon(icon)
			bar:SetIconPosition(frame.db.profile.alignIcon)
		end
		bar:SetTimeVisibility(frame.db.profile.timeText)
		bar:SetFill(frame.db.profile.fill)
		local flags = nil
		if frame.db.profile.monochrome and frame.db.profile.outline ~= "NONE" then
			flags = "MONOCHROME," .. frame.db.profile.outline
		elseif frame.db.profile.monochrome then
			flags = "MONOCHROME"
		elseif frame.db.profile.outline ~= "NONE" then
			flags = frame.db.profile.outline
		end
		bar.candyBarLabel:SetFont(media:Fetch("font", frame.db.profile.font), frame.db.profile.fontSize, flags)
		bar.candyBarDuration:SetFont(media:Fetch("font", frame.db.profile.font), frame.db.profile.fontSize, flags)
		if paused then -- Searching bars
			bar:Start()
			bar:Pause()
			bar:SetTimeVisibility(false)
		elseif rewardQuestID > 0 then -- Invasion duration bars
			bar:Start(21600) -- 6hrs = 60*6 = 360min = 360*60 = 21,600sec
		else -- Next invasion bars
			bar:Start()
		end
		RearrangeBars()
		if hiddenBars then
			bar:Hide()
		end
	end
end

local StartBroker
do
	local obj
	local prevTime, label, repeater = 0, "", false
	local function update()
		prevTime = prevTime - 60
		obj.text = label..": ".. SecondsToTime(prevTime, true)
	end
	StartBroker = function(text, timeLeft, icon)
		if not obj then
			obj = LibStub("LibDataBroker-1.1"):NewDataObject("LegionInvasionTimer", {
				type = "data source",
				icon = icon,
				text = text..": ".. SecondsToTime(timeLeft, true),
				OnTooltipShow = function(tooltip)
					if not tooltip or not tooltip.AddLine or not tooltip.AddDoubleLine then return end
					ShowTip(tooltip)
				end
			})
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

local FindInvasion
local justLoggedIn = true
do
	local GetAreaPOITimeLeft = C_AreaPoiInfo.GetAreaPOITimeLeft
	local isWaiting = false
	local zonePOIIds = {
		5177, -- Highmountain
		5178, -- Stormheim
		5210, -- Val'Sharah
		5175, -- Azsuna
	}
	local zoneNames = {
		C_Map.GetMapInfo(650).name, -- Highmountain
		C_Map.GetMapInfo(634).name, -- Stormheim
		C_Map.GetMapInfo(641).name, -- Val'Sharah
		C_Map.GetMapInfo(630).name, -- Azsuna
	}
	local questIds = {
		45840, -- Highmountain
		45839, -- Stormheim
		45812, -- Val'Sharah
		45838, -- Azsuna
	}
	FindInvasion = function()
		local mode = frame.db.profile.mode
		local found = false

		for i = 1, #zonePOIIds do
			local timeLeftMinutes = GetAreaPOITimeLeft(zonePOIIds[i])
			if timeLeftMinutes and timeLeftMinutes > 0 and timeLeftMinutes < 361 then -- On some realms timeLeftMinutes can return massive values during the initialization of a new event
				StopBar(NEXT)
				StopBar(L.waiting)
				local t = timeLeftMinutes * 60
				if mode == 2 then
					StartBroker(zoneNames[i], t, 236292) -- 236292 = Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
				else
					StartBar(zoneNames[i], t, questIds[i], 236292) -- 236292 = Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
					frame:RegisterEvent("QUEST_TURNED_IN")
				end
				Timer(t+60, FindInvasion)
				found = true
				if not IsEncounterInProgress() and not justLoggedIn and timeLeftMinutes > 350 then -- Not fighting a boss, didn't just log in, has just spawned (safety)
					FlashClientIcon()
					local text = "|T236292:15:15:0:0:64:64:4:60:4:60|t ".. ZONE_UNDER_ATTACK:format(zoneNames[i])
					print("|cFF33FF99LegionInvasionTimer|r:", text)
					RaidNotice_AddMessage(RaidBossEmoteFrame, text, {r=1, g=1, b=1})
					PlaySound(8959, "Master", false) -- SOUNDKIT.RAID_WARNING
				end
				justLoggedIn = false

				local t = time()
				local elapsed = 360-timeLeftMinutes
				t = t - (elapsed * 60)
				LegionInvasionTime = t
			end
		end

		if not found then
			if LegionInvasionTime then
				-- 18hrs * 60min = 1,080min = +30min = 1,110min = *60sec = 66,600sec
				local elapsed = time() - LegionInvasionTime
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
						if mode == 2 then
							StartBroker(L.waiting, 0, 132177) -- 132177 = Interface\\Icons\\Ability_Hunter_MasterMarksman
						else
							StartBar(L.waiting, t, 0, 132177, true) -- 132177 = Interface\\Icons\\Ability_Hunter_MasterMarksman
						end
					end
					return
				end

				if mode == 2 then
					StartBroker(NEXT, t, 132177) -- 132177 = Interface\\Icons\\Ability_Hunter_MasterMarksman
				else
					StartBar(NEXT, t, 0, 132177) -- 132177 = Interface\\Icons\\Ability_Hunter_MasterMarksman
				end

				Timer(t + 5, FindInvasion)
			else
				Timer(60, FindInvasion)
				if not isWaiting then
					isWaiting = true
					if mode == 2 then
						StartBroker(L.waiting, 0, 132177) -- 132177 = Interface\\Icons\\Ability_Hunter_MasterMarksman
					else
						StartBar(L.waiting, 1000, 0, 132177, true) -- 132177 = Interface\\Icons\\Ability_Hunter_MasterMarksman
					end
				end
			end
		end

		if isWaiting then
			isWaiting = false
		end
	end
end

local function CheckIfInRaid()
	if frame.db.profile.hideInRaid then
		local _, iType = GetInstanceInfo()
		if iType == "raid" then
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

	if type(legionTimerDB) == "table" and legionTimerDB.prev then
		LegionInvasionTime = legionTimerDB.prev
	end
	-- saved variables database setup
	local defaults = {
		profile = {
			lock = false,
			position = {"CENTER", "CENTER", 0, 0},
			fontSize = 10,
			barTexture = "Blizzard Raid Bar",
			outline = "NONE",
			monochrome = false,
			font = media:GetDefault("font"),
			width = 200,
			height = 20,
			icon = true,
			timeText = true,
			fill = false,
			growUp = false,
			spacing = 0,
			alignText = "LEFT",
			alignTime = "RIGHT",
			alignIcon = "LEFT",
			colorText = {1,1,1,1},
			colorComplete = {0,1,0,1},
			colorIncomplete = {1,0,0,1},
			colorNext = {0.25,0.33,0.68,1},
			colorBarBackground = {0,0,0,0.75},
			tooltip12hr = false,
			tooltipHideAchiev = false,
			tooltipHideNethershard = false,
			tooltipHideWarSupplies = false,
			hideInRaid = false,
			mode = 1,
		},
	}
	f.db = LibStub("AceDB-3.0"):New("LegionInvasionTimerDB", defaults, true)

	f:ClearAllPoints()
	f:SetPoint(f.db.profile.position[1], UIParent, f.db.profile.position[2], f.db.profile.position[3], f.db.profile.position[4])

	local bg = f:CreateTexture(nil, "PARENT")
	bg:SetAllPoints(f)
	bg:SetColorTexture(0, 1, 0, 0.3)
	f.bg = bg
	local header = f:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	header:SetAllPoints(f)
	header:SetText(name)
	f.header = header

	if f.db.profile.lock then
		f:EnableMouse(false)
		f:SetMovable(false)
		f.bg:Hide()
		f.header:Hide()
	end

	if f.db.profile.mode == 3 then
		f:SetParent(WorldMapFrame)
		f:SetFrameStrata("FULLSCREEN")
		f:SetFrameLevel(10)
	end

	candy.RegisterCallback(name, "LibCandyBar_Stop", function(_, bar)
		if bars[bar] then
			bars[bar] = nil
			RearrangeBars()
		end
	end)

	FindInvasion()

	Timer(15, function()
		justLoggedIn = false
		if not LegionInvasionTime then
			print("|cFF33FF99LegionInvasionTimer|r:", L.firstRunWarning)
		end
	end)

	CheckIfInRaid()
	f:SetScript("OnEvent", function(_, event, id)
		if event == "QUEST_TURNED_IN" then
			ChangeBarColor(id)
		else
			CheckIfInRaid()
		end
	end)
	f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end)

