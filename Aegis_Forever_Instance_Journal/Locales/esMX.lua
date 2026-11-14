local _, ns = ...

--[[
	The journal's interface in Latin American Spanish, for a client set to esMX. Drafted by Claude for
	review by a native speaker. It is laid over the English table (Locales/enUS.lua), so every file that
	already holds ns.L sees these strings, and anything not translated here stays English. Every other
	client skips it. Spain's client is another file (Locales/esES.lua): the two clients word many
	things their own way ("calabozo" here, "mazmorra" there).
]]
-- The journal's words where it speaks this language; the tables matched against the client's own
-- text where the client does, previewed or not (ns.LocaleTargets, Locales/enUS.lua).
local L, client = ns.LocaleTargets("esMX")
if not L then return end

L.JOURNAL_TITLE = "Guía de calabozos"
L.HOME = HOME or "Inicio"
L.TAB_DUNGEONS = DUNGEONS or "Calabozos"
L.TAB_RAIDS = RAIDS or "Bandas"
L.TAB_REPUTATION = REPUTATION or "Reputación"

L.BINDING_TOGGLE = "Mostrar/ocultar la Guía de calabozos"
L.KEY_CLAIMED = "Mayús+J ahora abre la Guía de calabozos."
L.KEY_TAKEN = "Mayús+J ya está asignada a %s. Elige una tecla en Atajos de teclado > Accesorios > Mostrar/ocultar la Guía de calabozos."
L.POSITION_RESET = "Se restableció la posición de la ventana."
L.DOCK_ON = "La ventana ahora se abre arriba a la izquierda, junto a las ventanas del juego. Arrástrala para moverla hasta que se cierre."
L.DOCK_OFF = "La ventana vuelve a estar libre: se abre donde la arrastraste por última vez."
L.DOCK_AFTER_COMBAT = "Se aplicará cuando termine el combate."
-- Its /aegis style sentence (2026-11-03; drafted, to be checked).
L.SLASH_HELP = "/aegis (o /ij) abre la guía. /aegis record inicia o detiene la grabación. /aegis reset devuelve la ventana a su lugar predeterminado. /aegis dock acopla la ventana arriba a la izquierda, junto a las ventanas del juego, o la vuelve a soltar. /aegis perf mide la memoria y la velocidad de la guía. /aegis where y /aegis taxi indican dónde estás y los puntos de vuelo de tu mapa. /aegis travel guarda un barco, zepelín, tranvía o portal para el mapa del mundo. /aegis items busca los objetos de la lista que el servidor no conoce. /aegis gear abre el Buscador de equipo, /aegis weights sus pesos de atributos; /aegis gearscan guarda lo que lee de tu equipo, para revisar su puntuación. /aegis options abre las opciones de la guía. /aegis style vuelve a mostrar la pregunta de estilo de la guía. /aegis lang muestra la guía en otro de sus idiomas. /aegis run muestra u oculta el bloque del recorrido (fuera de un calabozo, tu último recorrido); /aegis run new empieza un nuevo recorrido."
-- /aegis lang (Core/Init.lua)
L.LANG_USAGE = "/aegis lang de, fr, ru, cn, tw, es, mx, pt o ko muestra la guía en alemán, francés, ruso, chino (simplificado o tradicional), español (España o Latinoamérica), portugués de Brasil o coreano a partir de tu próximo /reload, para revisar una traducción; /aegis lang off vuelve al idioma de tu cliente. Ahora: %s."
L.LANG_SET = "A partir de tu próximo /reload, la guía usará el idioma %s, solo en sus propios textos: los nombres del juego siguen en el idioma de tu cliente. Escribe /reload ahora; /aegis lang off lo deshace."
L.LANG_OFF = "A partir de tu próximo /reload, la guía volverá al idioma de tu cliente. Escribe /reload ahora."
L.LANG_FONTS = "El chino necesita las fuentes de un cliente en chino: en el tuyo, algunos de sus caracteres podrían no verse."
L.LANG_FONTS_KO = "El coreano necesita las fuentes de un cliente en coreano: en el tuyo, algunos de sus caracteres podrían no verse."
L.LANG_ON = "Vista previa de la guía en el idioma %s. /aegis lang off la termina."
L.LANG_UNAVAILABLE = "Este cliente cargó la guía antes que su configuración guardada, así que no se pudo iniciar la vista previa del idioma."
L.AREAS_START = "Buscando en el cliente los ID de los %d nombres de áreas de la guía..."
L.AREAS_DONE = "Se encontraron los ID de %d de los %d nombres de áreas. Escribe /reload para guardarlos."
L.AREAS_MISSING = "No encontrados: %s."
L.AREAS_SCANNING = "Aún se están buscando los nombres de áreas."
L.AREAS_ENGLISH = "Usa /aegis areas en un cliente en inglés: los nombres que busca están en inglés."
L.ITEMS_START = "Consultando al servidor sobre los %d objetos que lista la guía. La respuesta llegará en unos %d segundos; sigue jugando como quieras."
L.ITEMS_SCANNING = "Aún se está consultando al servidor; la respuesta llegará en un momento."
L.ITEMS_DONE = "De %d objetos, el servidor no sabe nada de %d: lo más probable es que aún no estén en Forever. La guía los oculta hasta que el servidor o un recorrido grabado los confirme. La lista completa se escribe en el archivo guardado en tu próximo /reload o al cerrar sesión."
L.ITEMS_LINE = "  Objeto %d: %s"
L.ITEMS_MORE = "  ...y %d más."
L.PERF_HEADER = "Rendimiento (memoria en KB, tiempos en milisegundos; menos es mejor):"
L.PERF_MEMORY = "  %s: %.0f KB"
L.PERF_TIME = "  %s: %.2f ms"
L.PERF_BUILD = "Primera apertura (construcción de la ventana)"
L.PERF_BOOK = "Primer calabozo abierto (construcción del libro)"
L.PERF_OPEN = "Abrir y cerrar la guía"
L.PERF_DUNGEON = "Abrir la página de un calabozo"
L.PERF_TAB = "Cambiar a la pestaña %s"
L.PERF_FACTION = "Abrir la página de una facción"
L.PERF_LOOT = "Volver a dibujar una página de botín"
L.PERF_COMBAT = "La medición espera a que salgas de combate."
L.WHERE = "Mapa %s (%s)  x %.4f  y %.4f  área \"%s\"  minimapa \"%s\"  altura %s"
-- /aegis where: what the journal remembers the player as below a city, and its last changes (2026-11-06; drafted, to be checked).
L.WHERE_BELOW = "%s: recordado %s"
L.WHERE_BELOW_BELOW = "abajo"
L.WHERE_BELOW_TOP = "arriba"
L.WHERE_BELOW_NOTHING = "nada"
L.WHERE_BELOW_CHANGE = "  %s  %s  mapa %s  área \"%s\"  x %s  y %s:  %s -> %s"
L.TAXI = "Mapa %s  muestra puntos de vuelo por sí mismo: %s  puntos de vuelo en él: %d (%d descubiertos)  %s"
L.TAXI_ATLASES = "Iconos de viaje: %s"
L.YES = YES or "Sí"
L.NO = NO or "No"

L.EMPTY_DUNGEONS = "Aún no hay calabozos con entradas en la guía."
L.EMPTY_RAIDS = "Aún no hay bandas con entradas en la guía."
L.EMPTY_REPUTATION = "Aún no se conocen recompensas de facciones."
L.EMPTY_BRACKET = "No hay nada en este rango de niveles."

L.TAB_RECORD = "Grabar"
L.TAB_GEAR = "Buscador de equipo"

-- The Gear Finder (Core/GearFinder.lua, UI/GearPanel.lua, UI/CharacterTab.lua).
L.GEAR_TITLE = "Buscador de equipo"
L.GEAR_PREVIEW = "Vista previa"
L.GEAR_NO_UPGRADE = "No se encontró ninguna mejora"
L.GEAR_LOOKING = "Buscando en %d calabozos."
L.GEAR_LOOKING_ONE = "Buscando en 1 calabozo."
L.GEAR_LOADING = "Aún se están cargando %d objetos."
L.GEAR_LOADING_ONE = "Aún se está cargando 1 objeto."
L.GEAR_SCORING = "Puntuación para"
L.GEAR_AUTO = "Automático: %s"
L.GEAR_WHY_TALENTS = "%s (talentos)"
L.GEAR_WHY_LEVELLING = "%s (subiendo de nivel)"
L.GEAR_SUGGESTED = "Calabozo sugerido"
L.GEAR_UPGRADES_HERE = "%d mejoras aquí"
L.GEAR_UPGRADE_HERE = "1 mejora aquí"
L.GEAR_MORE_SLOTS = "y %d más"
L.GEAR_DUNGEON_OF = "%d de %d"
L.GEAR_NONE = "No hay mejoras en los calabozos cercanos a tu nivel."
L.GEAR_TIP_CLICK = "Haz clic para ver su botín; Mayús+clic para enlazarlo."
L.GEAR_TIP_CELL_CLICK = "Haz clic para ver las mejoras principales; clic derecho para ver su botín."
L.GEAR_TIP_PICK_CLICK = "Haz clic para mostrarlo aquí; clic derecho para ver su botín."
L.GEAR_TIP_PICKED = "Tu elección para esta ranura."
L.GEAR_PICK_TOP = "Las %d mejores de %d mejoras"
L.GEAR_PICK_ALL = "%d mejoras"
L.GEAR_PICK_ONE = "La única mejora"
L.GEAR_PICK_BIGGEST = "Mayor"
L.GEAR_PICK_YOURS = "Tu elección"
L.GEAR_PICK_KEPT = "Las elecciones se guardan para este personaje."
L.GEAR_PICK_CLEAR = "Quitar mi elección"
L.GEAR_TIP_NONE = "No hay ninguna mejora para esta ranura en los calabozos cercanos a tu nivel."
L.GEAR_CHAR_BUTTON = "Buscador de equipo"
L.GEAR_CHAR_BUTTON_TIP = "Tus pesos de atributos y las mejores mejoras que te esperan en los calabozos de la guía."
L.GEAR_SCAN_DONE = "Análisis de equipo guardado: %d objetos equipados y %d objetos de calabozos. Cierra sesión o escribe /reload para escribirlo en el archivo guardado."
L.GEAR_SCAN_ERRORS = "No se pudieron leer %d objetos; lo que falló se guarda con el análisis."
L.GEAR_SCAN_LOADING = "Aún se está cargando parte del botín: espera unos segundos y vuelve a escribir /aegis gearscan para obtener más."
L.GEAR_SLOT_FINGER1 = "Dedo 1"
L.GEAR_SLOT_FINGER2 = "Dedo 2"
L.GEAR_SLOT_TRINKET1 = "Abalorio 1"
L.GEAR_SLOT_TRINKET2 = "Abalorio 2"

