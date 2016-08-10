
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
			width = "full",
		},
		font = {
			type = "select",
			name = "Font",
			order = 2,
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

				frame.bar.candyBarLabel:SetFont(media:Fetch("font", font), op.fontSize)
				frame.bar.candyBarDuration:SetFont(media:Fetch("font", font), op.fontSize)
			end,
		},
		fontSize = {
			type = "range",
			name = "Font Size",
			order = 3,
			max = 40,
			min = 6,
			step = 1,
			set = function(info, value)
				op.fontSize = value

				frame.bar.candyBarLabel:SetFont(media:Fetch("font", op.font), value)
				frame.bar.candyBarDuration:SetFont(media:Fetch("font", op.font), value)
			end,
		},
		texture = {
			type = "select",
			name = L.texture,
			order = 4,
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

				frame.bar:SetTexture(texture)
			end,
		},
	},
}

acr:RegisterOptionsTable(acOptions.name, acOptions, true)
acd:SetDefaultSize(acOptions.name, 400, 400)

