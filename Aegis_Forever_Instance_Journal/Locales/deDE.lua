local _, ns = ...

--[[
	The journal's interface in German, for a client set to German. Drafted by Claude for review by a
	native speaker. It is laid over the English table (Locales/enUS.lua), so every file that already
	holds ns.L sees these strings, and anything not translated here stays English. Every other
	client skips it.
]]
-- The journal's words where it speaks this language; the tables matched against the client's own
-- text where the client does, previewed or not (ns.LocaleTargets, Locales/enUS.lua).
local L, client = ns.LocaleTargets("deDE")
if not L then return end

L.JOURNAL_TITLE = "Dungeonkompendium"
L.HOME = HOME or "Startseite"
L.TAB_DUNGEONS = DUNGEONS or "Dungeons"
L.TAB_RAIDS = RAIDS or "Schlachtzüge"
L.TAB_REPUTATION = REPUTATION or "Ruf"

L.BINDING_TOGGLE = "Dungeonkompendium ein-/ausblenden"
L.KEY_CLAIMED = "Umschalt+J öffnet jetzt das Dungeonkompendium."
L.KEY_TAKEN = "Umschalt+J ist bereits mit %s belegt. Wählt eine Taste unter Tastenbelegungen > AddOns > Dungeonkompendium ein-/ausblenden."
L.POSITION_RESET = "Fensterposition zurückgesetzt."
L.DOCK_ON = "Das Fenster öffnet sich jetzt oben links neben den Fenstern des Spiels. Zieht es, um es bis zum Schließen zu verschieben."
L.DOCK_OFF = "Das Fenster ist wieder frei: Es öffnet sich dort, wo Ihr es zuletzt hingezogen habt."
L.DOCK_AFTER_COMBAT = "Das gilt, sobald der Kampf endet."
-- Its /aegis style sentence (2026-11-03; drafted, to be checked).
L.SLASH_HELP = "/aegis (oder /ij) öffnet das Kompendium. /aegis record startet oder beendet die Aufzeichnung. /aegis reset setzt das Fenster an seinen Standardplatz zurück. /aegis dock dockt das Fenster oben links neben den Fenstern des Spiels an oder gibt es wieder frei. /aegis perf misst Speicherbedarf und Geschwindigkeit des Kompendiums. /aegis where und /aegis taxi melden, wo Ihr steht und welche Flugpunkte auf Eurer Karte liegen. /aegis travel speichert ein Schiff, einen Zeppelin, eine Bahn oder ein Portal für die Weltkarte. /aegis items sucht die aufgeführten Gegenstände, die der Server nicht kennt. /aegis gear öffnet die Ausrüstungssuche, /aegis weights ihre Wertgewichtung; /aegis gearscan speichert, was sie aus Eurer Ausrüstung ausliest, um ihre Bewertung zu prüfen. /aegis options öffnet die Optionen des Kompendiums. /aegis style zeigt die Stilfrage des Kompendiums erneut. /aegis lang zeigt das Kompendium zur Probe in einer seiner anderen Sprachen. /aegis run zeigt oder verbirgt die Durchlaufanzeige (außerhalb eines Dungeons Euren letzten Durchlauf); /aegis run new beginnt einen neuen Durchlauf. /aegis test öffnet den Testmodus."
-- /aegis lang (Core/Init.lua)
L.LANG_USAGE = "/aegis lang de, fr, ru, cn, tw, es, mx, pt oder ko zeigt das Kompendium ab Eurem nächsten /reload auf Deutsch, Französisch, Russisch, Chinesisch (vereinfacht oder traditionell), Spanisch (Spanien oder Lateinamerika), brasilianischem Portugiesisch oder Koreanisch, um eine Übersetzung zu prüfen; /aegis lang off kehrt zur Sprache Eures Clients zurück. Aktuell: %s."
L.LANG_SET = "Ab Eurem nächsten /reload erscheint das Kompendium in der Sprache %s: nur seine eigenen Texte, denn die Namen aus dem Spiel bleiben in der Sprache Eures Clients. Gebt jetzt /reload ein; /aegis lang off macht es rückgängig."
L.LANG_OFF = "Ab Eurem nächsten /reload erscheint das Kompendium wieder in der Sprache Eures Clients. Gebt jetzt /reload ein."
L.LANG_FONTS = "Chinesisch braucht die Schriftarten eines chinesischen Clients: Auf Eurem werden manche Zeichen womöglich nicht angezeigt."
L.LANG_FONTS_KO = "Koreanisch braucht die Schriftarten eines koreanischen Clients: Auf Eurem werden manche Zeichen womöglich nicht angezeigt."
L.LANG_ON = "Vorschau des Kompendiums in der Sprache %s. /aegis lang off beendet sie."
L.LANG_UNAVAILABLE = "Dieser Client hat das Kompendium vor seinen gespeicherten Einstellungen geladen, daher konnte die Sprachvorschau nicht starten."
-- A map addon the owner asked us to warn about, while it is loaded: its name twice (2026-11-12; drafted, to be checked).
L.MAP_ADDON_HIDES = "%s ist aktiviert. Es überdeckt die Weltkarte, daher können einige Karten und Funktionen des Kompendiums verborgen sein. Wir empfehlen, %s zu deaktivieren."
L.AREAS_START = "Die IDs der %d Gebietsnamen des Kompendiums werden im Client gesucht..."
L.AREAS_DONE = "IDs für %d der %d Gebietsnamen gefunden. Gebt /reload ein, um sie zu speichern."
L.AREAS_MISSING = "Nicht gefunden: %s."
L.AREAS_SCANNING = "Die Gebietsnamen werden noch gesucht."
L.AREAS_ENGLISH = "Führt /aegis areas auf einem englischen Client aus: Die gesuchten Namen sind englisch."
-- Test mode (UI/TestPanel.lua, UI/TestRun.lua, UI/FogTest.lua): the owner's fog test of 2026-11-13, made test
-- mode on 2026-11-18, for this session only (2026-11-18; drafted, to be checked).
L.FOGTEST_FOG_OFF = "Der Nebel ist bei dieser Figur aus, also ändern sich nur die Symbole. Um ihn zu sehen, schaltet den Kriegsnebel in der Legende der Karte ein oder spielt im Abenteuermodus."
L.FOGTEST_PIN_CLICK = "Testmodus: Klickt, um ihn als besiegt zu markieren oder wieder aufzustellen."
L.TEST_TITLE = "Testmodus"
L.TEST_PICK = "Dungeon wählen"
L.TEST_NO_MAP = "Dafür gibt es noch keine Karte."
L.TEST_INSIDE = "Als wäre ich drin"
L.TEST_INSIDE_TIP = "Die Durchlaufanzeige zeigt diesen Dungeon wie beim Betreten: keine Siege, die Uhr wartet auf den ersten Kampf (Abspielen startet sie). Bosse, die Ihr als besiegt markiert, zählen dort wie echte Siege. Nichts davon wird gespeichert."
L.TEST_INSIDE_RAID = "Die Durchlaufanzeige ist für Dungeons da, nicht für Schlachtzüge."
L.TEST_INSIDE_REAL = "Ihr seid in %s: Die Durchlaufanzeige zeigt Euren echten Durchlauf."
L.TEST_TRACKER_COMBAT = "Wartet, bis der Kampf vorbei ist: Die Durchlaufanzeige steckt in der Questverfolgung."
L.TEST_WALK_IN = "Eintreten"
L.TEST_WALK_IN_TIP = "Der Durchlauf im Scharlachroten Kloster wartet an der Tür, bis der erste Raum oder Kampf eines Flügels den Flügel nennt. Eintreten nennt ihn: %s."
L.TEST_FOUND = "Als gefunden zeigen (Abenteuermodus)"
L.TEST_FOUND_TIP = "Aktiviert: Das Kompendium behandelt diesen Dungeon als gefunden, als hättet Ihr ihn betreten. Seine Bosse, Beute und Quests erscheinen trotzdem erst, wenn Ihr sie findet oder ein Testsieg sie freischaltet. Deaktiviert: so, wie Eure Figur ihn gefunden hat. Ein Testsieg findet ihn ebenfalls."
L.TEST_FOUND_OFF = "Eure Figur spielt nicht im Abenteuermodus, also wird ohnehin alles gezeigt."
L.TEST_FOUND_REAL = "Eure Figur hat ihn gefunden."
L.TEST_BOSSES = "Bosse"
L.TEST_DEFEATED = "%d von %d besiegt"
L.TEST_TAG_RARE = "selten"
L.TEST_TAG_SUMMONED = "beschworen"
L.TEST_TAG_NOT_COUNTED = "nicht gezählt"
L.TEST_TAG_MAYBE = "vielleicht"
L.TEST_TAG_QUEST = "Quest"
L.TEST_TAG_OUTSIDE = "draußen"
L.TEST_TAG_FINAL = "letzter"
L.TEST_TIP_RARE = "Selten: kein Kreis und keine Zeile in der Durchlaufanzeige, und er hält keinen Nebel zurück."
L.TEST_TIP_SUMMONED = "Beschworen: Er hält keinen Nebel zurück."
L.TEST_TIP_NOT_COUNTED = "Nicht gezählt: eine Zeile in der Durchlaufanzeige, sobald er besiegt ist, kein Kreis."
L.TEST_TIP_MAYBE = "Vielleicht: Nur manche Durchläufe treffen auf ihn. Eine Zeile in der Durchlaufanzeige, sobald er besiegt ist, kein Kreis."
L.TEST_TIP_QUEST = "Quest: das Ziel einer Quest. Eine Zeile in der Durchlaufanzeige, sobald er besiegt ist, kein Kreis. Außerhalb des Tests öffnet seine Markierung seine Quest."
L.TEST_TIP_OUTSIDE = "Draußen: Er steht außerhalb des Dungeons, daher zeigt ihn die Durchlaufanzeige nie."
L.TEST_TIP_FINAL = "Letzter: Sein Sieg hält die Uhr des Durchlaufs an."
L.TEST_END = "Test beenden"
L.TEST_ON = "Testmodus an, nur für diese Sitzung: Nichts wird gespeichert. Test beenden oder ein /reload schaltet ihn aus."
L.TEST_OFF = "Testmodus aus: Alles ist wie zuvor."
L.TEST_RUN_TITLE = "%s (Test)"
L.TEST_RUN_ENDED = "Ihr habt einen Dungeon betreten, daher endet der vorgetäuschte Durchlauf des Tests."
L.TEST_STATE_INSIDE = "drin"
L.TEST_STATE_DOOR = "an der Tür (welcher Flügel?)"
L.TEST_STATE_OUTSIDE = "draußen"
L.TEST_STATE_DEFEATED = "%d/%d besiegt"
L.TEST_STATE_FOG_ON = "Nebel an"
L.TEST_STATE_FOG_OFF = "Nebel aus"
L.TEST_STATE_NO_FOG = "kein Nebel"
L.TEST_STATE_FOUND = "als gefunden gezeigt"
L.TEST_STATE_REAL = "wie bei Eurer Figur"
L.TEST_STATE_KILL_FOUND = "durch Testsieg gefunden"
L.TEST_STATE_REAL_INSIDE = "wirklich drin"
L.TEST_STATE_NOT_ADVENTURE = "nicht im Abenteuermodus"
L.TEST_STATE_COMBAT = "im Kampf"
L.TEST_USAGE = "/ij test öffnet den Testmodus. /ij test off beendet ihn. /ij test debug gibt aus, was er gerade tut."
L.ITEMS_START = "Der Server wird nach den %d Gegenständen gefragt, die das Kompendium aufführt. Die Antwort kommt in etwa %d Sekunden; spielt ruhig weiter."
L.ITEMS_SCANNING = "Der Server wird noch gefragt; die Antwort kommt gleich."
L.ITEMS_DONE = "Von %d Gegenständen kennt der Server %d nicht: Wahrscheinlich gibt es sie in Forever noch nicht. Das Kompendium blendet sie aus, bis der Server oder ein aufgezeichneter Durchlauf sie bestätigt. Die vollständige Liste kommt beim nächsten /reload oder Ausloggen in die gespeicherte Datei."
L.ITEMS_LINE = "  Gegenstand %d: %s"
L.ITEMS_MORE = "  ...und %d weitere."
L.PERF_HEADER = "Leistung (Speicher in KB, Zeiten in Millisekunden; weniger ist besser):"
L.PERF_MEMORY = "  %s: %.0f KB"
L.PERF_TIME = "  %s: %.2f ms"
L.PERF_BUILD = "Erstes Öffnen (Aufbau des Fensters)"
L.PERF_BOOK = "Erster geöffneter Dungeon (Aufbau des Buchs)"
L.PERF_OPEN = "Kompendium öffnen und schließen"
L.PERF_DUNGEON = "Seite eines Dungeons öffnen"
L.PERF_TAB = "Zum Reiter %s wechseln"
L.PERF_FACTION = "Seite einer Fraktion öffnen"
L.PERF_LOOT = "Beuteseite neu zeichnen"
L.PERF_COMBAT = "Die Messung wartet, bis Ihr nicht mehr im Kampf seid."
L.WHERE = "Karte %s (%s)  x %.4f  y %.4f  Gebiet \"%s\"  Minikarte \"%s\"  Höhe %s"
-- /aegis where: what the journal remembers the player as below a city, and its last changes (2026-11-06; drafted, to be checked).
L.WHERE_BELOW = "%s: gemerkt %s"
L.WHERE_BELOW_BELOW = "unten"
L.WHERE_BELOW_TOP = "oben"
L.WHERE_BELOW_NOTHING = "nichts"
L.WHERE_BELOW_CHANGE = "  %s  %s  Karte %s  Gebiet \"%s\"  x %s  y %s:  %s -> %s"
L.WHERE_GAMEPAD = "Gamepad-Oberfläche: Gamepad bei Kampfbeginn zurückgegeben: %d (zuletzt bei %s); zu spät: %d; Ereignisse der Kampfbeschränkung gehört: %d; wartende Überspring-Markierungen: %d"
L.WHERE_FLOOR = "%s: Karte auf Ebene %d (%s), nach dem Gebiet \"%s\""
L.WHERE_FLOOR_KEPT = "%s: Karte auf Ebene %d (%s), beibehalten: das Gebiet \"%s\" gehört zu keiner Ebene"
L.WHERE_FLOOR_HELD = "%s: Karte auf Ebene %d (%s), folgt dem Gebiet \"%s\" nicht: eine Ebene gewählt oder die ganze Karte"
L.TAXI = "Karte %s  zeigt selbst Flugpunkte: %s  Flugpunkte darauf: %d (%d entdeckt)  %s"
L.TAXI_ATLASES = "Reisesymbole: %s"
L.YES = YES or "Ja"
L.NO = NO or "Nein"

L.EMPTY_DUNGEONS = "Für Dungeons gibt es noch keine Einträge im Kompendium."
L.EMPTY_RAIDS = "Für Schlachtzüge gibt es noch keine Einträge im Kompendium."
L.EMPTY_REPUTATION = "Es sind noch keine Rufbelohnungen bekannt."
L.EMPTY_BRACKET = "In diesem Stufenbereich gibt es nichts."