-- Stat weights (Core/ItemScore.lua, UI/WeightsEditor.lua).
L.WEIGHTS_TITLE = "Pesos de atributos"
L.WEIGHTS_EDIT = "Editar pesos de atributos..."
L.WEIGHTS_SOURCE_DEFAULT = "Los pesos de la guía"
L.WEIGHTS_SOURCE_LEVELLING = "Los pesos de la guía, al subir de nivel"
L.WEIGHTS_SOURCE_CUSTOM = "Tus propios pesos"
L.WEIGHTS_SOURCE_PAWN = "Tus pesos, de Pawn: %s"
L.WEIGHTS_TIP = "Cuánto vale un punto de cada atributo para esta especialización. Haz clic en un peso para cambiarlo; tus propios pesos se muestran en verde y se guardan para este personaje."
L.WEIGHTS_RESET = "Restablecer"
L.WEIGHTS_RESET_TIP = "Volver a los pesos de la guía para esta especialización."
L.WEIGHTS_PAWN = "Pawn..."
-- The Pawn... button's tooltip names WoWSims' Pawn export (2026-11-03; drafted, to be checked).
L.WEIGHTS_PAWN_TIP = "Importar una escala de Pawn o pegar una exportación de Pawn de WoWSims."
L.WEIGHTS_PAWN_HELP = "En Pawn, elige la escala, selecciona Exportar, copia el texto y pégalo aquí."
L.WEIGHTS_IMPORT = "Importar"
L.WEIGHTS_CANCEL = "Cancelar"
L.WEIGHTS_BACK = "Volver"
L.WEIGHTS_OPEN_FINDER = "Abrir el Buscador de equipo"
L.WEIGHTS_IMPORTED = "Se importaron %d pesos de %s."
L.WEIGHTS_UNUSED = "Sin usar: %s."
L.WEIGHTS_NOT_PAWN = "Eso no es una escala de Pawn. En Pawn, selecciona Exportar y copia todo su texto."
L.WEIGHTS_OTHER_CLASS = "Esa escala es para la clase %s, no para la clase de este personaje."
L.WEIGHTS_FOR = "Para"
-- WoWSims' weights, the Gear Finder's defaults for the specs the sim has, and its Pawn export (2026-11-03; drafted, to be checked).
L.WEIGHTS_SOURCE_SIMS = "Los pesos de WoWSims: %s"
L.WEIGHTS_PAWN_SIMS = "Una exportación de Pawn de WoWSims (wowsims.com/forever) también funciona, con o sin Pawn, y puntúa como los pesos de WoWSims de la guía. No tiene pesos para curación, daño por escuela, penetración de hechizos, poder de ataque feral, defensa, bloqueo ni resistencias."
L.WEIGHTS_NO_STATS = "Esa escala de Pawn no tiene pesos que la guía pueda usar."
-- The journal's page in the game's options (Options > AddOns).
L.OPTIONS_TITLE = "Aegis Instance Journal"
L.OPTIONS_BOSS_LEVELS = "Mostrar los niveles de los jefes en la lista de jefes"
L.OPTIONS_BOSS_LEVELS_TIP = "Una insignia en el retrato de cada jefe con su nivel, coloreada según lo difícil que sea el jefe para ti: gris, verde, amarillo, naranja o rojo."
L.OPTIONS_ARROWS = "Marcar las mejoras con una flecha verde"
L.OPTIONS_MINIMAP = "Mostrar el botón del minimapa"
L.OPTIONS_PAWN_WEIGHTS = "Usar los pesos de atributos de Pawn en el Buscador de equipo"
L.OPTIONS_PAWN_WEIGHTS_TIP = "Con Pawn instalado, se muestran sus descripciones emergentes de objetos y sus flechas de mejora. Marcada: el Buscador de equipo puntúa los objetos con tu escala de Pawn para tu especialización. Sin marcar: Pawn muestra en su lugar los pesos de la guía para tu especialización, como una escala de la guía, y sus propias escalas quedan ocultas en este personaje hasta que marques esta opción."
L.PAWN_ASK = "Pawn también está instalado. Se mostrarán sus descripciones emergentes de objetos y sus flechas de mejora.\n\n¿Qué pesos de atributos deben usar tanto Pawn como el Buscador de equipo?\n\nLos de la guía: Pawn los muestra para tu especialización y oculta sus propias escalas en este personaje.\nLos de Pawn: el Buscador de equipo usa tus escalas de Pawn."
L.PAWN_USE_PAWN = "Los de Pawn"
L.PAWN_USE_JOURNAL = "Los de la guía"
L.PAWN_SCALE = "Guía: %s"
L.PAWN_RELOAD = "Las flechas de mejora de Pawn en tus bolsas de Baganator solo cambian después de recargar: Baganator conserva las respuestas de Pawn hasta que cambia tu equipo.\n\n¿Recargar ahora?"
L.PAWN_RELOAD_NOW = "Recargar"
L.PAWN_RELOAD_LATER = "Más tarde"
L.WEIGHTS_SOURCE_PAWN_LIVE = "Escala %s de Pawn. Cámbiala en Pawn o elige los pesos de la guía en sus opciones."
L.OPTIONS_MINIMAP_TIP = "El botón de la guía en el borde del minimapa: haz clic en él para abrir la guía, clic derecho para estas opciones y arrástralo para moverlo."
L.OPTIONS_DOCK = "Acoplar la ventana arriba a la izquierda"
L.OPTIONS_DOCK_TIP = "Marcada: la guía se abre arriba a la izquierda de la pantalla, donde el juego abre sus propias ventanas, y se aparta cuando se abre ahí una de ellas, como hacen entre sí; si no hay lugar para las dos, el juego cierra la más antigua. Arrástrala para moverla adonde quieras: se vuelve a acoplar la próxima vez que se abra. Desmarcada: se abre donde la arrastraste por última vez."
L.MINIMAP_LEFT_CLICK = "Haz clic para abrir o cerrar la guía."
L.MINIMAP_RIGHT_CLICK = "Clic derecho para ver sus opciones."
L.MINIMAP_DRAG = "Arrastra para moverlo alrededor del minimapa."
L.OPTIONS_ARROWS_TIP = "Una flecha verde en los objetos que son mejoras para tu especialización, según los cuenta el Buscador de equipo: en tus bolsas, en la ventana de botín y en las tiradas por botín."
L.WEIGHTS_SHOW_GAINS = "Mostrar pesos de atributos en las descripciones emergentes"
L.WEIGHTS_SHOW_GAINS_TIP = "Debajo de cada objeto, una línea por cada una de tus especializaciones: lo que vale el objeto según sus pesos y, cuando es una mejora, una flecha verde con lo que le aporta a tu equipo. Para todos tus personajes con el Buscador de equipo activado. Con Pawn instalado, esto muestra u oculta en su lugar la escala de la guía en Pawn y, con ella, las flechas de mejora de Pawn para los pesos de la guía: Pawn marca mejoras solo para las escalas que muestra."
L.OPTIONS_SOURCES = "Mostrar de dónde sale cada objeto en las descripciones emergentes"
L.OPTIONS_SOURCES_TIP = "Debajo de cada objeto que se consigue en los calabozos y bandas de la guía, una línea con el jefe y el calabozo: en tus bolsas, en tu personaje, en los enlaces del chat, con los vendedores y en cualquier otro lugar donde el juego muestre el objeto. Para todos tus personajes."
L.GEAR_WHY_CUSTOM = "%s (tus pesos)"
-- The specs' names and the units their weights count in, by spec key and by the English unit.
L.GEAR_SPEC_NAMES = {
	Arms = "Armas", Fury = "Furia", Protection = "Protección", Holy = "Sagrado", Retribution = "Reprensión",
	BeastMastery = "Bestias", Marksmanship = "Puntería", Survival = "Supervivencia",
	Assassination = "Asesinato", Combat = "Combate", Subtlety = "Sutileza", Discipline = "Disciplina", Shadow = "Sombra",
	Elemental = "Elemental", Enhancement = "Mejora", EnhancementTank = "Mejora (tanque)",
	Restoration = "Restauración", Arcane = "Arcano", Fire = "Fuego", Frost = "Escarcha", Affliction = "Aflicción",
	Demonology = "Demonología", Destruction = "Destrucción", Balance = "Equilibrio", FeralBear = "Combate feral (oso)",
	FeralCat = "Combate feral (felino)",
}
L.GEAR_UNITS = {
	["attack power"] = "poder de ataque", ["ranged attack power"] = "poder de ataque a distancia",
	["spell damage"] = "daño con hechizos", healing = "sanación", Stamina = "Aguante",
}
L.WEIGHT_GROUPS = {
	PRIMARY = "Atributos principales", WEAPONS = "Armas", SPELLS = "Hechizos", DEFENSE = "Defensa",
	RESISTANCE = "Resistencias",
}
L.STAT_NAMES = {
	STRENGTH = "Fuerza", AGILITY = "Agilidad", STAMINA = "Aguante", INTELLECT = "Intelecto", SPIRIT = "Espíritu",
	DPS = "DPS de arma", ["RANGED DPS"] = "DPS de arma a distancia", ["ATTACK POWER"] = "Poder de ataque",
	["RANGED ATTACK POWER"] = "Poder de ataque a distancia", ["FERAL ATTACK POWER"] = "Poder de ataque feral", HIT = "Probabilidad de golpe",
	CRIT = "Golpe crítico", ["RANGED CRIT"] = "Crítico a distancia", HASTE = "Velocidad de ataque", ["RANGED HASTE"] = "Velocidad a distancia",
	["SPELL POWER"] = "Daño y sanación", ["SPELL DAMAGE"] = "Daño con hechizos", HEALING = "Sanación", ["SPELL HIT"] = "Golpe con hechizos",
	["SPELL CRIT"] = "Crítico con hechizos", ["HOLY CRIT"] = "Crítico Sagrado", ["HOLY DAMAGE"] = "Daño Sagrado",
	["FIRE DAMAGE"] = "Daño de Fuego", ["FROST DAMAGE"] = "Daño de Escarcha", ["NATURE DAMAGE"] = "Daño de Naturaleza",
	["SHADOW DAMAGE"] = "Daño de Sombras", ["ARCANE DAMAGE"] = "Daño Arcano", ["SPELL PENETRATION"] = "Penetración de hechizos",
	MANA = "Maná", ["MANA PER 5"] = "Maná cada 5 s", ["CASTING REGEN"] = "Regeneración al lanzar hechizos",
	ARMOR = "Armadura", HEALTH = "Salud", ["HEALTH PER 5"] = "Salud cada 5 s", DEFENSE = "Defensa", DODGE = "Esquivar",
	PARRY = "Parada", BLOCK = "Bloqueo", ["BLOCK VALUE"] = "Valor de bloqueo",
	["HOLY RESISTANCE"] = "Resistencia a Sagrado", ["FIRE RESISTANCE"] = "Resistencia a Fuego",
	["NATURE RESISTANCE"] = "Resistencia a Naturaleza", ["FROST RESISTANCE"] = "Resistencia a Escarcha",
	["SHADOW RESISTANCE"] = "Resistencia a Sombras", ["ARCANE RESISTANCE"] = "Resistencia a Arcano",
}
L.RECORD_START = "Iniciar grabación"
L.RECORD_STOP = "Detener grabación"
L.RECORD_CLEAR = "Borrar"
L.RECORD_CLEAR_CONFIRM = "¿Descartar todo lo grabado hasta ahora? Esto no se puede deshacer."
L.RECORD_STATUS_ON = "Grabando desde %s"
L.RECORD_STATUS_OFF = "Sin grabar"
L.RECORD_COMBATLOG = "Escribir el registro de combate en los calabozos"
L.RECORD_COMBATLOG_TIP = "Las habilidades de los jefes provienen del registro de combate del juego. La guía lo activa dentro de los calabozos y lo vuelve a desactivar al salir; un registro que hayas iniciado tú no se toca. Para enviarlo, agrega el archivo del registro a tu grabación en la página del Log Reader (Copiar muestra el enlace)."
L.RECORD_RECENT = "Reciente"
L.RECORD_NOTHING_YET = "Aún no se ha captado nada. Entra a un calabozo con la grabación activada y luego mata, despoja y haz misiones como siempre."
L.RECORD_STARTED = "Grabación iniciada. /aegis record la detiene."
L.RECORD_STOPPED = "Grabación detenida."
L.RECORD_LOG_STARTED = "Grabación iniciada."
L.RECORD_LOG_STOPPED = "Grabación detenida."
L.RECORD_LOG_CLEARED = "Grabaciones borradas."
L.RECORD_LOG_ENTERED = "Entraste a %s."
L.RECORD_LOG_LEFT = "Saliste del calabozo."
L.RECORD_LOG_AREA = "Nueva área: %s."
L.RECORD_LOG_PULL = "Combate iniciado con %s."
L.RECORD_LOG_KILL = "Derrotado: %s."
L.RECORD_LOG_WIPE = "El grupo cayó ante %s."
L.RECORD_LOG_LOOT = "Botín: %d objeto(s) nuevo(s)."
L.RECORD_LOG_QUEST_OFFERED = "Misión ofrecida: %s."
L.RECORD_LOG_QUEST_DONE = "Misión entregada: %s."
L.RECORD_LOG_ENTRANCE = "Entrada de %s grabada."
L.RECORD_LOG_NO_ENTRANCE = "Entrada de %s no grabada: %s."
L.RECORD_NO_MAP = "el juego no dio ningún mapa al empezar la pantalla de carga"
L.RECORD_NO_POSITION = "el juego no dio ninguna posición al empezar la pantalla de carga"
L.RECORD_IN_DUNGEON_MAP = "la pantalla de carga empezó en el mapa de un calabozo"
L.RECORD_LOG_COMBATLOG_ON = "Registro de combate activado: Logs\\%s."
L.RECORD_LOG_COMBATLOG_OFF = "Registro de combate desactivado."

