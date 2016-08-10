
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
		return
	end,
	set = function(info, value)
		local key = info[#info]
		op[key] = value
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
			order = 1,
			values = media:List("font"),
			itemControl = "DDI-Font",
			set = function(info, value)
				local key = info[#info]
				op[key] = value
				frame.bar.candyBarLabel:SetFont(media:Fetch("font", value), op.fontSize)
				frame.bar.candyBarDuration:SetFont(media:Fetch("font", value), op.fontSize)
			end,
		},
	},
}

acr:RegisterOptionsTable(acOptions.name, acOptions, true)
acd:SetDefaultSize(acOptions.name, 400, 400)

