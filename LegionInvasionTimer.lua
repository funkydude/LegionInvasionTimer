
local weekday, month, day, year = CalendarGetDate()
if month ~= 8 or year ~= 2016 then
	return -- Good times come to an end
end

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
frame:SetScript("OnDragStart", function(f) f:StartMoving() end)
frame:SetScript("OnDragStop", function(f) f:StopMovingOrSizing() end)
frame:SetScript("OnMouseUp", function(f, btn)
	if btn == "RightButton" then
		LoadAddOn("LegionInvasionTimer_Options")
		LibStub("AceConfigDialog-3.0"):Open(name)
	end
end)
frame:SetScript("OnEnter", function(f)
	GameTooltip:SetOwner(f, "ANCHOR_NONE")
	GameTooltip:SetPoint("BOTTOM", f, "TOP")
	GameTooltip:AddLine("|cffeda55fClick|r to drag and move.", 0.2, 1, 0.2, 1)
	GameTooltip:AddLine("|cffeda55fRight-Click|r to open options.", 0.2, 1, 0.2, 1)
	GameTooltip:Show()
end)
frame:SetScript("OnLeave", GameTooltip_Hide)
frame:RegisterEvent("PLAYER_LOGIN")
local bg = frame:CreateTexture(nil, "PARENT")
bg:SetAllPoints(frame)
bg:SetColorTexture(0, 1, 0, 0.3)
local header = frame:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
header:SetAllPoints(frame)
header:SetText(name)

local aboutToStopBar = false
local function startBar(zone, timeLeft, rewardQuestID, first)
	local bar
	if first then
		header:SetText(name) -- We may have changed the header after the event ended
		if frame.bar1 then aboutToStopBar = true frame.bar1:Stop() aboutToStopBar = false end
		frame.bar1 = candy:New(media:Fetch("statusbar", frame.optionsTbl.texture), frame.optionsTbl.width, frame.optionsTbl.height)
		bar = frame.bar1
		bar:SetPoint("TOP", name, "BOTTOM")
	else
		if frame.bar2 then frame.bar2:Stop() end
		frame.bar2 = candy:New(media:Fetch("statusbar", frame.optionsTbl.texture), frame.optionsTbl.width, frame.optionsTbl.height)
		bar = frame.bar2
		bar:SetPoint("BOTTOM", name, "TOP")
	end

	bar:SetLabel(zone:match("[^%:]+:(.+)"))
	bar.candyBarLabel:SetJustifyH("LEFT")
	bar:SetDuration(timeLeft)
	if IsQuestFlaggedCompleted(rewardQuestID) then
		bar:SetColor(0,1,0,1)
	else
		bar:SetColor(1,0,0,1)
	end
	if frame.optionsTbl.icon then
		bar:SetIcon(236292) -- Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
	end
	bar.candyBarLabel:SetFont(media:Fetch("font", frame.optionsTbl.font), frame.optionsTbl.fontSize, frame.optionsTbl.outline)
	bar.candyBarDuration:SetFont(media:Fetch("font", frame.optionsTbl.font), frame.optionsTbl.fontSize, frame.optionsTbl.outline)
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
		header:SetText("Searching ".. (count == 1 and "-" or count == 2 and "\\" or count == 3 and "|" or "/"))
		if count == 4 then count = 0 end
		Timer(3, findTimer) -- Start hunting for the next event
	end
end

candy.RegisterCallback(name, "LibCandyBar_Stop", function(_, bar)
	if not aboutToStopBar and bar == frame.bar1 then
		Timer(20, findTimer) -- Start hunting for the next event
	end
end)

frame:SetScript("OnEvent", function()
	frame.optionsTbl = { -- XXX not saving for now
		fontSize = 10,
		texture = "BantoBar",
		outline = "NONE",
		font = media:GetDefault("font"),
		width = 200,
		height = 30,
		icon = true,
	}
	findTimer()
end)