L.LEVEL_RANGE = "Nivel %d-%d"
L.LEVEL_ALL = "Todos los niveles"
L.LEVEL_BRACKET = "Niveles %d a %d"
L.TRASH_DROPS = "Botín de bichos"
L.UNTESTED = "Aún sin probar"
L.UNTESTED_NOTE = "Aún sin probar: lo que hay aquí proviene del anuncio de Blizzard y podría estar incompleto. Recórrelo con la pestaña Grabar activada para completar sus jefes, su botín y su entrada."
L.COMING_SOON = "Próximamente"
L.COMING_SOON_TEXT = "Aún no está abierto en WoW: Forever. Sus jefes, su botín y su mapa se irán agregando a medida que los jugadores graben sus recorridos. ¿Grabaste uno? Publícalo en nuestro Discord y tu nombre aparecerá entre los colaboradores de la guía."
L.COMING_SOON_PARTLY = "Aún no está abierto en WoW: Forever: lo que hay aquí proviene del anuncio de Blizzard. ¿Grabaste un recorrido? Publícalo en nuestro Discord y tu nombre aparecerá entre los colaboradores de la guía."
L.DISCORD_COPY_HINT = "Haz clic y luego Ctrl+C"
L.FOREVER_MARK = "Nuevo en WoW: Forever"
L.RECORD_LOG_VENDOR = "%s: %d artículos guardados, %d nuevos para la guía."
L.RECORD_CAUGHT = "%d captados, %d nuevos desde tu última copia"
L.RECORD_COPY = "Copiar"
L.RECORD_AUTO = "Grabar automáticamente en los calabozos"
L.RECORD_AUTO_TIP = "La grabación se inicia sola al entrar a un calabozo o a una banda, y se detiene al salir. Una grabación que hayas iniciado tú nunca se detiene automáticamente."
L.RECORD_RECORDER = "Grabadora"
L.RECORD_SEND = "Envíanosla"
L.RECORD_HELP_TEXT = "Presiona Copiar y luego pega el texto en nuestro Discord:"
L.RECORD_CREDIT = "Darme crédito como:"
L.RECORD_CREDIT_TIP = "El nombre con el que se acreditan tus grabaciones entre los colaboradores de la guía. Si lo dejas vacío, será el nombre de tu personaje."
L.RECORD_CONTRIBUTORS = "Colaboradores"
L.RECORD_CONTRIBUTORS_NONE = "Nadie todavía: sé el primero."
L.RECORD_CONTRIBUTORS_FOOT = "Envía la tuya: tu nombre aparecerá aquí."
L.RECORD_COPY_TITLE = "Tu grabación, como texto"
L.RECORD_COPY_HINT = "Ya está todo seleccionado: presiona Ctrl+C y pégalo en nuestro Discord."
L.RECORD_COPY_HINT_LOG = "Presiona Ctrl+C y pégalo en el Log Reader junto con tu registro de combate (%s, en la carpeta Logs del juego). Publica lo que te dé en nuestro Discord."
L.RECORD_MORE_LOGS = "%s y %d más antiguos"
L.RECORD_BACK = "Volver"
L.RECORD_CAUGHT_TITLE = "Lo que captaste"
L.RECORD_ITEM = "Objeto %s"
L.RECORD_ONE_VISIT = "1 visita"
L.RECORD_VISITS = "%d visitas"
L.RECORD_ENTRANCE_YES = "entrada grabada"
L.RECORD_ENTRANCE_NO = "entrada aún sin grabar"
L.RECORD_AREAS = "%d áreas"
L.RECORD_KILLED = "Derrotados: %s"
L.RECORD_KILLED_TIMES = "%s (%d)"
L.RECORD_DROPS = "Botín: %s nuevos, %s ya en la guía"
L.RECORD_OFF = "De %s"
L.RECORD_OFF_TRASH = "De bichos"
L.RECORD_OFF_GROUP = "Despojado por tu grupo"
L.RECORD_OFF_OBJECTS = "De cofres y plantas"
L.RECORD_QUESTS = "Misiones"
L.RECORD_QUEST_DONE = "entregada"
L.RECORD_NEW = "nueva"
L.RECORD_QUARTERMASTERS = "Intendentes"
L.RECORD_WARES = "%s: %d artículos, %s nuevos"
L.RECORD_TRAVEL = "Marcas de viaje: %d"
L.FOREVER_LINE = "Nuevo en WoW: Forever."
L.LOCATION_LINE = "Ubicación: %s"

-- The dungeon's round icon at the top of its left page: its tooltip, under the dungeon's name (2026-11-04; drafted, to be checked).
L.INSTANCE_ICON_OVERVIEW = "Haz clic para ver su resumen."

