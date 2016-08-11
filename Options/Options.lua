
local acr = LibStub("AceConfigRegistry-3.0")
local acd = LibStub("AceConfigDialog-3.0")
local media = LibStub("LibSharedMedia-3.0")
local frame = LegionInvasionTimer
local op = LegionInvasionTimer.optionsTbl

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
				frame.bar2:SetIcon(value and 236292) -- Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
			end,
		},
		font = {
			type = "select",
			name = "Font",
			order = 3,
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
				frame.bar1.candyBarLabel:SetFont(media:Fetch("font", font), op.fontSize, op.outline)
				frame.bar2.candyBarLabel:SetFont(media:Fetch("font", font), op.fontSize, op.outline)
				frame.bar1.candyBarDuration:SetFont(media:Fetch("font", font), op.fontSize, op.outline)
				frame.bar2.candyBarDuration:SetFont(media:Fetch("font", font), op.fontSize, op.outline)
			end,
		},
		fontSize = {
			type = "range",
			name = "Font Size",
			order = 4,
			max = 40,
			min = 6,
			step = 1,
			set = function(info, value)
				op.fontSize = value
				frame.bar1.candyBarLabel:SetFont(media:Fetch("font", op.font), value, op.outline)
				frame.bar2.candyBarLabel:SetFont(media:Fetch("font", op.font), value, op.outline)
				frame.bar1.candyBarDuration:SetFont(media:Fetch("font", op.font), value, op.outline)
				frame.bar2.candyBarDuration:SetFont(media:Fetch("font", op.font), value, op.outline)
			end,
		},
		texture = {
			type = "select",
			name = "Texture",
			order = 5,
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
		outline = {
			type = "select",
			name = "Outline",
			order = 6,
			values = {
				NONE = "None",
				OUTLINE = "Thin",
				THICKOUTLINE = "Thick",
			},
			set = function(info, value)
				op.outline = value
				frame.bar1.candyBarLabel:SetFont(media:Fetch("font", op.font), op.fontSize, value)
				frame.bar2.candyBarLabel:SetFont(media:Fetch("font", op.font), op.fontSize, value)
				frame.bar1.candyBarDuration:SetFont(media:Fetch("font", op.font), op.fontSize, value)
				frame.bar2.candyBarDuration:SetFont(media:Fetch("font", op.font), op.fontSize, value)
			end,
		},
		width = {
			type = "range",
			name = "Bar Width",
			order = 7,
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
			order = 8,
			max = 100,
			min = 5,
			step = 1,
			set = function(info, value)
				op.height = value
				frame.bar1:SetHeight(value)
				frame.bar2:SetHeight(value)
			end,
		},
		introduction = {
			type = "description",
			name = "\n\nThese options do NOT permanently save yet.",
			fontSize = "large",
			order = 9,
			width = "full",
		},
	},
}

acr:RegisterOptionsTable(acOptions.name, acOptions, true)
acd:SetDefaultSize(acOptions.name, 400, 400)