L.TAB_RECORD = "Aufzeichnen"
L.TAB_GEAR = "Ausrüstungssuche"

-- The Gear Finder (Core/GearFinder.lua, UI/GearPanel.lua, UI/CharacterTab.lua).
L.GEAR_TITLE = "Ausrüstungssuche"
L.GEAR_PREVIEW = "Vorschau"
L.GEAR_NO_UPGRADE = "Keine Verbesserung gefunden"
L.GEAR_LOOKING = "Suche in %d Dungeons."
L.GEAR_LOOKING_ONE = "Suche in 1 Dungeon."
L.GEAR_LOADING = "%d Gegenstände werden noch geladen."
L.GEAR_LOADING_ONE = "1 Gegenstand wird noch geladen."
L.GEAR_SCORING = "Bewertung für"
L.GEAR_AUTO = "Automatisch: %s"
L.GEAR_WHY_TALENTS = "%s (Talente)"
L.GEAR_WHY_LEVELLING = "%s (Stufenaufstieg)"
L.GEAR_SUGGESTED = "Empfohlener Dungeon"
L.GEAR_UPGRADES_HERE = "%d Verbesserungen hier"
L.GEAR_UPGRADE_HERE = "1 Verbesserung hier"
L.GEAR_MORE_SLOTS = "und %d weitere"
L.GEAR_DUNGEON_OF = "%d von %d"
L.GEAR_NONE = "Keine Verbesserungen in den Dungeons Eurer Stufe."
L.GEAR_TIP_CLICK = "Klickt, um die Beute zu sehen; Umschalt+Klick, um den Gegenstand zu verlinken."
L.GEAR_TIP_CELL_CLICK = "Klickt für die besten Verbesserungen; Rechtsklick, um die Beute zu sehen."
L.GEAR_TIP_PICK_CLICK = "Klickt, um ihn hier anzuzeigen; Rechtsklick, um die Beute zu sehen."
L.GEAR_TIP_PICKED = "Eure Wahl für diesen Platz."
L.GEAR_PICK_TOP = "Die besten %d von %d Verbesserungen"
L.GEAR_PICK_ALL = "%d Verbesserungen"
L.GEAR_PICK_ONE = "Die einzige Verbesserung"
L.GEAR_PICK_BIGGEST = "Größte"
L.GEAR_PICK_YOURS = "Eure Wahl"
L.GEAR_PICK_KEPT = "Eure Wahl wird für diesen Charakter gespeichert."
L.GEAR_PICK_CLEAR = "Meine Wahl aufheben"
L.GEAR_TIP_NONE = "Keine Verbesserung für diesen Platz in den Dungeons Eurer Stufe."
L.GEAR_CHAR_BUTTON = "Ausrüstungssuche"
L.GEAR_CHAR_BUTTON_TIP = "Eure Wertgewichtung und die besten Verbesserungen, die in den Dungeons des Kompendiums auf Euch warten."
L.GEAR_SCAN_DONE = "Ausrüstungsscan gespeichert: %d getragene Gegenstände und %d Gegenstände aus Dungeons. Loggt Euch aus oder gebt /reload ein, um ihn in die gespeicherte Datei zu schreiben."
L.GEAR_SCAN_ERRORS = "%d Gegenstände konnten nicht gelesen werden; was schiefging, ist mit dem Scan gespeichert."
L.GEAR_SCAN_LOADING = "Manche Beute wird noch geladen: Wartet ein paar Sekunden und gebt erneut /aegis gearscan ein, um mehr zu erhalten."
L.GEAR_SLOT_FINGER1 = "Finger 1"
L.GEAR_SLOT_FINGER2 = "Finger 2"
L.GEAR_SLOT_TRINKET1 = "Schmuck 1"
L.GEAR_SLOT_TRINKET2 = "Schmuck 2"

-- Stat weights (Core/ItemScore.lua, UI/WeightsEditor.lua).
L.WEIGHTS_TITLE = "Wertgewichtung"
L.WEIGHTS_EDIT = "Wertgewichtung bearbeiten..."
L.WEIGHTS_SOURCE_DEFAULT = "Gewichtung des Kompendiums"
L.WEIGHTS_SOURCE_LEVELLING = "Gewichtung des Kompendiums, beim Stufenaufstieg"
L.WEIGHTS_SOURCE_CUSTOM = "Eure eigene Gewichtung"
L.WEIGHTS_SOURCE_PAWN = "Eure Gewichtung aus Pawn: %s"
L.WEIGHTS_TIP = "Wie viel ein Punkt jedes Werts dieser Spezialisierung wert ist. Klickt auf eine Gewichtung, um sie zu ändern; Eure eigenen Gewichtungen erscheinen grün und werden für diesen Charakter gespeichert."
L.WEIGHTS_RESET = "Zurücksetzen"
L.WEIGHTS_RESET_TIP = "Zurück zur Gewichtung des Kompendiums für diese Spezialisierung."
L.WEIGHTS_PAWN = "Pawn..."
-- The Pawn... button's tooltip names WoWSims' Pawn export (2026-11-03; drafted, to be checked).
L.WEIGHTS_PAWN_TIP = "Eine Skala aus Pawn übernehmen oder einen Pawn-Export von WoWSims einfügen."
L.WEIGHTS_PAWN_HELP = "Wählt in Pawn die Skala, dann Exportieren, kopiert den Text und fügt ihn hier ein."
L.WEIGHTS_IMPORT = "Importieren"
L.WEIGHTS_CANCEL = "Abbrechen"
L.WEIGHTS_BACK = "Zurück"
L.WEIGHTS_OPEN_FINDER = "Ausrüstungssuche öffnen"
L.WEIGHTS_IMPORTED = "%d Gewichtungen aus %s importiert."
L.WEIGHTS_UNUSED = "Nicht verwendet: %s."
L.WEIGHTS_NOT_PAWN = "Das ist keine Pawn-Skala. Wählt in Pawn Exportieren und kopiert den gesamten Text."
L.WEIGHTS_OTHER_CLASS = "Diese Skala ist für die Klasse %s, nicht für die Klasse dieses Charakters."
L.WEIGHTS_FOR = "Für"
-- WoWSims' weights, the Gear Finder's defaults for the specs the sim has, and its Pawn export (2026-11-03; drafted, to be checked).
L.WEIGHTS_SOURCE_SIMS = "Gewichtung von WoWSims: %s"
L.WEIGHTS_PAWN_SIMS = "Ein Pawn-Export von WoWSims (wowsims.com/forever) geht auch, mit oder ohne Pawn, und wertet wie die WoWSims-Gewichtung des Kompendiums. Er hat keine Gewichtung für Heilung, Schulschaden, Zauberdurchschlag, Feral-Angriffskraft, Verteidigung, Blocken oder Widerstände."
L.WEIGHTS_NO_STATS = "Diese Pawn-Skala hat keine Gewichtung, die das Kompendium verwenden kann."
-- The journal's page in the game's options (Options > AddOns).
L.OPTIONS_TITLE = "Aegis Instance Journal"
L.OPTIONS_BOSS_LEVELS = "Bossstufen in der Liste anzeigen"
L.OPTIONS_BOSS_LEVELS_TIP = "Ein Abzeichen auf dem Porträt jedes Bosses zeigt seine Stufe, gefärbt danach, wie schwer der Boss für Euch ist: grau, grün, gelb, orange oder rot."
L.OPTIONS_ARROWS = "Grüner Pfeil für Verbesserungen"
L.OPTIONS_MINIMAP = "Schaltfläche an der Minikarte"
L.OPTIONS_PAWN_WEIGHTS = "Wertgewichtung von Pawn nutzen"
L.OPTIONS_PAWN_WEIGHTS_TIP = "Ist Pawn installiert, werden seine Gegenstands-Tooltips und Verbesserungspfeile angezeigt. Angehakt: Die Ausrüstungssuche bewertet Gegenstände mit Eurer Pawn-Skala für Eure Spezialisierung. Nicht angehakt: Pawn zeigt stattdessen die Gewichtung des Kompendiums für Eure Spezialisierung, als Skala des Kompendiums, und seine eigenen Skalen bleiben auf diesem Charakter ausgeblendet, bis Ihr dies anhakt."
L.PAWN_ASK = "Pawn ist ebenfalls installiert. Seine Gegenstands-Tooltips und Verbesserungspfeile werden angezeigt.\n\nWessen Wertgewichtung sollen Pawn und die Ausrüstungssuche beide verwenden?\n\nDie des Kompendiums: Pawn zeigt sie für Eure Spezialisierung an und blendet auf diesem Charakter seine eigenen Skalen aus.\nDie von Pawn: Die Ausrüstungssuche verwendet Eure Pawn-Skalen."
L.PAWN_USE_PAWN = "Die von Pawn"
L.PAWN_USE_JOURNAL = "Die des Kompendiums"
L.PAWN_SCALE = "Kompendium: %s"
L.PAWN_RELOAD = "Pawns Verbesserungspfeile in Euren Baganator-Taschen ändern sich erst nach einem Neuladen: Baganator behält Pawns Antworten, bis sich Eure Ausrüstung ändert.\n\nJetzt neu laden?"
L.PAWN_RELOAD_NOW = "Neu laden"
L.PAWN_RELOAD_LATER = "Später"
L.WEIGHTS_SOURCE_PAWN_LIVE = "Pawn-Skala %s. Ändert sie in Pawn oder wählt in den Optionen die Gewichtung des Kompendiums."
L.OPTIONS_MINIMAP_TIP = "Die Schaltfläche des Kompendiums am Rand der Minikarte: Klickt darauf, um das Kompendium zu öffnen; ein Rechtsklick öffnet diese Optionen; zieht sie, um sie zu verschieben."
-- The journal's line in the minimap's addon menu, its box beside the minimap button's (UI/Options.lua; 2026-11-20; drafted, to be checked).
L.OPTIONS_ADDON_MENU = "Im Addon-Menü der Minikarte"
L.OPTIONS_ADDON_MENU_TIP = "Die Zeile des Kompendiums im Addon-Menü der Minikarte, der kleinen Schaltfläche mit einer Zahl: Klickt darauf, um das Kompendium zu öffnen; ein Rechtsklick öffnet diese Optionen. Abgewählt verschwindet sie nach einem /reload aus dem Menü."
L.OPTIONS_DOCK = "Fenster oben links andocken"
L.OPTIONS_DOCK_TIP = "Aktiviert: Das Kompendium öffnet sich oben links, wo das Spiel seine eigenen Fenster öffnet, und rückt zur Seite, wenn dort eines davon geöffnet wird, so wie sie es untereinander tun; ist für beide kein Platz, schließt das Spiel das ältere. Zieht es, um es irgendwohin zu verschieben: Beim nächsten Öffnen dockt es wieder an. Deaktiviert: Es öffnet sich dort, wo Ihr es zuletzt hingezogen habt."
-- Test mode's button, last on the options' page (UI/Options.lua; 2026-11-18; drafted, to be checked).
L.OPTIONS_TEST = "Testmodus"
L.OPTIONS_TEST_BUTTON = "Öffnen"
L.OPTIONS_TEST_TIP = "Zeigt die Karte, den Nebel und die Durchlaufanzeige jedes Dungeons, ohne hineinzugehen: Wählt einen Dungeon, markiert Bosse als besiegt, tut so, als wärt Ihr drin. Nur für diese Sitzung: Nichts wird gespeichert, und ein /reload beendet ihn."
L.OPTIONS_DUNGEON_FOG = "Kriegsnebel auf Dungeonkarten"
L.OPTIONS_DUNGEON_FOG_TIP = "Dungeonkarten liegen zu Beginn unter Nebel, nur der Eingang ist frei. Jeder Boss, den Eure Gruppe besiegt, macht seine Räume und den Weg zurück frei, und der letzte die ganze Karte; was frei ist, bleibt frei. Im Abenteuermodus immer an. Nur für diesen Charakter."
-- Adventure Mode's news: the chat line for new finds, the minimap button's line while it glows, and their two
-- boxes in the options (2026-11-11; translation drafted, to be checked).
L.ADVENTURE_NEWS = "Neu in Eurem Kompendium: %s"
L.MINIMAP_NEWS = "Es gibt Neues in Eurem Kompendium."
L.OPTIONS_ADVENTURE_CHAT = "Neue Funde im Chat"
L.OPTIONS_ADVENTURE_CHAT_TIP = "Im Abenteuermodus eine Zeile im Chat, wenn Ihr etwas Neues für das Kompendium findet: einen Dungeon, einen Boss, Beute, eine Quest, eine Fraktion oder eine Flugroute. Klickt auf einen Namen, um seine Seite zu öffnen (eine Flugroute hat keine). Für alle Eure Charaktere."
L.OPTIONS_ADVENTURE_GLOW = "Minikartenschaltfläche leuchtet"
L.OPTIONS_ADVENTURE_GLOW_TIP = "Im Abenteuermodus leuchtet die Schaltfläche an der Minikarte, wenn Ihr seit dem letzten Öffnen des Kompendiums etwas Neues gefunden habt, bis Ihr es öffnet. Für alle Eure Charaktere."
L.MINIMAP_LEFT_CLICK = "Klickt, um das Kompendium zu öffnen oder zu schließen."
L.MINIMAP_RIGHT_CLICK = "Rechtsklick für die Optionen."
L.MINIMAP_DRAG = "Zieht die Schaltfläche, um sie am Rand der Minikarte zu verschieben."
L.OPTIONS_ARROWS_TIP = "Ein grüner Pfeil auf Gegenständen, die für Eure Spezialisierung Verbesserungen sind, so wie die Ausrüstungssuche sie zählt: in Euren Taschen, im Beutefenster und beim Würfeln um Beute."
L.WEIGHTS_SHOW_GAINS = "Gewichtung in Tooltips anzeigen"
L.WEIGHTS_SHOW_GAINS_TIP = "Unter jedem Gegenstand eine Zeile für jede Eurer Spezialisierungen: was der Gegenstand nach ihrer Gewichtung wert ist, und ein grüner Pfeil mit dem, was er Eurer Ausrüstung hinzufügt, wenn er eine Verbesserung ist. Für alle Eure Charaktere mit eingeschalteter Ausrüstungssuche. Ist Pawn installiert, blendet dies stattdessen die Skala des Kompendiums in Pawn ein oder aus, und mit ihr Pawns Verbesserungspfeile für die Gewichtung des Kompendiums: Pawn markiert Verbesserungen nur für die Skalen, die es anzeigt."
L.OPTIONS_SOURCES = "Fundorte in Tooltips anzeigen"
L.OPTIONS_SOURCES_TIP = "Unter jedem Gegenstand, der in den Dungeons und Schlachtzügen des Kompendiums als Beute zu finden ist, eine Zeile mit dem Boss und dem Dungeon: in Euren Taschen, an Eurem Charakter, in Chatlinks, bei Händlern und überall sonst, wo das Spiel den Gegenstand zeigt. Für alle Eure Charaktere."
L.GEAR_WHY_CUSTOM = "%s (Eure Gewichtung)"
-- The specs' names and the units their weights count in, by spec key and by the English unit.
L.GEAR_SPEC_NAMES = {
	Arms = "Waffen", Fury = "Furor", Protection = "Schutz", Holy = "Heilig", Retribution = "Vergeltung",
	BeastMastery = "Tierherrschaft", Marksmanship = "Treffsicherheit", Survival = "Überleben",
	Assassination = "Meucheln", Combat = "Kampf", Subtlety = "Täuschung", Discipline = "Disziplin", Shadow = "Schattenmagie",
	Elemental = "Elementarkampf", Enhancement = "Verstärkung", EnhancementTank = "Verstärkung (Tank)",
	Restoration = "Wiederherstellung", Arcane = "Arkan", Fire = "Feuer", Frost = "Frost", Affliction = "Gebrechen",
	Demonology = "Dämonologie", Destruction = "Zerstörung", Balance = "Gleichgewicht", FeralBear = "Wilder Kampf (Bär)",
	FeralCat = "Wilder Kampf (Katze)",
}
L.GEAR_UNITS = {
	["attack power"] = "Angriffskraft", ["ranged attack power"] = "Distanzangriffskraft",
	["spell damage"] = "Zauberschaden", healing = "Heilung", Stamina = "Ausdauer",
}
L.WEIGHT_GROUPS = {
	PRIMARY = "Primäre Attribute", WEAPONS = "Waffen", SPELLS = "Zauber", DEFENSE = "Verteidigung",
	RESISTANCE = "Widerstände",
}
L.STAT_NAMES = {
	STRENGTH = "Stärke", AGILITY = "Beweglichkeit", STAMINA = "Ausdauer", INTELLECT = "Intelligenz", SPIRIT = "Willenskraft",
	DPS = "Waffenschaden pro Sek.", ["RANGED DPS"] = "Distanzwaffenschaden pro Sek.", ["ATTACK POWER"] = "Angriffskraft",
	["RANGED ATTACK POWER"] = "Distanzangriffskraft", ["FERAL ATTACK POWER"] = "Angriffskraft in Tiergestalt", HIT = "Trefferchance",
	CRIT = "Kritischer Treffer", ["RANGED CRIT"] = "Kritischer Distanztreffer", HASTE = "Angriffstempo", ["RANGED HASTE"] = "Distanztempo",
	["SPELL POWER"] = "Schaden und Heilung", ["SPELL DAMAGE"] = "Zauberschaden", HEALING = "Heilung", ["SPELL HIT"] = "Zaubertrefferchance",
	["SPELL CRIT"] = "Kritischer Zaubertreffer", ["HOLY CRIT"] = "Kritischer Heiligtreffer", ["HOLY DAMAGE"] = "Heiligschaden",
	["FIRE DAMAGE"] = "Feuerschaden", ["FROST DAMAGE"] = "Frostschaden", ["NATURE DAMAGE"] = "Naturschaden",
	["SHADOW DAMAGE"] = "Schattenschaden", ["ARCANE DAMAGE"] = "Arkanschaden", ["SPELL PENETRATION"] = "Zauberdurchschlagskraft",
	MANA = "Mana", ["MANA PER 5"] = "Mana alle 5 Sek.", ["CASTING REGEN"] = "Regeneration beim Zaubern",
	ARMOR = "Rüstung", HEALTH = "Gesundheit", ["HEALTH PER 5"] = "Gesundheit alle 5 Sek.", DEFENSE = "Verteidigung", DODGE = "Ausweichen",
	PARRY = "Parieren", BLOCK = "Blocken", ["BLOCK VALUE"] = "Blockwert",
	["HOLY RESISTANCE"] = "Heiligwiderstand", ["FIRE RESISTANCE"] = "Feuerwiderstand",
	["NATURE RESISTANCE"] = "Naturwiderstand", ["FROST RESISTANCE"] = "Frostwiderstand",
	["SHADOW RESISTANCE"] = "Schattenwiderstand", ["ARCANE RESISTANCE"] = "Arkanwiderstand",
}
L.RECORD_START = "Aufzeichnung starten"
L.RECORD_STOP = "Aufzeichnung beenden"
L.RECORD_CLEAR = "Leeren"
L.RECORD_CLEAR_CONFIRM = "Alles bisher Aufgezeichnete verwerfen? Dies kann nicht rückgängig gemacht werden."
L.RECORD_STATUS_ON = "Aufzeichnung seit %s"
L.RECORD_STATUS_OFF = "Keine Aufzeichnung"
L.RECORD_COMBATLOG = "Kampflog in Dungeons schreiben"
L.RECORD_COMBATLOG_TIP = "Die Fähigkeiten der Bosse stammen aus dem Kampflog des Spiels. Das Kompendium schaltet es in Dungeons ein und beim Verlassen wieder aus; ein Log, das Ihr selbst gestartet habt, bleibt unberührt. Um es einzusenden, fügt die Logdatei auf der Seite des Log Readers Eurer Aufzeichnung hinzu (Kopieren zeigt den Link)."
L.RECORD_RECENT = "Zuletzt"
L.RECORD_NOTHING_YET = "Noch nichts erfasst. Betretet mit eingeschalteter Aufzeichnung einen Dungeon und kämpft, plündert und erledigt Quests wie immer."
L.RECORD_STARTED = "Aufzeichnung gestartet. /aegis record beendet sie."
L.RECORD_STOPPED = "Aufzeichnung beendet."
L.RECORD_LOG_STARTED = "Aufzeichnung gestartet."
L.RECORD_LOG_STOPPED = "Aufzeichnung beendet."
L.RECORD_LOG_CLEARED = "Aufzeichnungen gelöscht."
L.RECORD_LOG_ENTERED = "%s betreten."
L.RECORD_LOG_LEFT = "Dungeon verlassen."
L.RECORD_LOG_AREA = "Neues Gebiet: %s."
L.RECORD_LOG_PULL = "Kampf mit %s begonnen."
L.RECORD_LOG_KILL = "%s getötet."
L.RECORD_LOG_WIPE = "Bei %s gescheitert."
L.RECORD_LOG_LOOT = "Neue Gegenstände erbeutet: %d."
L.RECORD_LOG_QUEST_OFFERED = "Quest angeboten: %s."
L.RECORD_LOG_QUEST_DONE = "Quest abgegeben: %s."
L.RECORD_LOG_ENTRANCE = "Eingang zu %s aufgezeichnet."
L.RECORD_LOG_NO_ENTRANCE = "Eingang zu %s nicht aufgezeichnet: %s."
L.RECORD_NO_MAP = "das Spiel lieferte zu Beginn des Ladebildschirms keine Karte"
L.RECORD_NO_POSITION = "das Spiel lieferte zu Beginn des Ladebildschirms keine Position"
L.RECORD_IN_DUNGEON_MAP = "der Ladebildschirm begann auf der Karte eines Dungeons"
L.RECORD_LOG_COMBATLOG_ON = "Kampflog an: Logs\\%s."
L.RECORD_LOG_COMBATLOG_OFF = "Kampflog aus."

