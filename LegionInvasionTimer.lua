
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

local OnEnter
do
	local id = 11201 -- Defender of Azeroth: Legion Invasions
	local GameTooltip = GameTooltip
	local SHORTDATE = SHORTDATE -- "%2$d/%1$02d/%3$02d" month / day / year for English EU clients O.o
	OnEnter = function(f)
		GameTooltip:SetOwner(f, "ANCHOR_NONE")
		GameTooltip:SetPoint("BOTTOM", f, "TOP")
		local _, name, _, _, month, day, year, description, _, _, _, _, wasEarnedByMe = GetAchievementInfo(id)
		if wasEarnedByMe then
			GameTooltip:AddDoubleLine(name, SHORTDATE:format(day, month, year), nil, nil, nil, .5, .5, .5)
		else
			GameTooltip:AddLine(name, nil, nil, nil, .5, .5, .5)
		end
		GameTooltip:AddLine(description, 1, 1, 1, true)
		for i = 1, GetAchievementNumCriteria(id) do
			local criteriaString, criteriaType, completed = GetAchievementCriteriaInfo(id, i)
			if completed == false then
				criteriaString = "|CFF808080 - " .. criteriaString .. "|r"
			else
				criteriaString = "|CFF00FF00 - " .. criteriaString .. "|r"
			end
			GameTooltip:AddLine(criteriaString)
		end
		GameTooltip:AddLine(" ")

		local cName, amount = GetCurrencyInfo(1226) -- Nethershard
		-- Icon 132775 = Interface\\Icons\\INV_DataCrystal01
		-- Color text red if > 1900
		GameTooltip:AddDoubleLine(cName, ("|T132775:15:15:0:0:64:64:4:60:4:60|t %d/2000"):format(amount), 1, 1, 1, 1, amount > 1900 and 0 or 1, amount > 1900 and 0 or 1)
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

local startBar
do
	local L = GetLocale()
	local pattern = "[^:]+: ?(.+)"
	if L == "zhCN" or L == "zhTW" then
		pattern = "[^：]+： ?(.+)" -- Different colon on Chinese clients
	end
	startBar = function(eventName, timeLeft, rewardQuestID, icon, pause, first)
		local text = eventName:match(pattern) or eventName -- Strip out the "Legion Invasion: " part and leave the zone name behind.
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
		if first then
			bar:Set("LegionInvasionTimer:first", true)
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
		if pause then -- Searching bars
			bar:Start()
			bar:Pause()
			bar:SetTimeVisibility(false)
		elseif rewardQuestID > 0 then -- Zone bars
			bar:Start(7200) -- 2hrs = 60*2 = 120min = 120*60 = 7,200sec
		else
			bar:Start() -- Boss bars
		end
		rearrangeBars()
	end
	mod.startBar = startBar
end

local hasPausedBars, justLoggedIn = false, true
local function findTimer()
	-- 3 Legion Invasion: Northern Barrens 0 43282
	-- 4 Legion Invasion: Westfall 0 43245
	-- 5 Legion Invasion: Tanaris 0 43244
	-- 6 Legion Invasion: Dun Morogh 0 43284
	-- 7 Legion Invasion: Hillsbrad 0 43285
	-- 8 Legion Invasion: Azshara 0 43301

	local first = true
	for i = 3, 8 do
		local zone, timeLeftMinutes, rewardQuestID = GetInvasionInfo(i)
		if timeLeftMinutes and timeLeftMinutes > 1 and timeLeftMinutes < 121 then -- On some realms timeLeftMinutes can return massive values during the initialization of a new event
			startBar(zone, timeLeftMinutes * 60, rewardQuestID, 236292, nil, first) -- 236292 = Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
			first = false
			if hasPausedBars then
				hasPausedBars = false
				stopBar(L.searching)
				-- Sometimes Blizz doesn't reset the quest ID very quickly after a new event spawns, do another few checks to fix colors if so
				-- We do multiple checks to try and fix the (potential) issue as fast as possible
				-- This is cleaner than trying to implement some method of remembering what were saved to, unless 20 sec isn't long enough to compensate...
				Timer(5, findTimer)
				Timer(10, findTimer)
				Timer(20, findTimer)
				if not IsEncounterInProgress() and not justLoggedIn and timeLeftMinutes > 110 then -- Not fighting a boss, didn't just log in, has just spawned (safety)
					FlashClientIcon()
					print("|cFF33FF99LegionInvasionTimer|r:", L.invasionsAvailable)
					RaidNotice_AddMessage(RaidBossEmoteFrame, L.invasionsAvailable, mod.c)
					PlaySound("RaidWarning", "Master")
				end
			end
			justLoggedIn = false
		end
	end

	if first then
		if not hasPausedBars then
			hasPausedBars = true
			startBar(L.searching, 7200, 0, 132177, true) -- 132177 = Interface\\Icons\\Ability_Hunter_MasterMarksman
		end
		Timer(3, findTimer) -- Start hunting for the next event
	end
end

frame:SetScript("OnEvent", function(f)
	f:UnregisterEvent("PLAYER_LOGIN")

	local weekday, month, day, year = CalendarGetDate()
	if month ~= 8 or year ~= 2016 then
		f:SetScript("OnEvent", nil)
		return -- Good times come to an end
	end

	local L = GetLocale()
	if L == "itIT" or L == "koKR" then
		Timer(5, function() print("|cFF33FF99LegionInvasionTimer|r: I need to be translated into '"..L.."' see the GitHub page for more info.") end)
	end

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

	candy.RegisterCallback(name, "LibCandyBar_Stop", function(_, bar, dontScan)
		if bars[bar] then
			bars[bar] = nil
			if not dontScan and bar:Get("LegionInvasionTimer:first") then
				Timer(2, findTimer) -- Event over, start hunting for the next event
			end
			rearrangeBars()
		end
	end)

	findTimer()
	Timer(15, function() justLoggedIn = false end) -- We might log in during an event swap and never see the "new event" message, so use a timer here
	f:RegisterEvent("SCENARIO_COMPLETED")
	f:SetScript("OnEvent", function()
		local _,_,_,_,_,_,_,_,_,scenarioType = C_Scenario.GetInfo()
		if scenarioType == 4 then -- LE_SCENARIO_TYPE_LEGION_INVASION = 4
			Timer(4, findTimer) -- Update bar color
		end
	end)
end)

