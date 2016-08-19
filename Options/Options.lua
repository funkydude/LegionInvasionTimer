
local acr = LibStub("AceConfigRegistry-3.0")
local acd = LibStub("AceConfigDialog-3.0")
local media = LibStub("LibSharedMedia-3.0")
local lit = LegionInvasionTimer
local L
do
	local _, mod = ...
	L = mod.L
end

local function updateFlags()
	local flags = nil
	if lit.db.monochrome and lit.db.outline ~= "NONE" then
		flags = "MONOCHROME," .. lit.db.outline
	elseif lit.db.monochrome then
		flags = "MONOCHROME"
	elseif lit.db.outline ~= "NONE" then
		flags = lit.db.outline
	end
	return flags
end

local acOptions = {
	type = "group",
	name = "LegionInvasionTimer",
	get = function(info)
		return lit.db[info[#info]]
	end,
	args = {
		lock = {
			type = "toggle",
			name = L.lock,
			order = 1,
			set = function(info, value)
				lit.db.lock = value
				if value then
					lit:EnableMouse(false)
					lit.bg:Hide()
					lit.header:Hide()
				else
					lit:EnableMouse(true)
					lit.bg:Show()
					lit.header:Show()
				end
			end,
		},
		icon = {
			type = "toggle",
			name = L.barIcon,
			order = 2,
			set = function(info, value)
				lit.db.icon = value
				lit.bar1:SetIcon(value and 236292) -- Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
				lit.bar2:SetIcon(value and 236292)
				lit.bar3:SetIcon(value and 236292)
			end,
		},
		timeText = {
			type = "toggle",
			name = L.showTime,
			order = 3,
			set = function(info, value)
				lit.db.timeText = value
				lit.bar1:SetTimeVisibility(value)
				lit.bar2:SetTimeVisibility(value)
				lit.bar3:SetTimeVisibility(value)
			end,
		},
		fill = {
			type = "toggle",
			name = L.fillBar,
			order = 4,
			set = function(info, value)
				lit.db.fill = value
				lit.bar1:SetFill(value)
				lit.bar2:SetFill(value)
				lit.bar3:SetFill(value)
			end,
		},
		font = {
			type = "select",
			name = L.font,
			order = 5,
			values = media:List("font"),
			itemControl = "DDI-Font",
			get = function()
				for i, v in next, media:List("font") do
					if v == lit.db.font then return i end
				end
			end,
			set = function(info, value)
				local list = media:List("font")
				local font = list[value]
				lit.db.font = font
				lit.bar1.candyBarLabel:SetFont(media:Fetch("font", font), lit.db.fontSize, updateFlags())
				lit.bar2.candyBarLabel:SetFont(media:Fetch("font", font), lit.db.fontSize, updateFlags())
				lit.bar3.candyBarLabel:SetFont(media:Fetch("font", font), lit.db.fontSize, updateFlags())
				lit.bar1.candyBarDuration:SetFont(media:Fetch("font", font), lit.db.fontSize, updateFlags())
				lit.bar2.candyBarDuration:SetFont(media:Fetch("font", font), lit.db.fontSize, updateFlags())
				lit.bar3.candyBarDuration:SetFont(media:Fetch("font", font), lit.db.fontSize, updateFlags())
			end,
		},
		fontSize = {
			type = "range",
			name = L.fontSize,
			order = 6,
			max = 40,
			min = 6,
			step = 1,
			set = function(info, value)
				lit.db.fontSize = value
				lit.bar1.candyBarLabel:SetFont(media:Fetch("font", lit.db.font), value, updateFlags())
				lit.bar2.candyBarLabel:SetFont(media:Fetch("font", lit.db.font), value, updateFlags())
				lit.bar3.candyBarLabel:SetFont(media:Fetch("font", lit.db.font), value, updateFlags())
				lit.bar1.candyBarDuration:SetFont(media:Fetch("font", lit.db.font), value, updateFlags())
				lit.bar2.candyBarDuration:SetFont(media:Fetch("font", lit.db.font), value, updateFlags())
				lit.bar3.candyBarDuration:SetFont(media:Fetch("font", lit.db.font), value, updateFlags())
			end,
		},
		monochrome = {
			type = "toggle",
			name = L.monochrome,
			order = 7,
			set = function(info, value)
				lit.db.monochrome = value
				lit.bar1.candyBarLabel:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
				lit.bar2.candyBarLabel:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
				lit.bar3.candyBarLabel:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
				lit.bar1.candyBarDuration:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
				lit.bar2.candyBarDuration:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
				lit.bar3.candyBarDuration:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
			end,
		},
		outline = {
			type = "select",
			name = L.outline,
			order = 8,
			values = {
				NONE = L.none,
				OUTLINE = L.thin,
				THICKOUTLINE = L.thick,
			},
			set = function(info, value)
				lit.db.outline = value
				lit.bar1.candyBarLabel:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
				lit.bar2.candyBarLabel:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
				lit.bar3.candyBarLabel:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
				lit.bar1.candyBarDuration:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
				lit.bar2.candyBarDuration:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
				lit.bar3.candyBarDuration:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
			end,
		},
		barTexture = {
			type = "select",
			name = L.texture,
			order = 9,
			values = media:List("statusbar"),
			itemControl = "DDI-Statusbar",
			get = function()
				for i, v in next, media:List("statusbar") do
					if v == lit.db.barTexture then return i end
				end
			end,
			set = function(info, value)
				local list = media:List("statusbar")
				local texture = list[value]
				lit.db.barTexture = texture
				lit.bar1:SetTexture(media:Fetch("statusbar", texture))
				lit.bar2:SetTexture(media:Fetch("statusbar", texture))
				lit.bar3:SetTexture(media:Fetch("statusbar", texture))
			end,
		},
		spacing = {
			type = "range",
			name = L.barSpacing,
			order = 10,
			max = 100,
			min = 0,
			step = 1,
			set = function(info, value)
				lit.db.spacing = value
				if lit.db.growUp then
					lit.bar2:SetPoint("BOTTOMLEFT", lit.bar1, "TOPLEFT", 0, value)
					lit.bar2:SetPoint("BOTTOMRIGHT", lit.bar1, "TOPRIGHT", 0, value)
					lit.bar3:SetPoint("BOTTOMLEFT", lit.bar2, "TOPLEFT", 0, value)
					lit.bar3:SetPoint("BOTTOMRIGHT", lit.bar2, "TOPRIGHT", 0, value)
				else
					lit.bar2:SetPoint("TOPLEFT", lit.bar1, "BOTTOMLEFT", 0, -value)
					lit.bar2:SetPoint("TOPRIGHT", lit.bar1, "BOTTOMRIGHT", 0, -value)
					lit.bar3:SetPoint("TOPLEFT", lit.bar2, "BOTTOMLEFT", 0, -value)
					lit.bar3:SetPoint("TOPRIGHT", lit.bar2, "BOTTOMRIGHT", 0, -value)
				end
			end,
		},
		width = {
			type = "range",
			name = L.barWidth,
			order = 11,
			max = 2000,
			min = 10,
			step = 1,
			set = function(info, value)
				lit.db.width = value
				lit.bar1:SetWidth(value)
				lit.bar2:SetWidth(value)
				lit.bar3:SetWidth(value)
			end,
		},
		height = {
			type = "range",
			name = L.barHeight,
			order = 12,
			max = 100,
			min = 5,
			step = 1,
			set = function(info, value)
				lit.db.height = value
				lit.bar1:SetHeight(value)
				lit.bar2:SetHeight(value)
				lit.bar3:SetHeight(value)
			end,
		},
		alignZone = {
			type = "select",
			name = L.alignZone,
			order = 13,
			values = {
				LEFT = L.left,
				CENTER = L.center,
				RIGHT = L.right,
			},
			set = function(info, value)
				lit.db.alignZone = value
				lit.bar1.candyBarLabel:SetJustifyH(value)
				lit.bar2.candyBarLabel:SetJustifyH(value)
				lit.bar3.candyBarLabel:SetJustifyH(value)
			end,
		},
		alignTime = {
			type = "select",
			name = L.alignTime,
			order = 14,
			values = {
				LEFT = L.left,
				CENTER = L.center,
				RIGHT = L.right,
			},
			set = function(info, value)
				lit.db.alignTime = value
				lit.bar1.candyBarDuration:SetJustifyH(value)
				lit.bar2.candyBarDuration:SetJustifyH(value)
				lit.bar3.candyBarDuration:SetJustifyH(value)
			end,
		},
		growUp = {
			type = "toggle",
			name = L.growUpwards,
			order = 15,
			set = function(info, value)
				lit.db.growUp = value
				lit.bar1:ClearAllPoints()
				lit.bar2:ClearAllPoints()
				lit.bar3:ClearAllPoints()
				if value then
					lit.bar1:SetPoint("BOTTOM", lit, "TOP")
					lit.bar2:SetPoint("BOTTOMLEFT", lit.bar1, "TOPLEFT", 0, lit.db.spacing)
					lit.bar2:SetPoint("BOTTOMRIGHT", lit.bar1, "TOPRIGHT", 0, lit.db.spacing)
					lit.bar3:SetPoint("BOTTOMLEFT", lit.bar2, "TOPLEFT", 0, lit.db.spacing)
					lit.bar3:SetPoint("BOTTOMRIGHT", lit.bar2, "TOPRIGHT", 0, lit.db.spacing)
				else
					lit.bar1:SetPoint("TOP", lit, "BOTTOM")
					lit.bar2:SetPoint("TOPLEFT", lit.bar1, "BOTTOMLEFT", 0, -lit.db.spacing)
					lit.bar2:SetPoint("TOPRIGHT", lit.bar1, "BOTTOMRIGHT", 0, -lit.db.spacing)
					lit.bar3:SetPoint("TOPLEFT", lit.bar2, "BOTTOMLEFT", 0, -lit.db.spacing)
					lit.bar3:SetPoint("TOPRIGHT", lit.bar2, "BOTTOMRIGHT", 0, -lit.db.spacing)
				end
			end,
		},
		colorText = {
			name = L.textColor,
			type = "color",
			order = 16,
			get = function()
				return unpack(lit.db.colorText)
			end,
			set = function(info, r, g, b, a)
				lit.db.colorText = {r, g, b, a}
				lit.bar1:SetTextColor(r, g, b, a)
				lit.bar2:SetTextColor(r, g, b, a)
				lit.bar3:SetTextColor(r, g, b, a)
			end,
		},
		colorComplete = {
			name = L.completedBar,
			type = "color",
			order = 17,
			get = function()
				return unpack(lit.db.colorComplete)
			end,
			set = function(info, r, g, b, a)
				lit.db.colorComplete = {r, g, b, a}
				if lit.bar1:Get("LegionInvasionTimer:complete") == 1 then
					lit.bar1:SetColor(r, g, b, a)
				end
				if lit.bar2:Get("LegionInvasionTimer:complete") == 1 then
					lit.bar2:SetColor(r, g, b, a)
				end
				if lit.bar3:Get("LegionInvasionTimer:complete") == 1 then
					lit.bar3:SetColor(r, g, b, a)
				end
			end,
		},
		colorIncomplete = {
			name = L.incompleteBar,
			type = "color",
			order = 18,
			get = function()
				return unpack(lit.db.colorIncomplete)
			end,
			set = function(info, r, g, b, a)
				lit.db.colorIncomplete = {r, g, b, a}
				if lit.bar1:Get("LegionInvasionTimer:complete") == 0 then
					lit.bar1:SetColor(r, g, b, a)
				end
				if lit.bar2:Get("LegionInvasionTimer:complete") == 0 then
					lit.bar2:SetColor(r, g, b, a)
				end
				if lit.bar3:Get("LegionInvasionTimer:complete") == 0 then
					lit.bar3:SetColor(r, g, b, a)
				end
			end,
		},
    		colorBarBackground = {
			name = L.barBackGroundColor,
			type = "color",
			hasAlpha = true,
			order = 18.1,
			get = function()
				return unpack(lit.db.colorBarBackground)
			end,
			set = function(info, r, g, b, a)
				lit.db.colorBarBackground = {r, g, b, a}
				if lit.bar1:Get("LegionInvasionTimer:complete") then
					lit.bar1.candyBarBackground:SetVertexColor(r, g, b, a)
        			end
				if lit.bar2:Get("LegionInvasionTimer:complete") then
					lit.bar2.candyBarBackground:SetVertexColor(r, g, b, a)
				end
				if lit.bar3:Get("LegionInvasionTimer:complete") then
					lit.bar3.candyBarBackground:SetVertexColor(r, g, b, a)
				end        
			end,
		},
		separator = {
			type = "header",
			name = "",
			order = 18.2,
		},
		hideBossWarnings = {
			type = "toggle",
			name = L.hideBossWarnings,
			order = 19,
			set = function(info, value)
				lit.db.hideBossWarnings = value
			end,
		},
		hideInRaid = {
			type = "toggle",
			name = L.hideInRaid,
			order = 20,
			set = function(info, value)
				lit.db.hideInRaid = value
			end,
		},
	},
}

acr:RegisterOptionsTable(acOptions.name, acOptions, true)
acd:SetDefaultSize(acOptions.name, 400, 500)