L.TAB_OVERVIEW = OVERVIEW or "Resumen"
L.TAB_LOOT = LOOT_NOUN or "Botín"
L.TAB_ABILITIES = ABILITIES or "Habilidades"
L.TAB_MODEL = MODEL or "Modelo"
L.TAB_QUESTS = QUESTS_LABEL or "Misiones"
L.ALL_CLASSES = ALL_CLASSES or "Todas las clases"
L.ALL_ARMOR = "Todas las armaduras"
L.ALL_TYPES = "Todos los tipos"
-- The loot pages' Type menu: the kinds of item, "All ..." atop the two with a submenu, and one of each.
L.LOOT_KIND = {
	EQUIPMENT = "Equipo", RECIPE = "Recetas", CONSUMABLE = "Consumibles", MOUNT = "Monturas", PET = "Mascotas",
	TOY = "Juguetes", BAG = "Bolsas", TRADE = "Objetos comerciables", QUEST = "Objetos de misión", OTHER = "Otros",
}
L.LOOT_KIND_ALL = { EQUIPMENT = "Todo el equipo", RECIPE = "Todas las recetas" }
L.LOOT_KIND_ONE = { MOUNT = "Montura", PET = "Mascota", TOY = "Juguete" }
L.LOOT_RECIPE = "Receta"
L.LOOT_FAVORITES = "Favoritos"
L.LOOT_FAVORITES_ONLY = "Solo favoritos"
L.LOOT_FAVORITE = "Agregar a favoritos"
L.LOOT_UNFAVORITE = "Quitar de favoritos"
L.LOOT_PINNED = "Fijados"
L.LOOT_ALL = "Botín"
L.LOOT_TRASH = "Bichos del calabozo"
L.DROPS_FROM_BOSS = "Botín de %s (%s)"
L.DROPS_FROM_TRASH = "Botín de bichos (%s)"
L.DROPS_FROM_BOSSES = "Botín de %d jefes (%s)"
L.DROPS_IN = "Botín en: %s"
L.DROPS_ALSO_IN = "También botín en: %s"
L.LEGEND_CLICK_HIDE = "Haz clic para ocultarlos en el mapa."
L.LEGEND_CLICK_SHOW = "Ocultos. Haz clic para volver a mostrarlos en el mapa."
-- The legend's Quest entry, the journal's own switch for its ! marks: what it does (2026-11-06; drafted, to be checked).
L.LEGEND_QUEST_TIP = "Las marcas ! de la guía en los mapas: misiones que puedes aceptar y, en gris, las que aún no están disponibles."
L.LEGEND_GAME_FILTER = "El filtro de mapa propio del juego, como en el menú de filtros del mapa: las misiones en curso y las listas para entregar comparten uno."
L.LEGEND_GAME_FILTER_MENU = "Se muestran u ocultan desde el menú de filtros del mapa: %s."
L.PREPARE_TITLE = "Antes de ir"
L.PREPARE_PROGRESS = "Completaste %d de sus %d misiones."
-- The same for a key with one quest (2026-10-30; drafted, to be checked).
L.PREPARE_PROGRESS_ONE = "Todavía no completas su misión."
L.PREPARE_HAVE = "Ya la tienes."
L.PREPARE_QUEST_HINT = "Haz clic para verla en la pestaña Misiones."
L.QUESTS_DUNGEON = "Misiones del calabozo"
-- The same on a raid's Quests tab (2026-10-30; drafted, to be checked).
L.QUESTS_RAID = "Misiones de la banda"
-- The Quests tab's dropdown of the quests for the player's class alone (2026-11-03; drafted, to be checked).
L.QUESTS_CLASS = "Misiones de clase"
L.TRASH = "Bichos"
L.TRASH_DESCRIPTION = "Lo que sueltan las demás criaturas del calabozo que vale la pena conocer: equipo raro y épico, recetas y objetos de misión."
L.LOOT_BOSS_LINE = BOSS_INFO_STRING or "Jefe: %s"
L.LOOT_FILTER_BAR = "Filtro: %s"
L.LOOT_RETRIEVING = RETRIEVING_ITEM_INFO or "Obteniendo información del objeto"
L.LOOT_NO_DATA = "Objeto %d"
L.LOOT_NO_DATA_TOOLTIP = "El servidor no ha enviado los detalles de este objeto. Puede que aún no esté en el juego."
L.LOOT_UNIDENTIFIED_TOOLTIP = "Aún sin identificar: su fuente lo nombra, pero no da su ID de objeto. Despójalo mientras grabas para agregarlo."
L.LOOT_TOOLTIP_PIN = "Clic derecho para fijar este objeto al principio de esta lista."
L.LOOT_TOOLTIP_UNPIN = "Clic derecho para dejar de fijarlo."
L.LOOT_NONE = "Aún no se conoce botín para esto."
L.LOOT_NO_MATCH = "Nada aquí coincide con los filtros. Bórralos con la X de arriba."
L.ABILITY_LOADING = RETRIEVING_DATA or "Obteniendo datos..."
L.ABILITIES_NONE = "Aún no se conocen habilidades para este encuentro. Graba un recorrido desde la pestaña Grabar para captarlas."
L.STATS_HIT = "Inflige %s"
L.STATS_TICK = "tics de %s"
L.STATS_FIRST = "primer lanzamiento a los %d s"
L.STATS_EVERY = "luego cada %s s"
L.QUEST_NONE = "No se conocen misiones de tu facción para este calabozo."
L.QUEST_STATUS_READY = "Completada: lista para entregar"
L.QUEST_STATUS_NEEDS = "Requiere: %s"
L.QUEST_STATUS_LEVEL = "Requiere nivel %d"
L.QUEST_DESCRIPTION = QUEST_DESCRIPTION or "Descripción"
L.QUEST_START_ITEM = "Empieza con:"
L.QUEST_PARTS = "%s (%d partes)"
-- A row for the quests of one chain that share a name: which of them its page shows (2026-11-04; drafted, to be checked).
L.QUEST_PART_OF = "Parte %d de %d"
-- One of them as a row of its own, in a chain: which part it is (2026-11-06; drafted, to be checked).
L.QUEST_PART_NAME = "%s (Parte %d)"
-- A step any one of several quests will do (2026-10-30; drafted, to be checked).
L.QUEST_STATUS_NEEDS_VERSION = "Requiere una de las %d versiones de %s"
L.QUEST_STATUS_NEEDS_ONE_OF = "Requiere una de estas: %s"
-- A quest given only while another is in the log (2026-11-03; drafted, to be checked).
L.QUEST_STATUS_NEEDS_IN_LOG = "Requiere: %s en tu registro de misiones"
L.QUEST_OR = " o "
L.QUEST_LIST_COMMA = ", "
L.QUEST_ONE_OF_VERSIONS = "Esta misión tiene %d versiones. Cualquiera de ellas sirve."
L.QUEST_ONE_OF_ANY = "Cualquiera de estas misiones sirve."
L.QUEST_SHOW_START = "Mostrar inicio"
L.QUEST_SHOW_END = "Mostrar final"
L.QUEST_PLACE_UNKNOWN = "Ubicación aún desconocida. Acepta o entrega esta misión con la pestaña Grabar en marcha para agregarla."
L.QUEST_OFFERED_BY = "Misión ofrecida por %s"
L.QUEST_HAND_IN_TO = "Entregar a %s"
L.QUESTMAP_DUNGEON_QUEST = "Misión de calabozo: %s"
L.QUESTMAP_RAID_QUEST = "Misión de banda: %s"
L.QUESTMAP_LEFT_CLICK = "Clic izquierdo para abrirla en la guía"
L.QUESTMAP_WAYPOINT_SET = "Punto de ruta establecido para %s."
L.QUESTMAP_WAYPOINT_SET_IN = "Punto de ruta establecido para %s, en %s."
L.WAYPOINT_OFFER = "Haz clic en %s para establecer el punto de ruta."
L.QUESTMAP_ONE_OF = "No siempre está en el mismo lugar: en uno de %d puntos."
-- What is looted, used or explored for a quest inside a dungeon, on its mark's tooltip, after the game's dash: the
-- item to take, the same for a name with no "the" in English, the thing to use, a place to explore (2026-11-11;
-- translation drafted, to be checked).
L.QUESTMAP_OBJECTIVE_TAKE = "Tomar: %s"
L.QUESTMAP_OBJECTIVE_TAKE_NAMED = "Tomar: %s"
L.QUESTMAP_TITLE_QUOTED = "“%s”"
L.QUESTMAP_OBJECTIVE_USE = "Usar: %s"
L.QUESTMAP_OBJECTIVE_EXPLORE = "Explorar este lugar"
-- A Matrix Punchograph's step, what goes in, then what comes out, in short words ("Yellow > Blue"), and the punch
-- cards' colors, as the cards' own names in the language have them (2026-11-12, the owner's "Blue > Red"; drafted, to
-- be checked); where what goes in drops (2026-11-12; drafted, to be checked).
L.QUESTMAP_OBJECTIVE_STEP = "%s > %s"
L.QUESTMAP_CARD_WHITE = "Blanca"
L.QUESTMAP_CARD_YELLOW = "Amarilla"
L.QUESTMAP_CARD_BLUE = "Azul"
L.QUESTMAP_CARD_RED = "Roja"
L.QUESTMAP_CARD_PRISMATIC = "Centelleante"
L.QUESTMAP_NOTE_INPUT_DROPS = "Los enemigos de estos túneles dejan caer %s."
-- A machine used again once its quest is done: it takes another of what it cleans (2026-11-12; drafted, to be checked).
L.QUESTMAP_REPEAT_AGAIN = "Repetible: introduce otro ejemplar de %s."
-- What a boss is to a quest, on his tooltip under his quest badge: one to kill, one that drops what the quest needs,
-- the same for a name with no "the" in English, one whose drop starts the quest; who gives or takes it there,
-- himself or by name; a quest's mob more than a boss (2026-11-11; translation drafted, to be checked).
L.QUEST_BADGE_KILL = "Matar para esta misión"
L.QUEST_BADGE_DROPS = "Suelta: %s"
L.QUEST_BADGE_DROPS_NAMED = "Suelta: %s"
L.QUEST_BADGE_STARTS = "Suelta: %s (inicia una misión)"
L.QUEST_BADGE_STARTS_NAMED = "Suelta: %s (inicia una misión)"
L.QUEST_BADGE_GIVES = "Da esta misión"
L.QUEST_BADGE_GIVES_WHO = "%s da esta misión aquí"
L.QUEST_BADGE_TAKES = "Entrégala aquí"
L.QUEST_BADGE_TAKES_WHO = "Entrégala aquí a: %s"
L.QUEST_TARGET = "Objetivo de misión"
L.MAP_ONE_OF = "No siempre está en el mismo lugar: en uno de %d puntos."
L.QUEST_REWARDS = REWARDS or "Recompensas"
L.QUEST_YOU_RECEIVE = YOU_RECEIVE or "Recibirás:"
L.QUEST_XP = "%s de experiencia"
-- XP that is only the original game's number, not yet confirmed on Forever: a note after it, and
-- its tooltip (2026-10-30; drafted, to be checked).
L.QUEST_XP_ORIGINAL = "(juego original)"
L.QUEST_XP_ORIGINAL_TIP = "Es lo que daba la misión en el juego original. Forever quizá dé más. Todavía no se ha comprobado en Forever. Entrégala con la pestaña Grabar en marcha para agregar lo que da Forever."
L.QUEST_REPUTATION = "%d de reputación con %s"
L.QUEST_CHOOSE = REWARD_CHOICES or "Podrás elegir una de estas recompensas:"
L.QUEST_ALSO = REWARD_ITEMS or "También recibirás:"
L.REP_REWARDS = "%d recompensas"
L.REP_REWARD_ONE = "1 recompensa"
L.REP_ALL_REWARDS = "Recompensas"
-- The group for wares that need no standing (2026-11-12; drafted, to be checked)
L.REP_ANY_STANDING = "Cualquier reputación"
L.REP_UNKNOWN = "Sin conocer"
L.REP_CARD_CLICK = "Haz clic para ver sus recompensas."
L.REP_YOUR_STANDING = "Tu reputación: %s"
L.REP_NOT_MET = "Aún no conoces a esta facción."
L.REP_PROGRESS = "%s / %s"
L.REP_QUARTERMASTER = "Intendente: %s"
L.REP_CAPTURE = "Capturar vendedor"
L.REP_CAPTURE_TIP = "Acércate a un intendente de reputación, abre su tienda y luego presiona esto. Se guarda todo lo que vende: el precio de cada artículo, cualquier otro costo y la reputación que requiere. Los artículos se suman de inmediato a las recompensas de su facción y se incluyen cuando presionas Copiar en la pestaña Grabar."
L.REP_CAPTURE_READY = "Tienda abierta: presiona Capturar vendedor."
L.REP_CAPTURE_HINT = "Abre la tienda de un intendente para capturar sus artículos."
L.REP_CAPTURED = "%s: %d artículos para %s, %d nuevos."
L.REP_CAPTURED_NONE = "%s: %d artículos guardados; ninguno requiere reputación."
L.REP_CAPTURED_UNKNOWN = "%s: %d artículos requieren reputación con una facción que el juego no nombra; se guardan hasta que un artículo la nombre."
L.REP_NOT_CAPTURED = "Aún sin capturar"
L.REP_NOT_CAPTURED_TIP = "Nadie ha capturado aún al intendente de esta facción."
L.REP_NOT_CAPTURED_TEXT = "Nadie ha capturado aún al intendente de esta facción. Busca uno, abre su tienda y presiona Capturar vendedor en la pestaña Reputación; luego publica tu grabación en nuestro Discord. Tu nombre aparecerá entre los colaboradores de la guía."
L.REP_LISTED_TIP = "Sus recompensas provienen de los datos de objetos del juego y aún no se han confirmado con un intendente."
L.REP_LISTED_TEXT = "Estas recompensas provienen de los datos de objetos del juego, aún no de un intendente, así que no tienen precios y puede que algunas ni siquiera estén a la venta. Busca a uno de los intendentes de esta facción, abre su tienda y presiona Capturar vendedor en la pestaña Reputación; luego publica tu grabación en nuestro Discord. Tu nombre aparecerá entre los colaboradores de la guía."
L.REP_COMING_SOON_TEXT = "Nueva en WoW: Forever y aún sin capturar. Cuando esté en el juego, busca a su intendente, abre su tienda y presiona Capturar vendedor en la pestaña Reputación; luego publica tu grabación en nuestro Discord."
L.MAP_SHOW = ENCOUNTER_JOURNAL_SHOW_MAP or "Mostrar mapa"
L.MAP_SHOW_UNEXPLORED = "Mostrar áreas sin explorar"
L.OPTIONS_UNEXPLORED_TIP = "Sombrea en el mapa del mundo las partes de cada zona que aún no has explorado."
L.MAP_FILTER_QUESTS = "Misiones disponibles"
L.MAP_FILTER_DUNGEONS = "Entradas de calabozos"
L.MAP_FILTER_RAIDS = "Entradas de bandas"
L.MAP_FILTER_FLIGHT = "Puntos de vuelo"
L.MAP_FILTER_CAVES = "Entradas de cuevas"
L.MAP_FILTER_TRANSPORT = "Barcos, zepelines, tranvías y portales"
L.MAP_PIN_OPEN = "Haz clic para abrirlo en la guía."
L.MAP_DEFEATED = DUNGEON_ENCOUNTER_DEFEATED or "Derrotado"
L.MAP_LEVEL = "Nivel %d"
L.MAP_FLOOR = "Piso %d"
L.MAP_GO_TO = "Hacia %s"
L.MAP_YOU_ARE_HERE = "Estás aquí"
L.ENTRANCE_DUNGEON = LFG_TYPE_DUNGEON or "Calabozo"
L.ENTRANCE_RAID = LFG_TYPE_RAID or "Banda"
L.ENTRANCE_DUNGEONS = DUNGEONS or "Calabozos"
L.ENTRANCE_RAIDS = RAIDS or "Bandas"
L.ENTRANCE_LEFT_CLICK = "Clic izquierdo para abrir la Guía de calabozos"
L.ENTRANCE_CHOOSE_LEFT_CLICK = "Clic izquierdo para elegir cuál abrir en la Guía de calabozos"
L.ENTRANCE_RIGHT_CLICK = "Clic derecho para establecer un punto de ruta"
L.ENTRANCE_WAYPOINT_SET = "Punto de ruta establecido en la entrada de %s."
L.ENTRANCE_VIA = "Su portal está más abajo, en %s: baja por la entrada de la cueva."
L.ENTRANCE_WAYPOINT_VIA = "Punto de ruta establecido en la bajada a %s, para %s."
L.CAVE_LABEL = "Entrada de cueva"
L.BUILDING_LABEL = "Entrada"
L.ENTRANCE_VIA_BUILDING = "Su portal está adentro, en %s: entra por la entrada."
L.CAVE_LEADS_TO = "El camino a %s"
L.CAVE_LEFT_CLICK = "Clic izquierdo para ver el mapa de %s"
L.CAVE_WAYPOINT_SET = "Punto de ruta establecido en la bajada a %s."
L.FLIGHT_POINT = MAP_LEGEND_FLIGHTPOINT or "Punto de vuelo"
L.CLICK_FOR_WAYPOINT = "Haz clic para establecer un punto de ruta"
L.FLIGHT_WAYPOINT_SET = "Punto de ruta establecido en el maestro de vuelo de %s."
L.TRAVEL_KINDS = { boat = "Barco", zeppelin = "Zepelín", airship = "Aeronave", tram = "Tranvía", portal = "Portal" }
L.TRAVEL_FACTIONS = { Alliance = FACTION_ALLIANCE or "Alianza", Horde = FACTION_HORDE or "Horda" }
L.TRAVEL_ROUTE = "%s a %s"
L.TRAVEL_AND = "%s y %s"
L.TRAVEL_ROUTE_NOTE = "%s: %s"
L.TRAVEL_HELP = "Colócate en un muelle, una torre de zepelín, un tranvía o un portal y escribe /aegis travel boat (o zeppelin, airship, tram, portal) seguido de su destino, p. ej. /aegis travel boat Auberdine. Agrega alliance, horde o neutral al final para indicar a quién sirve, y una nota entre paréntesis para indicar quién puede usarlo, p. ej. /aegis travel portal Dalaran (solo Cielonatos). /aegis travel list muestra lo guardado; /aegis travel undo deshace lo último."
L.TRAVEL_NO_POSITION = "El juego no da ninguna posición aquí, así que no se guardó nada."
L.TRAVEL_SAVED = "%s guardado en %s. /aegis travel undo lo deshace."
L.TRAVEL_UNDONE = "Se deshizo %s en %s."
L.TRAVEL_NOTHING = "No hay nada que deshacer."
L.TRAVEL_LIST_EMPTY = "Aún no hay puntos de viaje guardados. Escribe /aegis travel para ver cómo."
L.TRAVEL_LIST_LINE = "%d. %s en %s (mapa %d, %.4f, %.4f)"
L.TRAVEL_WAYPOINT_SET = "Punto de ruta establecido en %s."
L.LEGEND_TRANSPORT = "Transporte"
L.LEGEND_TRANSPORT_TOOLTIP = "Barcos, zepelines, el tranvía y portales. El azul sirve a la Alianza, el rojo a la Horda y el dorado a todos."
L.LEGEND_CAVE_TOOLTIP = "El camino a una cueva, donde está la entrada de un calabozo. Haz clic en él en el mapa para ver su interior."
L.LEGEND_BUILDING_TOOLTIP = "El camino a un edificio, a los salones de una montaña o a un nivel debajo de la zona, donde está la entrada de un calabozo. Haz clic en él en el mapa para ver su interior."
L.SEARCH_SHOW_ALL = SEARCH_RESULTS_SHOW_COUNT or "Mostrar los %d resultados"
L.SEARCH_RESULTS = ENCOUNTER_JOURNAL_SEARCH_RESULTS or "Resultados de la búsqueda de \"%s\" (%d)"
L.SEARCH_TYPE_BOSS = "Encuentro"
L.SEARCH_TYPE_ABILITY = "Habilidad"
L.SEARCH_TYPE_ITEM = "Objeto"
L.SEARCH_TYPE_QUEST = "Misión"
L.SEARCH_TYPE_FACTION = FACTION or "Facción"
L.MAP_PIN_CLEAR = "Haz clic para quitar este marcador."
L.MAP_PIN_COMBAT = "El mapa no se puede abrir en combate."
L.MAP_PIN_IN_ZONE = "%s está marcado en el mapa de %s."
L.MAP_LEVEL_LINK_CLICK = "Clic izquierdo para ver el mapa de ese nivel"
L.DOOR_SPIRE_ONE_INSTANCE = "La Cumbre de Roca Negra Inferior y la Superior son una sola instancia, con una sola puerta."
L.DOOR_SPIRE_LOWER = "Cumbre de Roca Negra Inferior: hasta 10 jugadores, pero sus misiones solo se pueden completar en un grupo de 5 o menos."
L.DOOR_SPIRE_UPPER = "Cumbre de Roca Negra Superior: más adentro, detrás de una puerta sellada que requiere el sello de ascensión. Hasta 10 jugadores."

