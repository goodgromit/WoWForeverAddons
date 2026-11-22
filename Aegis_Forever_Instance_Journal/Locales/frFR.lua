local _, ns = ...

--[[
	The journal's interface in French, drafted by Claude for review by a native speaker, for a
	client set to French. It is laid over the English table (Locales/enUS.lua), so every file that
	already holds ns.L sees these strings, and anything not translated here stays English. Every
	other client skips it.
]]
-- The journal's words where it speaks this language; the tables matched against the client's own
-- text where the client does, previewed or not (ns.LocaleTargets, Locales/enUS.lua).
local L, client = ns.LocaleTargets("frFR")
if not L then return end

L.JOURNAL_TITLE = "Journal des instances"
L.HOME = HOME or "Accueil"
L.TAB_DUNGEONS = DUNGEONS or "Donjons"
L.TAB_RAIDS = RAIDS or "Raids"
L.TAB_REPUTATION = REPUTATION or "Réputation"

L.BINDING_TOGGLE = "Ouvrir/fermer le journal des instances"
L.KEY_CLAIMED = "Maj+J ouvre désormais le journal des instances."
L.KEY_TAKEN = "Maj+J est déjà attribué à %s. Choisissez une touche dans Raccourcis > AddOns > Ouvrir/fermer le journal des instances."
L.POSITION_RESET = "Position de la fenêtre réinitialisée."
L.DOCK_ON = "La fenêtre s'ouvre désormais en haut à gauche, à côté des fenêtres du jeu. Faites-la glisser pour la déplacer jusqu'à sa fermeture."
L.DOCK_OFF = "La fenêtre est de nouveau libre : elle s'ouvre là où vous l'avez déplacée en dernier."
L.DOCK_AFTER_COMBAT = "Cela prendra effet à la fin du combat."
-- Its /aegis style sentence (2026-11-03; drafted, to be checked).
L.SLASH_HELP = "/aegis (ou /ij) ouvre le journal. /aegis record lance ou arrête l'enregistrement. /aegis reset replace la fenêtre à son emplacement par défaut. /aegis dock ancre la fenêtre en haut à gauche, à côté des fenêtres du jeu, ou la libère de nouveau. /aegis perf mesure la mémoire et la vitesse du journal. /aegis where et /aegis taxi indiquent votre position et les points de vol de votre carte. /aegis travel enregistre un bateau, un zeppelin, un tram ou un portail pour la carte du monde. /aegis items repère les objets listés que le serveur ne connaît pas. /aegis gear ouvre la recherche d'équipement, /aegis weights ses poids de caractéristiques ; /aegis gearscan enregistre ce qu'elle lit sur votre équipement, pour vérifier ses calculs. /aegis options ouvre les options du journal. /aegis style affiche de nouveau la question du style du journal. /aegis lang affiche le journal dans une autre de ses langues. /aegis run affiche ou masque le suivi du parcours (hors d'un donjon, votre dernier parcours) ; /aegis run new commence un nouveau parcours. /aegis test ouvre le mode test."
L.LANG_USAGE = "/aegis lang de, fr, ru, cn, tw, es, mx, pt ou ko affiche le journal en allemand, en français, en russe, en chinois (simplifié ou traditionnel), en espagnol (Espagne ou Amérique latine), en portugais du Brésil ou en coréen à partir de votre prochain /reload, pour vérifier une traduction ; /aegis lang off revient à la langue de votre client. Actuellement : %s."
L.LANG_SET = "À partir de votre prochain /reload, le journal s'affiche dans cette langue : %s. Seuls ses propres textes changent : les noms du jeu restent ceux de votre client. Tapez /reload maintenant ; /aegis lang off revient en arrière."
L.LANG_OFF = "À partir de votre prochain /reload, le journal reprend la langue de votre client. Tapez /reload maintenant."
L.LANG_FONTS = "Le chinois nécessite les polices d'un client chinois : sur le vôtre, certains caractères risquent de ne pas s'afficher."
L.LANG_FONTS_KO = "Le coréen nécessite les polices d'un client coréen : sur le vôtre, certains caractères risquent de ne pas s'afficher."
L.LANG_ON = "Aperçu du journal dans une autre langue : %s. /aegis lang off y met fin."
L.LANG_UNAVAILABLE = "Ce client a chargé le journal avant ses paramètres enregistrés : l'aperçu de langue n'a donc pas pu démarrer."
-- A map addon the owner asked us to warn about, while it is loaded: its name twice (2026-11-12; drafted, to be checked).
L.MAP_ADDON_HIDES = "%s est activé. Il recouvre la carte du monde : certaines cartes et fonctions du journal peuvent donc être masquées. Nous vous recommandons de désactiver %s."
L.AREAS_START = "Recherche des identifiants client des %d noms de zones du journal..."
L.AREAS_DONE = "Identifiants trouvés pour %d des %d noms de zones. Tapez /reload pour les enregistrer."
L.AREAS_MISSING = "Introuvables : %s."
L.AREAS_SCANNING = "Recherche des noms de zones toujours en cours."
L.AREAS_ENGLISH = "Lancez /aegis areas sur un client anglais : les noms recherchés sont en anglais."
-- Test mode (UI/TestPanel.lua, UI/TestRun.lua, UI/FogTest.lua): the owner's fog test of 2026-11-13, made test
-- mode on 2026-11-18, for this session only (2026-11-18; drafted, to be checked).
L.FOGTEST_FOG_OFF = "Le brouillard est désactivé pour ce personnage, seuls les repères changent. Pour le voir, activez le brouillard de guerre dans la légende de la carte, ou jouez en Mode Aventure."
L.FOGTEST_PIN_CLICK = "Mode test : cliquez pour le marquer vaincu, ou de nouveau debout."
L.TEST_TITLE = "Mode test"
L.TEST_PICK = "Choisir un donjon"
L.TEST_NO_MAP = "Celui-ci n'a pas encore de carte."
L.TEST_INSIDE = "Faire comme si j'y étais"
L.TEST_INSIDE_TIP = "Le suivi du parcours montre ce donjon comme à votre entrée : aucune victoire, le chrono attend le premier combat (Lecture le lance). Les boss que vous marquez y comptent comme de vraies victoires. Rien n'en est enregistré."
L.TEST_INSIDE_RAID = "Le suivi du parcours est fait pour les donjons, pas pour les raids."
L.TEST_INSIDE_REAL = "Vous êtes dans %s : le suivi du parcours montre votre vrai parcours."
L.TEST_TRACKER_COMBAT = "Attendez la fin du combat : le suivi du parcours est dans le suivi des quêtes."
L.TEST_WALK_IN = "Entrer"
L.TEST_WALK_IN_TIP = "Le parcours du Monastère écarlate attend à la porte jusqu'à ce que la première salle ou le premier combat d'une aile la désigne. Entrer la désigne : %s."
L.TEST_FOUND = "Montrer comme découvert (Aventure)"
L.TEST_FOUND_TIP = "Cochée : le journal traite ce donjon comme découvert, comme si vous y étiez entré. Ses boss, son butin et ses quêtes n'apparaissent toujours qu'à mesure que vous les découvrez, ou qu'une victoire de test les débloque. Décochée : tel que votre personnage l'a découvert. Une victoire de test le découvre aussi."
L.TEST_FOUND_OFF = "Votre personnage n'est pas en Mode Aventure : tout est déjà affiché."
L.TEST_FOUND_REAL = "Votre personnage l'a découvert."
L.TEST_BOSSES = "Boss"
L.TEST_DEFEATED = "%d sur %d vaincus"
L.TEST_TAG_RARE = "rare"
L.TEST_TAG_SUMMONED = "invoqué"
L.TEST_TAG_NOT_COUNTED = "non compté"
L.TEST_TAG_MAYBE = "peut-être"
L.TEST_TAG_QUEST = "quête"
L.TEST_TAG_OUTSIDE = "dehors"
L.TEST_TAG_FINAL = "dernier"
L.TEST_TIP_RARE = "Rare : ni cercle ni ligne dans le suivi du parcours, et il ne retient aucun brouillard."
L.TEST_TIP_SUMMONED = "Invoqué : il ne retient aucun brouillard."
L.TEST_TIP_NOT_COUNTED = "Non compté : une ligne dans le suivi du parcours une fois vaincu, pas de cercle."
L.TEST_TIP_MAYBE = "Peut-être : seuls certains parcours le rencontrent. Une ligne dans le suivi du parcours une fois vaincu, pas de cercle."
L.TEST_TIP_QUEST = "Quête : la cible d'une quête. Une ligne dans le suivi du parcours une fois vaincu, pas de cercle. Hors du test, son repère ouvre sa quête."
L.TEST_TIP_OUTSIDE = "Dehors : il se tient hors du donjon, le suivi du parcours ne le montre donc jamais."
L.TEST_TIP_FINAL = "Dernier : sa mort arrête le chrono du parcours."
L.TEST_END = "Fin du test"
L.TEST_ON = "Mode test activé, pour cette session seulement : rien n'est enregistré. Fin du test ou un /reload le désactive."
L.TEST_OFF = "Mode test désactivé : tout est comme avant."
L.TEST_RUN_TITLE = "%s (test)"
L.TEST_RUN_ENDED = "Vous êtes entré dans un donjon : le parcours simulé du test est terminé."
L.TEST_STATE_INSIDE = "dedans"
L.TEST_STATE_DOOR = "à la porte (quelle aile ?)"
L.TEST_STATE_OUTSIDE = "dehors"
L.TEST_STATE_DEFEATED = "%d/%d vaincus"
L.TEST_STATE_FOG_ON = "brouillard activé"
L.TEST_STATE_FOG_OFF = "brouillard désactivé"
L.TEST_STATE_NO_FOG = "pas de brouillard"
L.TEST_STATE_FOUND = "montré comme découvert"
L.TEST_STATE_REAL = "comme votre personnage"
L.TEST_STATE_KILL_FOUND = "découvert par victoire de test"
L.TEST_STATE_REAL_INSIDE = "vraiment dedans"
L.TEST_STATE_NOT_ADVENTURE = "pas en Mode Aventure"
L.TEST_STATE_COMBAT = "en combat"
L.TEST_USAGE = "/ij test ouvre le mode test. /ij test off le termine. /ij test debug affiche ce qu'il fait."
L.ITEMS_START = "Interrogation du serveur sur les %d objets listés par le journal. La réponse arrive dans environ %d secondes ; vous pouvez continuer à jouer."
L.ITEMS_SCANNING = "Interrogation du serveur en cours ; la réponse arrive dans un instant."
L.ITEMS_DONE = "Sur %d objets, le serveur n'en connaît pas %d : ils ne sont sans doute pas encore dans Forever. Le journal les masque jusqu'à ce que le serveur ou un parcours enregistré les confirme. La liste complète est écrite dans le fichier de sauvegarde à votre prochain /reload ou à votre déconnexion."
L.ITEMS_LINE = "  Objet %d : %s"
L.ITEMS_MORE = "  ...et %d de plus."
L.PERF_HEADER = "Performances (mémoire en Ko, temps en millisecondes ; plus c'est bas, mieux c'est) :"
L.PERF_MEMORY = "  %s : %.0f Ko"
L.PERF_TIME = "  %s : %.2f ms"
L.PERF_BUILD = "Première ouverture (construction de la fenêtre)"
L.PERF_BOOK = "Premier donjon ouvert (construction du livre)"
L.PERF_OPEN = "Ouvrir et fermer le journal"
L.PERF_DUNGEON = "Ouvrir la page d'un donjon"
L.PERF_TAB = "Passer à l'onglet %s"
L.PERF_FACTION = "Ouvrir la page d'une faction"
L.PERF_LOOT = "Redessiner une page de butin"
L.PERF_COMBAT = "La mesure attend que vous soyez hors de combat."
L.WHERE = "Carte %s (%s)  x %.4f  y %.4f  zone \"%s\"  minicarte \"%s\"  hauteur %s"
-- /aegis where: what the journal remembers the player as below a city, and its last changes (2026-11-06; drafted, to be checked).
L.WHERE_BELOW = "%s : mémorisé %s"
L.WHERE_BELOW_BELOW = "en bas"
L.WHERE_BELOW_TOP = "en haut"
L.WHERE_BELOW_NOTHING = "rien"
L.WHERE_BELOW_CHANGE = "  %s  %s  carte %s  zone \"%s\"  x %s  y %s :  %s -> %s"
L.WHERE_GAMEPAD = "Interface manette : manette rendue au début d'un combat : %d (la dernière fois sur %s) ; trop tard : %d ; événements de restriction de combat reçus : %d ; marques d'omission en attente : %d"
L.WHERE_FLOOR = "%s : carte au niveau %d (%s), d'après la zone \"%s\""
L.WHERE_FLOOR_KEPT = "%s : carte au niveau %d (%s), gardée : la zone \"%s\" n'est d'aucun niveau"
L.WHERE_FLOOR_HELD = "%s : carte au niveau %d (%s), ne suit pas la zone \"%s\" : un niveau choisi, ou la carte entière"
L.TAXI = "Carte %s  affiche elle-même les points de vol : %s  points de vol dessus : %d (%d découverts)  %s"
L.TAXI_ATLASES = "Icônes de voyage : %s"
L.YES = YES or "oui"
L.NO = NO or "non"

L.EMPTY_DUNGEONS = "Aucun donjon n'a encore d'entrée dans le journal."
L.EMPTY_RAIDS = "Aucun raid n'a encore d'entrée dans le journal."
L.EMPTY_REPUTATION = "Aucune récompense de faction n'est encore connue."
L.EMPTY_BRACKET = "Rien dans cette tranche de niveaux."

L.TAB_RECORD = "Enregistrer"
L.TAB_GEAR = "Recherche d'équipement"

