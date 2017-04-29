
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
				for bar in next, lit.bars do
					bar:SetIcon(value and 236292) -- Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
				end
			end,
		},
		timeText = {
			type = "toggle",
			name = L.showTime,
			order = 3,
			set = function(info, value)
				lit.db.timeText = value
				for bar in next, lit.bars do
					bar:SetTimeVisibility(value)
				end
			end,
		},
		fill = {
			type = "toggle",
			name = L.fillBar,
			order = 4,
			set = function(info, value)
				lit.db.fill = value
				for bar in next, lit.bars do
					bar:SetFill(value)
				end
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
				for bar in next, lit.bars do
					bar.candyBarLabel:SetFont(media:Fetch("font", font), lit.db.fontSize, updateFlags())
					bar.candyBarDuration:SetFont(media:Fetch("font", font), lit.db.fontSize, updateFlags())
				end
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
				for bar in next, lit.bars do
					bar.candyBarLabel:SetFont(media:Fetch("font", lit.db.font), value, updateFlags())
					bar.candyBarDuration:SetFont(media:Fetch("font", lit.db.font), value, updateFlags())
				end
			end,
		},
		monochrome = {
			type = "toggle",
			name = L.monochrome,
			order = 7,
			set = function(info, value)
				lit.db.monochrome = value
				for bar in next, lit.bars do
					bar.candyBarLabel:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
					bar.candyBarDuration:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
				end
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
				for bar in next, lit.bars do
					bar.candyBarLabel:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
					bar.candyBarDuration:SetFont(media:Fetch("font", lit.db.font), lit.db.fontSize, updateFlags())
				end
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
				for bar in next, lit.bars do
					bar:SetTexture(media:Fetch("statusbar", texture))
				end
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
				lit.rearrangeBars()
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
				for bar in next, lit.bars do
					bar:SetWidth(value)
				end
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
				for bar in next, lit.bars do
					bar:SetHeight(value)
				end
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
				for bar in next, lit.bars do
					bar.candyBarLabel:SetJustifyH(value)
				end
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
				for bar in next, lit.bars do
					bar.candyBarDuration:SetJustifyH(value)
				end
			end,
		},
		growUp = {
			type = "toggle",
			name = L.growUpwards,
			order = 15,
			set = function(info, value)
				lit.db.growUp = value
				lit.rearrangeBars()
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
				for bar in next, lit.bars do
					bar:SetTextColor(r, g, b, a)
				end
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
				for bar in next, lit.bars do
					if bar:Get("LegionInvasionTimer:complete") == 1 then
						bar:SetColor(r, g, b, a)
					end
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
				for bar in next, lit.bars do
					if bar:Get("LegionInvasionTimer:complete") == 0 then
						bar:SetColor(r, g, b, a)
					end
				end
			end,
		},
		colorBarBackground = {
			name = L.barBackground,
			type = "color",
			hasAlpha = true,
			order = 18.1,
			get = function()
				return unpack(lit.db.colorBarBackground)
			end,
			set = function(info, r, g, b, a)
				lit.db.colorBarBackground = {r, g, b, a}
				for bar in next, lit.bars do
					if bar then
						bar.candyBarBackground:SetVertexColor(r, g, b, a)
					end
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
		mode = {
			type = "select",
			name = "mode",
			order = 21,
			values = {
				[1] = "Bar",
				[2] = "Broker",
			},
			set = function(info, value)
				lit.db.mode = value
			end,
		},
	},
}

acr:RegisterOptionsTable(acOptions.name, acOptions, true)
acd:SetDefaultSize(acOptions.name, 400, 520)

