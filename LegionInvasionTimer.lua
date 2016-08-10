
local name = ...
local candy = LibStub("LibCandyBar-3.0")
local media = LibStub("LibSharedMedia-3.0")

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
local header = frame:CreateFontString("TargetPercentText", "OVERLAY", "TextStatusBarText")
header:SetAllPoints(frame)
header:SetText(name)

local function startBar(timeLeft)
	frame.bar = candy:New(media:Fetch("statusbar", "BantoBar"), 200, 30)
	frame.bar:SetLabel("Invasion")
	frame.bar.candyBarLabel:SetJustifyH("LEFT")
	frame.bar:SetDuration(timeLeft)
	frame.bar:SetIcon(236292) -- Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
	frame.bar:SetPoint("TOP", name, "BOTTOM")
	frame.bar:Start()
end

local function runOnLogin()
	local found = false

	for i = 1, 300 do
		local name, timeLeftMinutes, rewardQuestID = GetInvasionInfoByMapAreaID(i)
		if timeLeftMinutes and timeLeftMinutes > 0 then
			found = true
			legionInvasionTimerDB = {GetTime(), timeLeftMinutes}

			startBar(timeLeftMinutes * 60)
			break
		end
	end

	if not found and legionInvasionTimerDB then
		local t, rem = legionInvasionTimerDB[1], legionInvasionTimerDB[2]
		if t and rem then
			found = true
			local deduct = (GetTime() - t) / 60
			local timeLeftMinutes = rem - deduct
			startBar(timeLeftMinutes * 60)
		end
	end

	if not found then
		C_Timer.After(7, runOnLogin) -- The very first login doesn't have GetInvasionInfoByMapAreaID data fast enough, delay it
	end
end

frame:SetScript("OnEvent", runOnLogin)

