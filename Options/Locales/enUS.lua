
local _, mod = ...
if not mod.L then -- Support repo users by checking if it already exists
	mod.L = {}
end
local L = mod.L

-- Options
L.lock = "Lock"
L.barIcon = "Bar Icon"
L.showTime = "Show Time"
L.fillBar = "Fill Bar"
L.font = "Font"
L.fontSize = "Font Size"
L.monochrome = "Monochrome Text"
L.outline = "Outline"
L.none = "None"
L.thin = "Thin"
L.thick = "Thick"
L.texture = "Texture"
L.barSpacing = "Bar Spacing"
L.barWidth = "Bar Width"
L.barHeight = "Bar Height"
L.alignZone = "Align Zone"
L.alignTime = "Align Time"
L.left = "Left"
L.center = "Center"
L.right = "Right"
L.growUpwards = "Grow Upwards"
L.textColor = "Text Color"
L.completedBar = "Completed Bar"
L.incompleteBar = "Incomplete Bar"
L.barBackground = "Bar Background"
L.hideBossWarnings = "Hide Boss Warnings"
L.hideInRaid = "Hide In Raid"
L.hideInInstance = "Hide In Instance"
L.hideInArena = "Hide In Arena"
L.hideInBattleground = "Hide In Battleground"
L.hideInScenario = "Hide In Scenario"
