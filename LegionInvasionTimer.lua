
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
	if frame.bar then frame.bar:Stop() end
	frame.bar = candy:New(media:Fetch("statusbar", frame.optionsTbl.texture), frame.optionsTbl.width, frame.optionsTbl.height)
	frame.bar:SetLabel("Invasion")
	frame.bar.candyBarLabel:SetJustifyH("LEFT")
	frame.bar:SetDuration(timeLeft)
	if frame.optionsTbl.icon then
		frame.bar:SetIcon(236292) -- Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
	end
	frame.bar:SetPoint("TOP", name, "BOTTOM")
	frame.bar.candyBarLabel:SetFont(media:Fetch("font", frame.optionsTbl.font), frame.optionsTbl.fontSize, frame.optionsTbl.outline)
	frame.bar.candyBarDuration:SetFont(media:Fetch("font", frame.optionsTbl.font), frame.optionsTbl.fontSize, frame.optionsTbl.outline)
	frame.bar:Start()
end

local function findTimer()
	for i = 1, 20 do
		local name, timeLeftMinutes, rewardQuestID = GetInvasionInfo(i)
		if timeLeftMinutes and timeLeftMinutes > 0 then
			startBar(timeLeftMinutes * 60)
			break
		end
	end
end

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
	C_Timer.After(7, findTimer) -- Safety
end)

