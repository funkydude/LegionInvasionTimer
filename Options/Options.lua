
local acr = LibStub("AceConfigRegistry-3.0")
local acd = LibStub("AceConfigDialog-3.0")
local media = LibStub("LibSharedMedia-3.0")
local frame = LegionInvasionTimer
local op = legionTimerDB

local function updateFlags()
	local flags = nil
	if op.monochrome and op.outline ~= "NONE" then
		flags = "MONOCHROME," .. op.outline
	elseif op.monochrome then
		flags = "MONOCHROME"
	elseif op.outline ~= "NONE" then
		flags = op.outline
	end
	return flags
end

local acOptions = {
	type = "group",
	name = "LegionInvasionTimer",
	get = function(info)
		return op[info[#info]]
	end,
	set = function(info, value)
		op[info[#info]] = value
	end,
	args = {
		lock = {
			type = "toggle",
			name = "Lock",
			order = 1,
		},
		icon = {
			type = "toggle",
			name = "Bar Icon",
			order = 2,
			set = function(info, value)
				op.icon = value
				frame.bar1:SetIcon(value and 236292) -- Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
				frame.bar2:SetIcon(value and 236292)
			end,
		},
		timeText = {
			type = "toggle",
			name = "Show Time",
			order = 3,
			set = function(info, value)
				op.timeText = value
				frame.bar1:SetTimeVisibility(value)
				frame.bar2:SetTimeVisibility(value)
			end,
		},
		fill = {
			type = "toggle",
			name = "Fill Bar",
			order = 4,
			set = function(info, value)
				op.fill = value
				frame.bar1:SetFill(value)
				frame.bar2:SetFill(value)
			end,
		},
		font = {
			type = "select",
			name = "Font",
			order = 5,
			values = media:List("font"),
			itemControl = "DDI-Font",
			get = function()
				for i, v in next, media:List("font") do
					if v == op.font then return i end
				end
			end,
			set = function(info, value)
				local list = media:List("font")
				local font = list[value]
				op.font = font
				frame.bar1.candyBarLabel:SetFont(media:Fetch("font", font), op.fontSize, updateFlags())
				frame.bar2.candyBarLabel:SetFont(media:Fetch("font", font), op.fontSize, updateFlags())
				frame.bar1.candyBarDuration:SetFont(media:Fetch("font", font), op.fontSize, updateFlags())
				frame.bar2.candyBarDuration:SetFont(media:Fetch("font", font), op.fontSize, updateFlags())
			end,
		},
		fontSize = {
			type = "range",
			name = "Font Size",
			order = 6,
			max = 40,
			min = 6,
			step = 1,
			set = function(info, value)
				op.fontSize = value
				frame.bar1.candyBarLabel:SetFont(media:Fetch("font", op.font), value, updateFlags())
				frame.bar2.candyBarLabel:SetFont(media:Fetch("font", op.font), value, updateFlags())
				frame.bar1.candyBarDuration:SetFont(media:Fetch("font", op.font), value, updateFlags())
				frame.bar2.candyBarDuration:SetFont(media:Fetch("font", op.font), value, updateFlags())
			end,
		},
		monochrome = {
			type = "toggle",
			name = "Monochrome Text",
			order = 7,
			set = function(info, value)
				op.monochrome = value
				frame.bar1.candyBarLabel:SetFont(media:Fetch("font", op.font), op.fontSize, updateFlags())
				frame.bar2.candyBarLabel:SetFont(media:Fetch("font", op.font), op.fontSize, updateFlags())
				frame.bar1.candyBarDuration:SetFont(media:Fetch("font", op.font), op.fontSize, updateFlags())
				frame.bar2.candyBarDuration:SetFont(media:Fetch("font", op.font), op.fontSize, updateFlags())
			end,
		},
		outline = {
			type = "select",
			name = "Outline",
			order = 8,
			values = {
				NONE = "None",
				OUTLINE = "Thin",
				THICKOUTLINE = "Thick",
			},
			set = function(info, value)
				op.outline = value
				frame.bar1.candyBarLabel:SetFont(media:Fetch("font", op.font), op.fontSize, updateFlags())
				frame.bar2.candyBarLabel:SetFont(media:Fetch("font", op.font), op.fontSize, updateFlags())
				frame.bar1.candyBarDuration:SetFont(media:Fetch("font", op.font), op.fontSize, updateFlags())
				frame.bar2.candyBarDuration:SetFont(media:Fetch("font", op.font), op.fontSize, updateFlags())
			end,
		},
		texture = {
			type = "select",
			name = "Texture",
			order = 9,
			values = media:List("statusbar"),
			itemControl = "DDI-Statusbar",
			get = function()
				for i, v in next, media:List("statusbar") do
					if v == op.texture then return i end
				end
			end,
			set = function(info, value)
				local list = media:List("statusbar")
				local texture = list[value]
				op.texture = texture
				frame.bar1:SetTexture(media:Fetch("statusbar", texture))
				frame.bar2:SetTexture(media:Fetch("statusbar", texture))
			end,
		},
		spacing = {
			type = "range",
			name = "Bar Spacing",
			order = 10,
			max = 100,
			min = 0,
			step = 1,
			set = function(info, value)
				op.spacing = value
				if op.growUp then
					frame.bar2:SetPoint("BOTTOMLEFT", frame.bar1, "TOPLEFT", 0, value)
					frame.bar2:SetPoint("BOTTOMRIGHT", frame.bar1, "TOPRIGHT", 0, value)
				else
					frame.bar2:SetPoint("TOPLEFT", frame.bar1, "BOTTOMLEFT", 0, -value)
					frame.bar2:SetPoint("TOPRIGHT", frame.bar1, "BOTTOMRIGHT", 0, -value)
				end
			end,
		},
		width = {
			type = "range",
			name = "Bar Width",
			order = 11,
			max = 2000,
			min = 10,
			step = 1,
			set = function(info, value)
				op.width = value
				frame.bar1:SetWidth(value)
				frame.bar2:SetWidth(value)
			end,
		},
		height = {
			type = "range",
			name = "Bar Height",
			order = 12,
			max = 100,
			min = 5,
			step = 1,
			set = function(info, value)
				op.height = value
				frame.bar1:SetHeight(value)
				frame.bar2:SetHeight(value)
			end,
		},
		alignZone = {
			type = "select",
			name = "Align Zone",
			order = 13,
			values = {
				LEFT = "Left",
				CENTER = "Center",
				RIGHT = "Right",
			},
			set = function(info, value)
				op.alignZone = value
				frame.bar1.candyBarLabel:SetJustifyH(value)
				frame.bar2.candyBarLabel:SetJustifyH(value)
			end,
		},
		alignTime = {
			type = "select",
			name = "Align Time",
			order = 14,
			values = {
				LEFT = "Left",
				CENTER = "Center",
				RIGHT = "Right",
			},
			set = function(info, value)
				op.alignTime = value
				frame.bar1.candyBarDuration:SetJustifyH(value)
				frame.bar2.candyBarDuration:SetJustifyH(value)
			end,
		},
		growUp = {
			type = "toggle",
			name = "Grow Upwards",
			order = 15,
			set = function(info, value)
				op.growUp = value
				frame.bar1:ClearAllPoints()
				frame.bar2:ClearAllPoints()
				if value then
					frame.bar1:SetPoint("BOTTOM", frame, "TOP")
					frame.bar2:SetPoint("BOTTOMLEFT", frame.bar1, "TOPLEFT", 0, op.spacing)
					frame.bar2:SetPoint("BOTTOMRIGHT", frame.bar1, "TOPRIGHT", 0, op.spacing)
				else
					frame.bar1:SetPoint("TOP", frame, "BOTTOM")
					frame.bar2:SetPoint("TOPLEFT", frame.bar1, "BOTTOMLEFT", 0, -op.spacing)
					frame.bar2:SetPoint("TOPRIGHT", frame.bar1, "BOTTOMRIGHT", 0, -op.spacing)
				end
			end,
		},
	},
}

acr:RegisterOptionsTable(acOptions.name, acOptions, true)
acd:SetDefaultSize(acOptions.name, 400, 500)

