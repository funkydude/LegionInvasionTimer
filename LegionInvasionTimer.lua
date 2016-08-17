
local name, mod = ...
local L = mod.L
local candy = LibStub("LibCandyBar-3.0")
local media = LibStub("LibSharedMedia-3.0")
local Timer = C_Timer.After
mod.c = {r=1,g=1,b=1}

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

local function startBar(text, timeLeft, rewardQuestID, icon, count, pause)
	local bar
	if count == 1 then
		if frame.bar1 then frame.bar1:Stop(true) end
		frame.bar1 = candy:New(media:Fetch("statusbar", legionTimerDB.barTexture), legionTimerDB.width, legionTimerDB.height)
		bar = frame.bar1
		if legionTimerDB.growUp then
			bar:SetPoint("BOTTOM", name, "TOP")
		else
			bar:SetPoint("TOP", name, "BOTTOM")
		end
	elseif count == 2 then
		if frame.bar2 then frame.bar2:Stop() end
		frame.bar2 = candy:New(media:Fetch("statusbar", legionTimerDB.barTexture), legionTimerDB.width, legionTimerDB.height)
		bar = frame.bar2
		if legionTimerDB.growUp then
			frame.bar2:SetPoint("BOTTOMLEFT", frame.bar1, "TOPLEFT", 0, legionTimerDB.spacing)
			frame.bar2:SetPoint("BOTTOMRIGHT", frame.bar1, "TOPRIGHT", 0, legionTimerDB.spacing)
		else
			frame.bar2:SetPoint("TOPLEFT", frame.bar1, "BOTTOMLEFT", 0, -legionTimerDB.spacing)
			frame.bar2:SetPoint("TOPRIGHT", frame.bar1, "BOTTOMRIGHT", 0, -legionTimerDB.spacing)
		end
	else
		if frame.bar3 then frame.bar3:Stop() end
		frame.bar3 = candy:New(media:Fetch("statusbar", legionTimerDB.barTexture), legionTimerDB.width, legionTimerDB.height)
		bar = frame.bar3
		if legionTimerDB.growUp then
			frame.bar3:SetPoint("BOTTOMLEFT", frame.bar2, "TOPLEFT", 0, legionTimerDB.spacing)
			frame.bar3:SetPoint("BOTTOMRIGHT", frame.bar2, "TOPRIGHT", 0, legionTimerDB.spacing)
		else
			frame.bar3:SetPoint("TOPLEFT", frame.bar2, "BOTTOMLEFT", 0, -legionTimerDB.spacing)
			frame.bar3:SetPoint("TOPRIGHT", frame.bar2, "BOTTOMRIGHT", 0, -legionTimerDB.spacing)
		end
	end

	bar:SetLabel(text:match("[^%:]+:(.+)") or text)
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
	local count = 1
	for i = 3, 8 do
		local zone, timeLeftMinutes, rewardQuestID = GetInvasionInfo(i)
		if timeLeftMinutes and timeLeftMinutes > 1 and timeLeftMinutes < 121 then -- On some realms timeLeftMinutes can return massive values during the initialization of a new event
			startBar(zone, timeLeftMinutes * 60, rewardQuestID, 236292, count) -- 236292 = Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
			if count == 3 then break end -- 3 events
			count = count + 1
			if hasPausedBars and not justLoggedIn and timeLeftMinutes > 110 then
				hasPausedBars = false
				Timer(30, findTimer) -- Sometimes Blizz doesn't reset the quest ID very quickly, do another check to fix colors if so
				FlashClientIcon()
				print("|cFF33FF99LegionInvasionTimer|r:", L.invasionsAvailable)
				RaidNotice_AddMessage(RaidBossEmoteFrame, L.invasionsAvailable, mod.c)
				PlaySound("RaidWarning", "Master")
			end
			justLoggedIn = false
		end
	end

	if count == 1 then
		if not hasPausedBars then
			hasPausedBars = true
			startBar(L.searching, 7200, 0, 132177, count, true) -- 132177 = Interface\\Icons\\Ability_Hunter_MasterMarksman
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
	f.startBar = startBar
	f.db = legionTimerDB

	if legionTimerDB.lock then
		f:EnableMouse(false)
		f.bg:Hide()
		f.header:Hide()
	end

	candy.RegisterCallback(name, "LibCandyBar_Stop", function(_, bar, dontScan)
		if not dontScan and bar == frame.bar1 and bar:Get("LegionInvasionTimer:complete") then
			Timer(2, findTimer) -- Event over, start hunting for the next event
		end
		if bar == frame.bar1 then
			frame.bar1 = nil
		elseif bar == frame.bar2 then
			frame.bar2 = nil
		elseif bar == frame.bar3 then
			frame.bar3 = nil
		end
	end)

	findTimer()
	f:RegisterEvent("SCENARIO_COMPLETED")
	f:SetScript("OnEvent", function()
		local _,_,_,_,_,_,_,_,_,scenarioType = C_Scenario.GetInfo()
		if scenarioType == 4 then -- LE_SCENARIO_TYPE_LEGION_INVASION = 4
			Timer(8, findTimer) -- Update bar color
		end
	end)
end)