-- The Gear Finder (Core/GearFinder.lua, UI/GearPanel.lua, UI/CharacterTab.lua).
L.GEAR_TITLE = "Recherche d'équipement"
L.GEAR_PREVIEW = "Aperçu"
L.GEAR_NO_UPGRADE = "Aucune amélioration trouvée"
L.GEAR_LOOKING = "Recherche dans %d donjons."
L.GEAR_LOOKING_ONE = "Recherche dans 1 donjon."
L.GEAR_LOADING = "%d objets encore en chargement."
L.GEAR_LOADING_ONE = "1 objet encore en chargement."
L.GEAR_SCORING = "Calcul pour"
L.GEAR_AUTO = "Automatique : %s"
L.GEAR_WHY_TALENTS = "%s (talents)"
L.GEAR_WHY_LEVELLING = "%s (montée en niveau)"
L.GEAR_SUGGESTED = "Donjon suggéré"
L.GEAR_UPGRADES_HERE = "%d améliorations ici"
L.GEAR_UPGRADE_HERE = "1 amélioration ici"
L.GEAR_MORE_SLOTS = "et %d de plus"
L.GEAR_DUNGEON_OF = "%d sur %d"
L.GEAR_NONE = "Aucune amélioration dans les donjons proches de votre niveau."
L.GEAR_TIP_CLICK = "Cliquez pour voir son butin ; Maj-clic pour insérer un lien."
L.GEAR_TIP_CELL_CLICK = "Cliquez pour voir les meilleures améliorations ; clic droit pour voir son butin."
L.GEAR_TIP_PICK_CLICK = "Cliquez pour l'afficher ici ; clic droit pour voir son butin."
L.GEAR_TIP_PICKED = "Votre choix pour cet emplacement."
L.GEAR_PICK_TOP = "Les %d meilleures améliorations sur %d"
L.GEAR_PICK_ALL = "%d améliorations"
L.GEAR_PICK_ONE = "La seule amélioration"
L.GEAR_PICK_BIGGEST = "La plus forte"
L.GEAR_PICK_YOURS = "Votre choix"
L.GEAR_PICK_KEPT = "Les choix sont conservés pour ce personnage."
L.GEAR_PICK_CLEAR = "Effacer mon choix"
L.GEAR_TIP_NONE = "Aucune amélioration pour cet emplacement dans les donjons proches de votre niveau."
L.GEAR_CHAR_BUTTON = "Recherche d'équipement"
L.GEAR_CHAR_BUTTON_TIP = "Vos poids de caractéristiques, et les meilleures améliorations qui vous attendent dans les donjons du journal."
L.GEAR_SCAN_DONE = "Analyse de l'équipement enregistrée : %d objets portés et %d butins de donjon. Déconnectez-vous ou tapez /reload pour l'écrire dans le fichier de sauvegarde."
L.GEAR_SCAN_ERRORS = "%d objets n'ont pas pu être lus ; la cause est enregistrée avec l'analyse."
L.GEAR_SCAN_LOADING = "Certains butins sont encore en chargement : attendez quelques secondes et tapez à nouveau /aegis gearscan pour en obtenir davantage."
L.GEAR_SLOT_FINGER1 = "Doigt 1"
L.GEAR_SLOT_FINGER2 = "Doigt 2"
L.GEAR_SLOT_TRINKET1 = "Bijou 1"
L.GEAR_SLOT_TRINKET2 = "Bijou 2"

-- Stat weights (Core/ItemScore.lua, UI/WeightsEditor.lua).
L.WEIGHTS_TITLE = "Poids des caractéristiques"
L.WEIGHTS_EDIT = "Modifier les poids des caractéristiques..."
L.WEIGHTS_SOURCE_DEFAULT = "Les poids du journal"
L.WEIGHTS_SOURCE_LEVELLING = "Les poids du journal, pendant la montée en niveau"
L.WEIGHTS_SOURCE_CUSTOM = "Vos propres poids"
L.WEIGHTS_SOURCE_PAWN = "Vos poids, depuis Pawn : %s"
L.WEIGHTS_TIP = "Ce que vaut un point de chaque caractéristique pour cette spécialisation. Cliquez sur un poids pour le modifier ; vos propres poids s'affichent en vert et sont conservés pour ce personnage."
L.WEIGHTS_RESET = "Réinitialiser"
L.WEIGHTS_RESET_TIP = "Revenir aux poids du journal pour cette spécialisation."
L.WEIGHTS_PAWN = "Pawn..."
-- The Pawn... button's tooltip names WoWSims' Pawn export (2026-11-03; drafted, to be checked).
L.WEIGHTS_PAWN_TIP = "Importer une échelle depuis Pawn, ou coller un export Pawn de WoWSims."
L.WEIGHTS_PAWN_HELP = "Dans Pawn, choisissez l'échelle, cliquez sur Exporter, copiez le texte et collez-le ici."
L.WEIGHTS_IMPORT = "Importer"
L.WEIGHTS_CANCEL = "Annuler"
L.WEIGHTS_BACK = "Retour"
L.WEIGHTS_OPEN_FINDER = "Ouvrir la recherche d'équipement"
L.WEIGHTS_IMPORTED = "%d poids importés depuis %s."
L.WEIGHTS_UNUSED = "Non utilisés : %s."
L.WEIGHTS_NOT_PAWN = "Ce n'est pas une échelle Pawn. Dans Pawn, choisissez Exporter et copiez tout son texte."
L.WEIGHTS_OTHER_CLASS = "Cette échelle est faite pour la classe %s, pas pour celle de ce personnage."
L.WEIGHTS_FOR = "Pour"
-- WoWSims' weights, the Gear Finder's defaults for the specs the sim has, and its Pawn export (2026-11-03; drafted, to be checked).
L.WEIGHTS_SOURCE_SIMS = "Les poids de WoWSims : %s"
L.WEIGHTS_PAWN_SIMS = "Un export Pawn de WoWSims (wowsims.com/forever) fonctionne aussi, avec ou sans Pawn, et note comme les poids WoWSims du journal. Il n'a aucun poids pour les soins, les dégâts par école, la pénétration des sorts, la puissance d'attaque farouche, la défense, le blocage ni les résistances."
L.WEIGHTS_NO_STATS = "Cette échelle Pawn n'a aucun poids que le journal puisse utiliser."
-- The journal's page in the game's options (Options > AddOns).
L.OPTIONS_TITLE = "Aegis Instance Journal"
L.OPTIONS_BOSS_LEVELS = "Afficher le niveau des boss"
L.OPTIONS_BOSS_LEVELS_TIP = "Un badge sur le portrait de chaque boss indique son niveau, coloré selon la difficulté du boss pour vous : gris, vert, jaune, orange ou rouge."
L.OPTIONS_ARROWS = "Flèche verte sur les améliorations"
L.OPTIONS_MINIMAP = "Afficher le bouton de minicarte"
L.OPTIONS_PAWN_WEIGHTS = "Utiliser les poids de Pawn"
L.OPTIONS_PAWN_WEIGHTS_TIP = "Si Pawn est installé, ce sont ses infobulles d'objets et ses flèches d'amélioration qui s'affichent. Coché : la recherche d'équipement évalue les objets avec votre échelle Pawn pour votre spécialisation. Décoché : Pawn affiche à la place les poids du journal pour votre spécialisation, sous la forme d'une échelle du journal, et ses propres échelles sont masquées sur ce personnage jusqu'à ce que vous cochiez cette case."
L.PAWN_ASK = "Pawn est également installé. Ce sont ses infobulles d'objets et ses flèches d'amélioration qui s'afficheront.\n\nQuels poids de caractéristiques Pawn et la recherche d'équipement doivent-ils utiliser tous les deux ?\n\nCeux du journal : Pawn les affiche pour votre spécialisation et masque ses propres échelles sur ce personnage.\nCeux de Pawn : la recherche d'équipement utilise vos échelles Pawn."
L.PAWN_USE_PAWN = "Ceux de Pawn"
L.PAWN_USE_JOURNAL = "Ceux du journal"
L.PAWN_SCALE = "Journal : %s"
L.PAWN_RELOAD = "Les flèches d'amélioration de Pawn dans vos sacs Baganator ne changent qu'après un rechargement : Baganator conserve les réponses de Pawn jusqu'à ce que votre équipement change.\n\nRecharger maintenant ?"
L.PAWN_RELOAD_NOW = "Recharger"
L.PAWN_RELOAD_LATER = "Plus tard"
L.WEIGHTS_SOURCE_PAWN_LIVE = "L'échelle « %s » de Pawn. Modifiez-la dans Pawn, ou choisissez celle du journal dans les options du journal."
L.OPTIONS_MINIMAP_TIP = "Le bouton du journal au bord de la minicarte : cliquez dessus pour ouvrir le journal, faites un clic droit pour ces options, faites-le glisser pour le déplacer."
-- The journal's line in the minimap's addon menu, its box beside the minimap button's (UI/Options.lua; 2026-11-20; drafted, to be checked).
L.OPTIONS_ADDON_MENU = "Dans le menu des addons"
L.OPTIONS_ADDON_MENU_TIP = "La ligne du journal dans le menu des addons de la minicarte, le petit bouton avec un nombre : cliquez dessus pour ouvrir le journal, faites un clic droit pour ces options. Décochée, elle quitte le menu après un /reload."
L.OPTIONS_DOCK = "Ancrer en haut à gauche"
L.OPTIONS_DOCK_TIP = "Cochée : le journal s'ouvre en haut à gauche de l'écran, là où le jeu ouvre ses propres fenêtres, et se décale quand l'une d'elles s'ouvre à cet endroit, comme elles le font entre elles ; s'il n'y a pas de place pour les deux, le jeu ferme la plus ancienne. Faites-le glisser pour le déplacer où vous voulez : il se réancre à sa prochaine ouverture. Décochée : il s'ouvre là où vous l'avez déplacé en dernier."
-- Test mode's button, last on the options' page (UI/Options.lua; 2026-11-18; drafted, to be checked).
L.OPTIONS_TEST = "Mode test"
L.OPTIONS_TEST_BUTTON = "Ouvrir"
L.OPTIONS_TEST_TIP = "Voir la carte, le brouillard et le suivi du parcours de n'importe quel donjon sans y entrer : choisissez un donjon, marquez des boss vaincus, faites comme si vous y étiez. Pour cette session seulement : rien n'est enregistré, et un /reload le termine."
L.OPTIONS_DUNGEON_FOG = "Brouillard des cartes de donjon"
L.OPTIONS_DUNGEON_FOG_TIP = "Les cartes de donjon commencent sous le brouillard, seule l'entrée est dégagée. Chaque boss vaincu par votre groupe dégage ses salles et le chemin du retour, et le dernier dégage toute la carte ; ce qui est dégagé le reste. Toujours actif en Mode Aventure. Pour ce personnage seulement."
-- Adventure Mode's news: the chat line for new finds, the minimap button's line while it glows, and their two
-- boxes in the options (2026-11-11; translation drafted, to be checked).
L.ADVENTURE_NEWS = "Nouveau dans votre journal : %s"
L.MINIMAP_NEWS = "Il y a du nouveau dans votre journal."
L.OPTIONS_ADVENTURE_CHAT = "Découvertes dans la discussion"
L.OPTIONS_ADVENTURE_CHAT_TIP = "En Mode Aventure, une ligne dans la discussion quand vous trouvez quelque chose de nouveau pour le journal : un donjon, un boss, du butin, une quête, une faction ou une route aérienne. Cliquez sur un nom pour ouvrir sa page (une route aérienne n'en a pas). Pour tous vos personnages."
L.OPTIONS_ADVENTURE_GLOW = "Bouton de la minicarte lumineux"
L.OPTIONS_ADVENTURE_GLOW_TIP = "En Mode Aventure, le bouton de la minicarte brille quand vous avez trouvé quelque chose de nouveau depuis la dernière ouverture du journal, jusqu'à ce que vous l'ouvriez. Pour tous vos personnages."
L.MINIMAP_LEFT_CLICK = "Cliquez pour ouvrir ou fermer le journal."
L.MINIMAP_RIGHT_CLICK = "Clic droit pour ses options."
L.MINIMAP_DRAG = "Faites glisser pour le déplacer autour de la minicarte."
L.OPTIONS_ARROWS_TIP = "Une flèche verte sur les objets qui sont des améliorations pour votre spécialisation, selon les calculs de la recherche d'équipement : dans vos sacs, dans la fenêtre de butin et lors des jets de butin."
L.WEIGHTS_SHOW_GAINS = "Afficher les poids en infobulle"
L.WEIGHTS_SHOW_GAINS_TIP = "Sous chaque objet, une ligne pour chacune de vos spécialisations : la valeur de l'objet selon ses poids, et une flèche verte avec ce qu'il apporte à votre équipement lorsqu'il s'agit d'une amélioration. Pour tous vos personnages dont la recherche d'équipement est activée."
L.OPTIONS_SOURCES = "Afficher la provenance du butin"
L.OPTIONS_SOURCES_TIP = "Sous chaque objet que l'on trouve dans les donjons et raids du journal, une ligne indiquant le boss et le donjon : dans vos sacs, sur votre personnage, dans les liens de discussion, chez les marchands et partout où le jeu affiche l'objet. Pour tous vos personnages."
L.GEAR_WHY_CUSTOM = "%s (vos poids)"
L.GEAR_SPEC_NAMES = {
	Arms = "Armes", Fury = "Fureur", Protection = "Protection", Holy = "Sacré", Retribution = "Vindicte",
	BeastMastery = "Maîtrise des bêtes", Marksmanship = "Précision", Survival = "Survie",
	Assassination = "Assassinat", Combat = "Combat", Subtlety = "Finesse", Discipline = "Discipline", Shadow = "Ombre",
	Elemental = "Élémentaire", Enhancement = "Amélioration", EnhancementTank = "Amélioration (tank)",
	Restoration = "Restauration", Arcane = "Arcanes", Fire = "Feu", Frost = "Givre", Affliction = "Affliction",
	Demonology = "Démonologie", Destruction = "Destruction", Balance = "Équilibre", FeralBear = "Combat farouche (ours)",
	FeralCat = "Combat farouche (félin)",
}
L.GEAR_UNITS = {
	["attack power"] = "puissance d'attaque", ["ranged attack power"] = "puissance d'attaque à distance",
	["spell damage"] = "dégâts des sorts", healing = "soins", Stamina = "endurance",
}
L.WEIGHT_GROUPS = {
	PRIMARY = "Caractéristiques principales", WEAPONS = "Armes", SPELLS = "Sorts", DEFENSE = "Défense",
	RESISTANCE = "Résistances",
}
L.STAT_NAMES = {
	STRENGTH = "Force", AGILITY = "Agilité", STAMINA = "Endurance", INTELLECT = "Intelligence", SPIRIT = "Esprit",
	DPS = "DPS de l'arme", ["RANGED DPS"] = "DPS de l'arme à distance", ["ATTACK POWER"] = "Puissance d'attaque",
	["RANGED ATTACK POWER"] = "Puissance d'attaque à distance", ["FERAL ATTACK POWER"] = "Puissance d'attaque farouche", HIT = "Toucher",
	CRIT = "Coup critique", ["RANGED CRIT"] = "Critique à distance", HASTE = "Vitesse d'attaque", ["RANGED HASTE"] = "Vitesse à distance",
	["SPELL POWER"] = "Dégâts et soins", ["SPELL DAMAGE"] = "Dégâts des sorts", HEALING = "Soins", ["SPELL HIT"] = "Toucher des sorts",
	["SPELL CRIT"] = "Critique des sorts", ["HOLY CRIT"] = "Critique du Sacré", ["HOLY DAMAGE"] = "Dégâts du Sacré",
	["FIRE DAMAGE"] = "Dégâts de Feu", ["FROST DAMAGE"] = "Dégâts de Givre", ["NATURE DAMAGE"] = "Dégâts de Nature",
	["SHADOW DAMAGE"] = "Dégâts d'Ombre", ["ARCANE DAMAGE"] = "Dégâts des Arcanes", ["SPELL PENETRATION"] = "Pénétration des sorts",
	MANA = "Mana", ["MANA PER 5"] = "Mana toutes les 5 s", ["CASTING REGEN"] = "Régénération pendant l'incantation",
	ARMOR = "Armure", HEALTH = "Points de vie", ["HEALTH PER 5"] = "Points de vie toutes les 5 s", DEFENSE = "Défense", DODGE = "Esquive",
	PARRY = "Parade", BLOCK = "Blocage", ["BLOCK VALUE"] = "Valeur de blocage",
	["HOLY RESISTANCE"] = "Résistance au Sacré", ["FIRE RESISTANCE"] = "Résistance au Feu",
	["NATURE RESISTANCE"] = "Résistance à la Nature", ["FROST RESISTANCE"] = "Résistance au Givre",
	["SHADOW RESISTANCE"] = "Résistance à l'Ombre", ["ARCANE RESISTANCE"] = "Résistance aux Arcanes",
}
L.RECORD_START = "Lancer l'enregistrement"
L.RECORD_STOP = "Arrêter l'enregistrement"
L.RECORD_CLEAR = "Effacer"
L.RECORD_CLEAR_CONFIRM = "Supprimer tout ce qui a été enregistré jusqu'ici ? Cette action est irréversible."
L.RECORD_STATUS_ON = "Enregistrement depuis %s"
L.RECORD_STATUS_OFF = "Pas d'enregistrement en cours"
L.RECORD_COMBATLOG = "Écrire le journal de combat dans les donjons"
L.RECORD_COMBATLOG_TIP = "Les techniques des boss proviennent du journal de combat du jeu. Le journal des instances l'active dans les donjons et le coupe à la sortie ; s'il a été lancé par vous, il n'y touche pas. Pour l'envoyer, ajoutez le fichier du journal de combat à votre enregistrement sur la page Log Reader (Copier affiche le lien)."
L.RECORD_RECENT = "Récent"
L.RECORD_NOTHING_YET = "Rien n'a encore été capturé. Entrez dans un donjon avec l'enregistrement activé, puis tuez, ramassez le butin et faites vos quêtes comme d'habitude."
L.RECORD_STARTED = "Enregistrement lancé. /aegis record l'arrête."
L.RECORD_STOPPED = "Enregistrement arrêté."
L.RECORD_LOG_STARTED = "Enregistrement lancé."
L.RECORD_LOG_STOPPED = "Enregistrement arrêté."
L.RECORD_LOG_CLEARED = "Enregistrements effacés."
L.RECORD_LOG_ENTERED = "Vous entrez dans %s."
L.RECORD_LOG_LEFT = "Vous avez quitté le donjon."
L.RECORD_LOG_AREA = "Nouvelle zone : %s."
L.RECORD_LOG_PULL = "Engagé : %s."
L.RECORD_LOG_KILL = "Tué : %s."
L.RECORD_LOG_WIPE = "Défaite face à %s."
L.RECORD_LOG_LOOT = "Butin : %d nouvel(s) objet(s)."
L.RECORD_LOG_QUEST_OFFERED = "Quête proposée : %s."
L.RECORD_LOG_QUEST_DONE = "Quête rendue : %s."
L.RECORD_LOG_ENTRANCE = "Entrée enregistrée : %s."
L.RECORD_LOG_NO_ENTRANCE = "Entrée non enregistrée pour %s : %s."
L.RECORD_NO_MAP = "le jeu n'a fourni aucune carte au début de l'écran de chargement"
L.RECORD_NO_POSITION = "le jeu n'a fourni aucune position au début de l'écran de chargement"
L.RECORD_IN_DUNGEON_MAP = "l'écran de chargement a commencé sur la carte d'un donjon"
L.RECORD_LOG_COMBATLOG_ON = "Journal de combat activé : Logs\\%s."
L.RECORD_LOG_COMBATLOG_OFF = "Journal de combat désactivé."

