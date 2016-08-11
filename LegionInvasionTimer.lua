
local name = ...
local candy = LibStub("LibCandyBar-3.0")
local media = LibStub("LibSharedMedia-3.0")
local Timer = C_Timer.After

local frame = CreateFrame("Frame", name, UIParent)
frame:SetPoint("CENTER", UIParent, "CENTER")
frame:SetWidth(180)
frame:SetHeight(15)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetClampedToScreen(true)
frame:Hide()
frame:RegisterEvent("PLAYER_LOGIN")

local aboutToStopBar = false
local function startBar(zone, timeLeft, rewardQuestID, first)
	local bar
	if first then
		frame.header:SetText(name) -- We may have changed the header after the event ended
		if frame.bar1 then aboutToStopBar = true frame.bar1:Stop() aboutToStopBar = false end
		frame.bar1 = candy:New(media:Fetch("statusbar", legionTimerDB.texture), legionTimerDB.width, legionTimerDB.height)
		bar = frame.bar1
		if legionTimerDB.growUp then
			bar:SetPoint("BOTTOM", name, "TOP")
		else
			bar:SetPoint("TOP", name, "BOTTOM")
		end
	else
		if frame.bar2 then frame.bar2:Stop() end
		frame.bar2 = candy:New(media:Fetch("statusbar", legionTimerDB.texture), legionTimerDB.width, legionTimerDB.height)
		bar = frame.bar2
		if legionTimerDB.growUp then
			frame.bar2:SetPoint("BOTTOMLEFT", frame.bar1, "TOPLEFT", 0, legionTimerDB.spacing)
			frame.bar2:SetPoint("BOTTOMRIGHT", frame.bar1, "TOPRIGHT", 0, legionTimerDB.spacing)
		else
			frame.bar2:SetPoint("TOPLEFT", frame.bar1, "BOTTOMLEFT", 0, -legionTimerDB.spacing)
			frame.bar2:SetPoint("TOPRIGHT", frame.bar1, "BOTTOMRIGHT", 0, -legionTimerDB.spacing)
		end
	end

	bar:SetLabel(zone:match("[^%:]+:(.+)"))
	bar.candyBarLabel:SetJustifyH(legionTimerDB.alignZone)
	bar.candyBarDuration:SetJustifyH(legionTimerDB.alignTime)
	bar:SetDuration(timeLeft)
	if IsQuestFlaggedCompleted(rewardQuestID) then
		bar:SetColor(unpack(legionTimerDB.colorComplete))
		bar:Set("LegionInvasionTimer:complete", true)
	else
		bar:SetColor(unpack(legionTimerDB.colorIncomplete))
		bar:Set("LegionInvasionTimer:complete", false)
	end
	bar:SetTextColor(unpack(legionTimerDB.colorText))
	if legionTimerDB.icon then
		bar:SetIcon(236292) -- Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
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
	bar:Start()
end

local count = 0
local function findTimer()
	local first = true
	for i = 1, 20 do
		local zone, timeLeftMinutes, rewardQuestID = GetInvasionInfo(i)
		if timeLeftMinutes and timeLeftMinutes > 0 then
			startBar(zone, timeLeftMinutes * 60, rewardQuestID, first)
			if not first then break end -- I'm assuming it's always 2 events
			first = false
		end
	end

	if first then
		-- XXX Turn this into paused bars
		count = count + 1
		frame.header:SetText("Searching  ".. (count == 1 and "-" or count == 2 and "\\" or count == 3 and "|" or "/"))
		if count == 4 then count = 0 end
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
			texture = "BantoBar",
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
		GameTooltip:AddLine("|cffeda55fClick|r to drag and move.", 0.2, 1, 0.2, 1)
		GameTooltip:AddLine("|cffeda55fRight-Click|r to open options.", 0.2, 1, 0.2, 1)
		GameTooltip:Show()
	end)
	f:SetScript("OnLeave", GameTooltip_Hide)
	local bg = f:CreateTexture(nil, "PARENT")
	bg:SetAllPoints(f)
	bg:SetColorTexture(0, 1, 0, 0.3)
	local header = f:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	header:SetAllPoints(f)
	header:SetText(name)
	f.header = header

	candy.RegisterCallback(name, "LibCandyBar_Stop", function(_, bar)
		if not aboutToStopBar and bar == frame.bar1 then
			Timer(20, findTimer) -- Event over, start hunting for the next event
		end
		if bar == frame.bar1 then
			frame.bar1 = nil
		elseif bar == frame.bar2 then
			frame.bar2 = nil
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