L.RARE_SUFFIX = " (Raro)"
L.AND_MORE = "y %d más"
L.BULLET_AREA = "Se encuentra en %s."
L.BULLET_RARE = "Una criatura rara: no aparece en todos los recorridos."
L.BULLET_SUMMONED = "Un jefe oculto que invocas tú mismo: la nota de arriba explica cómo."
-- A quest's mob, on the map only, on his page (2026-11-11; translation drafted, to be checked).
L.BULLET_QUEST_TARGET = "Un objetivo de misión, no uno de los jefes de la mazmorra."
L.BULLET_LEVEL = "Un encuentro de nivel %d."
L.BULLET_ABILITIES = "Visto lanzando: %s."
L.BULLET_LOOT = "Suelta %d objetos, entre ellos %s."
L.BULLET_ADDS = "Acompañado por %s."
L.ADD_DESCRIPTION = "Lucha junto a %s."
L.BULLET_NOTHING_YET = "Aún no se sabe nada de este encuentro."

--[[
	The Latin American client's classic "Equip:" wordings (drafted from the esMX tooltip patterns Pawn
	reads, with the Spanish variants older items use; check against items in game). Each is matched on
	the text after "Equipar:", in lower case: Lua lowers A-Z only, so accented letters stay as written.
	The number comes before or after the stat's words, so most stats have a pattern for each order.
]]
L.EQUIP_PATTERNS = {
	-- Bonuses against undead or demons only, effects on being struck or on a hit, reduced dodge and
	-- parry against you, and the later ratings: worth nothing.
	{ "no%-muert", false },
	{ "no muert", false },
	{ "contra demonio", false },
	{ "poder de ataque.-contra", false },
	{ "poder de ataque.-al luchar", false },
	{ "en combate", false },
	{ "cuando te golpe", false },
	{ "al ser golpead", false },
	{ "atacante", false },
	{ "esquiven", false },
	{ "defensa aumentada %+?{n}", "DEFENSE" },
	{ "{n}.-índice de defensa", "DEFENSE" },
	{ "índice de defensa.-{n}", "DEFENSE" },
	{ "{n} p%. la defensa", "DEFENSE" },
	{ "{n} p%. de defensa", "DEFENSE" },
	{ "índice", false },
	{ "{n}%%.-crítico.-sagrad", "HOLY CRIT" },
	{ "crítico.-{n}%%.-sagrad", "HOLY CRIT" },
	{ "crítico.-sagrad.-{n}", "HOLY CRIT" },
	{ "{n}%%.-crítico.-hechizos y ataques", { "CRIT", "SPELL CRIT" } },
	{ "crítico.-hechizos y ataques.-{n}", { "CRIT", "SPELL CRIT" } },
	{ "{n}%%.-crítico.-hechizo", "SPELL CRIT" },
	{ "crítico.-{n}%%.-hechizo", "SPELL CRIT" },
	{ "crítico.-hechizo.-{n}", "SPELL CRIT" },
	{ "{n}%%.-crítico.-distancia", "RANGED CRIT" },
	{ "crítico.-{n}%%.-distancia", "RANGED CRIT" },
	{ "crítico.-distancia.-{n}", "RANGED CRIT" },
	{ "{n}%%.-crítico", "CRIT" },
	{ "crítico.-{n}", "CRIT" },
	{ "{n}%%.-golpear con todos", { "HIT", "SPELL HIT" } },
	{ "golpear con todos.-{n}", { "HIT", "SPELL HIT" } },
	{ "{n}%%.-golpear con hechizos", "SPELL HIT" },
	{ "golpear con hechizos.-{n}", "SPELL HIT" },
	{ "{n}%%.-alcanzar.-hechizos", "SPELL HIT" },
	{ "alcanzar.-hechizos.-{n}", "SPELL HIT" },
	{ "{n}%%.-golpear", "HIT" },
	{ "golpear.-{n}", "HIT" },
	{ "{n}%%.-alcanzar", "HIT" },
	{ "alcanzar.-{n}", "HIT" },
	{ "{n}.-daño y l?a? ?sanación", { "SPELL POWER", "HEALING" } },
	{ "daño y l?a? ?sanación.-{n}", { "SPELL POWER", "HEALING" } },
	{ "{n}.-daño y l?a? ?curación", { "SPELL POWER", "HEALING" } },
	{ "daño y l?a? ?curación.-{n}", { "SPELL POWER", "HEALING" } },
	{ "{n}.-sanación", "HEALING" },
	{ "sanación.-{n}", "HEALING" },
	{ "{n}.-curación", "HEALING" },
	{ "curación.-{n}", "HEALING" },
	{ "{n}.-daño.-sagrad", "HOLY DAMAGE" },
	{ "daño.-sagrad.-{n}", "HOLY DAMAGE" },
	{ "{n}.-daño.-fuego", "FIRE DAMAGE" },
	{ "daño.-fuego.-{n}", "FIRE DAMAGE" },
	{ "{n}.-daño.-escarcha", "FROST DAMAGE" },
	{ "daño.-escarcha.-{n}", "FROST DAMAGE" },
	{ "{n}.-daño.-naturaleza", "NATURE DAMAGE" },
	{ "daño.-naturaleza.-{n}", "NATURE DAMAGE" },
	{ "{n}.-daño.-sombra", "SHADOW DAMAGE" },
	{ "daño.-sombra.-{n}", "SHADOW DAMAGE" },
	{ "{n}.-daño.-arcan", "ARCANE DAMAGE" },
	{ "daño.-arcan.-{n}", "ARCANE DAMAGE" },
	{ "{n}.-daño.-mágic", "SPELL DAMAGE" },
	{ "daño.-mágic.-{n}", "SPELL DAMAGE" },
	{ "{n}.-daño con hechizos", "SPELL DAMAGE" },
	{ "{n}%%.-regeneración de maná", "CASTING REGEN" },
	{ "regeneración de maná.-{n}%%", "CASTING REGEN" },
	{ "resistencias mágicas.-{n}", "SPELL PENETRATION" },
	{ "{n}.-resistencias mágicas", "SPELL PENETRATION" },
	{ "penetración de.-hechizos.-{n}", "SPELL PENETRATION" },
	{ "{n}.-penetración de.-hechizos", "SPELL PENETRATION" },
	{ "{n}.-poder de ataque a distancia", "RANGED ATTACK POWER" },
	{ "poder de ataque a distancia.-{n}", "RANGED ATTACK POWER" },
	{ "{n}.-poder de ataque.-felin", "FERAL ATTACK POWER" },
	{ "poder de ataque.-{n}.-felin", "FERAL ATTACK POWER" },
	{ "poder de ataque.-felin.-{n}", "FERAL ATTACK POWER" },
	{ "{n}.-poder de ataque", "ATTACK POWER" },
	{ "poder de ataque.-{n}", "ATTACK POWER" },
	{ "{n}.-maná cada 5", "MANA PER 5" },
	{ "{n}.-maná por 5", "MANA PER 5" },
	{ "{n}.-vida cada 5", "HEALTH PER 5" },
	{ "{n}.-salud cada 5", "HEALTH PER 5" },
	{ "restaura {n}.-vida", "HEALTH PER 5" },
	{ "restaura {n}.-salud", "HEALTH PER 5" },
	{ "{n}%%.-esquivar", "DODGE" },
	{ "esquivar.-{n}", "DODGE" },
	{ "{n}%%.-parar", "PARRY" },
	{ "parar.-{n}", "PARRY" },
	{ "valor de bloqueo.-{n}", "BLOCK VALUE" },
	{ "{n}.-valor de bloqueo", "BLOCK VALUE" },
	{ "{n}%%.-bloquear", "BLOCK" },
	{ "bloquear.-{n}", "BLOCK" },
	{ "{n}%%.-velocidad de ataque", "HASTE" },
	{ "velocidad de ataque.-{n}", "HASTE" },
}