L.LEVEL_RANGE = "Niveaux %d-%d"
L.LEVEL_ALL = "Tous les niveaux"
L.LEVEL_BRACKET = "Niveaux %d à %d"
L.TRASH_DROPS = "Butin des monstres"
L.UNTESTED = "Pas encore testé"
L.UNTESTED_NOTE = "Pas encore testé : ce qui figure ici provient de l'annonce de Blizzard et peut être incomplet. Faites-le avec l'onglet Enregistrer actif pour compléter ses boss, son butin et son entrée."
L.COMING_SOON = "Bientôt disponible"
L.COMING_SOON_TEXT = "Pas encore ouvert dans WoW: Forever. Ses boss, son butin et sa carte arrivent au fil des parcours enregistrés par les joueurs. Vous en avez enregistré un ? Publiez-le sur notre Discord, et votre nom rejoindra les contributeurs du journal."
L.COMING_SOON_PARTLY = "Pas encore ouvert dans WoW: Forever : ce qui figure ici provient de l'annonce de Blizzard. Vous avez enregistré un parcours ? Publiez-le sur notre Discord, et votre nom rejoindra les contributeurs du journal."
L.DISCORD_COPY_HINT = "Cliquez, puis Ctrl+C"
L.FOREVER_MARK = "Nouveauté de WoW: Forever"
L.RECORD_LOG_VENDOR = "%s : %d articles conservés, %d nouveaux pour le journal."
L.RECORD_CAUGHT = "%d capturés, %d nouveaux depuis votre dernière copie"
L.RECORD_COPY = "Copier"
L.RECORD_AUTO = "Enregistrer automatiquement dans les donjons"
L.RECORD_AUTO_TIP = "L'enregistrement démarre tout seul quand vous entrez dans un donjon ou un raid, et s'arrête quand vous en sortez. Un enregistrement que vous avez lancé vous-même n'est jamais arrêté à votre place."
L.RECORD_RECORDER = "Enregistreur"
L.RECORD_SEND = "Envoyez-le-nous"
L.RECORD_HELP_TEXT = "Cliquez sur Copier, puis collez le texte sur notre Discord :"
L.RECORD_CREDIT = "Me créditer sous le nom :"
L.RECORD_CREDIT_TIP = "Le nom sous lequel vos enregistrements sont crédités parmi les contributeurs du journal. Laissé vide, c'est le nom de votre personnage."
L.RECORD_CONTRIBUTORS = "Contributeurs"
L.RECORD_CONTRIBUTORS_NONE = "Personne pour l'instant : soyez le premier."
L.RECORD_CONTRIBUTORS_FOOT = "Envoyez le vôtre : votre nom apparaîtra ici."
L.RECORD_COPY_TITLE = "Votre enregistrement, en texte"
L.RECORD_COPY_HINT = "Tout est sélectionné : appuyez sur Ctrl+C, puis collez-le sur notre Discord."
L.RECORD_COPY_HINT_LOG = "Appuyez sur Ctrl+C, puis collez-le dans le Log Reader avec votre journal de combat (%s, dans le dossier Logs du jeu). Publiez le résultat sur notre Discord."
L.RECORD_MORE_LOGS = "%s et %d plus anciens"
L.RECORD_BACK = "Retour"
L.RECORD_CAUGHT_TITLE = "Ce que vous avez capturé"
L.RECORD_ITEM = "Objet %s"
L.RECORD_ONE_VISIT = "1 visite"
L.RECORD_VISITS = "%d visites"
L.RECORD_ENTRANCE_YES = "entrée enregistrée"
L.RECORD_ENTRANCE_NO = "entrée pas encore enregistrée"
L.RECORD_AREAS = "%d zones"
L.RECORD_KILLED = "Tués : %s"
L.RECORD_KILLED_TIMES = "%s (%d)"
L.RECORD_DROPS = "Butin : %s nouveaux, %s déjà dans le journal"
L.RECORD_OFF = "Sur %s"
L.RECORD_OFF_TRASH = "Sur les monstres"
L.RECORD_OFF_GROUP = "Ramassé par votre groupe"
L.RECORD_OFF_OBJECTS = "Sur les coffres et les plantes"
L.RECORD_QUESTS = "Quêtes"
L.RECORD_QUEST_DONE = "rendue"
L.RECORD_NEW = "nouveau"
L.RECORD_QUARTERMASTERS = "Intendants"
L.RECORD_WARES = "%s : %d articles, %s nouveaux"
L.RECORD_TRAVEL = "Points de voyage : %d"
L.RECORD_MODELS = "Modèles : %d"
L.FOREVER_LINE = "Nouveauté de WoW: Forever."
L.LOCATION_LINE = "Emplacement : %s"

-- The dungeon's round icon at the top of its left page: its tooltip, under the dungeon's name (2026-11-04; drafted, to be checked).
L.INSTANCE_ICON_OVERVIEW = "Cliquez pour voir sa vue d'ensemble."

