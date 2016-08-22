
if GetLocale() ~= "deDE" then return end
local _, mod = ...
local L = mod.L

-- Options
L.lock = "Fenster Sperren"
L.barIcon = "Leistensymbol"
L.showTime = "Zeit anzeigen"
L.fillBar = "Leiste füllen"
L.font = "Schrift"
L.fontSize = "Schriftgröße"
L.monochrome = "Monochromer Text"
L.outline = "Umriss"
L.none = "Nichts"
L.thin = "Dünn"
L.thick = "Dick"
L.texture = "Textur"
L.barSpacing = "Zeilenabstand"
L.barWidth = "Leistenbreite"
L.barHeight = "Leistenhöhe"
L.alignZone = "Zone ausrichten"
L.alignTime = "Zeit ausrichten"
L.left = "Links"
L.center = "Zentriert"
L.right = "Rechts"
L.growUpwards = "nach Oben erweitern"
L.textColor = "Schriftfarbe"
L.completedBar = "abgeschlossene Leiste"
L.incompleteBar = "nicht abgeschlossen Leiste"
L.barBackground = "Leistenhintergrund"
L.hideBossWarnings = "Boss Warnungen verstecken"
L.hideInRaid = "Im Raid verstecken"
