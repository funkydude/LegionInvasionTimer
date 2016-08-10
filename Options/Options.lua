
local acr = LibStub("AceConfigRegistry-3.0")
local acd = LibStub("AceConfigDialog-3.0")

local acOptions = {
	type = "group",
	name = "LegionInvasionTimer",
	get = function(info)
		return legionInvasionTimerDB[info[#info]]
	end,
	set = function(info, value)
		local key = info[#info]
		legionInvasionTimerDB[key] = value
	end,
	args = {
		lock = {
			type = "toggle",
			name = "Lock",
			order = 1,
			width = "full",
		},
	},
}

acr:RegisterOptionsTable(acOptions.name, acOptions, true)
acd:SetDefaultSize(acOptions.name, 400, 400)