L.TAB_OVERVIEW = OVERVIEW or "Vue d'ensemble"
L.TAB_LOOT = LOOT_NOUN or "Butin"
L.TAB_ABILITIES = ABILITIES or "Techniques"
L.TAB_MODEL = MODEL or "Modèle"
L.TAB_QUESTS = QUESTS_LABEL or "Quêtes"
L.ALL_CLASSES = ALL_CLASSES or "Toutes les classes"
L.ALL_ARMOR = "Toutes les armures"
L.ALL_TYPES = "Tous les types"
-- The loot pages' Type menu: the kinds of item, "All ..." atop the two with a submenu, and one of each.
L.LOOT_KIND = {
	EQUIPMENT = "Équipement", RECIPE = "Recettes", CONSUMABLE = "Consommables", MOUNT = "Montures", PET = "Mascottes",
	TOY = "Jouets", BAG = "Sacs", TRADE = "Artisanat", QUEST = "Objets de quête", OTHER = "Autres",
}
L.LOOT_KIND_ALL = { EQUIPMENT = "Tout l'équipement", RECIPE = "Toutes les recettes" }
L.LOOT_KIND_ONE = { MOUNT = "Monture", PET = "Mascotte", TOY = "Jouet" }
L.LOOT_RECIPE = "Recette"
-- A loot row's type where the client cannot describe the item (2026-11-19; drafted, to be checked).
L.LOOT_QUEST_ITEM = "Objet de quête"
L.LOOT_WORDS = {
	Alchemy = "Alchimie", Blacksmithing = "Forge", Cooking = "Cuisine", Enchanting = "Enchantement",
	Engineering = "Ingénierie", ["First Aid"] = "Secourisme", Fishing = "Pêche", Leatherworking = "Travail du cuir",
	Tailoring = "Couture", Book = "Livre", Blueprint = "Plan", Bag = "Sac", ["Ammo Pouch"] = "Giberne",
	Quiver = "Carquois", Arrow = "Flèche", Bullet = "Balle", Consumable = "Consommable",
	["Food & Drink"] = "Nourriture et boissons", Potions = "Potions", Junk = "Camelote", Key = "Clé", Other = "Autre",
	Parts = "Pièces", Reagent = "Composant", Weapon = "Arme", Cloth = "Tissu", Leather = "Cuir", Mail = "Mailles",
	Plate = "Plaques", Shield = "Bouclier", Idol = "Idole", Libram = "Libram", Totem = "Totem", Axe = "Hache",
	Bow = "Arc", Crossbow = "Arbalète", Dagger = "Dague", ["Fist Weapon"] = "Arme de pugilat", Gun = "Arme à feu",
	Mace = "Masse", Polearm = "Arme d'hast", Staff = "Bâton", Sword = "Épée", Wand = "Baguette",
}
L.LOOT_FAVORITES = "Favoris"
L.LOOT_FAVORITES_ONLY = "Favoris uniquement"
L.LOOT_FAVORITE = "Ajouter aux favoris"
L.LOOT_UNFAVORITE = "Retirer des favoris"
L.LOOT_PINNED = "Épinglés"
L.LOOT_ALL = "Butin"
L.LOOT_TRASH = "Monstres du donjon"
L.LOOT_BOSSES_AND_RARES = "Tous les boss et monstres rares"
L.LOOT_BOSSES_AND_RARES_NOTE = "Butin des boss et monstres rares du donjon, pas de ses autres monstres."
-- A Recipes page's row the bosses drop, and a row not seen dropping yet (2026-11-20; drafted, to be checked).
L.LOOT_ANY_BOSS = "Tous les boss"
L.LOOT_ANY_BOSS_NOTE = "Butin des boss du donjon, pas de ses autres monstres."
L.LOOT_NOT_SEEN_NOTE = "Pas encore vu en butin."
L.DROPS_FROM_BOSS = "Butin : %s (%s)"
L.DROPS_FROM_TRASH = "Butin des monstres (%s)"
L.DROPS_FROM_BOSSES = "Butin de %d boss (%s)"
L.DROPS_FROM_BOSSES_AND_RARES = "Butin des boss et monstres rares (%s)"
L.DROPS_FROM_ANY_BOSS = "Butin des boss (%s)"
L.DROPS_IN = "Butin dans : %s"
L.DROPS_ALSO_IN = "Butin aussi dans : %s"
L.LEGEND_CLICK_HIDE = "Cliquez pour les masquer sur la carte."
L.LEGEND_CLICK_SHOW = "Masqués. Cliquez pour les afficher de nouveau sur la carte."
-- The legend's Quest entry, the journal's own switch for its ! marks: what it does (2026-11-06; drafted, to be checked).
L.LEGEND_QUEST_TIP = "Les marques ! du journal sur les cartes : les quêtes que vous pouvez prendre, et en gris celles pas encore ouvertes."
L.LEGEND_GAME_FILTER = "Un filtre de la carte du jeu, comme dans son menu de filtres : les quêtes en cours et celles prêtes à être rendues partagent le même."
L.LEGEND_GAME_FILTER_MENU = "Affichés ou masqués depuis le menu de filtres de la carte : %s."
L.PREPARE_TITLE = "Avant de partir"
L.PREPARE_PROGRESS = "Vous avez terminé %d de ses %d quêtes."
-- The same for a key with one quest (2026-10-30; drafted, to be checked).
L.PREPARE_PROGRESS_ONE = "Vous n'avez pas encore terminé sa quête."
L.PREPARE_HAVE = "Vous l'avez."
-- A chain of quests done, Before you go (2026-11-12; drafted, to be checked).
L.PREPARE_CHAIN_DONE = "Vous avez terminé ses quêtes."
-- Before you go's line on a dungeon's overview, pointing to the Quests tab (2026-11-13; drafted, to be checked).
L.PREPARE_POINTER = "Avant de partir : %d notes, dans l'onglet Quêtes."
L.PREPARE_POINTER_ONE = "Avant de partir : 1 note, dans l'onglet Quêtes."
-- The Play button beside the lore, which plays Spoken's recorded story; "Spoken" kept as it is (2026-11-13; drafted, to be checked).
L.SPOKEN_PLAY = "Écouter l'histoire"
L.SPOKEN_REPLAY = "Réécouter l'histoire"
L.SPOKEN_STOP = "Arrêter"
L.SPOKEN_BY = "Lu à voix haute par Spoken."
L.SPOKEN_REQUIRES = "Nécessite Spoken"
L.SPOKEN_ABOUT_PLACE = "Lit à voix haute l'histoire de ce lieu."
L.SPOKEN_ABOUT_BOSS = "Lit à voix haute l'histoire de ce boss."
L.SPOKEN_NO_STORY_PLACE = "Spoken n'a aucune histoire enregistrée pour ce lieu."
L.SPOKEN_NO_STORY_BOSS = "Spoken n'a aucune histoire enregistrée pour ce boss."
-- Spoken's own story API says no, the reason not known (2026-11-14; drafted, to be checked).
L.SPOKEN_NO_STORY_YET = "Spoken n'a encore aucune histoire qu'il puisse lire ici."
L.SPOKEN_NEEDS_BOSS_VOICES = "Nécessite les voix des boss de Spoken, qui ne sont pas installées."
L.SPOKEN_NEEDS_PLACE_VOICES = "Nécessite les voix des lieux de Spoken, qui ne sont pas installées."
L.SPOKEN_OFF = "Désactivé dans les options de Spoken."
L.SPOKEN_LOCKED_PLACE = "Spoken raconte cette histoire une fois que vous avez trouvé ce lieu."
L.SPOKEN_LOCKED_BOSS = "Spoken raconte cette histoire une fois que vous avez rencontré ce boss."
L.QUESTS_DUNGEON = "Quêtes du donjon"
-- The same on a raid's Quests tab (2026-10-30; drafted, to be checked).
L.QUESTS_RAID = "Quêtes du raid"
-- The Quests tab's dropdown of the quests for the player's class alone (2026-11-03; drafted, to be checked).
L.QUESTS_CLASS = "Quêtes de classe"
L.TRASH = "Monstres du donjon"
L.TRASH_DESCRIPTION = "Ce que laissent tomber les autres créatures du donjon et qui mérite d'être connu : équipement rare et épique, recettes et objets de quête."
-- The recipes' entry in a dungeon's boss list, and its page (drafted, to be checked).
L.RECIPES = "Recettes"
L.RECIPES_DESCRIPTION = "Les recettes, plans et patrons que laissent tomber les boss et les autres créatures du donjon. La recette propre à un boss figure aussi sur la page de ce boss."
L.LOOT_BOSS_LINE = BOSS_INFO_STRING or "Boss : %s"
L.LOOT_FILTER_BAR = "Filtre : %s"
L.LOOT_RETRIEVING = RETRIEVING_ITEM_INFO or "Récupération des informations de l'objet"
L.LOOT_NO_DATA = "Objet %d"
L.LOOT_NO_DATA_TOOLTIP = "Le serveur n'a pas envoyé les détails de cet objet. Il n'est peut-être pas encore en jeu."
L.LOOT_UNIDENTIFIED_TOOLTIP = "Pas encore identifié : sa source le nomme, mais sans donner son identifiant d'objet. Ramassez-le pendant un enregistrement pour l'ajouter."
L.LOOT_TOOLTIP_PIN = "Clic droit pour épingler cet objet en haut de cette liste."
L.LOOT_TOOLTIP_UNPIN = "Clic droit pour le désépingler."
L.LOOT_NONE = "Aucun butin n'est encore connu ici."
L.LOOT_NO_MATCH = "Rien ici ne correspond aux filtres. Effacez-les avec le X ci-dessus."
L.ABILITY_LOADING = RETRIEVING_DATA or "Récupération des données..."
L.ABILITIES_NONE = "Aucune technique n'est encore connue pour cette rencontre. Enregistrez un parcours depuis l'onglet Enregistrer pour les capturer."
L.STATS_HIT = "Inflige %s"
L.STATS_TICK = "tics de %s"
L.STATS_FIRST = "première incantation à %d s"
L.STATS_EVERY = "puis toutes les %s s"
L.QUEST_NONE = "Aucune quête pour votre faction n'est connue dans ce donjon."
L.QUEST_STATUS_READY = "Terminée : prête à être rendue"
L.QUEST_STATUS_NEEDS = "Requiert : %s"
L.QUEST_STATUS_LEVEL = "Niveau %d requis"
L.QUEST_DESCRIPTION = QUEST_DESCRIPTION or "Description"
L.QUEST_START_ITEM = "Commence par :"
L.QUEST_PARTS = "%s (%d parties)"
-- A row for the quests of one chain that share a name: which of them its page shows (2026-11-04; drafted, to be checked).
L.QUEST_PART_OF = "Partie %d sur %d"
-- One of them as a row of its own, in a chain: which part it is (2026-11-06; drafted, to be checked).
L.QUEST_PART_NAME = "%s (Partie %d)"
-- A step any one of several quests will do (2026-10-30; drafted, to be checked).
L.QUEST_STATUS_NEEDS_VERSION = "Requiert l'une des %d versions de %s"
L.QUEST_STATUS_NEEDS_ONE_OF = "Requiert l'une de ces quêtes : %s"
-- A quest given only while another is in the log (2026-11-03; drafted, to be checked).
L.QUEST_STATUS_NEEDS_IN_LOG = "Requiert : %s dans votre journal de quêtes"
L.QUEST_OR = " ou "
L.QUEST_LIST_COMMA = ", "
L.QUEST_ONE_OF_VERSIONS = "Cette quête existe en %d versions. N'importe laquelle convient."
L.QUEST_ONE_OF_ANY = "N'importe laquelle de ces quêtes convient."
L.QUEST_SHOW_START = "Voir le début"
L.QUEST_SHOW_END = "Voir la fin"
L.QUEST_PLACE_UNKNOWN = "Emplacement encore inconnu. Prenez ou rendez cette quête avec l'onglet Enregistrer actif pour l'ajouter."
L.QUEST_OFFERED_BY = "Quête donnée par %s"
L.QUEST_HAND_IN_TO = "À rendre à %s"
L.QUESTMAP_DUNGEON_QUEST = "Quête de donjon : %s"
L.QUESTMAP_RAID_QUEST = "Quête de raid : %s"
L.QUESTMAP_LEFT_CLICK = "Clic gauche pour l'ouvrir dans le journal"
L.QUESTMAP_WAYPOINT_SET = "Point de cheminement placé pour %s."
L.QUESTMAP_WAYPOINT_SET_IN = "Point de cheminement placé pour %s (%s)."
L.WAYPOINT_OFFER = "Cliquez sur %s pour placer le point de cheminement."
L.QUESTMAP_ONE_OF = "Pas toujours au même endroit : l'un de %d emplacements."
-- What is looted, used or explored for a quest inside a dungeon, on its mark's tooltip, after the game's dash: the
-- item to take, the same for a name with no "the" in English, the thing to use, a place to explore (2026-11-11;
-- translation drafted, to be checked).
L.QUESTMAP_OBJECTIVE_TAKE = "Prendre : %s"
L.QUESTMAP_OBJECTIVE_TAKE_NAMED = "Prendre : %s"
L.QUESTMAP_TITLE_QUOTED = "« %s »"
L.QUESTMAP_OBJECTIVE_USE = "Utiliser : %s"
L.QUESTMAP_OBJECTIVE_EXPLORE = "Explorer cet endroit"
-- At the Drowned City's tablets of I'lalai, a rubbing with the hide and charcoal (2026-11-12; drafted, to be checked).
L.QUESTMAP_OBJECTIVE_RUBBING = "Faire un frottage avec la peau et le fusain"
-- A Matrix Punchograph's step, what goes in, then what comes out, in short words ("Yellow > Blue"), and the punch
-- cards' colors, as the cards' own names in the language have them (2026-11-12, the owner's "Blue > Red"; drafted, to
-- be checked); where what goes in drops (2026-11-12; drafted, to be checked).
L.QUESTMAP_OBJECTIVE_STEP = "%s > %s"
L.QUESTMAP_CARD_WHITE = "Blanche"
L.QUESTMAP_CARD_YELLOW = "Jaune"
L.QUESTMAP_CARD_BLUE = "Bleue"
L.QUESTMAP_CARD_RED = "Rouge"
L.QUESTMAP_CARD_PRISMATIC = "Prismatique"
L.QUESTMAP_NOTE_INPUT_DROPS = "On obtient %s sur les monstres de ces tunnels."
-- A machine used again once its quest is done: it takes another of what it cleans (2026-11-12; drafted, to be checked).
L.QUESTMAP_REPEAT_AGAIN = "Répétable : insérez un autre exemplaire de %s."
-- What a boss is to a quest, on his tooltip under his quest badge: one to kill, one that drops what the quest needs,
-- the same for a name with no "the" in English, one whose drop starts the quest; who gives or takes it there,
-- himself or by name; a quest's mob more than a boss (2026-11-11; translation drafted, to be checked).
L.QUEST_BADGE_KILL = "À tuer pour cette quête"
L.QUEST_BADGE_DROPS = "Butin : %s"
L.QUEST_BADGE_DROPS_NAMED = "Butin : %s"
L.QUEST_BADGE_STARTS = "Butin : %s (commence une quête)"
L.QUEST_BADGE_STARTS_NAMED = "Butin : %s (commence une quête)"
L.QUEST_BADGE_GIVES = "Donne cette quête"
L.QUEST_BADGE_GIVES_WHO = "%s donne cette quête ici"
L.QUEST_BADGE_TAKES = "À rendre ici"
L.QUEST_BADGE_TAKES_WHO = "À rendre ici à : %s"
L.QUEST_TARGET = "Cible de quête"
L.MAP_ONE_OF = "Pas toujours au même endroit : l'un de %d emplacements."
L.QUEST_REWARDS = REWARDS or "Récompenses"
L.QUEST_YOU_RECEIVE = YOU_RECEIVE or "Vous recevrez :"
L.QUEST_XP = "%s points d'expérience"
-- XP that is only the original game's number, not yet confirmed on Forever: a note after it, and
-- its tooltip (2026-10-30; drafted, to be checked).
L.QUEST_XP_ORIGINAL = "(jeu d'origine)"
L.QUEST_XP_ORIGINAL_TIP = "C'est ce que donnait la quête dans le jeu d'origine. Forever donne peut-être plus. Ce n'est pas encore vérifié sur Forever. Rendez-la avec l'onglet Enregistrer actif pour ajouter ce que donne Forever."
L.QUEST_REPUTATION = "%d points de réputation auprès de %s"
L.QUEST_CHOOSE = REWARD_CHOICES or "Vous pourrez choisir une de ces récompenses :"
L.QUEST_ALSO = REWARD_ITEMS or "Vous recevrez également :"
L.REP_REWARDS = "%d récompenses"
L.REP_REWARD_ONE = "1 récompense"
L.REP_ALL_REWARDS = "Récompenses"
-- The group for wares that need no standing (2026-11-12; drafted, to be checked)
L.REP_ANY_STANDING = "Toute réputation"
L.REP_UNKNOWN = "Non rencontrée"
L.REP_CARD_CLICK = "Cliquez pour voir ses récompenses."
L.REP_YOUR_STANDING = "Votre réputation : %s"
L.REP_NOT_MET = "Vous n'avez pas encore rencontré cette faction."
L.REP_PROGRESS = "%s / %s"
L.REP_QUARTERMASTER = "Intendant : %s"
L.REP_CAPTURE = "Capturer le marchand"
L.REP_CAPTURE_TIP = "Approchez-vous d'un intendant de réputation et ouvrez sa boutique, puis appuyez sur ce bouton. Tout ce qu'il vend est conservé : le prix de chaque article, tout autre coût et la réputation requise. Les articles rejoignent aussitôt les récompenses de leur faction, et sont inclus quand vous cliquez sur Copier dans l'onglet Enregistrer."
L.REP_CAPTURE_READY = "Boutique ouverte : appuyez sur Capturer le marchand."
L.REP_CAPTURE_HINT = "Ouvrez la boutique d'un intendant pour capturer ses articles."
L.REP_CAPTURED = "%s : %d articles pour %s, %d nouveaux."
L.REP_CAPTURED_NONE = "%s : %d articles conservés ; aucun ne requiert de réputation."
L.REP_CAPTURED_UNKNOWN = "%s : %d articles requièrent une réputation auprès d'une faction que le jeu ne nomme pas ; conservés jusqu'à ce qu'un article la nomme."
L.REP_NOT_CAPTURED = "Pas encore capturé"
L.REP_NOT_CAPTURED_TIP = "Personne n'a encore capturé l'intendant de cette faction."
L.REP_NOT_CAPTURED_TEXT = "Personne n'a encore capturé l'intendant de cette faction. Trouvez-en un, ouvrez sa boutique et appuyez sur Capturer le marchand dans l'onglet Réputation, puis publiez votre enregistrement sur notre Discord. Votre nom rejoindra les contributeurs du journal."
L.REP_LISTED_TIP = "Ses récompenses proviennent des données d'objets du jeu et n'ont pas encore été confirmées auprès d'un intendant."
L.REP_LISTED_TEXT = "Ces récompenses proviennent des données d'objets du jeu, pas encore d'un intendant : elles n'ont donc pas de prix, et certaines ne sont peut-être pas vendues du tout. Trouvez l'un des intendants de cette faction, ouvrez sa boutique et appuyez sur Capturer le marchand dans l'onglet Réputation, puis publiez votre enregistrement sur notre Discord. Votre nom rejoindra les contributeurs du journal."
L.REP_COMING_SOON_TEXT = "Nouveauté de WoW: Forever, pas encore capturée. Une fois qu'elle sera en jeu, trouvez son intendant, ouvrez sa boutique et appuyez sur Capturer le marchand dans l'onglet Réputation, puis publiez votre enregistrement sur notre Discord."
-- The Reputation tab's Vendors: a page for each currency a vendor takes for wares that need no standing (2026-11-12; drafted, to be checked).
L.REP_VENDORS = "Marchands"
L.CURRENCY_YOU_HAVE = "Vous avez %s"
L.CURRENCY_VENDOR = "Marchand : %s"
L.CURRENCY_CARD_CLICK = "Cliquez pour voir ses articles."
L.REP_CAPTURED_CURRENCY = "%s : %d articles conservés, vendus contre %s."
-- Where Carved Centaur Totems come from, on its Vendors card and page (2026-11-13; drafted, to be checked: %s is the item's name as the client writes it; the quests keep their English names, their names in this language not known).
L.CURRENCY_NOTE_CENTAUR_TOTEM = "%s : les centaures de tous les clans de Désolace en laissent tomber, et la quête « Khan Hratha » en donne dix. La quête « Carved Centaur Totems » en demande cinq, à l'Alliance comme à la Horde."
L.MAP_SHOW = ENCOUNTER_JOURNAL_SHOW_MAP or "Afficher la carte"
L.MAP_SHOW_UNEXPLORED = "Afficher les zones inexplorées"
L.OPTIONS_UNEXPLORED_TIP = "Ombre sur la carte du monde les parties de chaque zone que vous n'avez pas encore explorées."
-- The map legend's Fog of War switch, the last of Movement's, and its tooltip (2026-11-11; translation drafted, to be checked).
L.LEGEND_FOG = "Brouillard de guerre"
L.LEGEND_FOG_TOOLTIP = "Masque les parties d'une zone que vous n'avez pas encore explorées et celles de la carte d'un donjon que votre groupe n'a pas encore dégagées."
L.LEGEND_FOG_ZONE_HIDDEN = "La carte ne montre que les parties de cette zone que vous avez explorées."
L.LEGEND_FOG_ZONE_SHOWN = "Les parties de cette zone que vous n'avez pas explorées sont aussi affichées, un peu plus sombres."
L.LEGEND_FOG_ZONE_SHOW = "Cliquez pour afficher les parties inexplorées."
L.LEGEND_FOG_ZONE_HIDE = "Cliquez pour n'afficher que les parties explorées."
L.LEGEND_FOG_DUNGEON_ON = "Le brouillard couvre les parties de cette carte que vous n'avez pas encore dégagées. Chaque boss vaincu par votre groupe dégage ses salles."
L.LEGEND_FOG_DUNGEON_OFF = "Le brouillard est désactivé : toute la carte est visible."
L.LEGEND_FOG_DUNGEON_CLEARED = "Le brouillard s'est dissipé : toute la carte est visible."
L.LEGEND_FOG_DUNGEON_LIFT = "Cliquez pour désactiver le brouillard."
L.LEGEND_FOG_DUNGEON_LAY = "Cliquez pour activer le brouillard."
L.LEGEND_FOG_ADVENTURE = "Ne peut pas être désactivé en Mode Aventure."
L.LEGEND_FOG_NONE = "Pas de brouillard de guerre sur cette carte."
L.LEGEND_FOG_ZONE_EXPLORED = "Vous avez exploré toute cette zone."
L.MAP_FILTER_QUESTS = "Quêtes disponibles"
L.MAP_FILTER_DUNGEONS = "Entrées de donjon"
L.MAP_FILTER_RAIDS = "Entrées de raid"
L.MAP_FILTER_FLIGHT = "Points de vol"
L.MAP_FILTER_CAVES = "Entrées de grotte"
L.MAP_FILTER_TRANSPORT = "Bateaux, zeppelins, trams et portails"
L.MAP_PIN_OPEN = "Cliquez pour l'ouvrir dans le journal."
L.MAP_DEFEATED = DUNGEON_ENCOUNTER_DEFEATED or "Vaincu"
L.MAP_FOG_HINT = "Vainquez-le pour dissiper le brouillard ici."
L.MAP_UNMET_HINT = "Aucune rencontre pour l'instant."
L.MAP_LEVEL = "Niveau %d"
L.MAP_FLOOR = "Niveau %d"
L.MAP_GO_TO = "Vers %s"
-- Under a way between floors, where two lead to one floor (the Drowned City's), where it comes out
-- (2026-11-17; drafted, to be checked).
L.MAP_WAY_OUT_SOUTHWEST = "Débouche à l'extrémité sud-ouest"
L.MAP_WAY_OUT_NORTHEAST = "Débouche à l'extrémité nord-est"
L.MAP_WAY_OUT_DEEP_ARCHIVES = "Débouche dans les Archives profondes"
L.MAP_WAY_OUT_CENTRAL_POOL = "Débouche dans le bassin central"
L.MAP_YOU_ARE_HERE = "Vous êtes ici"
L.ENTRANCE_DUNGEON = LFG_TYPE_DUNGEON or "Donjon"
L.ENTRANCE_RAID = LFG_TYPE_RAID or "Raid"
L.ENTRANCE_DUNGEONS = DUNGEONS or "Donjons"
L.ENTRANCE_RAIDS = RAIDS or "Raids"
L.ENTRANCE_LEFT_CLICK = "Clic gauche pour ouvrir le journal des instances"
L.ENTRANCE_CHOOSE_LEFT_CLICK = "Clic gauche pour choisir laquelle ouvrir dans le journal des instances"
L.ENTRANCE_RIGHT_CLICK = "Clic droit pour placer un point de cheminement"
L.ENTRANCE_WAYPOINT_SET = "Point de cheminement placé à l'entrée : %s."
L.ENTRANCE_VIA = "Son portail se trouve en contrebas, dans la zone « %s » : descendez à l'entrée de la grotte."
L.ENTRANCE_WAYPOINT_VIA = "Point de cheminement placé à la descente vers %s, pour %s."
L.CAVE_LABEL = "Entrée de grotte"
L.BUILDING_LABEL = "Entrée"
L.ENTRANCE_VIA_BUILDING = "Son portail se trouve à l'intérieur, dans %s : entrez par l'entrée."
L.CAVE_LEADS_TO = "Le chemin vers %s"
L.CAVE_LEFT_CLICK = "Clic gauche pour voir la carte : %s"
L.CAVE_WAYPOINT_SET = "Point de cheminement placé à la descente vers %s."
L.FLIGHT_POINT = MAP_LEGEND_FLIGHTPOINT or "Point de vol"
L.CLICK_FOR_WAYPOINT = "Cliquez pour placer un point de cheminement"
L.FLIGHT_WAYPOINT_SET = "Point de cheminement placé sur le maître de vol : %s."
L.TRAVEL_KINDS = { boat = "Bateau", zeppelin = "Zeppelin", airship = "Dirigeable", tram = "Tram", portal = "Portail" }
L.TRAVEL_FACTIONS = { Alliance = FACTION_ALLIANCE or "Alliance", Horde = FACTION_HORDE or "Horde" }
L.TRAVEL_ROUTE = "%s vers %s"
L.TRAVEL_AND = "%s et %s"
L.TRAVEL_ROUTE_NOTE = "%s : %s"
L.TRAVEL_HELP = "Placez-vous à un quai, une tour de zeppelin, un tram ou un portail et tapez /aegis travel boat (ou zeppelin, airship, tram, portal) suivi de la destination, par exemple /aegis travel boat Auberdine. Ajoutez alliance, horde ou neutral à la fin pour indiquer qui il dessert, et une note entre parenthèses pour indiquer qui peut l'emprunter, par exemple /aegis travel portal Dalaran (Réservé aux Nés-du-ciel). /aegis travel list affiche ce qui est enregistré ; /aegis travel undo annule le dernier."
L.TRAVEL_NO_POSITION = "Le jeu ne donne aucune position ici, donc rien n'a été enregistré."
L.TRAVEL_SAVED = "Enregistré : %s à %s. /aegis travel undo l'annule."
L.TRAVEL_UNDONE = "Annulé : %s à %s."
L.TRAVEL_NOTHING = "Rien à annuler."
L.TRAVEL_LIST_EMPTY = "Aucun point de voyage enregistré pour l'instant. Tapez /aegis travel pour savoir comment faire."
L.TRAVEL_LIST_LINE = "%d. %s à %s (carte %d, %.4f, %.4f)"
L.TRAVEL_WAYPOINT_SET = "Point de cheminement placé : %s."
L.LEGEND_TRANSPORT = "Transport"
L.LEGEND_TRANSPORT_TOOLTIP = "Bateaux, zeppelins, le tram et les portails. Le bleu dessert l'Alliance, le rouge la Horde, l'or tout le monde."
L.LEGEND_CAVE_TOOLTIP = "L'entrée d'une grotte, là où se trouve la porte d'un donjon. Cliquez dessus sur la carte pour voir l'intérieur."
L.LEGEND_BUILDING_TOOLTIP = "L'entrée d'un bâtiment, des salles d'une montagne ou d'un niveau sous la zone, là où se trouve la porte d'un donjon. Cliquez dessus sur la carte pour voir l'intérieur."
L.SEARCH_SHOW_ALL = SEARCH_RESULTS_SHOW_COUNT or "Afficher les %d résultats"
L.SEARCH_RESULTS = ENCOUNTER_JOURNAL_SEARCH_RESULTS or "Résultats de recherche pour « %s » (%d)"
L.SEARCH_TYPE_BOSS = "Rencontre"
L.SEARCH_TYPE_ABILITY = "Technique"
L.SEARCH_TYPE_ITEM = "Objet"
L.SEARCH_TYPE_QUEST = "Quête"
L.SEARCH_TYPE_FACTION = FACTION or "Faction"
L.MAP_PIN_CLEAR = "Cliquez pour retirer ce repère."
L.MAP_PIN_COMBAT = "La carte ne peut pas être ouverte en combat."
L.GAMEPAD_HUD_UP = "Quittez d'abord le mode HUD de l'interface manette, puis réessayez."
L.MAP_PIN_IN_ZONE = "%s est marqué sur la carte : %s."
L.MAP_LEVEL_LINK_CLICK = "Clic gauche pour voir la carte de ce niveau"
-- A place worth knowing on a dungeon's map (UI/DungeonMap.lua's MapSpot): its kind's name, and the Drowned City's
-- hidden chest's line under it (2026-11-17; drafted, to be checked).
L.MAP_SPOT_CHEST = "Coffre caché"
L.MAP_SPOT_DROWNED_CHEST = "Sur l'épave du bateau, au-delà de Min'loth le Serpent. Il n'est pas verrouillé : n'importe qui peut l'ouvrir pour obtenir des objets et des matériaux aléatoires."
L.DOOR_SPIRE_ONE_INSTANCE = "Le pic Rochenoire inférieur et le pic Rochenoire supérieur forment une seule instance, avec une seule porte."
L.DOOR_SPIRE_LOWER = "Pic Rochenoire inférieur : jusqu'à 10 joueurs, mais ses quêtes ne peuvent être terminées qu'en groupe de 5 au plus."
L.DOOR_SPIRE_UPPER = "Pic Rochenoire supérieur : plus loin, derrière une porte scellée qui demande le Sceau d'ascension. Jusqu'à 10 joueurs."

L.RARE_SUFFIX = " (rare)"
L.AND_MORE = "et %d de plus"
L.BULLET_AREA = "Emplacement : %s."
L.BULLET_RARE = "Une apparition rare : vous ne le croiserez pas à chaque passage."
L.BULLET_SUMMONED = "Un boss caché que vous invoquez vous-même : la note ci-dessus explique comment."
-- The same where his note names several bosses, not a hidden boss (2026-11-19; "summon" since 2026-11-20;
-- drafted, to be checked).
L.BULLET_CALLED_UP = "Un boss que vous invoquez vous-même : la note ci-dessus explique comment."
-- A quest's mob, on the map only, on his page (2026-11-11; translation drafted, to be checked).
L.BULLET_QUEST_TARGET = "Une cible de quête, pas l'un des boss du donjon."
L.BULLET_LEVEL = "Une rencontre de niveau %d."
L.BULLET_ABILITIES = "Incantations observées : %s."
L.BULLET_LOOT = "Butin : %d objets, dont %s."
L.BULLET_ADDS = "Accompagné par %s."
L.ADD_DESCRIPTION = "Combat aux côtés de %s."
L.BULLET_NOTHING_YET = "On ne sait encore rien de cette rencontre."

-- The French client's classic "Equip:" wordings (drafted; check against items in game).
L.EQUIP_PATTERNS = {
	-- Bonuses against undead only, and effects on being struck or on a hit: worth nothing.
	{ "morts%-vivants", false },
	{ "de {n}.-chance.-critique.-sacr", "HOLY CRIT" },
	{ "critique.-sacr.-de {n}", "HOLY CRIT" },
	{ "de {n}.-chance.-critique.-sorts", "SPELL CRIT" },
	{ "critique.-sorts.-de {n}", "SPELL CRIT" },
	{ "de {n}.-chance.-critique.-distance", "RANGED CRIT" },
	{ "critique.-distance.-de {n}", "RANGED CRIT" },
	{ "de {n}.-chance.-critique", "CRIT" },
	{ "critique de {n}", "CRIT" },
	{ "de {n}.-chance.-toucher.-sorts", "SPELL HIT" },
	{ "toucher.-sorts.-de {n}", "SPELL HIT" },
	{ "de {n}.-chance.-toucher", "HIT" },
	{ "toucher de {n}", "HIT" },
	{ "dégâts et.-soins.-{n}", { "SPELL POWER", "HEALING" } },
	{ "soins et.-dégâts.-{n}", { "SPELL POWER", "HEALING" } },
	{ "les soins.-sorts.-{n}", "HEALING" },
	{ "dégâts.-sorts.-sacr.-{n}", "HOLY DAMAGE" },
	{ "dégâts.-sorts.-feu.-{n}", "FIRE DAMAGE" },
	{ "dégâts.-sorts.-givre.-{n}", "FROST DAMAGE" },
	{ "dégâts.-sorts.-nature.-{n}", "NATURE DAMAGE" },
	{ "dégâts.-sorts.-%Aombre.-{n}", "SHADOW DAMAGE" },
	{ "dégâts.-sorts.-arcane.-{n}", "ARCANE DAMAGE" },
	{ "dégâts.-magiques.-{n}", "SPELL DAMAGE" },
	{ "permet .-{n}.-mana", "CASTING REGEN" },
	{ "{n}.-de votre.-mana.-incant", "CASTING REGEN" },
	{ "de {n}.-sistances? magiques?", "SPELL PENETRATION" },
	{ "sistances? magiques?.-de {n}", "SPELL PENETRATION" },
	{ "puissance d.-attaque.-combat", false },
	{ "puissance d.-attaque contre", false },
	{ "puissance d.-attaque face", false },
	{ "puissance d.-attaque.-morts%-vivants", false },
	{ "puissance d.-attaque.-démons", false },
	{ "^%+{n}.-puissance d.-attaque.-distance", "RANGED ATTACK POWER" },
	{ "de {n}.-puissance d.-attaque.-distance", "RANGED ATTACK POWER" },
	{ "puissance d.-attaque.-distance.-de {n}", "RANGED ATTACK POWER" },
	{ "^%+{n}.-puissance d.-attaque.-félin", "FERAL ATTACK POWER" },
	{ "de {n}.-puissance d.-attaque.-félin", "FERAL ATTACK POWER" },
	{ "de {n}.-puissance d.-attaque", "ATTACK POWER" },
	{ "puissance d.-attaque de {n}", "ATTACK POWER" },
	{ "%+{n}.-puissance d.-attaque", "ATTACK POWER" },
	{ "{n}.-mana toutes les 5", "MANA PER 5" },
	{ "{n}.-vie toutes les 5", "HEALTH PER 5" },
	{ "rend {n} points? de vie", "HEALTH PER 5" },
	{ "défense augment.-{n}", "DEFENSE" },
	{ "défense de {n}", "DEFENSE" },
	{ "de {n}.-défense", "DEFENSE" },
	{ "de {n}.-chance.-esquive", "DODGE" },
	{ "esquive.-de {n}", "DODGE" },
	{ "de {n}.-chance.-parer", "PARRY" },
	{ "parer.-de {n}", "PARRY" },
	{ "de {n}.-chance.-bloquer", "BLOCK" },
	{ "bloquer.-de {n}", "BLOCK" },
	{ "valeur de blocage.-{n}", "BLOCK VALUE" },
	{ "de {n}.-valeur de blocage", "BLOCK VALUE" },
	{ "vitesse d.-attaque.-de {n}", "HASTE" },
	{ "de {n}.-vitesse d.-attaque", "HASTE" },
}

-- The rooms inside dungeons, as the client names them where the player stands: "You are
-- here" and a wing's areas match these (Core/Areas.lua). Unconfirmed ones are listed in
-- the translation's to-check list.
L.AREA_NAMES = {
	-- The Drowned City's areas (Data/Authored/Upcoming.lua's floors: Abyssal Dais, Altar of the Serpent, Deep
	-- Archives, Eternal Amphitheater, the Flooded Shrine (the central pool) and Sunken Hollow on the city's map,
	-- Ataal'Byzal and Atal'Byzal on Atal'byzal), as a player's English recording (2026-11-13) and the client's
	-- English tables (2026-11-17) name them: drafted, to be checked (GetSubZoneText there)
	["Abyssal Dais"] = "Estrade abyssale",
	["Aku'mai's Lair"] = "Antre d'Aku'mai",
	-- Alcaz Prison's two names for its rooms (Data/Authored/Upcoming.lua's floors: Alcaz Prison on the first,
	-- Maximum Security on the second), as the client's English tables name them (2026-11-17): drafted, to be checked
	-- (GetSubZoneText there); Alcaz Prison as the dungeon's name in this language
	["Alcaz Prison"] = "Prison d'Alcaz",
	-- (the Drowned City's, drafted: see Abyssal Dais)
	["Altar of the Serpent"] = "Autel du Serpent",
	["Anvilmar's Rest"] = "Repos d'Anvilmar",
	-- (the Drowned City's shrine: its rooms' area and the building's own name, drafted: see Abyssal Dais)
	["Ataal'Byzal"] = "Ataal'Byzal",
	["Atal'Byzal"] = "Atal'Byzal",
	["Athenaeum"] = "Athénée",
	-- Blackmaw Hold's areas (Data/Authored/Upcoming.lua's floors: Blackmaw Grove, Blackmaw Stillwater, Bonesnout's
	-- Thicket, the Festering Grotto and the depths' four levels), by the labels on Santiago Reyes's maps, not read in
	-- game yet: drafted, to be checked (GetSubZoneText there). The client's tables keep the hold's own names in
	-- encrypted rows
	["Blackmaw Grove"] = "Bosquet de Noiregueule",
	["Blackmaw Stillwater"] = "Eaux dormantes de Noiregueule",
	["Blackrock Stadium"] = "Stade de Rochenoire",
	["Blackrock Stronghold"] = "Bastion Rochenoire",
	-- (Blackmaw Hold's, drafted: see Blackmaw Grove)
	["Bonesnout's Thicket"] = "Fourré de Bonesnout",
	-- City of Dalaran's rooms (Data/Authored/CityOfDalaran.lua's floors: Cantrips & Crows, City of
	-- Dalaran, Dalaran, Magus Commerce Exchange, Path of Renewal, Presage Plaza, Runeweaver Square, Sewer,
	-- The Eventide, The Purple Parlor, The Underbelly, The Violet Citadel, The Violet Hold): the city's
	-- own buildings name them. Most have no area id; Dalaran (279, 16558), City of Dalaran (16544, 16560)
	-- and The Eventide (17824) have, not baked yet: a scan (/aegis areas, Dev/bake_area_ids.py) can
	-- replace those three. By the names the game's Dalaran has in this language, the newest of four
	-- copies of a list of them, to be checked in game (GetSubZoneText there)
	["Cantrips & Crows"] = "Caboulot des corbeaux",
	["Capital Gardens"] = "Jardins de la Capitale",
	["Cavern of Mists"] = "Caverne des brumes",
	["Chamber of Atonement"] = "Chambre d'expiation",
	["Chamber of Battle"] = "Chambre de bataille",
	["Chapel Gardens"] = "Jardins de la chapelle",
	["City of Dalaran"] = "Cité de Dalaran",
	-- The Cleft of Shadow (Data/Authored/MicroDungeons.lua) has no area id, so it is found by this
	-- name alone, to be checked in game (GetSubZoneText in the Cleft): LibBabble-SubZone's root file's
	-- name (rev 238), as the other micro dungeons' are; the file the lib loads (Locale/frFR.lua, rev
	-- 258) has the newer "Faille de l’Ombre" (a typographic apostrophe), as the journal's Ragefire
	-- Chasm has it (a straight one), and Classic's quest text writes "la Faille de l'ombre"
	["Cleft of Shadow"] = "La Faille de l'Ombre",
	["Court of the Highborne"] = "Cour des Bien-nés",
	["Crag of the Everliving"] = "Escarpement de l'Immortel",
	["Crusader's Armory"] = "Armurerie du croisé",
	["Crusader's Chapel"] = "Chapelle du croisé",
	["Crusaders' Square"] = "Place des croisés",
	["Dalaran"] = "Dalaran",
	["Dark Iron Ingress"] = "Accès des Sombrefer",
	-- (the Drowned City's, drafted: see Abyssal Dais)
	["Deep Archives"] = "Archives profondes",
	["Defias Hideout"] = "Planque des Défias",
	-- (Blackmaw Hold's, drafted: see Blackmaw Grove)
	["Depths of Forbidden Magic"] = "Profondeurs de la Magie interdite",
	["Depths of the Burrow"] = "Profondeurs du Terrier",
	["Depths of the Elders"] = "Profondeurs des Anciens",
	["Depths of the Fallen Grove"] = "Profondeurs du Bosquet déchu",
	["Dig One"] = "Fouille numéro un",
	["Dragonspire Hall"] = "Salle de la Flèche-du-Dragon",
	["Dreamer's Rock"] = "Rocher du rêveur",
	["Elders' Square"] = "Place des anciens",
	["Eldre' Thalas"] = "Eldre'Thalas",
	["Eldreth Row"] = "Allée d'Eldreth",
	["Engineering Labs"] = "Laboratoires d'ingénierie",
	-- (the Drowned City's, drafted: see Abyssal Dais)
	["Eternal Amphitheater"] = "Amphithéâtre éternel",
	["Excavation Center"] = "Centre de fouilles",
	-- (Blackmaw Hold's, drafted: see Blackmaw Grove)
	["Festering Grotto"] = "Grotte purulente",
	["Festival Lane"] = "Allée du festival",
	-- (the Drowned City's, drafted: see Abyssal Dais)
	["Flooded Shrine"] = "Sanctuaire inondé",
	["Footman's Armory"] = "Armurerie du fantassin",
	-- City of Dalaran's city rooms a player's recording read (Data/Authored/CityOfDalaran.lua, 2026-11-13: Forge of
	-- Fate, Talismanic Textiles, Tempered Tomes, The Atrium of Fortune, The Silver Enclave, Violet Plates and
	-- Framing), with no area id. Drafted, to be checked in game (GetSubZoneText there)
	["Forge of Fate"] = "Forge du Destin",
	["Forgewright's Tomb"] = "Tombe du Forgeron",
	["Forlorn Cloister"] = "Cloître désolé",
	["Gallery of Treasures"] = "Galerie des trésors",
	["Goblin Foundry"] = "Fonderie gobeline",
	["Gordok Commons"] = "Communs gordok",
	["Hall of Champions"] = "Salle des champions",
	["Hall of the Keepers"] = "Salle des Gardiens",
	["Halycon's Lair"] = "Antre d'Halycon",
	["Honor's Tomb"] = "Tombe de l'honneur",
	["Hordemar City"] = "Cité de Hordemar",
	["Huntsman's Cloister"] = "Cloître du veneur",
	["King's Square"] = "Place du roi",
	["Launch Bay"] = "Aire de lancement",
	-- Three rooms of Gnomeregan's way in (Data/Authored/SubMaps.lua), the Loading Room, the Train
	-- Depot and the Workshop Entrance, have no area id, so they are found by these names alone, to be
	-- checked in game (GetSubZoneText there): LibBabble-SubZone's, the same in its root file (rev 238)
	-- and in the file the lib loads (rev 258)
	["Loading Room"] = "Salle de chargement",
	["Magus Commerce Exchange"] = "La halle des mages",
	["Market Row"] = "Allée du marché",
	-- (Alcaz Prison's lower floor, drafted: see Alcaz Prison)
	["Maximum Security"] = "Haute sécurité",
	["Mast Room"] = "Salle du mât",
	["Mok'Doom"] = "Mok'Doom",
	["Moonshrine Ruins"] = "Ruines du sanctuaire lunaire",
	["Moonshrine Sanctum"] = "Sanctum du sanctuaire lunaire",
	["North Common Hall"] = "Salle commune nord",
	["Path of Renewal"] = "Voie du Renouveau",
	["Pit of Fangs"] = "Fosse aux crocs",
	["Presage Plaza"] = "Place des Présages",
	["Prison of Immol'thar"] = "Prison d'Immol'thar",
	["Reliquary of Kings"] = "Reliquaire des rois",
	["Runeweaver Square"] = "Place Tisserune",
	["Screaming Gully"] = "Ravine hurlante",
	["Sewer"] = "Égouts",
	["Skitterweb Tunnels"] = "Tunnels de Grouilletoile",
	["Slaughter Square"] = "Place du massacre",
	["South Common Hall"] = "Salle commune sud",
	-- Razorfen Downs' rooms (Data/Instances/RazorfenDowns.lua: Spiral of Thorns, The Bone Pile, The Caller's Chamber
	-- and The Murder Pens), as a player's recording read them in English (2026-11-13): the dungeon building's own
	-- names, with no area id. Drafted, to be checked in game (GetSubZoneText there)
	["Spiral of Thorns"] = "Spirale d'épines",
	-- (the Drowned City's, drafted: see Abyssal Dais)
	["Sunken Hollow"] = "Creux englouti",
	-- (City of Dalaran's, drafted: see Forge of Fate)
	["Talismanic Textiles"] = "Textiles talismaniques",
	["Tazz'Alaor"] = "Tazz'Alaor",
	["Tazz'Alor"] = "Tazz'Alor",
	-- (City of Dalaran's, drafted: see Forge of Fate)
	["Tempered Tomes"] = "Tomes trempés",
	-- (City of Dalaran's, drafted: see Forge of Fate)
	["The Atrium of Fortune"] = "L'atrium de la Fortune",
	-- (Razorfen Downs', drafted: see Spiral of Thorns)
	["The Bone Pile"] = "Le tas d'os",
	-- (Razorfen Downs', drafted: see Spiral of Thorns)
	["The Caller's Chamber"] = "Chambre de l'Invocateur",
	-- Gnomeregan's Clean Zone, a room the map follows since 0.39.21 (2026-11-12; drafted, to be checked)
	["The Clean Zone"] = "La zone propre",
	["The Clockwerk Run"] = "Le couloir des rouages",
	["The Dormitory"] = "Le Dortoir",
	["The Drowned Sacellum"] = "Le sacellum englouti",
	["The Eventide"] = "Le Brunant",
	["The Forgotten Pool"] = "Le bassin oublié",
	["The Gauntlet"] = "Le Défilé",
	["The Grand Vestibule"] = "Le Grand vestibule",
	["The Grinding Quarry"] = "La Carrière broyeuse",
	["The Hall of Gears"] = "La salle des engrenages",
	["The Hall of Lights"] = "La salle des lumières",
	["The High Seat"] = "Le Haut-Siège",
	["The Hoard"] = "Le Trésor",
	["The Masonary"] = "La Maçonnerie",
	["The Molten Span"] = "La Travée en fusion",
	-- (Razorfen Downs', drafted: see Spiral of Thorns)
	["The Murder Pens"] = "Les enclos du meurtre",
	["The Pool of Ask'ar"] = "Le bassin d'Ask'ar",
	["The Purple Parlor"] = "Le salon Violet",
	["The Rookery"] = "Le Nid",
	["The Scarlet Bastion"] = "Le bastion écarlate",
	["The Sealed Hall"] = "La Salle scellée",
	["The Shrine of Eldretharr"] = "Le sanctuaire d'Eldretharr",
	-- (City of Dalaran's, drafted: see Forge of Fate)
	["The Silver Enclave"] = "L'Enclave argentée",
	["The Slaughter House"] = "L'Abattoir",
	["The Storehouse"] = "L'Entrepôt",
	["The Underbelly"] = "Les Entrailles",
	["The Violet Citadel"] = "La citadelle Pourpre",
	["The Violet Hold"] = "Le fort Pourpre",
	["The Wailing Caverns"] = "Cavernes des lamentations",
	["Tinkers' Court"] = "Cour des bricoleurs",
	-- Gnomeregan's way in, as the Loading Room above
	["Train Depot"] = "Dépôt des trains",
	["Training Grounds"] = "Terrain d'entraînement",
	-- (City of Dalaran's, drafted: see Forge of Fate)
	["Violet Plates and Framing"] = "Plaques et cadres violets",
	["Warpwood Quarter"] = "Quartier de Crochebois",
	-- Wailing Caverns' Winding Chasm (Data/Authored/WailingCaverns.lua, 2026-11-13): the game's name for it in this language, to be checked in game
	["Winding Chasm"] = "Gouffre tortueux",
	-- Gnomeregan's way in, as the Loading Room above
	["Workshop Entrance"] = "Entrée de l'atelier",
	-- (Blackmaw Hold's, drafted: see Blackmaw Grove; Zedrik's Rest a best guess from the label on a newer version
	-- of Santiago Reyes's whole hold, 2026-11-18)
	["Zedrik's Rest"] = "Repos de Zedrik",
	-- The Temple of Atal'Hakkar's way in (Data/Authored/SubMaps.lua, 2026-10-30): its nine rooms have no area id,
	-- so they are found by these names alone. Pool of Tears, Sorrowmurk and the temple's own name have ids (74,
	-- 1778, 1477): a scan (/aegis areas, Dev/bake_area_ids.py) can replace those three. LibBabble-SubZone's names,
	-- from its root file (rev 238); the file the lib loads (rev 258) has "Hall du Rituel", and the temple's name
	-- with curly apostrophes. Hall of Faces and Den of the Unholy are Forever's names. To be checked in game
	-- (GetSubZoneText there)
	["Chamber of Blood"] = "Chambre du Sang",
	["Den of the Caller"] = "Refuge de l'Invocateur",
	["Den of the Unholy"] = "L'Antre des impies",
	["Hall of Bones"] = "Hall des Ossements",
	["Hall of Faces"] = "Hall des visages",
	["Hall of Masks"] = "Hall des masques",
	["Hall of Ritual"] = "Hall du rituel",
	["Pool of Tears"] = "Bassin des Larmes",
	["Sorrowmurk"] = "Noirchagrin",
	["The Broken Hall"] = "Le Hall brisé",
	["The Butchery"] = "La Boucherie",
	["The Temple of Atal'Hakkar"] = "Le temple d'Atal'Hakkar",
}

-- The journal's style: its question at each character's first login, each choice and what it does, and the
-- choice and boxes in the options (2026-11-03; drafted, to be checked).
L.STYLE_TITLE = "Choisissez votre journal"
L.STYLE_SUBTITLE = "Que doit ajouter le journal à votre jeu ? Vous pouvez changer cela à tout moment dans les options du journal."
L.STYLE_CLASSIC = "Classique"
L.STYLE_CLASSIC_DESC = "Un journal plus proche de l'original, avec moins d'extras. Les boss, le butin, les quêtes et les cartes des donjons sont toujours là."
L.STYLE_MODERN = "Moderne"
L.STYLE_MODERN_DESC = "Tout ce que le journal propose, tel qu'il est aujourd'hui : la recherche d'équipement, les cartes des accès et ses repères sur la carte du monde."
L.STYLE_CUSTOM = "Personnalisé"
L.STYLE_CUSTOM_DESC = "À vous de choisir. Choisissez ceci pour ouvrir les réglages du journal, où chaque fonction a sa propre case à cocher."
-- Adventure Mode, in the options' list of styles, and what it does (2026-11-05; drafted, to be checked).
L.STYLE_ADVENTURE = "Mode Aventure"
L.STYLE_ADVENTURE_DESC = "Le journal commence vide et se remplit à mesure que vous jouez : donjons, boss, butin et quêtes apparaissent dès que vous les trouvez."
-- Adventure Mode's name on its box in the question at login, one word like Classic and Modern (2026-11-07).
L.STYLE_ADVENTURE_BOX = "Aventure"
-- Adventure Mode's pages: an unmet boss's line, the closed tabs' tooltips, the loot list with nothing seen
-- yet, and an item seen with its boss unknown (2026-11-05; drafted, to be checked).
L.ADVENTURE_BOSS_UNMET = "Vous ne l'avez pas encore rencontré."
L.ADVENTURE_ABILITIES_CLOSED = "Combattez ce boss pour découvrir ses techniques."
L.ADVENTURE_MODEL_CLOSED = "Rencontrez ce boss pour le voir ici."
L.ADVENTURE_LOOT_NONE = "Aucun butin n'a encore été vu ici."
L.ADVENTURE_LOOT_IN_DUNGEON = "Butin de : %s"
-- Adventure Mode's Quests tab, a step not offered yet and no quests found yet; the Reputation tab, no
-- faction met yet, and a faction's rewards not seen yet (2026-11-05; drafted, to be checked).
L.ADVENTURE_QUEST_UNKNOWN = "Cette quête ne vous a pas encore été proposée."
L.ADVENTURE_QUESTS_NONE = "Aucune quête de ce donjon n'a encore été trouvée."
L.ADVENTURE_REP_NONE = "Vous n'avez encore rencontré aucune de ces factions."
L.ADVENTURE_REP_TITLE = "Récompenses à découvrir"
L.ADVENTURE_REP_SEEN = "Ses récompenses apparaissent ici dès que vous les voyez chez son intendant."
L.ADVENTURE_REP_SEEN_AT = "Ses récompenses apparaissent ici dès que vous les voyez chez son intendant, %s."
L.ADVENTURE_REP_NONE_SEEN = "Aucune de ses récompenses n'a encore été vue."
L.ADVENTURE_DOOR_TITLE = "Une rumeur"
L.ADVENTURE_DOOR_LINE = "« %s »"
L.ADVENTURE_DOOR_UNKNOWN = "On sait encore peu de choses de cet endroit."
L.ADVENTURE_DOOR_DUNGEON = "Donjon inconnu"
L.ADVENTURE_DOOR_RAID = "Raid inconnu"
L.ADVENTURE_DOOR_NTH = "%s %d"
L.ADVENTURE_DOOR_CHOICE = "%s (%s)"
L.ADVENTURE_DOOR_VIA = "Son portail se trouve en contrebas : descendez à l'entrée de la grotte."
L.ADVENTURE_DOOR_VIA_BUILDING = "Son portail se trouve à l'intérieur : entrez par l'entrée."
L.ADVENTURE_DOOR_WAYPOINT_SET = "Point de cheminement placé là où mène la rumeur."
L.ADVENTURE_CAVE_LEADS_TO = "Le chemin vers un lieu entouré de rumeurs"
L.ADVENTURE_CAVE_LEFT_CLICK = "Clic gauche pour voir la carte du chemin d'accès"
-- Adventure Mode's quest marks on the world map (UI/QuestMap.lua): a quest not offered yet is a faint "!", a
-- rumor, under "A rumor" (ADVENTURE_DOOR_TITLE) and in ADVENTURE_DOOR_LINE's quotation marks: there may be work
-- there, from someone or something (inside a dungeon, a tablet or a crest). It names no quest, dungeon or
-- place (2026-11-11; translation drafted, to be checked).
L.ADVENTURE_QUEST_RUMOR = "Il y a peut-être du travail pour vous ici."
-- Adventure Mode's Gear Finder: an upgrade not seen to drop yet, a rumour's place (zone, level range), the
-- tooltip's line for one not seen, the click lines, and Show on map for a rumour's door (2026-11-10; translation
-- drafted, to be checked).
L.GEAR_ADVENTURE_BETTER = "Quelque chose de mieux"
L.GEAR_ADVENTURE_PLACE = "%s · %s"
L.GEAR_ADVENTURE_UNSEEN = "Vous ne l'avez pas encore vu tomber."
L.GEAR_ADVENTURE_CELL_CLICK = "Cliquez pour voir les meilleures améliorations ; clic droit pour voir le donjon."
L.GEAR_ADVENTURE_PICK_CLICK = "Cliquez pour l'afficher ici ; clic droit pour voir le donjon."
L.GEAR_ADVENTURE_ROW_CLICK = "Cliquez pour voir le donjon."
L.GEAR_ADVENTURE_MAP_CLICK = "Cliquez pour voir le chemin sur la carte du monde."
L.GEAR_ADVENTURE_NO_DOOR = "On ne sait pas encore où se trouve son entrée."
L.GEAR_ADVENTURE_SHOW_MAP = "Voir sur la carte"
-- The Gear Finder's rumour slot with upgrades to pick: its picture leads to the door, its words to the picks;
-- and the picks' right-click where the slot has no link (2026-11-10; translation drafted, to be checked).
L.GEAR_ADVENTURE_MAP_PICK_CLICK = "Cliquez sur l'icône pour voir le chemin sur la carte du monde ; cliquez sur le texte pour voir les améliorations à choisir."
L.GEAR_ADVENTURE_RUMOUR_PICKS = "Clic droit pour voir les améliorations à choisir."
L.STYLE_STARTING = "Réglages de départ :"
L.STYLE_LINE_ON = "%s : activé"
L.STYLE_LINE_OFF = "%s : désactivé"
L.STYLE_LINE_ADVENTURE_HIDDEN = "Donjons, boss et butin cachés au départ"
L.STYLE_LINE_ADVENTURE_FOG = "Cartes sous le brouillard jusqu'à la mort des boss"
L.STYLE_LINE_ADVENTURE_ON = "Recherche d'équipement, cartes des accès et repères activés"
L.STYLE_GEAR = "Recherche d'équipement, poids"
L.STYLE_GEAR_TIP = "L'onglet de la recherche d'équipement, son onglet dans la fenêtre du personnage, les lignes de poids dans les infobulles des objets, les flèches vertes d'amélioration et les poids du journal dans Pawn. Ils reposent tous sur les mêmes poids, ils vont donc ensemble. Pour ce personnage seulement."
L.STYLE_WAY_IN = "Cartes des accès et grottes"
L.STYLE_WAY_IN_TIP = "Les cartes du chemin vers un donjon (grottes, bâtiments, niveaux d'une montagne) sur la carte du monde, et leurs entrées de grotte et de bâtiment. Les cartes des donjons eux-mêmes restent. Pour ce personnage seulement."
L.STYLE_MARKERS = "Repères sur la carte du monde"
L.STYLE_MARKERS_TIP = "Les repères du journal sur la carte du monde : entrées de donjon et de raid, maîtres de vol, bateaux, zeppelins, trams et portails, ses repères de quête, niveaux des zones et zones inexplorées. Pour ce personnage seulement."
L.STYLE_CLICK = "Cliquez pour choisir"
L.STYLE_NOW = "Votre style actuel"
L.STYLE_CLOSE_NOTE = "Fermer conserve %s."
L.STYLE_CHOSEN = "Style du journal : %s. Vous pouvez le changer à tout moment dans les options du journal (/aegis options)."
L.STYLE_OPTIONS_AFTER_COMBAT = "Les options du journal s'ouvriront à la fin du combat."
L.STYLE_OPTION = "Style du journal"
L.STYLE_OPTION_TIP = "Classique, Moderne, Mode Aventure ou Personnalisé, pour ce personnage seulement. Cocher ou décocher une fonction ci-dessous le rend Personnalisé (le Mode Aventure reste actif)."
-- The Reset button under the style's dropdown, and its question (2026-11-03; drafted, to be checked).
L.STYLE_RESET = "Réinitialiser le Journal"
L.STYLE_RESET_BUTTON = "Réinitialiser"
L.STYLE_CHOOSE_BUTTON = "Choisir"
L.STYLE_RESET_TIP = "Remet les options du journal comme à l'installation, pour tous vos personnages, et repose la question du style à ce personnage. Les enregistrements, les poids de caractéristiques et le style de vos autres personnages sont conservés."
L.STYLE_RESET_CONFIRM = "Remettre les options du journal comme à l'installation, pour tous vos personnages, et reposer la question du style à ce personnage ? Vos enregistrements, vos poids de caractéristiques et le style de vos autres personnages sont conservés."
L.STYLE_GEAR_IS_OFF = "La recherche d'équipement est désactivée. Activez-la dans les options du journal (/aegis options)."
-- The Record tab's box in the options, and /aegis record while it is off (2026-11-03; drafted, to be checked).
L.OPTIONS_RECORD_TAB = "Afficher l'onglet Enregistrer"
L.OPTIONS_RECORD_TAB_TIP = "L'onglet qui enregistre vos donjons pour nous. Décochée : l'onglet est masqué et le journal n'enregistre rien (Capturer le marchand dans l'onglet Réputation fonctionne toujours). Ce que vous avez déjà enregistré est conservé."
L.RECORD_TAB_IS_OFF = "L'onglet Enregistrer est désactivé. Activez-le dans les options du journal (/aegis options)."
L.LEGEND_STYLE_OFF = "Désactivé dans les options du journal."

-- The run block (UI/RunTracker.lua, Core/Run.lua), 2026-11-11; drafted, to be checked. The client's own words where it has them.
L.RUN_BOSS_DEFEATED = "%s vaincu"
L.RUN_COMPLETE = DUNGEON_COMPLETED or "Donjon terminé !"
L.RUN_EXPERIENCE = EXPERIENCE_COLON or "Expérience :"
L.RUN_MONEY = MONEY_COLON or "Argent :"
L.RUN_ITEMS = "Objets :"
L.RUN_PER_HOUR = "%s/h"
L.RUN_GREED = "Gagnés en " .. (GREED or "Cupidité") .. " : %d"
L.RUN_DEFEATED = BOSS_DEAD or "Vaincu"
L.RUN_NOT_DEFEATED = "Pas encore vaincu"
L.RUN_PARTS = "%s, puis %s"
L.RUN_COIN = "Pièces ramassées"
L.RUN_ITEM_VALUE = "Objets au prix du marchand"
L.RUN_PENDING = "En attente d'un prix : %d"
L.RUN_DRAG = "Faites glisser l'en-tête pour le déplacer."
L.RUN_SUMMARY = "%s : %d/%d boss en %s"
L.RUN_SUMMARY_XP = "%s PX"
L.RUN_SUMMARY_ITEMS = "Objets : %d"
L.RUN_NEW = "Un nouveau parcours commence maintenant."
L.RUN_NOT_INSIDE = "Entrez dans un donjon pour commencer un nouveau parcours."
L.RUN_HIDDEN = "Le suivi du parcours est masqué pour ce parcours. Tapez /ij run pour le réafficher."
L.RUN_NONE = "Aucun parcours de donjon pour l'instant."
L.RUN_IS_OFF = "Le suivi des parcours est désactivé. Activez-le dans les options du journal (/aegis options)."
L.RUN_FREE_OFF = "Le suivi du parcours est de nouveau près du suivi des quêtes."
-- The run block's header lock and its chat lines, /ij run lock and unlock now the lock's, and /ij run's usage reworded for them (2026-11-17; drafted, to be checked).
L.RUN_USAGE = "/ij run affiche ou masque le suivi du parcours (hors d'un donjon, votre dernier parcours). /ij run new commence un nouveau parcours. /ij run lock et /ij run unlock le verrouillent à sa place ou permettent de le déplacer à nouveau, comme le cadenas de son en-tête ; /ij run reset le remet près du suivi des quêtes. /ij run debug affiche ce qu'il a compté."
L.RUN_LOCKED = "Verrouillé"
L.RUN_LOCKED_TIP = "Cliquez pour le déverrouiller, puis faites glisser le suivi par son en-tête."
L.RUN_UNLOCKED = "Déverrouillé"
L.RUN_UNLOCKED_TIP = "Faites glisser le suivi par son en-tête pour le déplacer. Cliquez pour le verrouiller à sa place."
L.RUN_LOCK_ON = "Le suivi du parcours est verrouillé à sa place."
L.RUN_LOCK_OFF = "Le suivi du parcours est déverrouillé : faites-le glisser par son en-tête pour le déplacer."
L.RUN_LOCK_NOT_FREE = "Il ne se déplace que s'il est placé librement (« %s » dans les options)."
-- The clock's buttons on the run block, between the time and the count (2026-11-14; drafted, to be checked).
L.RUN_CLOCK_START = "Lancer le chrono maintenant"
L.RUN_CLOCK_WAITING = "Sinon, il démarre tout seul au premier combat."
L.RUN_CLOCK_PAUSE = "Mettre le chrono en pause"
L.RUN_CLOCK_RESUME = "Reprendre le chrono"
L.RUN_CLOCK_DONE = "Le parcours est terminé : son chrono est arrêté."
L.RUN_RESTART = "Nouveau parcours"
L.RUN_RESTART_CONFIRM = "Commencer un nouveau parcours ? Ses boss vaincus sont effacés et le chrono repart de zéro."
-- The run block's one line inside a Scarlet Monastery wing before the wing is known (2026-11-17; drafted, to be checked).
L.RUN_WHICH_WING = "Quelle aile ?"
-- /ij run new or New run before the wing is known: the new run starts once it is (2026-11-17; drafted, to be checked).
L.RUN_NEW_WING = "Un nouveau parcours commencera dès que l'aile sera connue."
L.OPTIONS_RUN = "Suivi des parcours de donjon"
L.OPTIONS_RUN_TIP = "Dans un donjon, un bloc près du suivi des quêtes affiche la durée du parcours, ses boss et ce que vous avez gagné. Désactivé, rien n'est compté."
L.OPTIONS_RUN_NUMBERS = "Afficher l'expérience et l'argent"
L.OPTIONS_RUN_NUMBERS_TIP = "L'expérience et l'argent (les pièces ramassées plus le prix de vente de vos objets), chacun avec son rythme par heure, et le nombre d'objets obtenus."
L.OPTIONS_RUN_FREE = "Placer librement"
-- "Place it freely" on by default since 0.39.23: its tip says so, and what unticking it does (2026-11-17; drafted, to be checked).
L.OPTIONS_RUN_FREE_TIP = "Faites glisser le bloc par son en-tête où vous voulez. Activé par défaut : tant que vous ne l'avez pas déplacé, il attend près du suivi des quêtes. Désactivé, il reste près du suivi des quêtes et se déplace avec lui. « Dans le suivi des quêtes » l'emporte sur cette option."
-- The run block's dark mode: its gold art darkened, else the tracker's tint (UI/RunTracker.lua Paint), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_DARK_MODE = "Mode sombre"
L.OPTIONS_RUN_DARK_MODE_TIP = "Assombrit l'or de l'en-tête et du cadre du bloc du parcours. Désactivé, le bloc prend l'aspect des en-têtes de votre suivi des quêtes : il est sombre quand votre interface les assombrit."
L.OPTIONS_RUN_SUMMARY = "Résumé dans la discussion"
L.OPTIONS_RUN_SUMMARY_TIP = "Une ligne dans la discussion une minute après l'arrêt du chrono d'un parcours (plus tôt si vous partez). Un parcours quitté inachevé a sa ligne une fois terminé : quand le donjon est réinitialisé, ou après une demi-heure dehors."
-- The run block inside the quest tracker: off by default (the owner's call of 2026-11-13; on in 0.39.22's tests), its tip warning of blocked actions in combat until a /reload once the block has been inside the tracker (the owner's words, 2026-11-13), its name marked as a test (UI/RunTrackerInside.lua), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_INSIDE = "Dans le suivi des quêtes (test)"
-- Its tip: beside the tracker with this off only while "Place it freely" is unticked too, since that is on by default (2026-11-17; drafted, to be checked).
L.OPTIONS_RUN_INSIDE_TIP = "Le bloc entre dans le suivi des quêtes, juste sous « " .. (TRACKER_ALL_OBJECTIVES or "Tous les objectifs") .. " », et les sections du suivi (" .. (TRACKER_HEADER_QUESTS or "Quêtes") .. " et les autres) descendent sous lui. Désactivé par défaut. Un suivi que vous avez déplacé en mode Édition n'est pas plus haut que la hauteur réglée là : si elle est trop courte pour le bloc, le journal augmente une fois cette hauteur dans votre disposition du mode Édition et le dit dans la discussion (visible après un /reload ; le bouton dessous le refait). D'ici là, le bloc reste à côté, comme désactivé avec « Placer librement » décoché. Une fois que le bloc a été dans le suivi, il peut provoquer des actions bloquées en combat jusqu'à un /reload. C'est un test : si le jeu signale une action bloquée, il se désactive tout seul. S'il a déjà servi, il n'est complètement désactivé qu'après un /reload."
L.RUN_INSIDE_BLOCKED = "Le jeu a bloqué une action du journal (%s) : « Dans le suivi des quêtes » est donc désactivé et le bloc du parcours retourne près du suivi. Merci de signaler cette ligne. Tapez /reload pour le retirer complètement du suivi."
L.RUN_INSIDE_RELOAD = "« Dans le suivi des quêtes » est désactivé et le bloc du parcours retourne près du suivi. Tapez /reload pour le retirer complètement du suivi."
-- The tracker too short for the block inside: the Height it needs, and the options' Make taller button (UI/RunTrackerInside.lua), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_TALLER = "Agrandir le suivi des quêtes"
L.OPTIONS_RUN_TALLER_BUTTON = "Agrandir"
L.OPTIONS_RUN_TALLER_TIP = "Pour « Dans le suivi des quêtes » : règle la hauteur du suivi des quêtes dans votre disposition du mode Édition sur ce qu'il faut au bloc du parcours, et enregistre la disposition. Seulement pour un suivi que vous avez déplacé en mode Édition. À utiliser pendant que le bloc s'affiche, hors combat, mode Édition fermé. Visible après un /reload."
L.RUN_INSIDE_SHORT = "Le bloc du parcours reste à côté du suivi des quêtes : le suivi est trop court pour le contenir. Pour l'agrandir : %s, sélectionnez « %s », %s %d ou plus. Ou utilisez « %s » dans les options du journal (/aegis options)."
L.RUN_INSIDE_SHORT_TIP = "Le suivi des quêtes est trop court pour le bloc. Pour l'agrandir : %s, sélectionnez « %s », %s %d ou plus."
L.RUN_TALLER_COMBAT = ERR_NOT_IN_COMBAT or "Impossible de faire cela en combat."
L.RUN_TALLER_EDIT_MODE = "Fermez d'abord le %s."
L.RUN_TALLER_DEFAULT = "Le suivi des quêtes est à sa place par défaut, où il descend jusqu'en bas de l'écran : il n'a pas de hauteur à régler."
L.RUN_TALLER_UNKNOWN = "Utilisez ceci pendant que le bloc du parcours s'affiche (dans un donjon, ou votre dernier parcours avec /ij run) : sa hauteur est mesurée alors."
L.RUN_TALLER_ENOUGH = "Le suivi des quêtes est déjà assez haut pour le bloc du parcours."
L.RUN_TALLER_FAILED = "Votre disposition du mode Édition n'a pas pu être modifiée d'ici. Réglez-la vous-même : %s, sélectionnez « %s », %s %d ou plus."
L.RUN_TALLER_DONE = "%s – %s : maintenant %d dans votre disposition « %s » du mode Édition. Tapez /reload maintenant pour le voir."
L.RUN_TALLER_MOST = "C'est le maximum permis par le mode Édition : le bloc peut encore ne pas tenir."
-- The tracker's Height raised once by the journal itself when too short, 0.39.22 (UI/RunTrackerInside.lua AutoTaller), 2026-11-12; drafted, to be checked.
L.RUN_INSIDE_AUTO = "Le suivi des quêtes était trop court pour le bloc du parcours : le journal a donc changé sa %s de %d à %d dans votre disposition « %s » du mode Édition. Tapez /reload pour le voir. Vous pouvez la remettre dans le %s."
L.RUN_INSIDE_SAVED_TIP = "Votre disposition du mode Édition donne maintenant au suivi des quêtes une %s de %d. Tapez /reload pour le voir."
-- Edit Mode opened before the /reload after the journal saved a Height: its old copy (UI/RunTrackerInside.lua EditModeEntered), 2026-11-12; drafted, to be checked.
L.RUN_INSIDE_EDIT_MODE_OLD = "Le %s affiche encore l'ancienne %s du suivi des quêtes jusqu'à un /reload. Si vous y enregistrez quoi que ce soit maintenant, l'ancienne revient."

-- Matched against the client's own text: the client's language's only, previewed or not.
if client then client.EQUIP_PATTERNS, client.AREA_NAMES = L.EQUIP_PATTERNS, L.AREA_NAMES end
L.EQUIP_PATTERNS, L.AREA_NAMES = nil, nil
