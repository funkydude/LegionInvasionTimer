
local acr = LibStub("AceConfigRegistry-3.0")
local acd = LibStub("AceConfigDialog-3.0")
local media = LibStub("LibSharedMedia-3.0")
local adbo = LibStub("AceDBOptions-3.0")
local lit = LegionInvasionTimer
local L
do
	local _, mod = ...
	L = mod.L
end

local function updateFlags()
	local flags = nil
	if lit.db.profile.monochrome and lit.db.profile.outline ~= "NONE" then
		flags = "MONOCHROME," .. lit.db.profile.outline
	elseif lit.db.profile.monochrome then
		flags = "MONOCHROME"
	elseif lit.db.profile.outline ~= "NONE" then
		flags = lit.db.profile.outline
	end
	return flags
end

local function disabled()
	return lit.db.profile.mode == 2
end

local acOptions = {
	name = "LegionInvasionTimer",
	type = "group", childGroups = "tab",
	get = function(info)
		return lit.db.profile[info[#info]]
	end,
	set = function(info, value)
		lit.db.profile[info[#info]] = value
	end,
	args = {
		bar = {
			name = L.bar,
			order = 1, type = "group",
			args = {
				lock = {
					type = "toggle",
					name = L.lock,
					order = 1,
					set = function(_, value)
						lit.db.profile.lock = value
						if value then
							value = false
							lit.bg:Hide()
							lit.header:Hide()
						else
							value = true
							lit.bg:Show()
							lit.header:Show()
						end
						lit:EnableMouse(value)
						lit:SetMovable(value)
					end,
					disabled = disabled,
				},
				monochrome = {
					type = "toggle",
					name = L.monochrome,
					order = 2,
					set = function(_, value)
						lit.db.profile.monochrome = value
						lit.Bar.candyBarLabel:SetFont(media:Fetch("font", lit.db.profile.font), lit.db.profile.fontSize, updateFlags())
						lit.Bar.candyBarDuration:SetFont(media:Fetch("font", lit.db.profile.font), lit.db.profile.fontSize, updateFlags())
					end,
					disabled = disabled,
				},
				font = {
					type = "select",
					name = L.font,
					order = 3,
					width = 2,
					values = media:List("font"),
					itemControl = "DDI-Font",
					get = function()
						for i, v in next, media:List("font") do
							if v == lit.db.profile.font then return i end
						end
					end,
					set = function(_, value)
						local list = media:List("font")
						local font = list[value]
						lit.db.profile.font = font
						lit.Bar.candyBarLabel:SetFont(media:Fetch("font", font), lit.db.profile.fontSize, updateFlags())
						lit.Bar.candyBarDuration:SetFont(media:Fetch("font", font), lit.db.profile.fontSize, updateFlags())
					end,
					disabled = disabled,
				},
				fontSize = {
					type = "range",
					name = L.fontSize,
					order = 4,
					max = 200,
					min = 1,
					step = 1,
					set = function(_, value)
						lit.db.profile.fontSize = value
						lit.Bar.candyBarLabel:SetFont(media:Fetch("font", lit.db.profile.font), value, updateFlags())
						lit.Bar.candyBarDuration:SetFont(media:Fetch("font", lit.db.profile.font), value, updateFlags())
					end,
					disabled = disabled,
				},
				outline = {
					type = "select",
					name = L.outline,
					order = 5,
					values = {
						NONE = L.none,
						OUTLINE = L.thin,
						THICKOUTLINE = L.thick,
					},
					set = function(_, value)
						lit.db.profile.outline = value
						lit.Bar.candyBarLabel:SetFont(media:Fetch("font", lit.db.profile.font), lit.db.profile.fontSize, updateFlags())
						lit.Bar.candyBarDuration:SetFont(media:Fetch("font", lit.db.profile.font), lit.db.profile.fontSize, updateFlags())
					end,
					disabled = disabled,
				},
				timeText = {
					type = "toggle",
					name = L.showTime,
					order = 6,
					set = function(_, value)
						lit.db.profile.timeText = value
						lit.Bar:SetTimeVisibility(value)
					end,
					disabled = disabled,
				},
				alignTime = {
					type = "select",
					name = L.alignTime,
					order = 7,
					values = {
						LEFT = L.left,
						CENTER = L.center,
						RIGHT = L.right,
					},
					set = function(_, value)
						lit.db.profile.alignTime = value
						lit.Bar.candyBarDuration:SetJustifyH(value)
					end,
					disabled = function() return disabled() or not lit.db.profile.timeText end,
				},
				labelText = {
					type = "toggle",
					name = L.showText,
					order = 8,
					set = function(_, value)
						lit.db.profile.labelText = value
						lit.Bar:SetLabelVisibility(value)
					end,
					disabled = disabled,
				},
				alignText = {
					type = "select",
					name = L.alignText,
					order = 9,
					values = {
						LEFT = L.left,
						CENTER = L.center,
						RIGHT = L.right,
					},
					set = function(_, value)
						lit.db.profile.alignText = value
						lit.Bar.candyBarLabel:SetJustifyH(value)
					end,
					disabled = function() return disabled() or not lit.db.profile.labelText end,
				},
				icon = {
					type = "toggle",
					name = L.barIcon,
					order = 10,
					set = function(_, value)
						lit.db.profile.icon = value
						if value then
							local icon = lit.Bar:Get("LegionInvasionTimer:icon")
							lit.Bar:SetIcon(icon)
						else
							lit.Bar:SetIcon()
						end
					end,
					disabled = disabled,
				},
				alignIcon = {
					type = "select",
					name = L.alignIcon,
					order = 11,
					values = {
						LEFT = L.left,
						RIGHT = L.right,
					},
					set = function(_, value)
						lit.db.profile.alignIcon = value
						lit.Bar:SetIconPosition(value)
					end,
					disabled = function() return disabled() or not lit.db.profile.icon end,
				},
				barTexture = {
					type = "select",
					name = L.texture,
					order = 12,
					values = media:List("statusbar"),
					itemControl = "DDI-Statusbar",
					width = 2,
					get = function()
						for i, v in next, media:List("statusbar") do
							if v == lit.db.profile.barTexture then return i end
						end
					end,
					set = function(_, value)
						local list = media:List("statusbar")
						local texture = list[value]
						lit.db.profile.barTexture = texture
						lit.Bar:SetTexture(media:Fetch("statusbar", texture))
					end,
					disabled = disabled,
				},
				width = {
					type = "range",
					name = L.barWidth,
					order = 13,
					max = 2000,
					min = 10,
					step = 1,
					set = function(_, value)
						lit.db.profile.width = value
						lit.Bar:SetWidth(value)
					end,
					disabled = disabled,
				},
				height = {
					type = "range",
					name = L.barHeight,
					order = 14,
					max = 100,
					min = 5,
					step = 1,
					set = function(_, value)
						lit.db.profile.height = value
						lit.Bar:SetHeight(value)
					end,
					disabled = disabled,
				},
				growUp = {
					type = "toggle",
					name = L.growUpwards,
					order = 15,
					set = function(_, value)
						lit.db.profile.growUp = value
						lit.RearrangeBar()
					end,
					disabled = disabled,
				},
				fill = {
					type = "toggle",
					name = L.fillBar,
					order = 16,
					set = function(_, value)
						lit.db.profile.fill = value
						lit.Bar:SetFill(value)
					end,
					disabled = disabled,
				},
				colorComplete = {
					name = L.completedBar,
					type = "color",
					hasAlpha = true,
					order = 17,
					get = function()
						return unpack(lit.db.profile.colorComplete)
					end,
					set = function(_, r, g, b, a)
						lit.db.profile.colorComplete = {r, g, b, a}
						if lit.Bar:Get("LegionInvasionTimer:complete") == 1 then
							lit.Bar:SetColor(r, g, b, a)
						end
					end,
					disabled = disabled,
				},
				colorIncomplete = {
					name = L.incompleteBar,
					type = "color",
					hasAlpha = true,
					order = 18,
					get = function()
						return unpack(lit.db.profile.colorIncomplete)
					end,
					set = function(_, r, g, b, a)
						lit.db.profile.colorIncomplete = {r, g, b, a}
						if lit.Bar:Get("LegionInvasionTimer:complete") == 0 then
							lit.Bar:SetColor(r, g, b, a)
						end
					end,
					disabled = disabled,
				},
				colorNext = {
					name = L.nextBar,
					type = "color",
					hasAlpha = true,
					order = 19,
					get = function()
						return unpack(lit.db.profile.colorNext)
					end,
					set = function(_, r, g, b, a)
						lit.db.profile.colorNext = {r, g, b, a}
						if not lit.Bar:Get("LegionInvasionTimer:complete") then
							lit.Bar:SetColor(r, g, b, a)
						end
					end,
					disabled = disabled,
				},
				colorBarBackground = {
					name = L.barBackground,
					type = "color",
					hasAlpha = true,
					order = 20,
					get = function()
						return unpack(lit.db.profile.colorBarBackground)
					end,
					set = function(_, r, g, b, a)
						lit.db.profile.colorBarBackground = {r, g, b, a}
						lit.Bar.candyBarBackground:SetVertexColor(r, g, b, a)
					end,
					disabled = disabled,
				},
				colorText = {
					name = L.textColor,
					type = "color",
					hasAlpha = true,
					order = 21,
					get = function()
						return unpack(lit.db.profile.colorText)
					end,
					set = function(_, r, g, b, a)
						lit.db.profile.colorText = {r, g, b, a}
						lit.Bar:SetTextColor(r, g, b, a)
					end,
					disabled = disabled,
				},
			},
		},
		general = {
			name = L.general,
			order = 2, type = "group",
			args = {
				tooltipHeader = {
					type = "header",
					name = L.tooltipHeader,
					order = 22,
				},
				tooltip12hr = {
					type = "toggle",
					name = L.tooltip12hr,
					order = 23,
					width = 2,
				},
				tooltipHideAchiev = {
					type = "toggle",
					name = L.tooltipHideAchiev,
					order = 24,
					width = 2,
				},
				tooltipHideNethershard = {
					type = "toggle",
					name = L.hide:format((C_CurrencyInfo.GetCurrencyInfo(1226).name)),
					order = 25,
					width = 2,
				},
				tooltipHideWarSupplies = {
					type = "toggle",
					name = L.hide:format((C_CurrencyInfo.GetCurrencyInfo(1342).name)),
					order = 26,
					width = 2,
				},
				miscSeparator = {
					type = "header",
					name = "",
					order = 27,
				},
				zoneWarnings = {
					type = "toggle",
					name = L.zoneWarnings,
					desc = L.zoneWarningsDesc,
					order = 28,
				},
				hideInRaid = {
					type = "toggle",
					name = L.hideInRaid,
					order = 29,
					disabled = function() 
						return lit.db.profile.mode == 2 or lit.db.profile.mode == 3
					end,
				},
				mode = {
					type = "select",
					name = L.mode,
					order = 30,
					values = {
						[1] = L.modeBar,
						[2] = L.modeBroker,
						[3] = L.modeBarOnMap,
					},
					set = function(_, value)
						lit.db.profile.mode = value
						if value == 2 then
							if not lit.db.profile.lock then
								lit.db.profile.lock = true
							end
							if lit.db.profile.hideInRaid then
								lit.db.profile.hideInRaid = false
							end
						end
						if value == 3 and lit.db.profile.hideInRaid then
							lit.db.profile.hideInRaid = false
						end
						ReloadUI()
					end,
				},
			},
		},
		profiles = adbo:GetOptionsTable(lit.db),
	},
}
acOptions.args.profiles.order = 3

acr:RegisterOptionsTable(acOptions.name, acOptions, true)
acd:SetDefaultSize(acOptions.name, 420, 590)
