
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")

-- LIBRARIES
local candy = LibStub("LibCandyBar-3.0")
local media = LibStub("LibSharedMedia-3.0")

frame:SetScript("OnEvent", function()
	for i=1, 300 do
		local name, timeLeftMinutes, rewardQuestID = GetInvasionInfoByMapAreaID(i)
		if timeLeftMinutes then
			local bar = candy:New(media:Fetch("statusbar", "BantoBar"), 200, 30)
			bar:SetLabel("Invasion")
			bar.candyBarLabel:SetJustifyH("LEFT")
			bar:SetDuration(timeLeftMinutes * 60)
			bar:SetIcon(236292) -- Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
			bar:SetPoint("CENTER", UIParent, "CENTER")
			bar:Start()
			break
		end
	end
end)