L.LEVEL_RANGE = "Stufe %d-%d"
L.LEVEL_ALL = "Alle Stufen"
L.LEVEL_BRACKET = "Stufe %d bis %d"
L.TRASH_DROPS = "Trash-Beute"
L.UNTESTED = "Noch nicht getestet"
L.UNTESTED_NOTE = "Noch nicht getestet: Was hier steht, stammt aus der Ankündigung von Blizzard und ist womöglich unvollständig. Durchlauft den Dungeon mit eingeschalteter Aufzeichnung (Reiter Aufzeichnen), um Bosse, Beute und Eingang zu ergänzen."
L.COMING_SOON = "Demnächst"
L.COMING_SOON_TEXT = "In WoW: Forever noch nicht geöffnet. Bosse, Beute und Karte kommen hinzu, sobald Spieler ihre Durchläufe aufzeichnen. Habt Ihr einen aufgezeichnet? Postet ihn auf unserem Discord, und Euer Name kommt zu den Mitwirkenden des Kompendiums."
L.COMING_SOON_PARTLY = "In WoW: Forever noch nicht geöffnet: Was hier steht, stammt aus der Ankündigung von Blizzard. Habt Ihr einen Durchlauf aufgezeichnet? Postet ihn auf unserem Discord, und Euer Name kommt zu den Mitwirkenden des Kompendiums."
L.DISCORD_COPY_HINT = "Klicken, dann Strg+C"
L.FOREVER_MARK = "Neu in WoW: Forever"
L.RECORD_LOG_VENDOR = "%s: %d Waren gespeichert, %d davon neu im Kompendium."
L.RECORD_CAUGHT = "%d erfasst, %d neu seit Eurer letzten Kopie"
L.RECORD_COPY = "Kopieren"
L.RECORD_AUTO = "In Dungeons automatisch aufzeichnen"
L.RECORD_AUTO_TIP = "Die Aufzeichnung startet von selbst, wenn Ihr einen Dungeon oder Schlachtzug betretet, und endet, wenn Ihr ihn verlasst. Eine Aufzeichnung, die Ihr selbst gestartet habt, wird nie für Euch beendet."
L.RECORD_RECORDER = "Aufzeichner"
L.RECORD_SEND = "Schickt sie uns"
L.RECORD_HELP_TEXT = "Klickt auf Kopieren und fügt den Text dann in unseren Discord ein:"
L.RECORD_CREDIT = "Mich nennen als:"
L.RECORD_CREDIT_TIP = "Der Name, unter dem Eure Aufzeichnungen bei den Mitwirkenden des Kompendiums genannt werden. Bleibt das Feld leer, ist es der Name Eures Charakters."
L.RECORD_CONTRIBUTORS = "Mitwirkende"
L.RECORD_CONTRIBUTORS_NONE = "Noch niemand: Seid der Erste."
L.RECORD_CONTRIBUTORS_FOOT = "Schickt uns Eure Aufzeichnung: Euer Name erscheint hier."
L.RECORD_COPY_TITLE = "Eure Aufzeichnung als Text"
L.RECORD_COPY_HINT = "Alles ist markiert: Drückt Strg+C und fügt es dann in unseren Discord ein."
L.RECORD_COPY_HINT_LOG = "Drückt Strg+C und fügt es dann zusammen mit Eurem Kampflog (%s, im Ordner Logs des Spiels) im Log Reader ein. Postet das Ergebnis auf unserem Discord."
L.RECORD_MORE_LOGS = "%s und %d ältere"
L.RECORD_BACK = "Zurück"
L.RECORD_CAUGHT_TITLE = "Was Ihr erfasst habt"
L.RECORD_ITEM = "Gegenstand %s"
L.RECORD_ONE_VISIT = "1 Besuch"
L.RECORD_VISITS = "%d Besuche"
L.RECORD_ENTRANCE_YES = "Eingang aufgezeichnet"
L.RECORD_ENTRANCE_NO = "Eingang noch nicht aufgezeichnet"
L.RECORD_AREAS = "%d Gebiete"
L.RECORD_KILLED = "Getötet: %s"
L.RECORD_KILLED_TIMES = "%s (%d)"
L.RECORD_DROPS = "Beute: %s neu, %s bereits im Kompendium"
L.RECORD_OFF = "Von %s"
L.RECORD_OFF_TRASH = "Von Trash-Gegnern"
L.RECORD_OFF_GROUP = "Von Eurer Gruppe geplündert"
L.RECORD_OFF_OBJECTS = "Von Truhen und Pflanzen"
L.RECORD_QUESTS = "Quests"
L.RECORD_QUEST_DONE = "abgegeben"
L.RECORD_NEW = "neu"
L.RECORD_QUARTERMASTERS = "Rüstmeister"
L.RECORD_WARES = "%s: %d Waren, %s neu"
L.RECORD_TRAVEL = "Reisepunkte: %d"
L.RECORD_MODELS = "Modelle: %d"
L.FOREVER_LINE = "Neu in WoW: Forever."
L.LOCATION_LINE = "Ort: %s"

-- The dungeon's round icon at the top of its left page: its tooltip, under the dungeon's name (2026-11-04; drafted, to be checked).
L.INSTANCE_ICON_OVERVIEW = "Klickt, um die Übersicht zu sehen."

