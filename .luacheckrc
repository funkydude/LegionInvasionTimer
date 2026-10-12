std = "lua51"
max_line_length = false
codes = true
exclude_files = {
	"**/Libs",
}
ignore = {
	"111/SLASH_LegionInvasionTimer[12]", -- slash handlers
	"112/SlashCmdList",
	"213/i", -- unused loop variable
}
globals = {
	"CreateFrame",
	"C_AddOns",
	"C_AreaPoiInfo",
	"C_CurrencyInfo",
	"C_InstanceEncounter",
	"C_Map",
	"C_QuestLog",
	"C_Timer",
	"date",
	"EnableAddOn",
	"FlashClientIcon",
	"FormatShortDate",
	"GetAchievementCriteriaInfo",
	"GetAchievementInfo",
	"GetAchievementNumCriteria",
	"GetInstanceInfo",
	"GetLocale",
	"LegionInvasionTime",
	"LegionInvasionTimer",
	"LibStub",
	"LoadAddOn",
	"PlaySound",
	"RaidWarningUtil",
	"ReloadUI",
	"SecondsToTime",
	"time",
	"UIParent",
	"WorldMapFrame",
}
