std = "lua51"
max_line_length = false
codes = true
exclude_files = {
	"**/Libs",
}
ignore = {
	"111/SLASH_LegionInvasionTimer[12]", -- slash handlers
	"213/i", -- unused loop variable
}
globals = {
	"CreateFrame",
	"C_AreaPoiInfo",
	"C_CurrencyInfo",
	"C_Map",
	"C_QuestLog",
	"C_Timer",
	"GetLocale",
	"IsEncounterInProgress",
	"LibStub",
	"LegionInvasionTimer",
	"ReloadUI",
	"time",
}
