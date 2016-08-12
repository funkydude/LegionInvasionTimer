
local acr = LibStub("AceConfigRegistry-3.0")
local acd = LibStub("AceConfigDialog-3.0")
local media = LibStub("LibSharedMedia-3.0")
local frame = LegionInvasionTimer
local db = legionTimerDB

local function updateFlags()
	local flags = nil
	if db.monochrome and db.outline ~= "NONE" then
		flags = "MONOCHROME," .. db.outline
	elseif db.monochrome then
		flags = "MONOCHROME"
	elseif db.outline ~= "NONE" then
		flags = db.outline
	end
	return flags
end

local acOptions = {
	type = "group",
	name = "LegionInvasionTimer",
	get = function(info)
		return db[info[#info]]
	end,
	set = function(info, value)
		db[info[#info]] = value
	end,
	args = {
		lock = {
			type = "toggle",
			name = "Lock",
			order = 1,
			set = function(info, value)
				db.lock = value
				if value then
					frame:EnableMouse(false)
					frame.bg:Hide()
					frame.header:Hide()
				else
					frame:EnableMouse(true)
					frame.bg:Show()
					frame.header:Show()
				end
			end,
		},
		icon = {
			type = "toggle",
			name = "Bar Icon",
			order = 2,
			set = function(info, value)
				db.icon = value
				frame.bar1:SetIcon(value and 236292) -- Interface\\Icons\\Ability_Warlock_DemonicEmpowerment
				frame.bar2:SetIcon(value and 236292)
			end,
		},
		timeText = {
			type = "toggle",
			name = "Show Time",
			order = 3,
			set = function(info, value)
				db.timeText = value
				frame.bar1:SetTimeVisibility(value)
				frame.bar2:SetTimeVisibility(value)
			end,
		},
		fill = {
			type = "toggle",
			name = "Fill Bar",
			order = 4,
			set = function(info, value)
				db.fill = value
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
					if v == db.font then return i end
				end
			end,
			set = function(info, value)
				local list = media:List("font")
				local font = list[value]
				db.font = font
				frame.bar1.candyBarLabel:SetFont(media:Fetch("font", font), db.fontSize, updateFlags())
				frame.bar2.candyBarLabel:SetFont(media:Fetch("font", font), db.fontSize, updateFlags())
				frame.bar1.candyBarDuration:SetFont(media:Fetch("font", font), db.fontSize, updateFlags())
				frame.bar2.candyBarDuration:SetFont(media:Fetch("font", font), db.fontSize, updateFlags())
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
				db.fontSize = value
				frame.bar1.candyBarLabel:SetFont(media:Fetch("font", db.font), value, updateFlags())
				frame.bar2.candyBarLabel:SetFont(media:Fetch("font", db.font), value, updateFlags())
				frame.bar1.candyBarDuration:SetFont(media:Fetch("font", db.font), value, updateFlags())
				frame.bar2.candyBarDuration:SetFont(media:Fetch("font", db.font), value, updateFlags())
			end,
		},
		monochrome = {
			type = "toggle",
			name = "Monochrome Text",
			order = 7,
			set = function(info, value)
				db.monochrome = value
				frame.bar1.candyBarLabel:SetFont(media:Fetch("font", db.font), db.fontSize, updateFlags())
				frame.bar2.candyBarLabel:SetFont(media:Fetch("font", db.font), db.fontSize, updateFlags())
				frame.bar1.candyBarDuration:SetFont(media:Fetch("font", db.font), db.fontSize, updateFlags())
				frame.bar2.candyBarDuration:SetFont(media:Fetch("font", db.font), db.fontSize, updateFlags())
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
				db.outline = value
				frame.bar1.candyBarLabel:SetFont(media:Fetch("font", db.font), db.fontSize, updateFlags())
				frame.bar2.candyBarLabel:SetFont(media:Fetch("font", db.font), db.fontSize, updateFlags())
				frame.bar1.candyBarDuration:SetFont(media:Fetch("font", db.font), db.fontSize, updateFlags())
				frame.bar2.candyBarDuration:SetFont(media:Fetch("font", db.font), db.fontSize, updateFlags())
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
					if v == db.texture then return i end
				end
			end,
			set = function(info, value)
				local list = media:List("statusbar")
				local texture = list[value]
				db.texture = texture
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
				db.spacing = value
				if db.growUp then
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
				db.width = value
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
				db.height = value
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
				db.alignZone = value
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
				db.alignTime = value
				frame.bar1.candyBarDuration:SetJustifyH(value)
				frame.bar2.candyBarDuration:SetJustifyH(value)
			end,
		},
		growUp = {
			type = "toggle",
			name = "Grow Upwards",
			order = 15,
			set = function(info, value)
				db.growUp = value
				frame.bar1:ClearAllPoints()
				frame.bar2:ClearAllPoints()
				if value then
					frame.bar1:SetPoint("BOTTOM", frame, "TOP")
					frame.bar2:SetPoint("BOTTOMLEFT", frame.bar1, "TOPLEFT", 0, db.spacing)
					frame.bar2:SetPoint("BOTTOMRIGHT", frame.bar1, "TOPRIGHT", 0, db.spacing)
				else
					frame.bar1:SetPoint("TOP", frame, "BOTTOM")
					frame.bar2:SetPoint("TOPLEFT", frame.bar1, "BOTTOMLEFT", 0, -db.spacing)
					frame.bar2:SetPoint("TOPRIGHT", frame.bar1, "BOTTOMRIGHT", 0, -db.spacing)
				end
			end,
		},
		colorText = {
			name = "Text Color",
			type = "color",
			order = 16,
			get = function()
				return unpack(db.colorText)
			end,
			set = function(info, r, g, b, a)
				db.colorText = {r, g, b, a}
				frame.bar1:SetTextColor(r, g, b, a)
				frame.bar2:SetTextColor(r, g, b, a)
			end,
		},
		colorComplete = {
			name = "Completed Bar",
			type = "color",
			order = 17,
			get = function()
				return unpack(db.colorComplete)
			end,
			set = function(info, r, g, b, a)
				db.colorComplete = {r, g, b, a}
				if frame.bar1:Get("LegionInvasionTimer:complete") then
					frame.bar1:SetColor(r, g, b, a)
				end
				if frame.bar2:Get("LegionInvasionTimer:complete") then
					frame.bar2:SetColor(r, g, b, a)
				end
			end,
		},
		colorIncomplete = {
			name = "Incomplete Bar",
			type = "color",
			order = 18,
			get = function()
				return unpack(db.colorIncomplete)
			end,
			set = function(info, r, g, b, a)
				db.colorIncomplete = {r, g, b, a}
				if not frame.bar1:Get("LegionInvasionTimer:complete") then
					frame.bar1:SetColor(r, g, b, a)
				end
				if not frame.bar2:Get("LegionInvasionTimer:complete") then
					frame.bar2:SetColor(r, g, b, a)
				end
			end,
		},
	},
}

acr:RegisterOptionsTable(acOptions.name, acOptions, true)
acd:SetDefaultSize(acOptions.name, 400, 500)