-- The rooms inside dungeons, as the client names them where the player stands: "You are
-- here" and a wing's areas match these (Core/Areas.lua). Unconfirmed ones are listed in
-- the translation's to-check list.
L.AREA_NAMES = {
	["Aku'mai's Lair"] = "Guarida de Aku'mai",
	["Anvilmar's Rest"] = "Reposo de Yunquemar",
	["Athenaeum"] = "El Athenaeum",
	["Blackrock Stadium"] = "Estadio de Roca Negra",
	["Blackrock Stronghold"] = "Bastión de Roca Negra",
	-- City of Dalaran's rooms (Data/Authored/CityOfDalaran.lua's floors: Cantrips & Crows, City of
	-- Dalaran, Dalaran, Magus Commerce Exchange, Path of Renewal, Presage Plaza, Runeweaver Square, Sewer,
	-- The Eventide, The Purple Parlor, The Underbelly, The Violet Citadel, The Violet Hold): the city's
	-- own buildings name them. Most have no area id; Dalaran (279, 16558), City of Dalaran (16544, 16560)
	-- and The Eventide (17824) have, not baked yet: a scan (/aegis areas, Dev/bake_area_ids.py) can
	-- replace those three. By the names the game's Dalaran has in this language, the newest of four
	-- copies of a list of them, to be checked in game (GetSubZoneText there).
	-- The Purple Parlor follows the newest copy against three older ones ("Salón Púrpura"): check it
	-- first in game
	["Cantrips & Crows"] = "Taberna de los Cuervos",
	["Capital Gardens"] = "Jardines de la Capital",
	["Cavern of Mists"] = "Caverna Vaharada",
	["Chamber of Atonement"] = "Cámara Expiatoria",
	["Chamber of Battle"] = "Sala de la Batalla",
	["Chapel Gardens"] = "Jardines de la Capilla",
	["City of Dalaran"] = "Ciudad de Dalaran",
	["Cleft of Shadow"] = "Circo de las Sombras",
	["Court of the Highborne"] = "Corte de los Altonato",
	["Crag of the Everliving"] = "Risco de los Eternos",
	["Crusader's Armory"] = "Arsenal de los Cruzados",
	["Crusader's Chapel"] = "Capilla de los Cruzados",
	["Crusaders' Square"] = "Plaza de los Cruzados",
	["Dalaran"] = "Dalaran",
	["Dark Iron Ingress"] = "Acceso Hierro Negro",
	["Deeprun Tram"] = "Tranvía Subterráneo",
	["Defias Hideout"] = "Ladronera de los Defias",
	["Dig One"] = "Excavación Uno",
	["Dragonspire Hall"] = "Sala Dracopico",
	["Dreamer's Rock"] = "Roca del Soñador",
	["Elders' Square"] = "Plaza de los Ancestros",
	["Eldre' Thalas"] = "Eldre'Thalas",
	["Eldreth Row"] = "Hilera Eldreth",
	["Engineering Labs"] = "Laboratorios de Ingeniería",
	["Excavation Center"] = "Centro de excavación",
	["Festival Lane"] = "Calle del Festival",
	["Footman's Armory"] = "Arsenal de los Soldados",
	["Forgewright's Tomb"] = "Tumba del Forjador",
	["Forlorn Cloister"] = "Claustro Inhóspito",
	["Gallery of Treasures"] = "Galería de los Tesoros",
	["Goblin Foundry"] = "Fundición Goblin",
	["Gordok Commons"] = "Ágora de Gordok",
	["Hall of Champions"] = "Sala de los Campeones",
	["Hall of the Keepers"] = "Sala de los Guardianes",
	["Halycon's Lair"] = "Guarida de Halycon",
	["Honor's Tomb"] = "Tumba del Honor",
	["Hordemar City"] = "Ciudad Hordemar",
	["Huntsman's Cloister"] = "Claustro del Cazador",
	["Ironclad Cove"] = "Cala del Acorazado",
	["Ironforge"] = "Forjaz",
	["King's Alley"] = "Callejón del Rey",
	["King's Square"] = "Plaza del Rey",
	["Launch Bay"] = "Aeropuerto",
	-- Three rooms of Gnomeregan's way in (Data/Authored/SubMaps.lua), the Loading Room, the Train
	-- Depot and the Workshop Entrance, have no area id, so they are found by these names alone, to be
	-- checked in game (GetSubZoneText there): LibBabble-SubZone's, the same in its root file (rev 238)
	-- and in the file the lib loads (rev 258)
	["Loading Room"] = "Zona de Carga",
	["Lordaeron Graveyard"] = "Cementerio de Lordaeron",
	["Lordamere Overlook"] = "Mirador de Lordamere",
	["Lost Dig Site"] = "Excavación Perdida",
	["Lost Marsh"] = "Marjal Perdido",
	["Magus Commerce Exchange"] = "Mercado de Magos",
	["Market Row"] = "Fila del Mercado",
	["Market Street"] = "Calle del Mercado",
	["Mast Room"] = "Sala del Mástil",
	["Mok'Doom"] = "Mok'Doom",
	["Moonshrine Ruins"] = "Ruinas del Santuario Lunar",
	["Moonshrine Sanctum"] = "Sagrario Lunar",
	["Mount Hyjal"] = "Monte Hyjal",
	["North Common Hall"] = "Sala común norte",
	["Path of Renewal"] = "Camino de Renovación",
	["Pit of Fangs"] = "Foso de los Colmillos",
	["Presage Plaza"] = "Plaza del Presagio",
	["Prison of Immol'thar"] = "Prisión de Immol'thar",
	["Reliquary of Kings"] = "Relicario de los Reyes",
	["Riverglades"] = "Claros del Río",
	["Runeweaver Square"] = "Plaza Tejerruna",
	["Screaming Gully"] = "Quebrada del Llanto",
	["Sewer"] = "Cloaca",
	["Shen'dralas"] = "Shen'dralas",
	["Site of the Guardian"] = "Sitio del Guardián",
	["Skitterweb Tunnels"] = "Túneles de Arácnidas",
	["Slaughter Square"] = "Plaza Degolladero",
	["South Common Hall"] = "Sala común sur",
	["Stalker's Thicket"] = "Matorral del Acechador",
	["Tazz'Alaor"] = "Tazz'Alaor",
	["Tazz'Alor"] = "Tazz'Alor",
	-- Gnomeregan's Clean Zone, a room the map follows since 0.39.21 (2026-11-12; drafted, to be checked)
	["The Clean Zone"] = "La Zona Limpia",
	["The Clockwerk Run"] = "La Rampa del Engranaje",
	["The Deadmines"] = "Las Minas de la Muerte",
	["The Dormitory"] = "Los Dormitorios",
	["The Drowned Sacellum"] = "El Templete Sumergido",
	["The Eventide"] = "El Manto de la Noche",
	["The Forgotten Pool"] = "Las Charcas del Olvido",
	["The Gauntlet"] = "El Guantelete",
	["The Grand Vestibule"] = "El Gran Vestíbulo",
	["The Grinding Quarry"] = "La Cantera Trituradora",
	["The Hall of Gears"] = "La Sala de Máquinas",
	["The Hall of Lights"] = "La Sala de las Luces",
	["The High Seat"] = "El Trono",
	["The Hoard"] = "El Tesoro Oculto",
	["The Masonary"] = "La Mampostería",
	["The Molten Span"] = "El Puente Fundido",
	["The Pool of Ask'ar"] = "La Alberca de Ask'ar",
	["The Purple Parlor"] = "El Salón Púrpura",
	["The Rookery"] = "El Grajero",
	["The Scarlet Bastion"] = "El Bastión Escarlata",
	["The Sealed Hall"] = "La Sala Sellada",
	["The Shrine of Eldretharr"] = "Santuario de Eldretharr",
	["The Slaughter House"] = "El Degolladero",
	["The Storehouse"] = "Almacén",
	["The Underbelly"] = "Los Bajos Fondos",
	["The Violet Citadel"] = "La Ciudadela Violeta",
	["The Violet Hold"] = "El Bastión Violeta",
	["The Wailing Caverns"] = "Cuevas de los Lamentos",
	["Tinkers' Court"] = "Cámara Manitas",
	-- Gnomeregan's way in, as the Loading Room above
	["Train Depot"] = "Depósito de Trenes",
	["Training Grounds"] = "Patio de Armas",
	["Warpwood Quarter"] = "Barrio Alabeo",
	-- Gnomeregan's way in, as the Loading Room above
	["Workshop Entrance"] = "Entrada del Taller",
	-- The Temple of Atal'Hakkar's way in (Data/Authored/SubMaps.lua, 2026-10-30): its nine rooms have no area id,
	-- so they are found by these names alone. Pool of Tears, Sorrowmurk and the temple's own name have ids (74,
	-- 1778, 1477): a scan (/aegis areas, Dev/bake_area_ids.py) can replace those three. LibBabble-SubZone's names,
	-- the same in its root file (rev 238) and in the file the lib loads (rev 258). Hall of Faces and Den of
	-- the Unholy are Forever's names. To be checked in game (GetSubZoneText there)
	["Chamber of Blood"] = "Cámara Sangrienta",
	["Den of the Caller"] = "Cubil del Clamor",
	["Den of the Unholy"] = "Cubil de los Impuros",
	["Hall of Bones"] = "Sala de los Huesos",
	["Hall of Faces"] = "Sala de los Rostros",
	["Hall of Masks"] = "Sala de las Máscaras",
	["Hall of Ritual"] = "Sala de los Rituales",
	["Pool of Tears"] = "Charca de Lágrimas",
	["Sorrowmurk"] = "Tinieblas de las Penas",
	["The Broken Hall"] = "Cámara Partida",
	["The Butchery"] = "Carnicería",
	["The Temple of Atal'Hakkar"] = "El Templo de Atal'Hakkar",
}