L.TAB_OVERVIEW = OVERVIEW or "Übersicht"
L.TAB_LOOT = LOOT_NOUN or "Beute"
L.TAB_ABILITIES = ABILITIES or "Fähigkeiten"
L.TAB_MODEL = MODEL or "Modell"
L.TAB_QUESTS = QUESTS_LABEL or "Quests"
L.ALL_CLASSES = ALL_CLASSES or "Alle Klassen"
L.ALL_ARMOR = "Alle Rüstungsarten"
L.ALL_TYPES = "Alle Arten"
-- The loot pages' Type menu: the kinds of item, "All ..." atop the two with a submenu, and one of each.
L.LOOT_KIND = {
	EQUIPMENT = "Ausrüstung", RECIPE = "Rezepte", CONSUMABLE = "Verbrauchsgüter", MOUNT = "Reittiere", PET = "Haustiere",
	TOY = "Spielzeuge", BAG = "Taschen", TRADE = "Handwerkswaren", QUEST = "Questgegenstände", OTHER = "Sonstiges",
}
L.LOOT_KIND_ALL = { EQUIPMENT = "Gesamte Ausrüstung", RECIPE = "Alle Rezepte" }
L.LOOT_KIND_ONE = { MOUNT = "Reittier", PET = "Haustier", TOY = "Spielzeug" }
L.LOOT_RECIPE = "Rezept"
-- A loot row's type where the client cannot describe the item (2026-11-19; drafted, to be checked).
L.LOOT_QUEST_ITEM = "Questgegenstand"
L.LOOT_WORDS = {
	Alchemy = "Alchemie", Blacksmithing = "Schmiedekunst", Cooking = "Kochkunst", Enchanting = "Verzauberkunst",
	Engineering = "Ingenieurskunst", ["First Aid"] = "Erste Hilfe", Fishing = "Angeln",
	Leatherworking = "Lederverarbeitung", Tailoring = "Schneiderei", Book = "Buch", Blueprint = "Bauplan",
	Bag = "Tasche", ["Ammo Pouch"] = "Munitionsbeutel", Quiver = "Köcher", Arrow = "Pfeil", Bullet = "Kugel",
	Consumable = "Verbrauchbar", ["Food & Drink"] = "Essen & Trinken", Potions = "Tränke", Junk = "Plunder",
	Key = "Schlüssel", Other = "Sonstiges", Parts = "Teile", Reagent = "Reagenz", Weapon = "Waffe", Cloth = "Stoff",
	Leather = "Leder", Mail = "Schwere Rüstung", Plate = "Platte", Shield = "Schild", Idol = "Götze",
	Libram = "Buchband", Totem = "Totem", Axe = "Axt", Bow = "Bogen", Crossbow = "Armbrust", Dagger = "Dolch",
	["Fist Weapon"] = "Faustwaffe", Gun = "Schusswaffe", Mace = "Streitkolben", Polearm = "Stangenwaffe",
	Staff = "Stab", Sword = "Schwert", Wand = "Zauberstab",
}
L.LOOT_FAVORITES = "Favoriten"
L.LOOT_FAVORITES_ONLY = "Nur Favoriten"
L.LOOT_FAVORITE = "Zu Favoriten hinzufügen"
L.LOOT_UNFAVORITE = "Aus Favoriten entfernen"
L.LOOT_PINNED = "Angeheftet"
L.LOOT_ALL = "Beute"
L.LOOT_TRASH = "Dungeon-Trash"
L.LOOT_BOSSES_AND_RARES = "Alle Bosse und seltenen Gegner"
L.LOOT_BOSSES_AND_RARES_NOTE = "Beute der Bosse und seltenen Gegner des Dungeons, nicht vom Trash."
-- A Recipes page's row the bosses drop, and a row not seen dropping yet (2026-11-20; drafted, to be checked).
L.LOOT_ANY_BOSS = "Alle Bosse"
L.LOOT_ANY_BOSS_NOTE = "Beute der Bosse des Dungeons, nicht vom Trash."
L.LOOT_NOT_SEEN_NOTE = "Noch nicht als Beute gesehen."
L.DROPS_FROM_BOSS = "Beute von %s (%s)"
L.DROPS_FROM_TRASH = "Beute vom Trash (%s)"
L.DROPS_FROM_BOSSES = "Beute von %d Bossen (%s)"
L.DROPS_FROM_BOSSES_AND_RARES = "Beute von Bossen und seltenen Gegnern (%s)"
L.DROPS_FROM_ANY_BOSS = "Beute von Bossen (%s)"
L.DROPS_IN = "Beute in: %s"
L.DROPS_ALSO_IN = "Auch Beute in: %s"
L.LEGEND_CLICK_HIDE = "Klickt, um diese auf der Karte auszublenden."
L.LEGEND_CLICK_SHOW = "Ausgeblendet. Klickt, um diese wieder auf der Karte anzuzeigen."
-- The legend's Quest entry, the journal's own switch for its ! marks: what it does (2026-11-06; drafted, to be checked).
L.LEGEND_QUEST_TIP = "Die !-Markierungen des Kompendiums auf den Karten: Quests, die Ihr annehmen könnt, und graue, die noch nicht offen sind."
L.LEGEND_GAME_FILTER = "Der eigene Kartenfilter des Spiels, wie im Filtermenü der Karte: Laufende und abgabebereite Quests teilen sich einen."
L.LEGEND_GAME_FILTER_MENU = "Ein- und ausblenden im Filtermenü der Karte: %s."
L.PREPARE_TITLE = "Vor dem Aufbruch"
L.PREPARE_PROGRESS = "Ihr habt %d seiner %d Quests erledigt."
-- The same for a key with one quest (2026-10-30; drafted, to be checked).
L.PREPARE_PROGRESS_ONE = "Ihr habt seine Quest noch nicht erledigt."
L.PREPARE_HAVE = "Bereits in Eurem Besitz."
-- A chain of quests done, Before you go (2026-11-12; drafted, to be checked).
L.PREPARE_CHAIN_DONE = "Ihr habt seine Quests erledigt."
-- Before you go's line on a dungeon's overview, pointing to the Quests tab (2026-11-13; drafted, to be checked).
L.PREPARE_POINTER = "Vor dem Aufbruch: %d Hinweise, im Reiter Quests."
L.PREPARE_POINTER_ONE = "Vor dem Aufbruch: 1 Hinweis, im Reiter Quests."
-- The Play button beside the lore, which plays Spoken's recorded story; "Spoken" kept as it is (2026-11-13; drafted, to be checked).
L.SPOKEN_PLAY = "Geschichte abspielen"
L.SPOKEN_REPLAY = "Geschichte erneut abspielen"
L.SPOKEN_STOP = "Anhalten"
L.SPOKEN_BY = "Vorgelesen von Spoken."
L.SPOKEN_REQUIRES = "Benötigt Spoken"
L.SPOKEN_ABOUT_PLACE = "Liest die Geschichte dieses Ortes vor."
L.SPOKEN_ABOUT_BOSS = "Liest die Geschichte dieses Bosses vor."
L.SPOKEN_NO_STORY_PLACE = "Spoken hat keine aufgenommene Geschichte zu diesem Ort."
L.SPOKEN_NO_STORY_BOSS = "Spoken hat keine aufgenommene Geschichte zu diesem Boss."
-- Spoken's own story API says no, the reason not known (2026-11-14; drafted, to be checked).
L.SPOKEN_NO_STORY_YET = "Spoken hat hier noch keine Geschichte, die es abspielen kann."
L.SPOKEN_NEEDS_BOSS_VOICES = "Benötigt die Bossstimmen von Spoken, die nicht installiert sind."
L.SPOKEN_NEEDS_PLACE_VOICES = "Benötigt die Ortsstimmen von Spoken, die nicht installiert sind."
L.SPOKEN_OFF = "In den Einstellungen von Spoken ausgeschaltet."
L.SPOKEN_LOCKED_PLACE = "Spoken erzählt diese Geschichte, sobald du diesen Ort gefunden hast."
L.SPOKEN_LOCKED_BOSS = "Spoken erzählt diese Geschichte, sobald du diesem Boss begegnet bist."
L.QUESTS_DUNGEON = "Dungeonquests"
-- The same on a raid's Quests tab (2026-10-30; drafted, to be checked).
L.QUESTS_RAID = "Schlachtzugsquests"
-- The Quests tab's dropdown of the quests for the player's class alone (2026-11-03; drafted, to be checked).
L.QUESTS_CLASS = "Klassenquests"
L.TRASH = "Trash"
L.TRASH_DESCRIPTION = "Was die übrigen Kreaturen des Dungeons fallen lassen und wissenswert ist: seltene und epische Ausrüstung, Rezepte und Questgegenstände."
-- The recipes' entry in a dungeon's boss list, and its page (drafted, to be checked).
L.RECIPES = "Rezepte"
L.RECIPES_DESCRIPTION = "Die Rezepte, Pläne und Muster, die im Dungeon fallen, von seinen Bossen und seinen übrigen Kreaturen. Das eigene Rezept eines Bosses steht auch auf dessen Seite."
L.LOOT_BOSS_LINE = BOSS_INFO_STRING or "Boss: %s"
L.LOOT_FILTER_BAR = "Filter: %s"
L.LOOT_RETRIEVING = RETRIEVING_ITEM_INFO or "Gegenstandsinformationen werden abgerufen"
L.LOOT_NO_DATA = "Gegenstand %d"
L.LOOT_NO_DATA_TOOLTIP = "Der Server hat die Details dieses Gegenstands nicht gesendet. Vielleicht gibt es ihn noch nicht im Spiel."
L.LOOT_UNIDENTIFIED_TOOLTIP = "Noch nicht identifiziert: Seine Quelle nennt ihn, aber nicht seine Gegenstands-ID. Plündert ihn während einer Aufzeichnung, um ihn hinzuzufügen."
L.LOOT_TOOLTIP_PIN = "Rechtsklick, um diesen Gegenstand oben in dieser Liste anzuheften."
L.LOOT_TOOLTIP_UNPIN = "Rechtsklick zum Lösen."
L.LOOT_NONE = "Hierfür ist noch keine Beute bekannt."
L.LOOT_NO_MATCH = "Nichts hier passt zu den Filtern. Setzt sie mit dem X oben zurück."
L.ABILITY_LOADING = RETRIEVING_DATA or "Daten werden abgerufen..."
L.ABILITIES_NONE = "Für diese Begegnung sind noch keine Fähigkeiten bekannt. Zeichnet über den Reiter Aufzeichnen einen Durchlauf auf, um sie zu erfassen."
L.STATS_HIT = "Trifft %s"
L.STATS_TICK = "tickt %s"
L.STATS_FIRST = "erstmals nach %d Sek."
L.STATS_EVERY = "dann alle %s Sek."
L.QUEST_NONE = "Für Eure Fraktion sind in diesem Dungeon keine Quests bekannt."
L.QUEST_STATUS_READY = "Abgeschlossen: bereit zur Abgabe"
L.QUEST_STATUS_NEEDS = "Benötigt: %s"
L.QUEST_STATUS_LEVEL = "Benötigt Stufe %d"
L.QUEST_DESCRIPTION = QUEST_DESCRIPTION or "Beschreibung"
L.QUEST_START_ITEM = "Beginnt mit:"
L.QUEST_PARTS = "%s (%d Teile)"
-- A row for the quests of one chain that share a name: which of them its page shows (2026-11-04; drafted, to be checked).
L.QUEST_PART_OF = "Teil %d von %d"
-- One of them as a row of its own, in a chain: which part it is (2026-11-06; drafted, to be checked).
L.QUEST_PART_NAME = "%s (Teil %d)"
-- A step any one of several quests will do (2026-10-30; drafted, to be checked).
L.QUEST_STATUS_NEEDS_VERSION = "Benötigt eine der %d Fassungen von %s"
L.QUEST_STATUS_NEEDS_ONE_OF = "Benötigt eine davon: %s"
-- A quest given only while another is in the log (2026-11-03; drafted, to be checked).
L.QUEST_STATUS_NEEDS_IN_LOG = "Benötigt: %s im Questlog"
L.QUEST_OR = " oder "
L.QUEST_LIST_COMMA = ", "
L.QUEST_ONE_OF_VERSIONS = "Diese Quest gibt es in %d Fassungen. Jede davon genügt."
L.QUEST_ONE_OF_ANY = "Jede dieser Quests genügt."
L.QUEST_SHOW_START = "Anfang zeigen"
L.QUEST_SHOW_END = "Ende zeigen"
L.QUEST_PLACE_UNKNOWN = "Ort noch nicht bekannt. Nehmt diese Quest an oder gebt sie ab, während die Aufzeichnung läuft, um ihn hinzuzufügen."
L.QUEST_OFFERED_BY = "Quest vergeben von %s"
L.QUEST_HAND_IN_TO = "Abgeben bei %s"
L.QUESTMAP_DUNGEON_QUEST = "Dungeonquest: %s"
L.QUESTMAP_RAID_QUEST = "Schlachtzugsquest: %s"
L.QUESTMAP_LEFT_CLICK = "Linksklick, um sie im Kompendium zu öffnen"
L.QUESTMAP_WAYPOINT_SET = "Wegpunkt für %s gesetzt."
L.QUESTMAP_WAYPOINT_SET_IN = "Wegpunkt für %s gesetzt, in %s."
L.WAYPOINT_OFFER = "Klickt auf %s, um den Wegpunkt zu setzen."
L.QUESTMAP_ONE_OF = "Nicht immer am selben Ort: an einer von %d Stellen."
-- What is looted, used or explored for a quest inside a dungeon, on its mark's tooltip, after the game's dash: the
-- item to take, the same for a name with no "the" in English, the thing to use, a place to explore (2026-11-11;
-- translation drafted, to be checked).
L.QUESTMAP_OBJECTIVE_TAKE = "Mitnehmen: %s"
L.QUESTMAP_OBJECTIVE_TAKE_NAMED = "Mitnehmen: %s"
L.QUESTMAP_TITLE_QUOTED = "„%s“"
L.QUESTMAP_OBJECTIVE_USE = "Benutzen: %s"
L.QUESTMAP_OBJECTIVE_EXPLORE = "Diesen Ort erkunden"
-- At the Drowned City's tablets of I'lalai, a rubbing with the hide and charcoal (2026-11-12; drafted, to be checked).
L.QUESTMAP_OBJECTIVE_RUBBING = "Mit Fell und Kohle eine Abreibung anfertigen"
-- A Matrix Punchograph's step, what goes in, then what comes out, in short words ("Yellow > Blue"), and the punch
-- cards' colors, as the cards' own names in the language have them (2026-11-12, the owner's "Blue > Red"; drafted, to
-- be checked); where what goes in drops (2026-11-12; drafted, to be checked).
L.QUESTMAP_OBJECTIVE_STEP = "%s > %s"
L.QUESTMAP_CARD_WHITE = "Weiß"
L.QUESTMAP_CARD_YELLOW = "Gelb"
L.QUESTMAP_CARD_BLUE = "Blau"
L.QUESTMAP_CARD_RED = "Rot"
L.QUESTMAP_CARD_PRISMATIC = "Prisma"
L.QUESTMAP_NOTE_INPUT_DROPS = "%s erbeutet man von Gegnern in diesen Tunneln."
-- A machine used again once its quest is done: it takes another of what it cleans (2026-11-12; drafted, to be checked).
L.QUESTMAP_REPEAT_AGAIN = "Wiederholbar: Legt ein weiteres Exemplar von %s ein."
-- What a boss is to a quest, on his tooltip under his quest badge: one to kill, one that drops what the quest needs,
-- the same for a name with no "the" in English, one whose drop starts the quest; who gives or takes it there,
-- himself or by name; a quest's mob more than a boss (2026-11-11; translation drafted, to be checked).
L.QUEST_BADGE_KILL = "Für diese Quest töten"
L.QUEST_BADGE_DROPS = "Lässt fallen: %s"
L.QUEST_BADGE_DROPS_NAMED = "Lässt fallen: %s"
L.QUEST_BADGE_STARTS = "Lässt fallen: %s (beginnt eine Quest)"
L.QUEST_BADGE_STARTS_NAMED = "Lässt fallen: %s (beginnt eine Quest)"
L.QUEST_BADGE_GIVES = "Vergibt diese Quest"
L.QUEST_BADGE_GIVES_WHO = "%s vergibt diese Quest hier"
L.QUEST_BADGE_TAKES = "Hier abgeben"
L.QUEST_BADGE_TAKES_WHO = "Hier abgeben bei: %s"
L.QUEST_TARGET = "Questziel"
L.MAP_ONE_OF = "Nicht immer am selben Ort: an einer von %d Stellen."
L.QUEST_REWARDS = REWARDS or "Belohnungen"
L.QUEST_YOU_RECEIVE = YOU_RECEIVE or "Ihr erhaltet:"
L.QUEST_XP = "%s Erfahrung"
-- XP that is only the original game's number, not yet confirmed on Forever: a note after it, and
-- its tooltip (2026-10-30; drafted, to be checked).
L.QUEST_XP_ORIGINAL = "(ursprüngliches Spiel)"
L.QUEST_XP_ORIGINAL_TIP = "So viel gab die Quest im ursprünglichen Spiel. Forever gibt vielleicht mehr. Auf Forever ist das noch nicht geprüft. Gebt sie ab, während die Aufzeichnung läuft, um hinzuzufügen, was Forever gibt."
L.QUEST_REPUTATION = "%d Ruf bei %s"
L.QUEST_CHOOSE = REWARD_CHOICES or "Ihr könnt eine dieser Belohnungen auswählen:"
L.QUEST_ALSO = REWARD_ITEMS or "Außerdem erhaltet Ihr:"
L.REP_REWARDS = "%d Belohnungen"
L.REP_REWARD_ONE = "1 Belohnung"
L.REP_ALL_REWARDS = "Belohnungen"
-- The group for wares that need no standing (2026-11-12; drafted, to be checked)
L.REP_ANY_STANDING = "Jeder Ruf"
L.REP_UNKNOWN = "Noch nicht begegnet"
L.REP_CARD_CLICK = "Klickt, um die Belohnungen zu sehen."
L.REP_YOUR_STANDING = "Euer Ruf: %s"
L.REP_NOT_MET = "Ihr seid dieser Fraktion noch nicht begegnet."
L.REP_PROGRESS = "%s / %s"
L.REP_QUARTERMASTER = "Rüstmeister: %s"
L.REP_CAPTURE = "Händler erfassen"
L.REP_CAPTURE_TIP = "Geht zum Rüstmeister einer Fraktion, öffnet seinen Laden und klickt dann hierauf. Alles, was er verkauft, wird gespeichert: der Preis jeder Ware, alle weiteren Kosten und der benötigte Ruf. Die Waren kommen sofort zu den Belohnungen ihrer Fraktion und werden mitgeschickt, wenn Ihr im Reiter Aufzeichnen auf Kopieren klickt."
L.REP_CAPTURE_READY = "Laden geöffnet: Klickt auf Händler erfassen."
L.REP_CAPTURE_HINT = "Öffnet den Laden eines Rüstmeisters, um seine Waren zu erfassen."
L.REP_CAPTURED = "%s: %d Waren für %s, %d neu."
L.REP_CAPTURED_NONE = "%s: %d Waren gespeichert; keine erfordert Ruf."
L.REP_CAPTURED_UNKNOWN = "%s: %d Waren erfordern Ruf bei einer Fraktion, die das Spiel nicht nennt; gespeichert, bis eine Ware sie nennt."
L.REP_NOT_CAPTURED = "Noch nicht erfasst"
L.REP_NOT_CAPTURED_TIP = "Den Rüstmeister dieser Fraktion hat noch niemand erfasst."
L.REP_NOT_CAPTURED_TEXT = "Den Rüstmeister dieser Fraktion hat noch niemand erfasst. Sucht einen auf, öffnet seinen Laden und klickt im Reiter Ruf auf Händler erfassen. Postet dann Eure Aufzeichnung auf unserem Discord. Euer Name kommt zu den Mitwirkenden des Kompendiums."
L.REP_LISTED_TIP = "Die Belohnungen stammen aus den Gegenstandsdaten des Spiels und wurden noch nicht bei einem Rüstmeister bestätigt."
L.REP_LISTED_TEXT = "Diese Belohnungen stammen aus den Gegenstandsdaten des Spiels, noch nicht von einem Rüstmeister. Daher haben sie keine Preise, und einige werden womöglich gar nicht verkauft. Sucht einen Rüstmeister dieser Fraktion auf, öffnet seinen Laden und klickt im Reiter Ruf auf Händler erfassen. Postet dann Eure Aufzeichnung auf unserem Discord. Euer Name kommt zu den Mitwirkenden des Kompendiums."
L.REP_COMING_SOON_TEXT = "Neu in WoW: Forever und noch nicht erfasst. Sobald die Fraktion im Spiel ist, sucht ihren Rüstmeister auf, öffnet seinen Laden und klickt im Reiter Ruf auf Händler erfassen. Postet dann Eure Aufzeichnung auf unserem Discord."
-- The Reputation tab's Vendors: a page for each currency a vendor takes for wares that need no standing (2026-11-12; drafted, to be checked).
L.REP_VENDORS = "Händler"
L.CURRENCY_YOU_HAVE = "Im Besitz: %s"
L.CURRENCY_VENDOR = "Händler: %s"
L.CURRENCY_CARD_CLICK = "Klickt, um die Waren zu sehen."
L.REP_CAPTURED_CURRENCY = "%s: %d Waren gespeichert, verkauft für %s."
-- Where Carved Centaur Totems come from, on its Vendors card and page (2026-11-13; drafted, to be checked: %s is the item's name as the client writes it; the quests keep their English names, their names in this language not known).
L.CURRENCY_NOTE_CENTAUR_TOTEM = "%s: Zentauren jedes Clans in Desolace lassen sie fallen, und die Quest „Khan Hratha“ gibt zehn. Die Quest „Carved Centaur Totems“ verlangt fünf davon, von der Allianz wie von der Horde."
L.MAP_SHOW = ENCOUNTER_JOURNAL_SHOW_MAP or "Karte anzeigen"
L.MAP_SHOW_UNEXPLORED = "Unerforschte Gebiete anzeigen"
L.OPTIONS_UNEXPLORED_TIP = "Schattiert auf der Weltkarte die Teile einer Zone, die Ihr noch nicht erkundet habt."
-- The map legend's Fog of War switch, the last of Movement's, and its tooltip (2026-11-11; translation drafted, to be checked).
L.LEGEND_FOG = "Kriegsnebel"
L.LEGEND_FOG_TOOLTIP = "Verbirgt die Teile einer Zone, die Ihr noch nicht erkundet habt, und die Teile einer Dungeonkarte, die Eure Gruppe noch nicht freigelegt hat."
L.LEGEND_FOG_ZONE_HIDDEN = "Die Karte zeigt nur die Teile dieser Zone, die Ihr erkundet habt."
L.LEGEND_FOG_ZONE_SHOWN = "Auch die Teile dieser Zone, die Ihr noch nicht erkundet habt, werden angezeigt, etwas dunkler."
L.LEGEND_FOG_ZONE_SHOW = "Klickt, um die unerkundeten Teile anzuzeigen."
L.LEGEND_FOG_ZONE_HIDE = "Klickt, um nur die erkundeten Teile anzuzeigen."
L.LEGEND_FOG_DUNGEON_ON = "Nebel bedeckt die Teile dieser Karte, die Ihr noch nicht freigelegt habt. Jeder Boss, den Eure Gruppe besiegt, macht seine Räume frei."
L.LEGEND_FOG_DUNGEON_OFF = "Der Nebel ist aus: Die ganze Karte ist zu sehen."
L.LEGEND_FOG_DUNGEON_CLEARED = "Der Nebel hat sich gelichtet: Die ganze Karte ist zu sehen."
L.LEGEND_FOG_DUNGEON_LIFT = "Klickt, um den Nebel auszuschalten."
L.LEGEND_FOG_DUNGEON_LAY = "Klickt, um den Nebel einzuschalten."
L.LEGEND_FOG_ADVENTURE = "Im Abenteuermodus nicht abschaltbar."
L.LEGEND_FOG_NONE = "Kein Kriegsnebel auf dieser Karte."
L.LEGEND_FOG_ZONE_EXPLORED = "Ihr habt diese ganze Zone erkundet."
L.MAP_FILTER_QUESTS = "Verfügbare Quests"
L.MAP_FILTER_DUNGEONS = "Dungeoneingänge"
L.MAP_FILTER_RAIDS = "Schlachtzugseingänge"
L.MAP_FILTER_FLIGHT = "Flugpunkte"
L.MAP_FILTER_CAVES = "Höhleneingänge"
L.MAP_FILTER_TRANSPORT = "Schiffe, Zeppeline, Tiefenbahn und Portale"
L.MAP_PIN_OPEN = "Klickt, um es im Kompendium zu öffnen."
L.MAP_DEFEATED = DUNGEON_ENCOUNTER_DEFEATED or "Besiegt"
L.MAP_FOG_HINT = "Besiegt ihn, um den Nebel hier zu lichten."
L.MAP_UNMET_HINT = "Noch nicht begegnet."
L.MAP_LEVEL = "Stufe %d"
L.MAP_FLOOR = "Ebene %d"
L.MAP_GO_TO = "Gehe zu: %s"
-- Under a way between floors, where two lead to one floor (the Drowned City's), where it comes out
-- (2026-11-17; drafted, to be checked).
L.MAP_WAY_OUT_SOUTHWEST = "Kommt am Südwestende heraus"
L.MAP_WAY_OUT_NORTHEAST = "Kommt am Nordostende heraus"
L.MAP_WAY_OUT_DEEP_ARCHIVES = "Kommt in den Tiefenarchiven heraus"
L.MAP_WAY_OUT_CENTRAL_POOL = "Kommt im zentralen Becken heraus"
L.MAP_YOU_ARE_HERE = "Ihr seid hier"
L.ENTRANCE_DUNGEON = LFG_TYPE_DUNGEON or "Dungeon"
L.ENTRANCE_RAID = LFG_TYPE_RAID or "Schlachtzug"
L.ENTRANCE_DUNGEONS = DUNGEONS or "Dungeons"
L.ENTRANCE_RAIDS = RAIDS or "Schlachtzüge"
L.ENTRANCE_LEFT_CLICK = "Linksklick, um das Dungeonkompendium zu öffnen"
L.ENTRANCE_CHOOSE_LEFT_CLICK = "Linksklick, um auszuwählen, was im Dungeonkompendium geöffnet werden soll"
L.ENTRANCE_RIGHT_CLICK = "Rechtsklick, um einen Wegpunkt zu setzen"
L.ENTRANCE_WAYPOINT_SET = "Wegpunkt zum Eingang von %s gesetzt."
L.ENTRANCE_VIA = "Das Portal liegt weiter unten, in %s: Steigt am Höhleneingang hinab."
L.ENTRANCE_WAYPOINT_VIA = "Wegpunkt zum Abstieg nach %s gesetzt, für %s."
L.CAVE_LABEL = "Höhleneingang"
L.BUILDING_LABEL = "Eingang"
L.ENTRANCE_VIA_BUILDING = "Sein Portal liegt drinnen, in %s: Geht am Eingang hinein."
L.CAVE_LEADS_TO = "Der Weg nach %s"
L.CAVE_LEFT_CLICK = "Linksklick, um die Karte von %s zu sehen"
L.CAVE_WAYPOINT_SET = "Wegpunkt zum Abstieg nach %s gesetzt."
L.FLIGHT_POINT = MAP_LEGEND_FLIGHTPOINT or "Flugpunkt"
L.CLICK_FOR_WAYPOINT = "Klickt, um einen Wegpunkt zu setzen"
L.FLIGHT_WAYPOINT_SET = "Wegpunkt zum Flugmeister in %s gesetzt."
L.TRAVEL_KINDS = { boat = "Schiff", zeppelin = "Zeppelin", airship = "Luftschiff", tram = "Tiefenbahn", portal = "Portal" }
L.TRAVEL_FACTIONS = { Alliance = FACTION_ALLIANCE or "Allianz", Horde = FACTION_HORDE or "Horde" }
L.TRAVEL_ROUTE = "%s nach %s"
L.TRAVEL_AND = "%s und %s"
L.TRAVEL_ROUTE_NOTE = "%s: %s"
L.TRAVEL_HELP = "Stellt Euch an einen Anleger, einen Zeppelinturm, eine Bahn oder ein Portal und gebt /aegis travel boat (oder zeppelin, airship, tram, portal) ein, gefolgt vom Ziel, z. B. /aegis travel boat Auberdine. Fügt am Ende alliance, horde oder neutral hinzu, um anzugeben, wem es dient, und in Klammern eine Notiz, wer es benutzen darf, z. B. /aegis travel portal Dalaran (nur Himmelsgeborene). /aegis travel list zeigt, was gespeichert ist; /aegis travel undo nimmt den letzten Eintrag zurück."
L.TRAVEL_NO_POSITION = "Das Spiel liefert hier keine Position, daher wurde nichts gespeichert."
L.TRAVEL_SAVED = "%s bei %s gespeichert. /aegis travel undo nimmt es zurück."
L.TRAVEL_UNDONE = "%s bei %s zurückgenommen."
L.TRAVEL_NOTHING = "Nichts zum Zurücknehmen."
L.TRAVEL_LIST_EMPTY = "Noch keine Reisepunkte gespeichert. Gebt /aegis travel ein, um zu erfahren, wie es geht."
L.TRAVEL_LIST_LINE = "%d. %s bei %s (Karte %d, %.4f, %.4f)"
L.TRAVEL_WAYPOINT_SET = "Wegpunkt zu %s gesetzt."
L.LEGEND_TRANSPORT = "Transportmittel"
L.LEGEND_TRANSPORT_TOOLTIP = "Schiffe, Zeppeline, die Tiefenbahn und Portale. Blau dient der Allianz, Rot der Horde, Gold allen."
L.LEGEND_CAVE_TOOLTIP = "Der Weg in eine Höhle, wo der Eingang eines Dungeons liegt. Klickt auf der Karte darauf, um hineinzusehen."
L.LEGEND_BUILDING_TOOLTIP = "Der Weg in ein Gebäude, in die Hallen eines Berges oder auf eine Ebene unterhalb des Gebiets, wo der Eingang eines Dungeons liegt. Klickt auf der Karte darauf, um hineinzusehen."
L.SEARCH_SHOW_ALL = SEARCH_RESULTS_SHOW_COUNT or "Alle %d Ergebnisse anzeigen"
L.SEARCH_RESULTS = ENCOUNTER_JOURNAL_SEARCH_RESULTS or "Suchergebnisse für „%s“ (%d)"
L.SEARCH_TYPE_BOSS = "Begegnung"
L.SEARCH_TYPE_ABILITY = "Fähigkeit"
L.SEARCH_TYPE_ITEM = "Gegenstand"
L.SEARCH_TYPE_QUEST = "Quest"
L.SEARCH_TYPE_FACTION = FACTION or "Fraktion"
L.MAP_PIN_CLEAR = "Klickt, um diese Markierung zu entfernen."
L.MAP_PIN_COMBAT = "Die Karte kann im Kampf nicht geöffnet werden."
L.GAMEPAD_HUD_UP = "Verlasst zuerst den HUD-Modus der Gamepad-Oberfläche und versucht es dann erneut."
L.MAP_PIN_IN_ZONE = "%s ist auf der Karte von %s markiert."
L.MAP_LEVEL_LINK_CLICK = "Linksklick, um die Karte dieser Ebene zu sehen"
-- A place worth knowing on a dungeon's map (UI/DungeonMap.lua's MapSpot): its kind's name, and the Drowned City's
-- hidden chest's line under it (2026-11-17; drafted, to be checked).
L.MAP_SPOT_CHEST = "Versteckte Truhe"
L.MAP_SPOT_DROWNED_CHEST = "Auf dem Bootswrack, nach dem Kampf gegen Min'loth die Schlange. Sie ist nicht verschlossen: Jeder kann sie öffnen und findet darin zufällige Gegenstände und Materialien."
L.DOOR_SPIRE_ONE_INSTANCE = "Die Untere und die Obere Schwarzfelsspitze sind eine Instanz mit einem Eingang."
L.DOOR_SPIRE_LOWER = "Untere Schwarzfelsspitze: bis zu 10 Spieler, ihre Quests lassen sich aber nur in einer Gruppe von höchstens 5 abschließen."
L.DOOR_SPIRE_UPPER = "Obere Schwarzfelsspitze: weiter drinnen, hinter einer versiegelten Tür, für die Ihr das Siegel des Aufstiegs braucht. Bis zu 10 Spieler."

L.RARE_SUFFIX = " (Selten)"
L.AND_MORE = "und %d weitere"
L.BULLET_AREA = "Anzutreffen in %s."
L.BULLET_RARE = "Ein seltener Gegner: Nicht jeder Durchlauf trifft auf ihn."
L.BULLET_SUMMONED = "Ein versteckter Boss, den Ihr selbst beschwört: Die Notiz oben erklärt, wie."
-- The same where his note names several bosses, not a hidden boss (2026-11-19; "summon" since 2026-11-20;
-- drafted, to be checked).
L.BULLET_CALLED_UP = "Ein Boss, den Ihr selbst beschwört: Die Notiz oben erklärt, wie."
-- A quest's mob, on the map only, on his page (2026-11-11; translation drafted, to be checked).
L.BULLET_QUEST_TARGET = "Ein Questziel, keiner der Bosse des Dungeons."
L.BULLET_LEVEL = "Eine Begegnung der Stufe %d."
L.BULLET_ABILITIES = "Beim Wirken beobachtet: %s."
L.BULLET_LOOT = "Beute: %d Gegenstände, darunter %s."
L.BULLET_ADDS = "Begleitet von %s."
L.ADD_DESCRIPTION = "Kämpft an der Seite von %s."
L.BULLET_NOTHING_YET = "Über diese Begegnung ist noch nichts bekannt."

-- The German client's classic "Equip:" wordings (drafted; check against items in game).
L.EQUIP_PATTERNS = {
	-- Bonuses against undead only, and effects on being struck or on a hit: worth nothing.
	{ "untot", false },
	{ "kritisch.-heilig.-um {n}", "HOLY CRIT" },
	{ "heilig.-kritisch.-um {n}", "HOLY CRIT" },
	{ "kritisch.-zauber.-um {n}", "SPELL CRIT" },
	{ "zauber.-kritisch.-um {n}", "SPELL CRIT" },
	{ "kritisch.-distanz.-um {n}", "RANGED CRIT" },
	{ "distanz.-kritisch.-um {n}", "RANGED CRIT" },
	{ "kritisch.-fernkampf.-um {n}", "RANGED CRIT" },
	{ "fernkampf.-kritisch.-um {n}", "RANGED CRIT" },
	{ "kritisch.-treffer.-um {n}", "CRIT" },
	{ "zauber.-treffen.-um {n}", "SPELL HIT" },
	{ "trefferchance.-zauber.-um {n}", "SPELL HIT" },
	{ "zaubertreffer.-um {n}", "SPELL HIT" },
	{ "trefferchance.-um {n}", "HIT" },
	{ "chance.-zu treffen.-um {n}", "HIT" },
	{ "untot.-um bis zu", false },
	{ "schaden und.-heilung.-um bis zu {n}", { "SPELL POWER", "HEALING" } },
	{ "heilung und.-schaden.-um bis zu {n}", { "SPELL POWER", "HEALING" } },
	{ "heilung.-um bis zu {n}", "HEALING" },
	{ "heiligzauber.-um bis zu {n}", "HOLY DAMAGE" },
	{ "feuerzauber.-um bis zu {n}", "FIRE DAMAGE" },
	{ "frostzauber.-um bis zu {n}", "FROST DAMAGE" },
	{ "naturzauber.-um bis zu {n}", "NATURE DAMAGE" },
	{ "schattenzauber.-um bis zu {n}", "SHADOW DAMAGE" },
	{ "arkanzauber.-um bis zu {n}", "ARCANE DAMAGE" },
	{ "magische.-schaden.-um bis zu {n}", "SPELL DAMAGE" },
	{ "zauber.-schaden.-um bis zu {n}", "SPELL DAMAGE" },
	{ "{n}%%.-mana%-?regeneration", "CASTING REGEN" },
	{ "magiewiderst.-um {n}", "SPELL PENETRATION" },
	{ "zauberdurchschlag.-um {n}", "SPELL PENETRATION" },
	{ "angriffskraft im kampf gegen", false },
	{ "angriffskraft.-gegen", false },
	{ "^%+{n} distanz%-?angriffskraft", "RANGED ATTACK POWER" },
	{ "^%+{n} fernkampf%-?angriffskraft", "RANGED ATTACK POWER" },
	{ "distanz%-?angriffskraft.-um {n}", "RANGED ATTACK POWER" },
	{ "fernkampf%-?angriffskraft.-um {n}", "RANGED ATTACK POWER" },
	{ "^%+{n} angriffskraft.-katze", "FERAL ATTACK POWER" },
	{ "angriffskraft.-katze.-um {n}", "FERAL ATTACK POWER" },
	{ "angriffskraft um {n}.-katze", "FERAL ATTACK POWER" },
	{ "angriffskraft.-um {n}", "ATTACK POWER" },
	{ "%+{n} angriffskraft", "ATTACK POWER" },
	{ "alle 5 sek.-{n}%D-mana", "MANA PER 5" },
	{ "{n} mana.-5 sek", "MANA PER 5" },
	{ "alle 5 sek.-{n}%D-gesundheit", "HEALTH PER 5" },
	{ "stellt.-{n}%D-gesundheit", "HEALTH PER 5" },
	{ "verteidigung %+{n}", "DEFENSE" },
	{ "verteidigung.-um {n}", "DEFENSE" },
	{ "aus%a*weich.-um {n}", "DODGE" },
	{ "parier.-um {n}", "PARRY" },
	{ "blocken.-um {n}", "BLOCK" },
	{ "blockchance.-um {n}", "BLOCK" },
	{ "blockwert[^u].-um {n}", "BLOCK VALUE" },
	{ "angriffstempo.-um {n}", "HASTE" },
	{ "angriffsgeschwindigkeit.-um {n}", "HASTE" },
}

-- The rooms inside dungeons, as the client names them where the player stands: "You are
-- here" and a wing's areas match these (Core/Areas.lua). Unconfirmed ones are listed in
-- the translation's to-check list.
L.AREA_NAMES = {
	-- The Drowned City's areas (Data/Authored/Upcoming.lua's floors: Abyssal Dais, Altar of the Serpent, Deep
	-- Archives, Eternal Amphitheater, the Flooded Shrine (the central pool) and Sunken Hollow on the city's map,
	-- Ataal'Byzal and Atal'Byzal on Atal'byzal), as a player's English recording (2026-11-13) and the client's
	-- English tables (2026-11-17) name them: drafted, to be checked (GetSubZoneText there)
	["Abyssal Dais"] = "Abyssisches Podest",
	["Aku'mai's Lair"] = "Aku'mais Hort",
	-- Alcaz Prison's two names for its rooms (Data/Authored/Upcoming.lua's floors: Alcaz Prison on the first,
	-- Maximum Security on the second), as the client's English tables name them (2026-11-17): drafted, to be checked
	-- (GetSubZoneText there); Alcaz Prison as the dungeon's name in this language
	["Alcaz Prison"] = "Gefängnis von Alcaz",
	-- (the Drowned City's, drafted: see Abyssal Dais)
	["Altar of the Serpent"] = "Altar der Schlange",
	["Anvilmar's Rest"] = "Ambossars Ruhestätte",
	-- (the Drowned City's shrine: its rooms' area and the building's own name, drafted: see Abyssal Dais)
	["Ataal'Byzal"] = "Ataal'Byzal",
	["Atal'Byzal"] = "Atal'Byzal",
	["Athenaeum"] = "Athenaeum",
	-- Blackmaw Hold's areas (Data/Authored/Upcoming.lua's floors: Blackmaw Grove, Blackmaw Stillwater, Bonesnout's
	-- Thicket, the Festering Grotto and the depths' four levels), by the labels on Santiago Reyes's maps, not read in
	-- game yet: drafted, to be checked (GetSubZoneText there). The client's tables keep the hold's own names in
	-- encrypted rows
	["Blackmaw Grove"] = "Schwarzschlundhain",
	["Blackmaw Stillwater"] = "Stillwasser des Schwarzschlunds",
	["Blackrock Stadium"] = "Schwarzfelsstadion",
	["Blackrock Stronghold"] = "Schwarzfelsfestung",
	-- (Blackmaw Hold's, drafted: see Blackmaw Grove)
	["Bonesnout's Thicket"] = "Bonesnouts Dickicht",
	-- City of Dalaran's rooms (Data/Authored/CityOfDalaran.lua's floors: Cantrips & Crows, City of
	-- Dalaran, Dalaran, Magus Commerce Exchange, Path of Renewal, Presage Plaza, Runeweaver Square, Sewer,
	-- The Eventide, The Purple Parlor, The Underbelly, The Violet Citadel, The Violet Hold): the city's
	-- own buildings name them. Most have no area id; Dalaran (279, 16558), City of Dalaran (16544, 16560)
	-- and The Eventide (17824) have, not baked yet: a scan (/aegis areas, Dev/bake_area_ids.py) can
	-- replace those three. By the names the game's Dalaran has in this language, the newest of four
	-- copies of a list of them, to be checked in game (GetSubZoneText there).
	-- Here City of Dalaran reads as Dalaran: both are on the city's floor, and the map reads only the
	-- room's name in there (roomsOnly), so the zone's name, where no room is named, never turns it
	["Cantrips & Crows"] = "Zur Zauberkrähe",
	["Capital Gardens"] = "Hauptstadtgärten",
	["Cavern of Mists"] = "Nebelhöhle",
	["Chamber of Atonement"] = "Kammer der Buße",
	["Chamber of Battle"] = "Kammer der Schlacht",
	["Chapel Gardens"] = "Kapellengärten",
	["City of Dalaran"] = "Dalaran",
	-- The Cleft of Shadow (Data/Authored/MicroDungeons.lua) has no area id, so it is found by this
	-- name alone, to be checked in game (GetSubZoneText in the Cleft): LibBabble-SubZone's root file's
	-- name (rev 238), as the other micro dungeons' are; the file the lib loads (Locale/deDE.lua, rev
	-- 258) has the newer "Kluft der Schatten", as the journal's Ragefire Chasm has it
	["Cleft of Shadow"] = "Die Kluft der Schatten",
	["Court of the Highborne"] = "Hof der Hochgeborenen",
	["Crag of the Everliving"] = "Klippe des Ewiglebenden",
	["Crusader's Armory"] = "Waffenkammer der Kreuzfahrer",
	["Crusader's Chapel"] = "Kapelle der Kreuzfahrer",
	["Crusaders' Square"] = "Platz der Kreuzfahrer",
	["Dalaran"] = "Dalaran",
	["Dark Iron Ingress"] = "Zugang der Dunkeleisen",
	-- (the Drowned City's, drafted: see Abyssal Dais)
	["Deep Archives"] = "Tiefenarchive",
	["Defias Hideout"] = "Versteck der Defias",
	-- (Blackmaw Hold's, drafted: see Blackmaw Grove)
	["Depths of Forbidden Magic"] = "Tiefen der Verbotenen Magie",
	["Depths of the Burrow"] = "Tiefen des Baus",
	["Depths of the Elders"] = "Tiefen der Ältesten",
	["Depths of the Fallen Grove"] = "Tiefen des Gefallenen Hains",
	["Dig One"] = "Grabung Eins",
	["Dragonspire Hall"] = "Halle der Drachenspitze",
	["Dreamer's Rock"] = "Fels des Träumers",
	["Elders' Square"] = "Platz der Ältesten",
	["Eldre' Thalas"] = "Eldre'Thalas",
	["Eldreth Row"] = "Eldrethgasse",
	["Engineering Labs"] = "Ingenieurslabore",
	-- (the Drowned City's, drafted: see Abyssal Dais)
	["Eternal Amphitheater"] = "Ewiges Amphitheater",
	["Excavation Center"] = "Ausgrabungszentrum",
	-- (Blackmaw Hold's, drafted: see Blackmaw Grove)
	["Festering Grotto"] = "Eiternde Grotte",
	["Festival Lane"] = "Festgasse",
	-- (the Drowned City's, drafted: see Abyssal Dais)
	["Flooded Shrine"] = "Überfluteter Schrein",
	["Footman's Armory"] = "Waffenkammer der Fußsoldaten",
	-- City of Dalaran's city rooms a player's recording read (Data/Authored/CityOfDalaran.lua, 2026-11-13: Forge of
	-- Fate, Talismanic Textiles, Tempered Tomes, The Atrium of Fortune, The Silver Enclave, Violet Plates and
	-- Framing), with no area id. Drafted, to be checked in game (GetSubZoneText there)
	["Forge of Fate"] = "Schmiede des Schicksals",
	["Forgewright's Tomb"] = "Grab des Schmiedemeisters",
	["Forlorn Cloister"] = "Verlassener Kreuzgang",
	["Gallery of Treasures"] = "Galerie der Schätze",
	["Goblin Foundry"] = "Goblingießerei",
	["Gordok Commons"] = "Gordokplatz",
	["Hall of Champions"] = "Halle der Champions",
	["Hall of the Keepers"] = "Halle der Bewahrer",
	["Halycon's Lair"] = "Halycons Hort",
	["Honor's Tomb"] = "Grab der Ehre",
	["Hordemar City"] = "Stadt Hordemar",
	["Huntsman's Cloister"] = "Kreuzgang des Jägers",
	["King's Square"] = "Königsplatz",
	["Launch Bay"] = "Startbucht",
	-- Three rooms of Gnomeregan's way in (Data/Authored/SubMaps.lua), the Loading Room, the Train
	-- Depot and the Workshop Entrance, have no area id, so they are found by these names alone, to be
	-- checked in game (GetSubZoneText there): LibBabble-SubZone's, the same in its root file (rev 238)
	-- and in the file the lib loads (rev 258)
	["Loading Room"] = "Laderaum",
	["Magus Commerce Exchange"] = "Handelsmarkt der Magier",
	["Market Row"] = "Marktgasse",
	-- (Alcaz Prison's lower floor, drafted: see Alcaz Prison)
	["Maximum Security"] = "Hochsicherheitstrakt",
	["Mast Room"] = "Mastraum",
	["Mok'Doom"] = "Mok'Doom",
	["Moonshrine Ruins"] = "Ruinen des Mondschreins",
	["Moonshrine Sanctum"] = "Sanktum des Mondschreins",
	["North Common Hall"] = "Nördliche Gemeinschaftshalle",
	["Path of Renewal"] = "Der Pfad der Erneuerung",
	["Pit of Fangs"] = "Grube der Fänge",
	["Presage Plaza"] = "Plaza der Prophezeiung",
	["Prison of Immol'thar"] = "Gefängnis von Immol'thar",
	["Reliquary of Kings"] = "Reliquiar der Könige",
	["Runeweaver Square"] = "Der Runenweberplatz",
	["Screaming Gully"] = "Schreiende Schlucht",
	["Sewer"] = "Der Abwasserkanal",
	["Skitterweb Tunnels"] = "Huschnetztunnel",
	["Slaughter Square"] = "Schlachthofplatz",
	["South Common Hall"] = "Südliche Gemeinschaftshalle",
	-- Razorfen Downs' rooms (Data/Instances/RazorfenDowns.lua: Spiral of Thorns, The Bone Pile, The Caller's Chamber
	-- and The Murder Pens), as a player's recording read them in English (2026-11-13): the dungeon building's own
	-- names, with no area id. Drafted, to be checked in game (GetSubZoneText there)
	["Spiral of Thorns"] = "Dornenspirale",
	-- (the Drowned City's, drafted: see Abyssal Dais)
	["Sunken Hollow"] = "Versunkene Senke",
	-- (City of Dalaran's, drafted: see Forge of Fate)
	["Talismanic Textiles"] = "Talismanische Textilien",
	["Tazz'Alaor"] = "Tazz'Alaor",
	["Tazz'Alor"] = "Tazz'Alor",
	-- (City of Dalaran's, drafted: see Forge of Fate)
	["Tempered Tomes"] = "Gehärtete Folianten",
	-- (City of Dalaran's, drafted: see Forge of Fate)
	["The Atrium of Fortune"] = "Das Atrium des Glücks",
	-- (Razorfen Downs', drafted: see Spiral of Thorns)
	["The Bone Pile"] = "Der Knochenhaufen",
	-- (Razorfen Downs', drafted: see Spiral of Thorns)
	["The Caller's Chamber"] = "Kammer des Rufers",
	-- Gnomeregan's Clean Zone, a room the map follows since 0.39.21 (2026-11-12; drafted, to be checked)
	["The Clean Zone"] = "Die saubere Zone",
	["The Clockwerk Run"] = "Der Uhrwerkgang",
	["The Dormitory"] = "Der Schlafsaal",
	["The Drowned Sacellum"] = "Das Versunkene Sacellum",
	["The Eventide"] = "Die Abendruh",
	["The Forgotten Pool"] = "Der Vergessene Teich",
	["The Gauntlet"] = "Der Spießrutenlauf",
	["The Grand Vestibule"] = "Die Große Vorhalle",
	["The Grinding Quarry"] = "Der Mahlende Steinbruch",
	["The Hall of Gears"] = "Die Halle der Zahnräder",
	["The Hall of Lights"] = "Die Halle der Lichter",
	["The High Seat"] = "Der Hohe Sitz",
	["The Hoard"] = "Der Hort",
	["The Masonary"] = "Die Steinmetzhalle",
	["The Molten Span"] = "Die Geschmolzene Spanne",
	-- (Razorfen Downs', drafted: see Spiral of Thorns)
	["The Murder Pens"] = "Die Mordpferche",
	["The Pool of Ask'ar"] = "Der Teich von Ask'ar",
	["The Purple Parlor"] = "Der Purpursalon",
	["The Rookery"] = "Die Brutstätte",
	["The Scarlet Bastion"] = "Die Scharlachrote Bastion",
	["The Sealed Hall"] = "Die Versiegelte Halle",
	["The Shrine of Eldretharr"] = "Der Schrein von Eldretharr",
	-- (City of Dalaran's, drafted: see Forge of Fate)
	["The Silver Enclave"] = "Die Silberne Enklave",
	["The Slaughter House"] = "Das Schlachthaus",
	["The Storehouse"] = "Das Lagerhaus",
	["The Underbelly"] = "Die Schattenseite",
	["The Violet Citadel"] = "Die Violette Zitadelle",
	["The Violet Hold"] = "Die Violette Festung",
	["The Wailing Caverns"] = "Die Höhlen des Wehklagens",
	["Tinkers' Court"] = "Tüftlerhof",
	-- Gnomeregan's way in, as the Loading Room above
	["Train Depot"] = "Zugdepot",
	["Training Grounds"] = "Übungsplatz",
	-- (City of Dalaran's, drafted: see Forge of Fate)
	["Violet Plates and Framing"] = "Violette Platten und Rahmen",
	["Warpwood Quarter"] = "Wucherborkenviertel",
	-- Wailing Caverns' Winding Chasm (Data/Authored/WailingCaverns.lua, 2026-11-13): the game's name for it in this language, to be checked in game
	["Winding Chasm"] = "Gewundener Abgrund",
	-- Gnomeregan's way in, as the Loading Room above
	["Workshop Entrance"] = "Werkstatteingang",
	-- (Blackmaw Hold's, drafted: see Blackmaw Grove; Zedrik's Rest a best guess from the label on a newer version
	-- of Santiago Reyes's whole hold, 2026-11-18)
	["Zedrik's Rest"] = "Zedriks Ruhestätte",
	-- The Temple of Atal'Hakkar's way in (Data/Authored/SubMaps.lua, 2026-10-30): its nine rooms have no area id,
	-- so they are found by these names alone. Pool of Tears, Sorrowmurk and the temple's own name have ids (74,
	-- 1778, 1477): a scan (/aegis areas, Dev/bake_area_ids.py) can replace those three. LibBabble-SubZone's names,
	-- from its root file (rev 238); the file the lib loads (rev 258) has "Die Ritualhalle" for the Hall of Ritual.
	-- Hall of Faces and Den of the Unholy are Forever's names. To be checked in game (GetSubZoneText there)
	["Chamber of Blood"] = "Kammer des Bluts",
	["Den of the Caller"] = "Höhlenbau des Rufenden",
	["Den of the Unholy"] = "Höhlenbau des Unheiligen",
	["Hall of Bones"] = "Halle der Knochen",
	["Hall of Faces"] = "Halle der Gesichter",
	["Hall of Masks"] = "Halle der Masken",
	["Hall of Ritual"] = "Halle des Rituals",
	["Pool of Tears"] = "Tränenteich",
	["Sorrowmurk"] = "Sorgendunkel",
	["The Broken Hall"] = "Die verheerte Halle",
	["The Butchery"] = "Der Schlachthof",
	["The Temple of Atal'Hakkar"] = "Der Tempel von Atal'Hakkar",
}

-- The journal's style: its question at each character's first login, each choice and what it does, and the
-- choice and boxes in the options (2026-11-03; drafted, to be checked).
L.STYLE_TITLE = "Wählt Euer Kompendium"
L.STYLE_SUBTITLE = "Wie viel soll das Kompendium Eurem Spiel hinzufügen? Ihr könnt das jederzeit in den Optionen des Kompendiums ändern."
L.STYLE_CLASSIC = "Klassisch"
L.STYLE_CLASSIC_DESC = "Ein Kompendium mehr im ursprünglichen Stil, mit weniger Extras. Bosse, Beute, Quests und Dungeonkarten sind alle noch da."
L.STYLE_MODERN = "Modern"
L.STYLE_MODERN_DESC = "Alles, was das Kompendium hat, so wie jetzt: die Ausrüstungssuche, Karten der Wege hinein und seine Markierungen auf der Weltkarte."
L.STYLE_CUSTOM = "Benutzerdefiniert"
L.STYLE_CUSTOM_DESC = "Ihr entscheidet. Wählt dies, um die Einstellungen des Kompendiums zu öffnen, wo jede Funktion ihr eigenes Kästchen hat."
-- Adventure Mode, in the options' list of styles, and what it does (2026-11-05; drafted, to be checked).
L.STYLE_ADVENTURE = "Abenteuermodus"
L.STYLE_ADVENTURE_DESC = "Das Kompendium beginnt leer und füllt sich, während Ihr spielt: Dungeons, Bosse, Beute und Quests erscheinen, sobald Ihr sie findet."
-- Adventure Mode's name on its box in the question at login, one word like Classic and Modern (2026-11-07).
L.STYLE_ADVENTURE_BOX = "Abenteuer"
-- Adventure Mode's pages: an unmet boss's line, the closed tabs' tooltips, the loot list with nothing seen
-- yet, and an item seen with its boss unknown (2026-11-05; drafted, to be checked).
L.ADVENTURE_BOSS_UNMET = "Ihr seid diesem Gegner noch nicht begegnet."
L.ADVENTURE_ABILITIES_CLOSED = "Kämpft gegen diesen Boss, um seine Fähigkeiten kennenzulernen."
L.ADVENTURE_MODEL_CLOSED = "Begegnet diesem Boss, um ihn hier zu sehen."
L.ADVENTURE_LOOT_NONE = "Hier wurde noch keine Beute gesehen."
L.ADVENTURE_LOOT_IN_DUNGEON = "Beute aus: %s"
-- Adventure Mode's Quests tab, a step not offered yet and no quests found yet; the Reputation tab, no
-- faction met yet, and a faction's rewards not seen yet (2026-11-05; drafted, to be checked).
L.ADVENTURE_QUEST_UNKNOWN = "Diese Quest wurde Euch noch nicht angeboten."
L.ADVENTURE_QUESTS_NONE = "Für diesen Dungeon wurden noch keine Quests gefunden."
L.ADVENTURE_REP_NONE = "Ihr seid noch keiner dieser Fraktionen begegnet."
L.ADVENTURE_REP_TITLE = "Belohnungen zu finden"
L.ADVENTURE_REP_SEEN = "Ihre Belohnungen erscheinen hier, sobald Ihr sie bei ihrem Rüstmeister seht."
L.ADVENTURE_REP_SEEN_AT = "Ihre Belohnungen erscheinen hier, sobald Ihr sie bei ihrem Rüstmeister seht: %s."
L.ADVENTURE_REP_NONE_SEEN = "Noch keine ihrer Belohnungen gesehen."
L.ADVENTURE_DOOR_TITLE = "Ein Gerücht"
L.ADVENTURE_DOOR_LINE = "„%s“"
L.ADVENTURE_DOOR_UNKNOWN = "Über diesen Ort ist noch wenig bekannt."
L.ADVENTURE_DOOR_DUNGEON = "Unbekannter Dungeon"
L.ADVENTURE_DOOR_RAID = "Unbekannter Schlachtzug"
L.ADVENTURE_DOOR_NTH = "%s %d"
L.ADVENTURE_DOOR_CHOICE = "%s (%s)"
L.ADVENTURE_DOOR_VIA = "Das Portal liegt weiter unten: Steigt am Höhleneingang hinab."
L.ADVENTURE_DOOR_VIA_BUILDING = "Sein Portal liegt drinnen: Geht am Eingang hinein."
L.ADVENTURE_DOOR_WAYPOINT_SET = "Wegpunkt dorthin gesetzt, wohin das Gerücht führt."
L.ADVENTURE_CAVE_LEADS_TO = "Der Weg zu einem sagenumwobenen Ort"
L.ADVENTURE_CAVE_LEFT_CLICK = "Linksklick, um die Karte des Zugangs zu sehen"
-- Adventure Mode's quest marks on the world map (UI/QuestMap.lua): a quest not offered yet is a faint "!", a
-- rumor, under "A rumor" (ADVENTURE_DOOR_TITLE) and in ADVENTURE_DOOR_LINE's quotation marks: there may be work
-- there, from someone or something (inside a dungeon, a tablet or a crest). It names no quest, dungeon or
-- place (2026-11-11; translation drafted, to be checked).
L.ADVENTURE_QUEST_RUMOR = "Hier könnte es Arbeit für Euch geben."
-- Adventure Mode's Gear Finder: an upgrade not seen to drop yet, a rumour's place (zone, level range), the
-- tooltip's line for one not seen, the click lines, and Show on map for a rumour's door (2026-11-10; translation
-- drafted, to be checked).
L.GEAR_ADVENTURE_BETTER = "Etwas Besseres"
L.GEAR_ADVENTURE_PLACE = "%s · %s"
L.GEAR_ADVENTURE_UNSEEN = "Ihr habt es noch nicht fallen sehen."
L.GEAR_ADVENTURE_CELL_CLICK = "Klickt für die besten Verbesserungen; Rechtsklick für den Dungeon."
L.GEAR_ADVENTURE_PICK_CLICK = "Klickt, um es hier anzuzeigen; Rechtsklick für den Dungeon."
L.GEAR_ADVENTURE_ROW_CLICK = "Klickt für den Dungeon."
L.GEAR_ADVENTURE_MAP_CLICK = "Klickt, um den Weg dorthin auf der Weltkarte zu sehen."
L.GEAR_ADVENTURE_NO_DOOR = "Wo sein Eingang liegt, ist noch nicht bekannt."
L.GEAR_ADVENTURE_SHOW_MAP = "Auf der Karte zeigen"
-- The Gear Finder's rumour slot with upgrades to pick: its picture leads to the door, its words to the picks;
-- and the picks' right-click where the slot has no link (2026-11-10; translation drafted, to be checked).
L.GEAR_ADVENTURE_MAP_PICK_CLICK = "Klickt auf das Symbol, um den Weg dorthin auf der Weltkarte zu sehen; klickt auf den Text für die Verbesserungen zur Auswahl."
L.GEAR_ADVENTURE_RUMOUR_PICKS = "Rechtsklick für die Verbesserungen zur Auswahl."
L.STYLE_STARTING = "Starteinstellungen:"
L.STYLE_LINE_ON = "%s an"
L.STYLE_LINE_OFF = "%s aus"
L.STYLE_LINE_ADVENTURE_HIDDEN = "Dungeons, Bosse und Beute anfangs verborgen"
L.STYLE_LINE_ADVENTURE_FOG = "Dungeonkarten im Nebel, bis die Bosse fallen"
L.STYLE_LINE_ADVENTURE_ON = "Ausrüstungssuche, Wegkarten und Markierungen an"
L.STYLE_GEAR = "Ausrüstungssuche, Gewichtung"
L.STYLE_GEAR_TIP = "Der Reiter der Ausrüstungssuche, ihr Reiter im Charakterfenster, die Zeilen der Wertgewichtung in Gegenstands-Tooltips, die grünen Pfeile für Verbesserungen und die Gewichtung des Kompendiums in Pawn. Sie gehen alle von derselben Gewichtung aus und gehören daher zusammen. Nur für diesen Charakter."
L.STYLE_WAY_IN = "Karten der Zugänge und Höhlen"
L.STYLE_WAY_IN_TIP = "Karten des Wegs in einen Dungeon (Höhlen, Gebäude, die Ebenen eines Bergs) über der Weltkarte, und die Höhlen- und Gebäudeeingänge dorthin. Die eigenen Karten der Dungeons bleiben. Nur für diesen Charakter."
L.STYLE_MARKERS = "Markierungen auf der Weltkarte"
L.STYLE_MARKERS_TIP = "Die Markierungen des Kompendiums auf der Weltkarte: Dungeon- und Schlachtzugseingänge, Flugmeister, Schiffe, Zeppeline, Bahnen und Portale, seine Questmarkierungen, Gebietsstufen und unerforschte Gebiete. Nur für diesen Charakter."
L.STYLE_CLICK = "Klickt zum Wählen"
L.STYLE_NOW = "Euer Stil jetzt"
L.STYLE_CLOSE_NOTE = "Beim Schließen bleibt es bei %s."
L.STYLE_CHOSEN = "Stil des Kompendiums: %s. Ihr könnt ihn jederzeit in den Optionen des Kompendiums ändern (/aegis options)."
L.STYLE_OPTIONS_AFTER_COMBAT = "Die Optionen des Kompendiums öffnen sich, sobald der Kampf endet."
L.STYLE_OPTION = "Stil des Kompendiums"
L.STYLE_OPTION_TIP = "Klassisch, Modern, Abenteuermodus oder Benutzerdefiniert, nur für diesen Charakter. Hakt Ihr unten eine Funktion an oder ab, wird daraus Benutzerdefiniert (der Abenteuermodus bleibt an)."
-- The Reset button under the style's dropdown, and its question (2026-11-03; drafted, to be checked).
L.STYLE_RESET = "Kompendium zurücksetzen"
L.STYLE_RESET_BUTTON = "Zurücksetzen"
L.STYLE_CHOOSE_BUTTON = "Wählen"
L.STYLE_RESET_TIP = "Setzt die Optionen des Kompendiums für alle Eure Charaktere auf den Stand nach der Installation zurück und stellt diesem Charakter die Stilfrage erneut. Aufzeichnungen, Wertgewichtungen und die Stile Eurer anderen Charaktere bleiben erhalten."
L.STYLE_RESET_CONFIRM = "Die Optionen des Kompendiums für alle Eure Charaktere auf den Stand nach der Installation zurücksetzen und diesem Charakter die Stilfrage erneut stellen? Eure Aufzeichnungen, Wertgewichtungen und die Stile Eurer anderen Charaktere bleiben erhalten."
L.STYLE_GEAR_IS_OFF = "Die Ausrüstungssuche ist ausgeschaltet. Schaltet sie in den Optionen des Kompendiums ein (/aegis options)."
-- The Record tab's box in the options, and /aegis record while it is off (2026-11-03; drafted, to be checked).
L.OPTIONS_RECORD_TAB = "Reiter Aufzeichnen anzeigen"
L.OPTIONS_RECORD_TAB_TIP = "Der Reiter, der Eure Dungeonläufe für uns aufzeichnet. Deaktiviert: Der Reiter ist ausgeblendet und das Kompendium zeichnet nichts auf (Händler erfassen im Reiter Ruf funktioniert weiter). Was Ihr schon aufgezeichnet habt, bleibt erhalten."
L.RECORD_TAB_IS_OFF = "Der Reiter Aufzeichnen ist ausgeschaltet. Schaltet ihn in den Optionen des Kompendiums ein (/aegis options)."
L.LEGEND_STYLE_OFF = "In den Optionen des Kompendiums ausgeschaltet."

-- The run block (UI/RunTracker.lua, Core/Run.lua), 2026-11-11; drafted, to be checked. The client's own words where it has them.
L.RUN_BOSS_DEFEATED = "%s besiegt"
L.RUN_COMPLETE = DUNGEON_COMPLETED or "Dungeon abgeschlossen!"
L.RUN_EXPERIENCE = EXPERIENCE_COLON or "Erfahrung:"
L.RUN_MONEY = MONEY_COLON or "Geld:"
L.RUN_ITEMS = "Gegenstände:"
L.RUN_PER_HOUR = "%s/Std."
L.RUN_GREED = "%d per " .. (GREED or "Gier") .. " gewonnen"
L.RUN_DEFEATED = BOSS_DEAD or "Besiegt"
L.RUN_NOT_DEFEATED = "Noch nicht besiegt"
L.RUN_PARTS = "%s, dann %s"
L.RUN_COIN = "Erbeutetes Geld"
L.RUN_ITEM_VALUE = "Gegenstände zum Händlerpreis"
L.RUN_PENDING = "Warten auf einen Preis: %d"
L.RUN_DRAG = "Zieht die Überschrift, um sie zu verschieben."
L.RUN_SUMMARY = "%s: %d/%d Bosse in %s"
L.RUN_SUMMARY_XP = "%s EP"
L.RUN_SUMMARY_ITEMS = "Gegenstände: %d"
L.RUN_NEW = "Ein neuer Durchlauf beginnt jetzt."
L.RUN_NOT_INSIDE = "Betretet einen Dungeon, um einen neuen Durchlauf zu beginnen."
L.RUN_HIDDEN = "Die Durchlaufanzeige ist für diesen Durchlauf ausgeblendet. Gebt /ij run ein, um sie wieder zu zeigen."
L.RUN_NONE = "Noch kein Dungeondurchlauf."
L.RUN_IS_OFF = "Die Durchlaufanzeige ist ausgeschaltet. Schaltet sie in den Optionen des Kompendiums ein (/aegis options)."
L.RUN_FREE_OFF = "Die Durchlaufanzeige sitzt wieder an der Questverfolgung."
-- The run block's header lock and its chat lines, /ij run lock and unlock now the lock's, and /ij run's usage reworded for them (2026-11-17; drafted, to be checked).
L.RUN_USAGE = "/ij run zeigt oder verbirgt die Durchlaufanzeige (außerhalb eines Dungeons Euren letzten Durchlauf). /ij run new beginnt einen neuen Durchlauf. /ij run lock und /ij run unlock sperren sie an ihrem Platz oder lassen Euch sie wieder ziehen, wie das Schloss an ihrer Überschrift; /ij run reset setzt sie wieder an die Questverfolgung. /ij run debug zeigt, was sie gezählt hat."
L.RUN_LOCKED = "Gesperrt"
L.RUN_LOCKED_TIP = "Klickt, um sie zu entsperren, und zieht die Anzeige dann an ihrer Überschrift."
L.RUN_UNLOCKED = "Entsperrt"
L.RUN_UNLOCKED_TIP = "Zieht die Anzeige an ihrer Überschrift, um sie zu verschieben. Klickt, um sie an ihrem Platz zu sperren."
L.RUN_LOCK_ON = "Die Durchlaufanzeige ist an ihrem Platz gesperrt."
L.RUN_LOCK_OFF = "Die Durchlaufanzeige ist entsperrt: Zieht sie an ihrer Überschrift, um sie zu verschieben."
L.RUN_LOCK_NOT_FREE = "Sie bewegt sich nur, solange sie frei platziert wird („%s“ in den Optionen)."
-- The clock's buttons on the run block, between the time and the count (2026-11-14; drafted, to be checked).
L.RUN_CLOCK_START = "Uhr jetzt starten"
L.RUN_CLOCK_WAITING = "Sonst startet sie beim ersten Kampf von selbst."
L.RUN_CLOCK_PAUSE = "Uhr anhalten"
L.RUN_CLOCK_RESUME = "Uhr fortsetzen"
L.RUN_CLOCK_DONE = "Der Durchlauf ist geschafft, seine Uhr steht."
L.RUN_RESTART = "Neuer Durchlauf"
L.RUN_RESTART_CONFIRM = "Einen neuen Durchlauf beginnen? Die besiegten Bosse werden zurückgesetzt und die Uhr beginnt von vorn."
-- The run block's one line inside a Scarlet Monastery wing before the wing is known (2026-11-17; drafted, to be checked).
L.RUN_WHICH_WING = "Welcher Flügel?"
-- /ij run new or New run before the wing is known: the new run starts once it is (2026-11-17; drafted, to be checked).
L.RUN_NEW_WING = "Ein neuer Durchlauf beginnt, sobald der Flügel bekannt ist."
L.OPTIONS_RUN = "Dungeondurchläufe anzeigen"
L.OPTIONS_RUN_TIP = "In einem Dungeon zeigt eine Anzeige an der Questverfolgung, wie lange der Durchlauf dauert, seine Bosse und was Ihr gewonnen habt. Ausgeschaltet wird nichts gezählt."
L.OPTIONS_RUN_NUMBERS = "Erfahrung und Geld anzeigen"
L.OPTIONS_RUN_NUMBERS_TIP = "Erfahrung und Geld (erbeutetes Geld plus der Händlerpreis Eurer Gegenstände), jeweils mit ihrem Wert pro Stunde, und wie viele Gegenstände Ihr bekommen habt."
L.OPTIONS_RUN_FREE = "Frei platzieren"
-- "Place it freely" on by default since 0.39.23: its tip says so, and what unticking it does (2026-11-17; drafted, to be checked).
L.OPTIONS_RUN_FREE_TIP = "Zieht die Anzeige an ihrer Überschrift an einen beliebigen Ort. Standardmäßig an: Bis Ihr sie verschiebt, wartet sie an der Questverfolgung. Ausgeschaltet sitzt sie an der Questverfolgung und bewegt sich mit ihr. „In der Questverfolgung“ hat Vorrang davor."
-- The run block's dark mode: its gold art darkened, else the tracker's tint (UI/RunTracker.lua Paint), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_DARK_MODE = "Dunkler Modus"
L.OPTIONS_RUN_DARK_MODE_TIP = "Dunkelt das Gold der Überschrift und des Rahmens der Durchlaufanzeige ab. Ausgeschaltet sieht die Anzeige aus wie die Überschriften Eurer Questverfolgung, ist also dunkel, wenn Euer Interface sie abdunkelt."
L.OPTIONS_RUN_SUMMARY = "Zusammenfassung im Chat"
L.OPTIONS_RUN_SUMMARY_TIP = "Eine Zeile im Chat eine Minute, nachdem die Uhr eines Durchlaufs stoppt (früher, wenn Ihr geht). Ein Durchlauf, den Ihr unbeendet verlasst, bekommt seine Zeile, sobald er vorbei ist: wenn der Dungeon zurückgesetzt wird oder nach einer halben Stunde außerhalb."
-- The run block inside the quest tracker: off by default (the owner's call of 2026-11-13; on in 0.39.22's tests), its tip warning of blocked actions in combat until a /reload once the block has been inside the tracker (the owner's words, 2026-11-13), its name marked as a test (UI/RunTrackerInside.lua), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_INSIDE = "In der Questverfolgung (Test)"
-- Its tip: beside the tracker with this off only while "Place it freely" is unticked too, since that is on by default (2026-11-17; drafted, to be checked).
L.OPTIONS_RUN_INSIDE_TIP = "Die Anzeige kommt in die Questverfolgung, direkt unter „" .. (TRACKER_ALL_OBJECTIVES or "Alle Ziele") .. "“, und deren Abschnitte (" .. (TRACKER_HEADER_QUESTS or "Quests") .. " und die übrigen) rücken unter sie. Standardmäßig aus. Eine Questverfolgung, die Ihr im Bearbeitungsmodus verschoben habt, ist nur so hoch wie ihre Höhe dort: Ist das zu kurz für die Anzeige, erhöht das Kompendium diese Höhe einmal in Eurem Layout des Bearbeitungsmodus und sagt es im Chat (zu sehen nach einem /reload; die Schaltfläche darunter macht es erneut). Bis dahin bleibt die Anzeige neben ihr, wie ausgeschaltet, wenn auch „Frei platzieren“ abgewählt ist. Sobald die Anzeige in der Questverfolgung war, kann sie bis zu einem /reload im Kampf blockierte Aktionen verursachen. Dies ist ein Test: Meldet das Spiel eine blockierte Aktion, schaltet sie sich selbst aus. Wurde sie schon benutzt, ist sie erst nach einem /reload ganz aus."
L.RUN_INSIDE_BLOCKED = "Das Spiel hat eine Aktion des Kompendiums blockiert (%s), daher ist „In der Questverfolgung“ jetzt aus und die Durchlaufanzeige kehrt neben die Questverfolgung zurück. Bitte meldet diese Zeile. Gebt /reload ein, um sie ganz aus der Questverfolgung zu nehmen."
L.RUN_INSIDE_RELOAD = "„In der Questverfolgung“ ist jetzt aus und die Durchlaufanzeige kehrt neben die Questverfolgung zurück. Gebt /reload ein, um sie ganz aus der Questverfolgung zu nehmen."
-- The tracker too short for the block inside: the Height it needs, and the options' Make taller button (UI/RunTrackerInside.lua), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_TALLER = "Questverfolgung höher machen"
L.OPTIONS_RUN_TALLER_BUTTON = "Höher machen"
L.OPTIONS_RUN_TALLER_TIP = "Für „In der Questverfolgung“: setzt die Höhe der Questverfolgung in Eurem Layout des Bearbeitungsmodus auf das, was die Durchlaufanzeige braucht, und speichert das Layout. Nur für eine Questverfolgung, die Ihr im Bearbeitungsmodus verschoben habt. Benutzt es, während die Durchlaufanzeige zu sehen ist, außerhalb des Kampfes und bei geschlossenem Bearbeitungsmodus. Zu sehen ist es nach einem /reload."
L.RUN_INSIDE_SHORT = "Die Durchlaufanzeige bleibt neben der Questverfolgung: Die Questverfolgung ist zu kurz für sie. So wird sie höher: %s, wählt „%s“, %s %d oder mehr. Oder benutzt „%s“ in den Optionen des Kompendiums (/aegis options)."
L.RUN_INSIDE_SHORT_TIP = "Die Questverfolgung ist zu kurz für die Anzeige. So wird sie höher: %s, wählt „%s“, %s %d oder mehr."
L.RUN_TALLER_COMBAT = ERR_NOT_IN_COMBAT or "Das könnt Ihr im Kampf nicht tun."
L.RUN_TALLER_EDIT_MODE = "Schließt zuerst den %s."
L.RUN_TALLER_DEFAULT = "Die Questverfolgung steht an ihrem Standardplatz und reicht dort bis zum unteren Bildschirmrand: Sie hat keine Höhe einzustellen."
L.RUN_TALLER_UNKNOWN = "Benutzt dies, während die Durchlaufanzeige zu sehen ist (in einem Dungeon, oder Euer letzter Durchlauf mit /ij run): Dann wird ihre Höhe gemessen."
L.RUN_TALLER_ENOUGH = "Die Questverfolgung ist schon hoch genug für die Durchlaufanzeige."
L.RUN_TALLER_FAILED = "Euer Layout des Bearbeitungsmodus ließ sich von hier aus nicht ändern. Stellt es selbst ein: %s, wählt „%s“, %s %d oder mehr."
L.RUN_TALLER_DONE = "%s – %s: jetzt %d in Eurem Layout „%s“ des Bearbeitungsmodus. Gebt jetzt /reload ein, um es zu sehen."
L.RUN_TALLER_MOST = "Mehr erlaubt der Bearbeitungsmodus nicht, die Anzeige passt also vielleicht immer noch nicht."
-- The tracker's Height raised once by the journal itself when too short, 0.39.22 (UI/RunTrackerInside.lua AutoTaller), 2026-11-12; drafted, to be checked.
L.RUN_INSIDE_AUTO = "Die Questverfolgung war zu kurz für die Durchlaufanzeige, daher hat das Kompendium ihre %s von %d auf %d gesetzt, in Eurem Layout „%s“ des Bearbeitungsmodus. Gebt /reload ein, um es zu sehen. Zurückstellen könnt Ihr es im %s."
L.RUN_INSIDE_SAVED_TIP = "Euer Layout des Bearbeitungsmodus gibt der Questverfolgung jetzt eine %s von %d. Gebt /reload ein, um es zu sehen."
-- Edit Mode opened before the /reload after the journal saved a Height: its old copy (UI/RunTrackerInside.lua EditModeEntered), 2026-11-12; drafted, to be checked.
L.RUN_INSIDE_EDIT_MODE_OLD = "Der %s zeigt bis zu einem /reload noch die alte %s der Questverfolgung. Speichert Ihr dort jetzt etwas, kehrt die alte zurück."

-- Matched against the client's own text: the client's language's only, previewed or not.
if client then client.EQUIP_PATTERNS, client.AREA_NAMES = L.EQUIP_PATTERNS, L.AREA_NAMES end
L.EQUIP_PATTERNS, L.AREA_NAMES = nil, nil
