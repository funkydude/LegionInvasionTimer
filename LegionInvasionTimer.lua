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
frame:RegisterEvent("PLAYER_LOGIN", frameOnEvent)
frame.bar = {}

local function startBar(bar, text, timeLeft, rewardQuestID, icon)
	bar:SetLabel(text:match("[^%:]+:(.+)") or text)
	bar:SetDuration(timeLeft)
	if legionTimerDB.icon then
		bar:SetIcon(icon)
	end
	bar:SetTimeVisiblity(true)
	if rewardQuestID then -- Zone bars
		if IsQuestFlaggedCompleted(rewardQuestID) then
			bar:SetColor(unpack(legionTimerDB.colorComplete))
		else
			bar:SetColor(unpack(legionTimerDB.colorIncomplete))
		end
	else -- Searching bars
		bar:SetTimeVisibility(false)
	end
	bar:Start(7200) -- 2hrs = 60*2 = 120min = 120*60 = 7,200sec
end

local function setupBar(bar, count, icon)
	if count == 1 then
		if legionTimerDB.growUp then
			bar:SetPoint("BOTTOM", name, "TOP")
		else
			bar:SetPoint("TOP", name, "BOTTOM")
		end
	else
		if legionTimerDB.growUp then
			bar:SetPoint("BOTTOMLEFT", frame.bar[count - 1], "TOPLEFT", 0, legionTimerDB.spacing)
			bar:SetPoint("BOTTOMRIGHT", frame.bar[count - 1], "TOPRIGHT", 0, legionTimerDB.spacing)
		else
			bar:SetPoint("TOPLEFT", frame.bar[count - 1], "BOTTOMLEFT", 0, -legionTimerDB.spacing)
			bar:SetPoint("TOPRIGHT", frame.bar[count - 1], "BOTTOMRIGHT", 0, -legionTimerDB.spacing)
		end
	end
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
	bar.candyBarLabel:SetJustifyH(legionTimerDB.alignZone)
	bar.candyBarDuration:SetJustifyH(legionTimerDB.alignTime)
	bar:SetTextColor(unpack(legionTimerDB.colorText))
	bar:SetTimeVisibility(legionTimerDB.timeText)
	bar:SetFill(legionTimerDB.fill)
	startBar(frame.bar[i], "Searching...", 7200, nil, 132177) -- 132177 = Interface\\Icons\\Ability_Hunter_MasterMarksman
end

local function findTimer()
	-- 3 Legion Invasion: Northern Barrens 0 43282
	-- 4 Legion Invasion: Westfall 0 43245
	-- 5 Legion Invasion: Tanaris 0 43244
	-- 6 Legion Invasion: Dun Morogh 0 43284
	-- 7 Legion Invasion: Hillsbrad 0 43285
	-- 8 Legion Invasion: Azshara 0 43301

	local count = 1
	for i = 3, 8 do
		local zone, timeLeftMinutes, rewardQuestID = GetInvasionInfo(i)
		if timeLeftMinutes and timeLeftMinutes > 0 then
			startBar(frame.bar[count], zone, timeLeftMinutes * 60, rewardQuestID, 236292) -- 236292 = Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
			count = count + 1
			if timeLeftMinutes > 110 then
				FlashClientIcon()
				print("|cFF33FF99LegionInvasionTimer|r:", L.invasionsAvailable)
				RaidNotice_AddMessage(RaidBossEmoteFrame, L.invasionsAvailable, mod.c)
				PlaySound("RaidWarning", "Master")
			end
		end
	end

	if count == 1 then
		Timer(3, findTimer) -- Start hunting for the next event
	end
end

local function frameOnEnter(f)
	GameTooltip:SetOwner(f, "ANCHOR_NONE")
	GameTooltip:SetPoint("BOTTOM", f, "TOP")
	GameTooltip:AddLine(L.tooltipClick, 0.2, 1, 0.2, 1)
	GameTooltip:AddLine(L.tooltipClickOptions, 0.2, 1, 0.2, 1)
	GameTooltip:Show()
end

local function frameOnMouseUp(f, btn)
	if btn == "RightButton" then
		SlashCmdList[name]()
	end
end

local function slashHandler()
	LoadAddOn("LegionInvasionTimer_Options")
	LibStub("AceConfigDialog-3.0"):Open(name)
end

local function frameOnEvent()
	frame:UnregisterEvent("PLAYER_LOGIN")

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

	for i = 1, 6 do
		frame.bar[i] = candy:New(media:Fetch("statusbar", legionTimerDB.barTexture), legionTimerDB.width, legionTimerDB.height)
		setupBar(frame.bar[i], i)
	end

	frame:Show()
	SLASH_LegionInvasionTimer1, SLASH_LegionInvasionTimer2 = "/lit", "/legioninvasiontimer"
	SlashCmdList[name] = slashHandler
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetScript("OnLeave", GameTooltip_Hide)
	frame:SetScript("OnEnter", frameOnEnter)
	frame:SetScript("OnMouseUp", frameOnMouseUp)
	local bg = frame:CreateTexture(nil, "PARENT")
	bg:SetAllPoints(frame)
	bg:SetColorTexture(0, 1, 0, 0.3)
	frame.bg = bg
	local header = frame:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	header:SetAllPoints(frame)
	header:SetText(name)
	frame.header = header

	if legionTimerDB.lock then
		frame:EnableMouse(false)
		frame.bg:Hide()
		frame.header:Hide()
	end

	candy.RegisterCallback(name, "LibCandyBar_Stop", function(_, bar)
		if bar == frame.bar[1] then
			Timer(2, findTimer) -- Event over, start hunting for the next event
		end
	end)

	findTimer()
	frame:RegisterEvent("SCENARIO_COMPLETED")
	frameOnEvent = function()
		local _,_,_,_,_,_,_,_,_,scenarioType = C_Scenario.GetInfo()
		if scenarioType == 4 then -- LE_SCENARIO_TYPE_LEGION_INVASION = 4
			Timer(8, findTimer) -- Update bar color
		end
	end
end