-- The journal's style: its question at each character's first login, each choice and what it does, and the
-- choice and boxes in the options (2026-11-03; drafted, to be checked).
L.STYLE_TITLE = "Elige tu guía"
L.STYLE_SUBTITLE = "¿Cuánto debe añadir la guía a tu juego? Puedes cambiarlo cuando quieras en las opciones de la guía."
L.STYLE_CLASSIC = "Clásico"
L.STYLE_CLASSIC_DESC = "Una guía más al estilo original, con menos extras. Los jefes, el botín, las misiones y los mapas de los calabozos siguen ahí."
L.STYLE_MODERN = "Moderno"
L.STYLE_MODERN_DESC = "Todo lo que tiene la guía, tal como es ahora: el Buscador de equipo, los mapas de los accesos y sus marcas en el mapa del mundo."
L.STYLE_CUSTOM = "Personalizado"
L.STYLE_CUSTOM_DESC = "Tú eliges. Elige esto para abrir los ajustes de la guía, donde cada función tiene su propia casilla."
L.STYLE_STARTING = "Ajustes iniciales:"
L.STYLE_LINE_ON = "%s: activado"
L.STYLE_LINE_OFF = "%s: desactivado"
L.STYLE_LINE_CHOOSE = "%s: a tu elección"
L.STYLE_GEAR = "Buscador de equipo y pesos de atributos"
L.STYLE_GEAR_TIP = "La pestaña del Buscador de equipo, su pestaña en el panel del personaje, las líneas de pesos en las descripciones de los objetos, las flechas verdes de mejora y los pesos de la guía en Pawn. Todos usan los mismos pesos, así que van juntos. Solo para este personaje."
L.STYLE_WAY_IN = "Mapas de acceso y cuevas"
L.STYLE_WAY_IN_TIP = "Los mapas del camino a un calabozo (cuevas, edificios, niveles de una montaña) sobre el mapa del mundo, y sus entradas de cueva y de edificio. Los mapas propios de los calabozos se quedan. Solo para este personaje."
L.STYLE_MARKERS = "Marcas en el mapa del mundo"
L.STYLE_MARKERS_TIP = "Las marcas de la guía en el mapa del mundo: entradas de calabozos y bandas, maestros de vuelo, barcos, zepelines, tranvías y portales, sus marcas de misión, niveles de zona y zonas sin explorar. Solo para este personaje."
L.STYLE_CLICK = "Haz clic para elegir"
L.STYLE_NOW = "Tu estilo ahora"
L.STYLE_CLOSE_NOTE = "Al cerrar se mantiene %s."
L.STYLE_CHOSEN = "Estilo de la guía: %s. Puedes cambiarlo cuando quieras en las opciones de la guía (/aegis options)."
L.STYLE_OPTIONS_AFTER_COMBAT = "Las opciones de la guía se abrirán cuando termine el combate."
L.STYLE_OPTION = "Estilo de la guía"
L.STYLE_OPTION_TIP = "Clásico, Moderno o Personalizado, solo para este personaje. Marcar o desmarcar una función de abajo lo vuelve Personalizado."
-- The Reset button under the style's dropdown, and its question (2026-11-03; drafted, to be checked).
L.STYLE_RESET = "Restablecer la Guía de calabozos"
L.STYLE_RESET_BUTTON = "Restablecer"
L.STYLE_CHOOSE_BUTTON = "Elegir"
L.STYLE_RESET_TIP = "Devuelve las opciones de la guía a como estaban al instalarla, para todos tus personajes, y vuelve a hacer la pregunta de estilo a este personaje. Las grabaciones, los pesos de atributos y el estilo de tus demás personajes se conservan."
L.STYLE_RESET_CONFIRM = "¿Devolver las opciones de la guía a como estaban al instalarla, para todos tus personajes, y volver a hacer la pregunta de estilo a este personaje? Tus grabaciones, tus pesos de atributos y el estilo de tus demás personajes se conservan."
L.STYLE_GEAR_IS_OFF = "El Buscador de equipo está desactivado. Actívalo en las opciones de la guía (/aegis options)."
-- The Record tab's box in the options, and /aegis record while it is off (2026-11-03; drafted, to be checked).
L.OPTIONS_RECORD_TAB = "Mostrar la pestaña Grabar"
L.OPTIONS_RECORD_TAB_TIP = "La pestaña que graba tus calabozos para nosotros. Desmarcada: la pestaña se oculta y la guía no graba nada (Capturar vendedor en la pestaña Reputación sigue funcionando). Lo que ya grabaste se conserva."
L.RECORD_TAB_IS_OFF = "La pestaña Grabar está desactivada. Actívala en las opciones de la guía (/aegis options)."
L.LEGEND_STYLE_OFF = "Desactivado en las opciones de la guía."

-- The run block (UI/RunTracker.lua, Core/Run.lua), 2026-11-11; drafted, to be checked. The client's own words where it has them.
L.RUN_BOSS_DEFEATED = "%s derrotado"
L.RUN_COMPLETE = DUNGEON_COMPLETED or "¡Calabozo completado!"
L.RUN_EXPERIENCE = EXPERIENCE_COLON or "Experiencia:"
L.RUN_MONEY = MONEY_COLON or "Dinero:"
L.RUN_ITEMS = "Objetos:"
L.RUN_PER_HOUR = "%s/h"
L.RUN_GREED = "Ganados por " .. (GREED or "Codicia") .. ": %d"
L.RUN_DEFEATED = BOSS_DEAD or "Derrotado"
L.RUN_NOT_DEFEATED = "Aún no derrotado"
L.RUN_PARTS = "%s, luego %s"
L.RUN_COIN = "Monedas despojadas"
L.RUN_ITEM_VALUE = "Objetos a precio de vendedor"
L.RUN_PENDING = "Esperando un precio: %d"
L.RUN_DRAG = "Arrastra el encabezado para moverlo."
L.RUN_SUMMARY = "%s: %d/%d jefes en %s"
L.RUN_SUMMARY_XP = "%s PX"
L.RUN_SUMMARY_ITEMS = "Objetos: %d"
L.RUN_NEW = "Empieza un nuevo recorrido."
L.RUN_NOT_INSIDE = "Entra en un calabozo para empezar un nuevo recorrido."
L.RUN_HIDDEN = "El bloque del recorrido está oculto durante este recorrido. Escribe /ij run para mostrarlo de nuevo."
L.RUN_NONE = "Aún no hay ningún recorrido de calabozo."
L.RUN_IS_OFF = "El seguimiento de recorridos está desactivado. Actívalo en las opciones de la guía (/aegis options)."
L.RUN_FREE_ON = "Arrastra el bloque del recorrido por su encabezado para moverlo. /ij run lock lo devuelve junto al seguimiento de misiones."
L.RUN_FREE_OFF = "El bloque del recorrido vuelve a estar junto al seguimiento de misiones."
L.RUN_USAGE = "/ij run muestra u oculta el bloque del recorrido (fuera de un calabozo, tu último recorrido). /ij run new empieza un nuevo recorrido. /ij run unlock te deja moverlo; /ij run lock y /ij run reset lo devuelven junto al seguimiento de misiones. /ij run debug muestra lo que ha contado."
L.OPTIONS_RUN = "Seguimiento de recorridos de calabozo"
L.OPTIONS_RUN_TIP = "Dentro de un calabozo, un bloque junto al seguimiento de misiones muestra cuánto dura el recorrido, sus jefes y lo que has ganado. Desactivado, no se cuenta nada."
L.OPTIONS_RUN_NUMBERS = "Mostrar experiencia y dinero"
L.OPTIONS_RUN_NUMBERS_TIP = "La experiencia y el dinero (monedas despojadas más el precio de venta de tus objetos), cada uno con su ritmo por hora, y cuántos objetos conseguiste."
L.OPTIONS_RUN_FREE = "Colocar libremente"
L.OPTIONS_RUN_FREE_TIP = "Arrastra el bloque por su encabezado a cualquier lugar. Desactivado, se queda junto al seguimiento de misiones y se mueve con él."
-- The run block's dark mode: its gold art darkened, else the tracker's tint (UI/RunTracker.lua Paint), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_DARK_MODE = "Modo oscuro"
L.OPTIONS_RUN_DARK_MODE_TIP = "Oscurece el dorado del encabezado y el marco del bloque del recorrido. Desactivado, el bloque toma el aspecto de los encabezados de tu seguimiento de misiones: es oscuro cuando tu interfaz los oscurece."
L.OPTIONS_RUN_SUMMARY = "Resumen en el chat"
L.OPTIONS_RUN_SUMMARY_TIP = "Una línea en el chat un minuto después de que el reloj de un recorrido se detenga (antes si sales). Un recorrido que dejas sin terminar recibe su línea cuando acaba: al reiniciarse el calabozo o tras media hora fuera."
-- The run block inside the quest tracker: an experiment, off by default (UI/RunTrackerInside.lua), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_INSIDE = "Dentro del seguimiento de misiones (experimental)"
L.OPTIONS_RUN_INSIDE_TIP = "El bloque entra en el seguimiento de misiones, justo bajo «" .. (TRACKER_ALL_OBJECTIVES or "Todos los objetivos") .. "», y las secciones del seguimiento (" .. (TRACKER_HEADER_QUESTS or "Misiones") .. " y las demás) bajan debajo de él. Un seguimiento que moviste en el modo de edición solo es tan alto como su altura allí: si es demasiado baja para el bloque, el bloque se queda a su lado, como desactivado, y el botón de abajo puede hacer más alto el seguimiento. Es una prueba: si el juego informa de una acción bloqueada, se desactiva solo. Si ya se usó, solo queda desactivado por completo después de un /reload."
L.RUN_INSIDE_BLOCKED = "El juego bloqueó una acción de la guía (%s), así que «Dentro del seguimiento de misiones» está desactivado y el bloque del recorrido vuelve junto al seguimiento. Informa de esta línea, por favor. Escribe /reload para sacarlo del seguimiento por completo."
L.RUN_INSIDE_RELOAD = "«Dentro del seguimiento de misiones» está desactivado y el bloque del recorrido vuelve junto al seguimiento. Escribe /reload para sacarlo del seguimiento por completo."
-- The tracker too short for the block inside: the Height it needs, and the options' Make taller button (UI/RunTrackerInside.lua), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_TALLER = "Hacer más alto el seguimiento de misiones"
L.OPTIONS_RUN_TALLER_BUTTON = "Más alto"
L.OPTIONS_RUN_TALLER_TIP = "Para «Dentro del seguimiento de misiones»: pone la altura del seguimiento de misiones en tu diseño del modo de edición en lo que necesita el bloque del recorrido, y guarda el diseño. Solo para un seguimiento que moviste en el modo de edición. Úsalo mientras se ve el bloque, fuera de combate y con el modo de edición cerrado. Se ve después de un /reload."
L.RUN_INSIDE_SHORT = "El bloque del recorrido se queda junto al seguimiento de misiones: el seguimiento es demasiado bajo para contenerlo. Para hacerlo más alto: %s, selecciona «%s», %s %d o más. O usa «%s» en las opciones de la guía (/aegis options)."
L.RUN_INSIDE_SHORT_TIP = "El seguimiento de misiones es demasiado bajo para el bloque. Para hacerlo más alto: %s, selecciona «%s», %s %d o más."
L.RUN_TALLER_COMBAT = ERR_NOT_IN_COMBAT or "No puedes hacer eso en combate."
L.RUN_TALLER_EDIT_MODE = "Cierra primero el %s."
L.RUN_TALLER_DEFAULT = "El seguimiento de misiones está en su sitio predeterminado, donde llega hasta abajo de la pantalla: no tiene altura que ajustar."
L.RUN_TALLER_UNKNOWN = "Usa esto mientras se ve el bloque del recorrido (en un calabozo, o tu último recorrido con /ij run): entonces se mide su altura."
L.RUN_TALLER_ENOUGH = "El seguimiento de misiones ya es lo bastante alto para el bloque del recorrido."
L.RUN_TALLER_FAILED = "No se pudo cambiar tu diseño del modo de edición desde aquí. Ajústalo tú: %s, selecciona «%s», %s %d o más."
L.RUN_TALLER_DONE = "%s – %s: ahora %d en tu diseño «%s» del modo de edición. Escribe /reload ahora para verlo."
L.RUN_TALLER_MOST = "Es lo máximo que permite el modo de edición, así que puede que el bloque aún no quepa."

-- Matched against the client's own text: the client's language's only, previewed or not.
if client then client.EQUIP_PATTERNS, client.AREA_NAMES = L.EQUIP_PATTERNS, L.AREA_NAMES end
L.EQUIP_PATTERNS, L.AREA_NAMES = nil, nil
