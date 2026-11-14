local _, ns = ...

--[[
	The journal's interface in Russian, by Staree4ok, for a client set to Russian. It is laid over
	the English table (Locales/enUS.lua), so every file that already holds ns.L sees these
	strings, and anything not translated here stays English. Every other client skips it.
]]
-- The journal's words where it speaks this language; the tables matched against the client's own
-- text where the client does, previewed or not (ns.LocaleTargets, Locales/enUS.lua).
local L, client = ns.LocaleTargets("ruRU")
if not L then return end

L.JOURNAL_TITLE = "Путеводитель по подземельям"
L.HOME = HOME or "Главная"
L.TAB_DUNGEONS = DUNGEONS or "Подземелья"
L.TAB_RAIDS = RAIDS or "Рейды"
L.TAB_REPUTATION = REPUTATION or "Репутация"

L.BINDING_TOGGLE = "Открыть путеводитель по подземельям"
L.KEY_CLAIMED = "Shift+J теперь открывает путеводитель по подземельям."
L.KEY_TAKEN = "Shift+J уже назначена на %s. Выберите клавишу в Назначение клавиш > Модификации > Открыть путеводитель по подземельям."
L.POSITION_RESET = "Положение окна сброшено."
L.DOCK_ON = "Теперь окно открывается в левом верхнем углу, рядом с окнами игры. Перетащите его, чтобы переместить до закрытия."
L.DOCK_OFF = "Окно снова свободно: оно открывается там, куда вы перетащили его в последний раз."
L.DOCK_AFTER_COMBAT = "Это вступит в силу после окончания боя."
-- Its /aegis style sentence (2026-11-03; drafted, to be checked).
L.SLASH_HELP = "/aegis (или /ij) открывает путеводитель. /aegis record включает или выключает запись. /aegis reset возвращает окно на место по умолчанию. /aegis dock закрепляет окно слева вверху, рядом с окнами игры, или снова освобождает его. /aegis perf измеряет память и скорость путеводителя. /aegis where и /aegis taxi показывают, где вы стоите и точки полетов на карте. /aegis travel сохраняет корабль, дирижабль, подземку или портал для карты мира. /aegis items находит предметы из списка, о которых сервер ничего не знает. /aegis gear открывает поиск снаряжения, /aegis weights — настройку приоритетов характеристик; /aegis gearscan сохраняет данные экипировки для проверки расчета улучшений. /aegis style снова показывает выбор вида путеводителя. /aegis run показывает или скрывает блок забега (вне подземелья — ваш последний забег); /aegis run new начинает новый забег."
L.LANG_USAGE = "/aegis lang de, fr, ru, cn, tw, es, mx, pt или ko показывает путеводитель на немецком, французском, русском, китайском (упрощённом или традиционном), испанском (Испания или Латинская Америка), бразильском португальском или корейском после следующего /reload, чтобы проверить перевод; /aegis lang off возвращает язык вашего клиента. Сейчас: %s."
L.LANG_SET = "После следующего /reload путеводитель перейдёт на язык %s — только его собственные тексты: названия из самой игры останутся на языке вашего клиента. Введите /reload сейчас; /aegis lang off вернёт всё как было."
L.LANG_OFF = "После следующего /reload путеводитель снова будет на языке вашего клиента. Введите /reload сейчас."
L.LANG_FONTS = "Для китайского нужны шрифты китайского клиента: в вашем часть символов может не отображаться."
L.LANG_FONTS_KO = "Для корейского нужны шрифты корейского клиента: в вашем часть символов может не отображаться."
L.LANG_ON = "Предпросмотр путеводителя на языке %s. /aegis lang off завершает его."
L.LANG_UNAVAILABLE = "Этот клиент загрузил путеводитель раньше его сохранённых настроек, поэтому предпросмотр языка не удалось запустить."
L.AREAS_START = "Поиск в клиенте идентификаторов для %d названий зон журнала..."
L.AREAS_DONE = "Найдены идентификаторы %d из %d названий зон. Введите /reload, чтобы сохранить их."
L.AREAS_MISSING = "Не найдено: %s."
L.AREAS_SCANNING = "Поиск названий зон еще не завершен."
L.AREAS_ENGLISH = "Запустите /aegis areas в английском клиенте: команда ищет английские названия."
L.OPTIONS_TITLE = "Aegis Instance Journal"
L.OPTIONS_BOSS_LEVELS = "Показывать уровни боссов в списке боссов"
L.OPTIONS_BOSS_LEVELS_TIP = "Значок с уровнем на портрете каждого босса, окрашенный по тому, насколько босс для вас сложен: серый, зелёный, жёлтый, оранжевый или красный."
L.OPTIONS_ARROWS = "Отмечать улучшения зелёной стрелкой"
L.OPTIONS_MINIMAP = "Показывать кнопку у миникарты"
L.OPTIONS_PAWN_WEIGHTS = "Использовать приоритет характеристик из Pawn в поиске снаряжения"
L.OPTIONS_PAWN_WEIGHTS_TIP = "Если установлен Pawn, показываются его подсказки к предметам и стрелки улучшений. Флажок установлен: поиск снаряжения оценивает предметы по вашей шкале Pawn для вашей специализации. Флажок снят: Pawn вместо этого показывает приоритет журнала для вашей специализации в виде шкалы журнала, а его собственные шкалы скрыты на этом персонаже, пока вы не установите флажок."
L.PAWN_ASK = "Также установлен Pawn. Будут показываться его подсказки к предметам и стрелки улучшений.\n\nОткуда Pawn и поиску снаряжения брать приоритет характеристик?\n\nИз журнала: Pawn показывает его для вашей специализации и скрывает свои шкалы на этом персонаже.\nИз Pawn: поиск снаряжения использует ваши шкалы Pawn."
L.PAWN_USE_PAWN = "Из Pawn"
L.PAWN_USE_JOURNAL = "Из журнала"
L.PAWN_SCALE = "Журнал: %s"
L.PAWN_RELOAD = "Стрелки улучшений Pawn в сумках Baganator изменятся только после перезагрузки: Baganator хранит ответы Pawn, пока не сменится ваше снаряжение.\n\nПерезагрузить сейчас?"
L.PAWN_RELOAD_NOW = "Перезагрузить"
L.PAWN_RELOAD_LATER = "Позже"
L.WEIGHTS_SOURCE_PAWN_LIVE = "Шкала Pawn «%s». Измените её в Pawn или выберите в настройках приоритет журнала."
L.OPTIONS_MINIMAP_TIP = "Кнопка путеводителя на краю миникарты: ЛКМ открывает путеводитель, ПКМ — эти настройки, перетаскивание перемещает кнопку."
L.OPTIONS_DOCK = "Закрепить окно в левом верхнем углу"
L.OPTIONS_DOCK_TIP = "Включено: путеводитель открывается в левом верхнем углу экрана, там, где игра открывает свои окна, и сдвигается, когда там открывается одно из них, как они делают друг для друга; если места для обоих нет, игра закрывает более старое. Перетащите его, чтобы переместить куда угодно: при следующем открытии он снова закрепится. Выключено: он открывается там, куда вы перетащили его в последний раз."
L.MINIMAP_LEFT_CLICK = "ЛКМ — открыть или закрыть путеводитель."
L.MINIMAP_RIGHT_CLICK = "ПКМ — настройки."
L.MINIMAP_DRAG = "Перетащите, чтобы передвинуть кнопку вдоль миникарты."
L.OPTIONS_ARROWS_TIP = "Зелёная стрелка на предметах, которые по расчёту поиска снаряжения являются улучшениями для вашей специализации: в сумках, в окне добычи и при розыгрыше добычи."
L.WEIGHTS_SHOW_GAINS = "Показывать приоритет характеристик в подсказках"
L.WEIGHTS_SHOW_GAINS_TIP = "Под каждым предметом — строка для каждой вашей специализации: сколько стоит предмет по её приоритету и, если это улучшение, зелёная стрелка с тем, что он добавит к вашему снаряжению. Для всех ваших персонажей с включённым поиском снаряжения. Если установлен Pawn, этот флажок вместо этого показывает или скрывает шкалу журнала в Pawn, а вместе с ней стрелки улучшений Pawn по приоритету журнала: Pawn отмечает улучшения только для тех шкал, которые показывает."
L.OPTIONS_SOURCES = "Показывать в подсказках, где добывается предмет"
L.OPTIONS_SOURCES_TIP = "Под каждым предметом, который добывается в подземельях и рейдах путеводителя, — строка с боссом и подземельем: в сумках, на персонаже, в ссылках в чате, у торговцев и везде, где игра показывает предмет. Для всех ваших персонажей."
L.ITEMS_START = "Запрос к серверу о %d предметах из списка путеводителя. Ответ придет примерно через %d сек.; можете продолжать игру."
L.ITEMS_SCANNING = "Ожидание ответа от сервера; данные появятся через секунду."
L.ITEMS_DONE = "Из %d предметов сервер ничего не знает о %d: скорее всего, их еще нет на сервере Forever. Путеводитель скрывает их, пока сервер или записанное прохождение не подтвердят их наличие. Полный список будет сохранен в файл при следующем /reload или выходе из игры."
L.ITEMS_LINE = "  Предмет %d: %s"
L.ITEMS_MORE = "  ...и еще %d."
L.PERF_HEADER = "Производительность (память в КБ, время в миллисекундах; чем меньше, тем лучше):"
L.PERF_MEMORY = "  %s: %.0f КБ"
L.PERF_TIME = "  %s: %.2f мс"
L.PERF_BUILD = "Первое открытие (создание окна)"
L.PERF_BOOK = "Первое открытое подземелье (создание книги)"
L.PERF_OPEN = "Открыть и закрыть путеводитель"
L.PERF_DUNGEON = "Открыть страницу подземелья"
L.PERF_TAB = "Переключиться на вкладку %s"
L.PERF_FACTION = "Открыть страницу фракции"
L.PERF_LOOT = "Перерисовать страницу добычи"
L.PERF_COMBAT = "Измерение отложено, пока вы не выйдете из боя."
L.WHERE = "Карта %s (%s)  x %.4f  y %.4f  зона \"%s\"  миникарта \"%s\"  высота %s"
-- /aegis where: what the journal remembers the player as below a city, and its last changes (2026-11-06; drafted, to be checked).
L.WHERE_BELOW = "%s: запомнено %s"
L.WHERE_BELOW_BELOW = "внизу"
L.WHERE_BELOW_TOP = "наверху"
L.WHERE_BELOW_NOTHING = "ничего"
L.WHERE_BELOW_CHANGE = "  %s  %s  карта %s  зона \"%s\"  x %s  y %s:  %s -> %s"
L.TAXI = "Карта %s  сама показывает точки полетов: %s  точек на ней: %d (%d открыто)  %s"
L.TAXI_ATLASES = "Иконки перемещения: %s"
L.YES = YES or "да"
L.NO = NO or "нет"

L.EMPTY_DUNGEONS = "Для подземелий пока нет записей в путеводителе."
L.EMPTY_RAIDS = "Для рейдов пока нет записей в путеводителе."
L.EMPTY_REPUTATION = "Награды за репутацию пока неизвестны."
L.EMPTY_BRACKET = "Ничего нет для этого диапазона уровней."

L.TAB_RECORD = "Запись"
L.TAB_GEAR = "Поиск снаряжения"

-- The Gear Finder (Core/GearFinder.lua, UI/GearPanel.lua, UI/CharacterTab.lua).
L.GEAR_TITLE = "Поиск снаряжения"
L.GEAR_PREVIEW = "Просмотр"
L.GEAR_NO_UPGRADE = "Улучшений не найдено"
L.GEAR_LOOKING = "Поиск в подземельях: %d."
L.GEAR_LOOKING_ONE = "Поиск в 1 подземелье."
L.GEAR_LOADING = "Загружается предметов: %d."
L.GEAR_LOADING_ONE = "Загружается 1 предмет."
L.GEAR_SCORING = "Расчёт для"
L.GEAR_AUTO = "Автоматически: %s"
L.GEAR_WHY_TALENTS = "%s (таланты)"
L.GEAR_WHY_LEVELLING = "%s (прокачка)"
L.GEAR_SUGGESTED = "Рекомендуем"
L.GEAR_UPGRADES_HERE = "Улучшений здесь: %d"
L.GEAR_UPGRADE_HERE = "1 улучшение здесь"
L.GEAR_MORE_SLOTS = "и ещё %d"
L.GEAR_DUNGEON_OF = "%d из %d"
L.GEAR_NONE = "В подземельях вашего уровня улучшений нет."
L.GEAR_TIP_CLICK = "ЛКМ — открыть добычу в журнале; Shift+ЛКМ — вставить ссылку."
L.GEAR_TIP_CELL_CLICK = "ЛКМ — лучшие улучшения; ПКМ — открыть добычу."
L.GEAR_TIP_PICK_CLICK = "ЛКМ — показать здесь; ПКМ — открыть добычу."
L.GEAR_TIP_PICKED = "Ваш выбор для этого слота."
L.GEAR_PICK_TOP = "Лучшие %d из %d улучшений"
L.GEAR_PICK_ALL = "Улучшений: %d"
L.GEAR_PICK_ONE = "Единственное улучшение"
L.GEAR_PICK_BIGGEST = "Наибольшее"
L.GEAR_PICK_YOURS = "Ваш выбор"
L.GEAR_PICK_KEPT = "Выбор сохраняется для этого персонажа."
L.GEAR_PICK_CLEAR = "Сбросить мой выбор"
L.GEAR_TIP_NONE = "Для этого слота нет улучшений в подземельях вашего уровня."
L.GEAR_CHAR_BUTTON = "Поиск снаряжения"
L.GEAR_CHAR_BUTTON_TIP = "Ваш приоритет характеристик и лучшие улучшения в подземельях журнала."
L.GEAR_SCAN_DONE = "Сканирование сохранено: %d надетых предметов и %d предметов из подземелий. Выйдите из игры или введите /reload, чтобы записать файл."
L.GEAR_SCAN_ERRORS = "Не удалось прочитать предметов: %d. Подробности сохранены вместе со сканом."
L.GEAR_SCAN_LOADING = "Часть добычи ещё загружается: подождите несколько секунд и снова введите /aegis gearscan."
L.GEAR_SLOT_FINGER1 = "Кольцо 1"
L.GEAR_SLOT_FINGER2 = "Кольцо 2"
L.GEAR_SLOT_TRINKET1 = "Аксессуар 1"
L.GEAR_SLOT_TRINKET2 = "Аксессуар 2"

-- Stat weights (Core/ItemScore.lua, UI/WeightsEditor.lua).
L.WEIGHTS_TITLE = "Приоритет характеристик"
L.WEIGHTS_EDIT = "Изменить приоритет характеристик..."
L.WEIGHTS_SOURCE_DEFAULT = "Приоритет из журнала"
L.WEIGHTS_SOURCE_LEVELLING = "Приоритет из журнала (при прокачке)"
L.WEIGHTS_SOURCE_CUSTOM = "Ваш собственный приоритет"
L.WEIGHTS_SOURCE_PAWN = "Ваш приоритет из Pawn: %s"
L.WEIGHTS_TIP = "Насколько важна 1 единица каждой характеристики для этой специализации. Нажмите на значение, чтобы изменить его; собственные значения отображаются зелёным и сохраняются для этого персонажа."
L.WEIGHTS_RESET = "Сброс"
L.WEIGHTS_RESET_TIP = "Вернуть приоритет журнала для этой специализации."
L.WEIGHTS_PAWN = "Pawn..."
-- The Pawn... button's tooltip names WoWSims' Pawn export (2026-11-03; drafted, to be checked).
L.WEIGHTS_PAWN_TIP = "Импортировать приоритет из Pawn или вставить экспорт для Pawn из WoWSims."
L.WEIGHTS_PAWN_HELP = "В Pawn откройте вкладку «Весы», выберите шкалу, нажмите «Экспорт», скопируйте текст и вставьте его сюда."
L.WEIGHTS_IMPORT = "Импорт"
L.WEIGHTS_CANCEL = "Отмена"
L.WEIGHTS_BACK = "Назад"
L.WEIGHTS_OPEN_FINDER = "Открыть поиск снаряжения"
L.WEIGHTS_IMPORTED = "Импортировано значений: %d из %s."
L.WEIGHTS_UNUSED = "Не использовано: %s."
L.WEIGHTS_NOT_PAWN = "Это не шкала Pawn. В Pawn выберите «Экспорт» и скопируйте весь текст."
L.WEIGHTS_OTHER_CLASS = "Эта шкала для класса %s, а не для класса этого персонажа."
L.WEIGHTS_FOR = "Для"
-- WoWSims' weights, the Gear Finder's defaults for the specs the sim has, and its Pawn export (2026-11-03; drafted, to be checked).
L.WEIGHTS_SOURCE_SIMS = "Приоритет из WoWSims: %s"
L.WEIGHTS_PAWN_SIMS = "Экспорт для Pawn из WoWSims (wowsims.com/forever) тоже подойдёт, с Pawn или без него, и оценивает так же, как приоритет WoWSims в журнале. В нём нет весов для исцеления, урона отдельных школ, проникающей способности заклинаний, силы атаки в облике зверя, защиты, блока и сопротивлений."
L.WEIGHTS_NO_STATS = "В этой шкале Pawn нет характеристик, которые журнал может использовать."
L.GEAR_WHY_CUSTOM = "%s (ваш приоритет)"
L.WEIGHT_GROUPS = {
	PRIMARY = "Основные характеристики", WEAPONS = "Оружие", SPELLS = "Заклинания", DEFENSE = "Защита",
	RESISTANCE = "Сопротивления",
}
L.STAT_NAMES = {
	STRENGTH = "Сила", AGILITY = "Ловкость", STAMINA = "Выносливость", INTELLECT = "Интеллект", SPIRIT = "Дух",
	DPS = "Урон оружием в сек.", ["RANGED DPS"] = "Урон дальнего оружия в сек.", ["ATTACK POWER"] = "Сила атаки",
	["RANGED ATTACK POWER"] = "Сила атаки дальнего боя", ["FERAL ATTACK POWER"] = "Сила атаки в облике зверя", HIT = "Меткость",
	CRIT = "Критический удар", ["RANGED CRIT"] = "Критический удар дальнего боя", HASTE = "Скорость атаки", ["RANGED HASTE"] = "Скорость дальнего боя",
	["SPELL POWER"] = "Урон и исцеление", ["SPELL DAMAGE"] = "Урон от заклинаний", HEALING = "Исцеление", ["SPELL HIT"] = "Меткость заклинаний",
	["SPELL CRIT"] = "Критический удар заклинаний", ["HOLY CRIT"] = "Критический удар светлой магии", ["HOLY DAMAGE"] = "Урон от светлой магии",
	["FIRE DAMAGE"] = "Урон от огня", ["FROST DAMAGE"] = "Урон от магии льда", ["NATURE DAMAGE"] = "Урон от сил природы",
	["SHADOW DAMAGE"] = "Урон от тёмной магии", ["ARCANE DAMAGE"] = "Урон от тайной магии", ["SPELL PENETRATION"] = "Проникающая способность заклинаний",
	MANA = "Мана", ["MANA PER 5"] = "Мана за 5 сек.", ["CASTING REGEN"] = "Восстановление при чтении",
	ARMOR = "Броня", HEALTH = "Здоровье", ["HEALTH PER 5"] = "Здоровье за 5 сек.", DEFENSE = "Защита", DODGE = "Уклонение",
	PARRY = "Парирование", BLOCK = "Блок", ["BLOCK VALUE"] = "Показатель блока",
	["HOLY RESISTANCE"] = "Сопротивление светлой магии", ["FIRE RESISTANCE"] = "Сопротивление огню",
	["NATURE RESISTANCE"] = "Сопротивление силам природы", ["FROST RESISTANCE"] = "Сопротивление магии льда",
	["SHADOW RESISTANCE"] = "Сопротивление тёмной магии", ["ARCANE RESISTANCE"] = "Сопротивление тайной магии",
}
L.GEAR_SPEC_NAMES = {
	Arms = "Оружие", Fury = "Неистовство", Protection = "Защита", Holy = "Свет", Retribution = "Возмездие",
	BeastMastery = "Повелитель зверей", Marksmanship = "Стрельба", Survival = "Выживание",
	Assassination = "Убийство", Combat = "Бой", Subtlety = "Скрытность", Discipline = "Послушание", Shadow = "Тьма",
	Elemental = "Стихии", Enhancement = "Совершенствование", EnhancementTank = "Совершенствование (танк)",
	Restoration = "Исцеление", Arcane = "Тайная магия", Fire = "Огонь", Frost = "Лед", Affliction = "Колдовство",
	Demonology = "Демонология", Destruction = "Разрушение", Balance = "Баланс", FeralBear = "Сила зверя (медведь)",
	FeralCat = "Сила зверя (кошка)",
}
L.GEAR_UNITS = {
	["attack power"] = "сила атаки", ["ranged attack power"] = "сила атаки дальнего боя",
	["spell damage"] = "урон от заклинаний", healing = "исцеление", Stamina = "выносливость",
}
L.RECORD_START = "Начать запись"
L.RECORD_STOP = "Остановить запись"
L.RECORD_CLEAR = "Очистить"
L.RECORD_CLEAR_CONFIRM = "Удалить все записанные данные? Это действие нельзя отменить."
L.RECORD_STATUS_ON = "Запись идет с %s"
L.RECORD_STATUS_OFF = "Запись выключена"
L.RECORD_COMBATLOG = "Записывать журнал боя в подземельях"
L.RECORD_COMBATLOG_TIP = "Способности боссов берутся из игрового журнала боя. Путеводитель включает его внутри подземелий и выключает на выходе; журнал, запущенный вами вручную, затронут не будет. Чтобы отправить его, добавьте файл журнала к вашей записи на странице Читателя логов (кнопка «Копировать» покажет ссылку)."
L.RECORD_RECENT = "Недавние"
L.RECORD_NOTHING_YET = "Пока ничего не записано. Зайдите в подземелье с включенной записью, а затем убивайте боссов, собирайте добычу и выполняйте задания как обычно."
L.RECORD_STARTED = "Запись запущена. Команда /aegis record остановит ее."
L.RECORD_STOPPED = "Запись остановлена."
L.RECORD_LOG_STARTED = "Запись запущена."
L.RECORD_LOG_STOPPED = "Запись остановлена."
L.RECORD_LOG_CLEARED = "Записи очищены."
L.RECORD_LOG_ENTERED = "Вы вошли в %s."
L.RECORD_LOG_LEFT = "Вы вышли из подземелья."
L.RECORD_LOG_AREA = "Новая зона: %s."
L.RECORD_LOG_PULL = "Агро: %s."
L.RECORD_LOG_KILL = "Убит: %s."
L.RECORD_LOG_WIPE = "Вайп на боссе: %s."
L.RECORD_LOG_LOOT = "Добыча: %d нов. предмет(ов)."
L.RECORD_LOG_QUEST_OFFERED = "Предложено задание: %s."
L.RECORD_LOG_QUEST_DONE = "Сдано задание: %s."
L.RECORD_LOG_ENTRANCE = "Вход в %s записан."
L.RECORD_LOG_NO_ENTRANCE = "Вход в %s не записан: %s."
L.RECORD_NO_MAP = "игра не выдала карту при начале загрузочного экрана"
L.RECORD_NO_POSITION = "игра не выдала координаты при начале загрузочного экрана"
L.RECORD_IN_DUNGEON_MAP = "загрузочный экран начался на карте подземелья"
L.RECORD_LOG_COMBATLOG_ON = "Журнал боя включен: Logs\\%s."
L.RECORD_LOG_COMBATLOG_OFF = "Журнал боя выключен."

L.LEVEL_RANGE = "Уровень %d-%d"
L.LEVEL_BRACKET = "Уровень %d-%d"
L.LEVEL_ALL = "Все уровни"
L.TRASH_DROPS = "Добыча с существ"
L.UNTESTED = "Еще не протестировано"
L.UNTESTED_NOTE = "Еще не протестировано: информация взята из анонсов Blizzard и может быть неполной. Пройдите это подземелье с включенной вкладкой «Запись», чтобы заполнить данные о боссах, добыче и входе."
L.COMING_SOON = "Скоро откроется"
L.COMING_SOON_TEXT = "Еще не открыто в WoW: Forever. Боссы, добыча и карта появятся, когда игроки запишут свои прохождения. Записали такое? Опубликуйте его в нашем Discord, и ваше имя попадет в список авторов путеводителя."
L.COMING_SOON_PARTLY = "Еще не открыто в WoW: Forever: информация взята из анонса Blizzard. Записали прохождение? Опубликуйте его в нашем Discord, и ваше имя попадет в список авторов путеводителя."
L.DISCORD_COPY_HINT = "Нажмите, затем Ctrl+C"
L.FOREVER_MARK = "Новое в WoW: Forever"
L.RECORD_LOG_VENDOR = "%s: сохранено товаров: %d, из них новых для путеводителя: %d."
L.RECORD_CAUGHT = "Записано: %d, новых с момента последнего копирования: %d"
L.RECORD_COPY = "Копировать"
L.RECORD_AUTO = "Записывать автоматически в подземельях"
L.RECORD_AUTO_TIP = "Запись запускается автоматически при входе в подземелье или рейд и останавливается при выходе. Запись, которую вы запустили вручную, никогда не остановится автоматически."
L.RECORD_RECORDER = "Запись вел"
L.RECORD_SEND = "Отправьте это нам"
L.RECORD_HELP_TEXT = "Нажмите «Копировать», затем вставьте текст в наш Discord:"
L.RECORD_CREDIT = "Указать мое авторство как:"
L.RECORD_CREDIT_TIP = "Имя, под которым ваши записи будут отмечены в списке авторов путеводителя. Если оставить пустым, будет использовано имя вашего персонажа."
L.RECORD_CONTRIBUTORS = "Авторы"
L.RECORD_CONTRIBUTORS_NONE = "Пока никого: станьте первым."
L.RECORD_CONTRIBUTORS_FOOT = "Отправьте свою запись: ваше имя появится здесь."
L.RECORD_COPY_TITLE = "Ваша запись в виде текста"
L.RECORD_COPY_HINT = "Все выделено: нажмите Ctrl+C, затем вставьте в наш Discord."
L.RECORD_COPY_HINT_LOG = "Нажмите Ctrl+C, затем вставьте в Читатель логов вместе с вашим журналом боя (%s, находится в папке Logs в директории игры). Опубликуйте полученный результат в нашем Discord."
L.RECORD_MORE_LOGS = "%s и %d более старых"
L.RECORD_BACK = "Назад"
L.RECORD_CAUGHT_TITLE = "Что вы записали"
L.RECORD_ITEM = "Предмет %s"
L.RECORD_ONE_VISIT = "1 посещение"
L.RECORD_VISITS = "Посещений: %d"
L.RECORD_ENTRANCE_YES = "вход записан"
L.RECORD_ENTRANCE_NO = "вход еще не записан"
L.RECORD_AREAS = "Зоны: %d"
L.RECORD_KILLED = "Убито: %s"
L.RECORD_KILLED_TIMES = "%s (%d)"
L.RECORD_DROPS = "Добыча: %s новых, %s уже есть в путеводителе"
L.RECORD_OFF = "С босса %s"
L.RECORD_OFF_TRASH = "С треша"
L.RECORD_OFF_GROUP = "Добыто вашей группой"
L.RECORD_OFF_OBJECTS = "Из сундуков и растений"
L.RECORD_QUESTS = "Задания"
L.RECORD_QUEST_DONE = "сдано"
L.RECORD_NEW = "новое"
L.RECORD_QUARTERMASTERS = "Интенданты"
L.RECORD_WARES = "%s: товаров: %d, новых: %s"
L.RECORD_TRAVEL = "Точки перемещения: %d"
L.FOREVER_LINE = "Новое в WoW: Forever."
L.LOCATION_LINE = "Расположение: %s"

-- The dungeon's round icon at the top of its left page: its tooltip, under the dungeon's name (2026-11-04; drafted, to be checked).
L.INSTANCE_ICON_OVERVIEW = "Нажмите, чтобы открыть обзор."

L.TAB_OVERVIEW = OVERVIEW or "Обзор"
L.TAB_LOOT = LOOT_NOUN or "Добыча"
L.TAB_ABILITIES = ABILITIES or "Способности"
L.TAB_MODEL = MODEL or "Модель"
L.TAB_QUESTS = QUESTS_LABEL or "Задания"
L.ALL_CLASSES = ALL_CLASSES or "Все классы"
L.ALL_ARMOR = "Вся броня"
L.ALL_TYPES = "Все типы"
L.LOOT_KIND = {
	EQUIPMENT = "Экипировка", RECIPE = "Рецепты", CONSUMABLE = "Расходники", MOUNT = "Транспорт", PET = "Питомцы",
	TOY = "Игрушки", BAG = "Сумки", TRADE = "Хозяйственные товары", QUEST = "Предметы заданий", OTHER = "Другое",
}
L.LOOT_KIND_ALL = { EQUIPMENT = "Вся экипировка", RECIPE = "Все рецепты" }
L.LOOT_KIND_ONE = { MOUNT = "Транспорт", PET = "Питомец", TOY = "Игрушка" }
L.LOOT_RECIPE = "Рецепт"
L.LOOT_FAVORITES = "Избранное"
L.LOOT_FAVORITES_ONLY = "Только избранное"
L.LOOT_FAVORITE = "Добавить в избранное"
L.LOOT_UNFAVORITE = "Удалить из избранного"
L.LOOT_PINNED = "Закрепленные"
L.LOOT_ALL = "Добыча"
L.LOOT_TRASH = "Трэш подземелья"
L.DROPS_FROM_BOSS = "Добыча: %s (%s)"
L.DROPS_FROM_TRASH = "Добыча: трэш (%s)"
L.DROPS_FROM_BOSSES = "Добыча с боссов: %d (%s)"
L.DROPS_IN = "Добыча в подземельях: %s"
L.DROPS_ALSO_IN = "Также добыча в подземельях: %s"
L.LEGEND_CLICK_HIDE = "Нажмите, чтобы скрыть их на карте."
L.LEGEND_CLICK_SHOW = "Скрыто. Нажмите, чтобы снова показать их на карте."
-- The legend's Quest entry, the journal's own switch for its ! marks: what it does (2026-11-06; drafted, to be checked).
L.LEGEND_QUEST_TIP = "Метки «!» путеводителя на картах: задания, которые можно взять, и серые, ещё не открытые."
L.LEGEND_GAME_FILTER = "Фильтр самой игры, как в меню фильтров карты: у выполняемых заданий и готовых к сдаче он общий."
L.LEGEND_GAME_FILTER_MENU = "Показываются и скрываются в меню фильтров карты: %s."
L.PREPARE_TITLE = "Перед походом"
L.PREPARE_PROGRESS = "Выполнено заданий: %d из %d."
-- The same for a key with one quest (2026-10-30; drafted, to be checked).
L.PREPARE_PROGRESS_ONE = "Задание еще не выполнено."
L.PREPARE_HAVE = "Уже есть."
L.PREPARE_QUEST_HINT = "Нажмите, чтобы открыть на вкладке «Задания»."
L.QUESTS_DUNGEON = "Задания подземелья"
-- The same on a raid's Quests tab (2026-10-30; drafted, to be checked).
L.QUESTS_RAID = "Задания рейда"
-- The Quests tab's dropdown of the quests for the player's class alone (2026-11-03; drafted, to be checked).
L.QUESTS_CLASS = "Классовые задания"
L.TRASH = "Трэш"
L.TRASH_DESCRIPTION = "Что стоит знать о добыче с остальных существ подземелья: редкое и эпическое снаряжение, рецепты и предметы для заданий."
L.LOOT_BOSS_LINE = BOSS_INFO_STRING or "Босс: %s"
L.LOOT_FILTER_BAR = "Фильтр: %s"
L.LOOT_RETRIEVING = RETRIEVING_ITEM_INFO or "Получение сведений о предмете"
L.LOOT_NO_DATA = "Предмет %d"
L.LOOT_NO_DATA_TOOLTIP = "Сервер не прислал данные об этом предмете. Возможно, его еще нет в игре."
L.LOOT_UNIDENTIFIED_TOOLTIP = "Еще не идентифицировано: источник указывает имя, но не ID предмета. Соберите этот лут во время записи, чтобы добавить его."
L.LOOT_TOOLTIP_PIN = "Нажмите правой кнопкой мыши, чтобы закрепить предмет вверху списка."
L.LOOT_TOOLTIP_UNPIN = "Нажмите правой кнопкой мыши, чтобы открепить."
L.LOOT_NONE = "Добыча для этого источника пока неизвестна."
L.LOOT_NO_MATCH = "Ничего не найдено по заданным фильтрам. Очистите их, нажав X выше."
L.ABILITY_LOADING = RETRIEVING_DATA or "Получение данных..."
L.ABILITIES_NONE = "Способности для этого босса пока неизвестны. Запишите прохождение во вкладке «Запись», чтобы сохранить их."
L.STATS_HIT = "Попадания %s"
L.STATS_TICK = "тики %s"
L.STATS_FIRST = "первое применение на %d сек."
L.STATS_EVERY = "затем каждые %s сек."
L.QUEST_NONE = "Для вашей фракции нет известных заданий в этом подземелье."
L.QUEST_STATUS_READY = "Готово: можно сдавать"
L.QUEST_STATUS_NEEDS = "Требуется: %s"
L.QUEST_STATUS_LEVEL = "Требуется уровень %d"
L.QUEST_DESCRIPTION = QUEST_DESCRIPTION or "Описание"
L.QUEST_START_ITEM = "Начинается с:"
-- Worded without a number to agree with, since a row of same-named quests shows it with 2 and 3 too
-- (2026-11-04; drafted, to be checked).
L.QUEST_PARTS = "%s (частей: %d)"
-- A row for the quests of one chain that share a name: which of them its page shows (2026-11-04; drafted, to be checked).
L.QUEST_PART_OF = "Часть %d из %d"
-- One of them as a row of its own, in a chain: which part it is (2026-11-06; drafted, to be checked).
L.QUEST_PART_NAME = "%s (Часть %d)"
-- A step any one of several quests will do (2026-10-30; drafted, to be checked).
L.QUEST_STATUS_NEEDS_VERSION = "Требуется один из вариантов (%d): %s"
L.QUEST_STATUS_NEEDS_ONE_OF = "Требуется одно из: %s"
-- A quest given only while another is in the log (2026-11-03; drafted, to be checked).
L.QUEST_STATUS_NEEDS_IN_LOG = "Требуется: %s в журнале заданий"
L.QUEST_OR = " или "
L.QUEST_LIST_COMMA = ", "
L.QUEST_ONE_OF_VERSIONS = "Вариантов этого задания: %d. Подойдёт любой."
L.QUEST_ONE_OF_ANY = "Подойдёт любое из этих заданий."
L.QUEST_SHOW_START = "Показать начало"
L.QUEST_SHOW_END = "Показать конец"
L.QUEST_PLACE_UNKNOWN = "Место пока неизвестно. Возьмите или сдайте это задание с включенной вкладкой «Запись», чтобы добавить его."
L.QUEST_OFFERED_BY = "Задание выдаёт: %s"
L.QUEST_HAND_IN_TO = "Сдать: %s"
L.QUESTMAP_DUNGEON_QUEST = "Задание подземелья: %s"
L.QUESTMAP_RAID_QUEST = "Задание рейда: %s"
L.QUESTMAP_LEFT_CLICK = "ЛКМ — открыть в путеводителе"
L.QUESTMAP_WAYPOINT_SET = "Точка маршрута установлена: %s."
L.QUESTMAP_WAYPOINT_SET_IN = "Точка маршрута установлена: %s (%s)."
L.WAYPOINT_OFFER = "Нажмите %s, чтобы установить точку маршрута."
L.QUESTMAP_ONE_OF = "Не всегда в одном месте: одна из %d точек."
-- What is looted, used or explored for a quest inside a dungeon, on its mark's tooltip, after the game's dash: the
-- item to take, the same for a name with no "the" in English, the thing to use, a place to explore (2026-11-11;
-- translation drafted, to be checked).
L.QUESTMAP_OBJECTIVE_TAKE = "Взять: %s"
L.QUESTMAP_OBJECTIVE_TAKE_NAMED = "Взять: %s"
L.QUESTMAP_TITLE_QUOTED = "«%s»"
L.QUESTMAP_OBJECTIVE_USE = "Использовать: %s"
L.QUESTMAP_OBJECTIVE_EXPLORE = "Исследовать это место"
-- A Matrix Punchograph's step, what goes in, then what comes out, in short words ("Yellow > Blue"), and the punch
-- cards' colors, as the cards' own names in the language have them (2026-11-12, the owner's "Blue > Red"; drafted, to
-- be checked); where what goes in drops (2026-11-12; drafted, to be checked).
L.QUESTMAP_OBJECTIVE_STEP = "%s > %s"
L.QUESTMAP_CARD_WHITE = "Белая"
L.QUESTMAP_CARD_YELLOW = "Жёлтая"
L.QUESTMAP_CARD_BLUE = "Синяя"
L.QUESTMAP_CARD_RED = "Красная"
L.QUESTMAP_CARD_PRISMATIC = "Радужная"
L.QUESTMAP_NOTE_INPUT_DROPS = "%s выпадает из противников в этих туннелях."
-- A machine used again once its quest is done: it takes another of what it cleans (2026-11-12; drafted, to be checked).
L.QUESTMAP_REPEAT_AGAIN = "Повторяемое: вставьте ещё один предмет «%s»."
-- What a boss is to a quest, on his tooltip under his quest badge: one to kill, one that drops what the quest needs,
-- the same for a name with no "the" in English, one whose drop starts the quest; who gives or takes it there,
-- himself or by name; a quest's mob more than a boss (2026-11-11; translation drafted, to be checked).
L.QUEST_BADGE_KILL = "Убить для этого задания"
L.QUEST_BADGE_DROPS = "Добыча: %s"
L.QUEST_BADGE_DROPS_NAMED = "Добыча: %s"
L.QUEST_BADGE_STARTS = "Добыча: %s (начинает задание)"
L.QUEST_BADGE_STARTS_NAMED = "Добыча: %s (начинает задание)"
L.QUEST_BADGE_GIVES = "Дает это задание"
L.QUEST_BADGE_GIVES_WHO = "Здесь это задание дает: %s"
L.QUEST_BADGE_TAKES = "Сдать здесь"
L.QUEST_BADGE_TAKES_WHO = "Сдать здесь: %s"
L.QUEST_TARGET = "Цель задания"
L.MAP_ONE_OF = "Не всегда в одном месте: одна из %d точек."
L.QUEST_REWARDS = REWARDS or "Награды"
L.QUEST_YOU_RECEIVE = YOU_RECEIVE or "Вы получите:"
L.QUEST_XP = "%s опыта"
-- XP that is only the original game's number, not yet confirmed on Forever: a note after it, and
-- its tooltip (2026-10-30; drafted, to be checked).
L.QUEST_XP_ORIGINAL = "(исходная игра)"
L.QUEST_XP_ORIGINAL_TIP = "Столько давало задание в исходной игре. На Forever может быть больше. На Forever это еще не проверено. Сдайте задание с включенной вкладкой «Запись», чтобы добавить, сколько дает Forever."
L.QUEST_REPUTATION = "%d репутации с фракцией %s"
L.QUEST_CHOOSE = REWARD_CHOICES or "Вы сможете выбрать одну из этих наград:"
L.QUEST_ALSO = REWARD_ITEMS or "Вы также получите:"
L.REP_REWARDS = "Наград: %d"
L.REP_REWARD_ONE = "1 награда"
L.REP_ALL_REWARDS = "Награды"
-- The group for wares that need no standing (2026-11-12; drafted, to be checked)
L.REP_ANY_STANDING = "Любое отношение"
L.REP_UNKNOWN = "Не встречались"
L.REP_CARD_CLICK = "Нажмите, чтобы посмотреть награды."
L.REP_YOUR_STANDING = "Ваша репутация: %s"
L.REP_NOT_MET = "Вы еще не встречались с этой фракцией."
L.REP_PROGRESS = "%s / %s"
L.REP_QUARTERMASTER = "Интендант: %s"
L.REP_CAPTURE = "Записать торговца"
L.REP_CAPTURE_TIP = "Подойдите к интенданту репутации, откройте его магазин и нажмите эту кнопку. Сохраняется все, что он продает: цена каждого товара, прочие затраты и нужный уровень репутации. Товары сразу попадают в награды фракции и уйдут вместе с записью, когда вы нажмете «Копировать» на вкладке «Запись»."
L.REP_CAPTURE_READY = "Магазин открыт: нажмите «Записать торговца»."
L.REP_CAPTURE_HINT = "Откройте магазин интенданта, чтобы записать его товары."
L.REP_CAPTURED = "%s: товаров: %d (для %s), новых: %d."
L.REP_CAPTURED_NONE = "%s: сохранено товаров: %d; ни один не требует репутации."
L.REP_CAPTURED_UNKNOWN = "%s: %d товаров требуют репутации с фракцией без имени; сохранены, пока товар ее не назовет."
L.REP_NOT_CAPTURED = "Еще не записано"
L.REP_NOT_CAPTURED_TIP = "Интенданта этой фракции еще никто не записал."
L.REP_NOT_CAPTURED_TEXT = "Интенданта этой фракции еще никто не записал. Найдите его, откройте магазин и нажмите «Записать торговца» на вкладке «Репутация», затем опубликуйте запись в нашем Discord. Ваше имя попадет в список авторов путеводителя."
L.REP_COMING_SOON_TEXT = "Новое в WoW: Forever, еще не записано. Когда фракция появится в игре, найдите интенданта, откройте магазин и нажмите «Записать торговца» на вкладке «Репутация», затем опубликуйте запись в нашем Discord."
L.REP_LISTED_TIP = "Ее награды взяты из данных предметов игры и еще не подтверждены у интенданта."
L.REP_LISTED_TEXT = "Эти награды взяты из данных предметов игры, а не от интенданта: цены не показаны, и часть из них может вообще не продаваться. Найдите интенданта этой фракции, откройте его магазин и нажмите «Записать торговца» на вкладке «Репутация», затем опубликуйте запись в нашем Discord. Ваше имя попадет в список авторов путеводителя."
L.MAP_SHOW = ENCOUNTER_JOURNAL_SHOW_MAP or "Показать карту"
L.MAP_SHOW_UNEXPLORED = "Показывать неисследованные области"
L.OPTIONS_UNEXPLORED_TIP = "Затеняет на карте мира ещё не исследованные части каждой зоны."
L.MAP_FILTER_QUESTS = "Доступные задания"
L.MAP_FILTER_DUNGEONS = "Входы в подземелья"
L.MAP_FILTER_RAIDS = "Входы в рейды"
L.MAP_FILTER_FLIGHT = "Точки полета"
L.MAP_FILTER_CAVES = "Входы в пещеры"
L.MAP_FILTER_TRANSPORT = "Корабли, дирижабли, подземка и порталы"
L.MAP_PIN_OPEN = "Нажмите, чтобы открыть в путеводителе."
L.MAP_DEFEATED = DUNGEON_ENCOUNTER_DEFEATED or "Побежден"
L.MAP_LEVEL = "Уровень %d"
L.MAP_FLOOR = "Уровень %d"
L.MAP_GO_TO = "К %s"
L.MAP_YOU_ARE_HERE = "Вы здесь"
L.ENTRANCE_DUNGEON = LFG_TYPE_DUNGEON or "Подземелье"
L.ENTRANCE_RAID = LFG_TYPE_RAID or "Рейд"
L.ENTRANCE_DUNGEONS = DUNGEONS or "Подземелья"
L.ENTRANCE_RAIDS = RAIDS or "Рейды"
L.ENTRANCE_LEFT_CLICK = "ЛКМ — открыть путеводитель по подземельям"
L.ENTRANCE_CHOOSE_LEFT_CLICK = "ЛКМ — выбрать, что открыть в путеводителе"
L.ENTRANCE_RIGHT_CLICK = "ПКМ — установить точку маршрута"
L.ENTRANCE_WAYPOINT_SET = "Точка маршрута установлена у входа в %s."
L.ENTRANCE_VIA = "Портал находится ниже, в зоне «%s»: спуститесь у входа в пещеру."
L.ENTRANCE_WAYPOINT_VIA = "Точка маршрута установлена у спуска в %s, к %s."
L.CAVE_LABEL = "Вход в пещеру"
L.BUILDING_LABEL = "Вход"
L.ENTRANCE_VIA_BUILDING = "Портал находится внутри: %s. Войдите через вход."
L.CAVE_LEADS_TO = "Путь к %s"
L.CAVE_LEFT_CLICK = "ЛКМ — посмотреть карту: %s"
L.CAVE_WAYPOINT_SET = "Точка маршрута установлена у спуска в %s."
L.FLIGHT_POINT = MAP_LEGEND_FLIGHTPOINT or "Точка полета"
L.CLICK_FOR_WAYPOINT = "Нажмите, чтобы установить точку маршрута"
L.FLIGHT_WAYPOINT_SET = "Точка маршрута установлена у распорядителя полетов: %s."
L.TRAVEL_KINDS = { boat = "Корабль", zeppelin = "Дирижабль", airship = "Воздушный корабль", tram = "Подземка", portal = "Портал" }
L.TRAVEL_FACTIONS = { Alliance = FACTION_ALLIANCE or "Альянс", Horde = FACTION_HORDE or "Орда" }
L.TRAVEL_ROUTE = "%s до %s"
L.TRAVEL_AND = "%s и %s"
L.TRAVEL_ROUTE_NOTE = "%s: %s"
L.TRAVEL_HELP = "Встаньте у причала, башни дирижаблей, подземки или портала и введите /aegis travel boat (или zeppelin, airship, tram, portal) и куда он ведет, например /aegis travel boat Auberdine. В конце можно указать alliance, horde или neutral — кому он служит, и примечание в скобках, кто может им пользоваться, например /aegis travel portal Dalaran (только Небожители). /aegis travel list показывает сохраненное; /aegis travel undo отменяет последнюю точку."
L.TRAVEL_NO_POSITION = "Игра не дает координат здесь, поэтому ничего не сохранено."
L.TRAVEL_SAVED = "Сохранено: %s у %s. /aegis travel undo отменяет это."
L.TRAVEL_UNDONE = "Отменено: %s у %s."
L.TRAVEL_NOTHING = "Нечего отменять."
L.TRAVEL_LIST_EMPTY = "Точек перемещения пока нет. Введите /aegis travel, чтобы узнать, как их сохранить."
L.TRAVEL_LIST_LINE = "%d. %s у %s (карта %d, %.4f, %.4f)"
L.TRAVEL_WAYPOINT_SET = "Точка маршрута установлена: %s."
L.LEGEND_TRANSPORT = "Транспорт"
L.LEGEND_TRANSPORT_TOOLTIP = "Корабли, дирижабли, подземка и порталы. Синий — для Альянса, красный — для Орды, золотой — для всех."
L.LEGEND_CAVE_TOOLTIP = "Путь в пещеру, где находится вход в подземелье. Нажмите на карте, чтобы увидеть, что внутри."
L.LEGEND_BUILDING_TOOLTIP = "Путь в здание, в залы горы или на уровень ниже зоны, где находится вход в подземелье. Нажмите на карте, чтобы увидеть, что внутри."
L.SEARCH_SHOW_ALL = SEARCH_RESULTS_SHOW_COUNT or "Показать все результаты: %d"
L.SEARCH_RESULTS = ENCOUNTER_JOURNAL_SEARCH_RESULTS or "Результаты поиска «%s» (%d)"
L.SEARCH_TYPE_BOSS = "Босс"
L.SEARCH_TYPE_ABILITY = "Способность"
L.SEARCH_TYPE_ITEM = "Предмет"
L.SEARCH_TYPE_QUEST = "Задание"
L.SEARCH_TYPE_FACTION = FACTION or "Фракция"
L.MAP_PIN_CLEAR = "Нажмите, чтобы убрать эту метку."
L.MAP_PIN_COMBAT = "Карту нельзя открыть в бою."
L.MAP_PIN_IN_ZONE = "%s: отмечено на карте локации %s."
L.MAP_LEVEL_LINK_CLICK = "ЛКМ — посмотреть карту этого уровня"
L.DOOR_SPIRE_ONE_INSTANCE = "Нижняя и Верхняя части пика Черной горы — одно подземелье с одним входом."
L.DOOR_SPIRE_LOWER = "Нижняя часть пика Черной горы: до 10 игроков, но задания можно выполнить только в группе из 5 игроков или меньше."
L.DOOR_SPIRE_UPPER = "Верхняя часть пика Черной горы: дальше внутри, за запечатанной дверью, для которой нужна печать вознесения. До 10 игроков."

L.RARE_SUFFIX = " (редкий)"
L.AND_MORE = "и еще %d"
L.BULLET_AREA = "Встречается в зоне: %s."
L.BULLET_RARE = "Редкий противник: появляется не в каждом заходе."
L.BULLET_SUMMONED = "Скрытый босс, которого вы призываете сами: как именно — сказано в заметке выше."
-- A quest's mob, on the map only, on his page (2026-11-11; translation drafted, to be checked).
L.BULLET_QUEST_TARGET = "Цель задания, а не один из боссов подземелья."
L.BULLET_LEVEL = "Противник %d-го уровня."
L.BULLET_ABILITIES = "Применяет: %s."
L.BULLET_LOOT = "Добыча: %d предметов, в том числе %s."
L.BULLET_ADDS = "Рядом: %s."
L.ADD_DESCRIPTION = "Сражается рядом с %s."
L.BULLET_NOTHING_YET = "Об этом противнике пока ничего не известно."

L.INSTANCE_NAMES = {
	RagefireChasm = "Огненная Пропасть",
	WailingCaverns = "Пещеры Стенаний",
	TheDeadmines = "Мертвые копи",
	ShadowfangKeep = "Крепость Темного Клыка",
	TheStockade = "Тюрьма",
	BlackfathomDeeps = "Непроглядная Пучина",
	Gnomeregan = "Гномреган",
	RazorfenKraul = "Лабиринты Иглошкурых",
	ScarletMonasteryGraveyard = "Монастырь Алого ордена: Кладбище",
	ScarletMonasteryLibrary = "Монастырь Алого ордена: Библиотека",
	ScarletMonasteryArmory = "Монастырь Алого ордена: Оружейная",
	ScarletMonasteryCathedral = "Монастырь Алого ордена: Собор",
	RazorfenDowns = "Курганы Иглошкурых",
	Uldaman = "Ульдаман",
	ZulFarrak = "Зул'Фаррак",
	Maraudon = "Мародон",
	TempleOfAtalHakkar = "Храм Атал'Хаккара",
	BlackrockDepths = "Глубины Черной горы",
	LowerBlackrockSpire = "Нижняя часть пика Черной горы",
	UpperBlackrockSpire = "Верхняя часть пика Черной горы",
	DireMaulEast = "Забытый Город (восток)",
	DireMaulNorth = "Забытый Город (север)",
	DireMaulWest = "Забытый Город (запад)",
	Scholomance = "Некроситет",
	StratholmeMainGate = "Стратхольм (главные врата)",
	StratholmeServiceGate = "Стратхольм (черный ход)",
	CityOfDalaran = "Даларан",
	HallOfThanes = "Зал Танов",
	RuinsOfLordaeron = "Руины Лордерона",
	ExcavationSiteWetlands = "Раскопки: Болотина",
	BarrowDeeps = "Глубины кургана",
	HyjalSummit = "Вершина Хиджала",
	OnyxiasLair = "Логово Ониксии",
	TheDrownedCity = "Затопленный город",
	KroldokStronghold = "Крепость Крол'док",
	AlcazPrison = "Тюрьма Альказа",
	BlackmawHold = "Цитадель Чернопасти",
	ShapersTerrace = "Терраса ваятеля",
}

L.INSTANCE_LOCATIONS = {
	RagefireChasm = "Расселина Теней, Оргриммар",
	WailingCaverns = "Северные Степи",
	TheDeadmines = "Западный Край",
	ShadowfangKeep = "Серебряный бор",
	TheStockade = "Штормград",
	BlackfathomDeeps = "Ясеневый лес",
	Gnomeregan = "Дун Морог",
	RazorfenKraul = "Степи",
	ScarletMonasteryGraveyard = "Тирисфальские леса",
	ScarletMonasteryLibrary = "Тирисфальские леса",
	ScarletMonasteryArmory = "Тирисфальские леса",
	ScarletMonasteryCathedral = "Тирисфальские леса",
	RazorfenDowns = "Степи",
	Uldaman = "Бесплодные земли",
	ZulFarrak = "Танарис",
	Maraudon = "Пустоши",
	TempleOfAtalHakkar = "Болото Печали",
	BlackrockDepths = "Черная гора",
	LowerBlackrockSpire = "Черная гора",
	UpperBlackrockSpire = "Черная гора",
	DireMaulEast = "Фералас",
	DireMaulNorth = "Фералас",
	DireMaulWest = "Фералас",
	Scholomance = "Западные Чумные земли",
	StratholmeMainGate = "Восточные Чумные земли",
	StratholmeServiceGate = "Восточные Чумные земли",
	CityOfDalaran = "Альтеракские горы",
	HallOfThanes = "Под Стальгорном, Дун Морог",
	RuinsOfLordaeron = "Разрушенная столица Лордерона",
	ExcavationSiteWetlands = "Болотина",
	HyjalSummit = "Гора Хиджал",
	OnyxiasLair = "Пылевые топи",
	TheDrownedCity = "Побережье Тернистой долины",
	KroldokStronghold = "Речные низины",
	AlcazPrison = "Остров Алькац, Пылевые топи",
	BlackmawHold = "Северная Азшара",
	ShapersTerrace = "Кратер Ун'Горо",
}

L.INSTANCE_DESCRIPTIONS = {
	HallOfThanes = "Под Стальгорном кто-то вскрыл гробницу дворфийских королей.",
	RuinsOfLordaeron = "Плеть все еще держит руины старой столицы, где некромант копит силы.",
	ExcavationSiteWetlands = "Титанический раскоп над Раскопками Вельгара, вырванный из времени: создания титанов больше никому не подчиняются. Внутри: Затерянное болото, Чащоба Сталкера, Место Стража и Затерянный раскоп.",
	BarrowDeeps = "Рейд, новый в WoW: Forever. Боссы и добыча пока неизвестны.",
	HyjalSummit = "Рейд, новый в WoW: Forever, на горе Хиджал. Боссы и добыча пока неизвестны.",
	OnyxiasLair = "Праматерь черных драконов ждет в логове под Драконьими топями. Версия Forever пока неизвестна.",
	TheDrownedCity = "Тролльский город, давно ушедший на дно, снова поднялся из океана. Его улицы заняли наги, пираты и твари из глубин.",
	KroldokStronghold = "Огрская крепость, битком набитая воинами: Молот Сумерек нашел здесь союзников.",
	AlcazPrison = "В тюрьме на острове Алькац все еще сидят узники Братства Справедливости, но наги захватили остров и сделали тюрьму своей.",
	BlackmawHold = "За вратами фурболгов на дальнем севере Азшары лежит одно из крупнейших логовищ, и из глубин его что-то оскверняет.",
	ShapersTerrace = "Титанический комплекс, скрытый в кратере Ун'Горо: среди динозавров он хранит тайны творцов.",
}

L.SUBMAP_NAMES = {
	OldIronforge = "Старый Стальгорн",
	DeadminesApproach = "Убежище Братства Справедливости",
	WailingCavernsApproach = "Пещеры Стенаний",
	WailingCavernsApproachBarrens = "Пещеры Стенаний",
	BlackfathomApproach = "Непроглядная Пучина",
	BlackfathomApproachAshenvale = "Непроглядная Пучина",
	GnomereganApproach = "Гномреган",
	RazorfenDownsApproach = "Курганы Иглошкурых",
	RazorfenDownsApproachKalimdor = "Курганы Иглошкурых",
	RazorfenDownsSkull = "Курганы Иглошкурых",
	RazorfenDownsSkullKalimdor = "Курганы Иглошкурых",
	TempleOfAtalHakkarHalls = "Храм Атал'Хаккара",
	TempleOfAtalHakkarHallsSwamp = "Храм Атал'Хаккара",
	TempleOfAtalHakkarPool = "Храм Атал'Хаккара",
	TempleOfAtalHakkarPoolSwamp = "Храм Атал'Хаккара",
	UldamanApproach = "Ульдаман",
	MaraudonOrange = "Мародон",
	MaraudonPurple = "Мародон",
	MaraudonOrangeCave = "Мародон (оранжевый)",
	MaraudonPurpleCave = "Мародон (фиолетовый)",
	BlackrockMountain = "Черная гора",
	BlackrockMountainGorge = "Черная гора",
	BlackrockMountainMiddle = "Черная гора",
	BlackrockDepthsApproach = "Черная гора",
	BlackrockDepthsApproachSteppes = "Черная гора",
	DireMaulRuins = "Забытый Город",
	ScarletMonasteryHall = "Монастырь Алого ордена",
	ScarletMonasteryHallContinent = "Монастырь Алого ордена",
	DeeprunTram = "Подземный поезд",
	-- The micro dungeons (Data/Authored/MicroDungeons.lua), by the game's names for their areas and retail's for
	-- Frostmane Hovel (drafted, to be checked)
	FargodeepMine = "Рудник Подземных Глубин",
	FargodeepMineLower = "Рудник Подземных Глубин",
	JasperlodeMine = "Яшмовая шахта",
	EchoRidgeMine = "Рудник Горного Эха",
	ColdridgePass = "Туннель Холодной долины",
	GrizzledDen = "Серая берлога",
	GolBolarQuarry = "Карьер Гол'Болар",
	FrostmaneHovel = "Пещера Мерзлогривов",
	BurningBladeCoven = "Грот Пылающего Клинка",
	TiragardeKeep = "Крепость Тирагард",
	TiragardeKeepGreatHall = "Крепость Тирагард",
	SkullRock = "Скала Черепа",
	CleftOfShadow = "Расселина Теней",
	ShadowthreadCave = "Паучье логово",
	FelRock = "Пещера Бесов",
	BanethilBarrowDen = "Обитель Бен'этиль",
	BanethilBarrowDenLower = "Обитель Бен'этиль",
	NightWebsHollow = "Паучья низина",
}

-- Levels of an area below a zone (its menu on the world map), by their English names.
L.SUBMAP_LEVELS = {
	["Blackrock Spire"] = "Пик Черной горы",
	["Blackrock Mountain"] = "Черная гора",
	["Blackrock Depths"] = "Глубины Черной горы",
	-- Fargodeep Mine's levels: the mine's name, and retail's Lower Mines (drafted)
	["Fargodeep Mine"] = "Рудник Подземных Глубин",
	["Lower Mines"] = "Нижние шахты",
	-- Tiragarde Keep's levels, top to bottom: retail's Great Hall (drafted), and the keep's name
	["Great Hall"] = "Большой зал",
	["Tiragarde Keep"] = "Крепость Тирагард",
	-- Ban'ethil Barrow Den's levels, top to bottom: retail's Upper Den and Lower Den (drafted)
	["Upper Den"] = "Верхнее логово",
	["Lower Den"] = "Нижнее логово",
	-- Razorfen Downs' levels (Data/Authored/SubMaps.lua): the dungeon's name, and Agamaggan's Skull
	-- (drafted, to be checked)
	["Razorfen Downs"] = "Курганы Иглошкурых",
	["Agamaggan's Skull"] = "Череп Агамаггана",
	-- The Temple of Atal'Hakkar's map: its lowest level, the ring round the pool (Data/Instances/
	-- TempleOfAtalHakkar.lua's floor names; drafted, to be checked)
	["Lower Level"] = "Нижний уровень",
	-- The Temple of Atal'Hakkar's way in (Data/Authored/SubMaps.lua), top to bottom: the Pool of Tears by the
	-- client's name for it (LibBabble-SubZone's, as in AREA_NAMES), and the dungeon's name
	["Pool of Tears"] = "Озеро Слез",
	["The Temple of Atal'Hakkar"] = "Храм Атал'Хаккара",
	-- Shaper's Terrace's map (Data/Authored/Upcoming.lua's floor names): the dungeon's name, and its cave, the
	-- Prismatic Talus (drafted, to be checked: the client's tables have the cave only as its building's name, in English)
	["Shaper's Terrace"] = "Терраса ваятеля",
	["Prismatic Talus"] = "Призматическая осыпь",
}

L.FACTION_NAMES = {
	[529] = "Серебряный Рассвет",
	[2586] = "Торговая палата Азерота",
	[21] = "Пиратская Бухта",
	[910] = "Род Ноздорму",
	[609] = "Круг Кенария",
	[2798] = "Налетчики Черного Копья",
	[2587] = "Снабжение и логистика Дуротара",
	[2787] = "Служители Земли",
	[577] = "Круговзор",
	[369] = "Прибамбасск",
	[2765] = "Стражи Хиджала",
	[749] = "Гидраксианские Повелители Вод",
	[2740] = "Кирин-Тор",
	[2758] = "Друиды Ночного Когтя",
	[2827] = "Пороховой Фитиль",
	[470] = "Кабестан",
	[890] = "Среброкрылые Часовые",
	[510] = "Осквернители",
	[509] = "Лига Аратора",
	[2819] = "Дозорные",
	[2799] = "Экспедиционный корпус Терамора",
	[59] = "Братство Тория",
	[576] = "Древобрюхи",
	[889] = "Всадники Песни Войны",
	[270] = "Племя Зандалар",
}

-- The Russian client's classic "Equip:" wordings (drafted; check against items in game).
L.EQUIP_PATTERNS = {
	-- Bonuses against undead only, and effects on being struck or on a hit: worth nothing.
	{ "нежит", false },
	{ "критическ.-свет.-на {n}%%", "HOLY CRIT" },
	{ "критическ.-Свет.-на {n}%%", "HOLY CRIT" },
	{ "критическ.-свят.-на {n}%%", "HOLY CRIT" },
	{ "критическ.-заклинани.-на {n}%%", "SPELL CRIT" },
	{ "заклинани.-критическ.-на {n}%%", "SPELL CRIT" },
	{ "критическ.-дальн.-на {n}%%", "RANGED CRIT" },
	{ "критическ.-стрелков.-на {n}%%", "RANGED CRIT" },
	{ "критическ.-метательн.-на {n}%%", "RANGED CRIT" },
	{ "критическ.-на {n}%%", "CRIT" },
	{ "попадани.-заклинани.-на {n}%%", "SPELL HIT" },
	{ "меткост.-заклинани.-на {n}%%", "SPELL HIT" },
	{ "вероятност.-попадани.-на {n}%%", "HIT" },
	{ "шанс.-попадани.-на {n}%%", "HIT" },
	{ "меткост.-на {n}%%", "HIT" },
	{ "урон.-исцел.-{n}", { "SPELL POWER", "HEALING" } },
	{ "урон.-целит.-{n}", { "SPELL POWER", "HEALING" } },
	{ "урон.-лечени.-{n}", { "SPELL POWER", "HEALING" } },
	{ "исцел.-урон.-{n}", { "SPELL POWER", "HEALING" } },
	{ "лечени.-урон.-{n}", { "SPELL POWER", "HEALING" } },
	{ "исцел.-заклинани.-{n}", "HEALING" },
	{ "исцел.-эффект.-{n}", "HEALING" },
	{ "заклинани.-исцел.-{n}", "HEALING" },
	{ "целит.-заклинани.-{n}", "HEALING" },
	{ "лечени.-заклинани.-{n}", "HEALING" },
	{ "урон.-свет.-{n}", "HOLY DAMAGE" },
	{ "урон.-Свет.-{n}", "HOLY DAMAGE" },
	{ "урон.-свят.-{n}", "HOLY DAMAGE" },
	{ "урон.-огн.-{n}", "FIRE DAMAGE" },
	{ "урон.-огон.-{n}", "FIRE DAMAGE" },
	{ "урон.-льд.-{n}", "FROST DAMAGE" },
	{ "урон.-Льд.-{n}", "FROST DAMAGE" },
	{ "урон.-ледян.-{n}", "FROST DAMAGE" },
	{ "урон.-холод.-{n}", "FROST DAMAGE" },
	{ "урон.-природ.-{n}", "NATURE DAMAGE" },
	{ "урон.-Природ.-{n}", "NATURE DAMAGE" },
	{ "урон.-тьм.-{n}", "SHADOW DAMAGE" },
	{ "урон.-Тьм.-{n}", "SHADOW DAMAGE" },
	{ "урон.-темн.-{n}", "SHADOW DAMAGE" },
	{ "урон.-тайн.-{n}", "ARCANE DAMAGE" },
	{ "урон.-Тайн.-{n}", "ARCANE DAMAGE" },
	{ "урон.-заклинани.-{n}", "SPELL DAMAGE" },
	{ "урон.-магическ.-{n}", "SPELL DAMAGE" },
	{ "осполн.-маны.-{n}%%", "CASTING REGEN" },
	{ "{n}%%.-осполн.-маны", "CASTING REGEN" },
	{ "егенерац.-маны.-{n}%%", "CASTING REGEN" },
	{ "{n}%%.-егенерац.-маны", "CASTING REGEN" },
	{ "осстановлени.-маны.-{n}%%", "CASTING REGEN" },
	{ "{n}%%.-осстановлени.-маны", "CASTING REGEN" },
	{ "маны.-во время.-{n}%%", "CASTING REGEN" },
	{ "{n}%%.-маны.-во время", "CASTING REGEN" },
	{ "сопротивл.-цел.-{n}", "SPELL PENETRATION" },
	{ "цел.-сопротивл.-{n}", "SPELL PENETRATION" },
	{ " сил.-атак.-в бою", false },
	{ " сил.-атак.-против ", false },
	{ " сил.-атак.-сражени", false },
	{ "{n} к сил.-атак.-дальн", "RANGED ATTACK POWER" },
	{ " сил.-атак.-дальн.-на {n}", "RANGED ATTACK POWER" },
	{ "{n} к сил.-атак.-облик", "FERAL ATTACK POWER" },
	{ "{n} к сил.-атак.-кошк", "FERAL ATTACK POWER" },
	{ " сил.-атак.-на {n}.-облик", "FERAL ATTACK POWER" },
	{ " сил.-атак.-на {n}.-кошк", "FERAL ATTACK POWER" },
	{ "скорост.-атак.-на {n}%%", "HASTE" },
	{ " сил.-атак.-на {n}", "ATTACK POWER" },
	{ "{n} к сил.-атак", "ATTACK POWER" },
	{ "{n}[^%d]-маны.-5 с", "MANA PER 5" },
	{ "{n}[^%d]-здоров.-5 с", "HEALTH PER 5" },
	{ "осполн.-{n}[^%d]-здоров", "HEALTH PER 5" },
	{ "осстан.-{n}[^%d]-здоров", "HEALTH PER 5" },
	{ "ащит.-%+{n}", "DEFENSE" },
	{ "{n} к защит", "DEFENSE" },
	{ "ащит.-на {n}", "DEFENSE" },
	{ "уклон.-на {n}%%", "DODGE" },
	{ "парир.-на {n}%%", "PARRY" },
	{ "блок.-на {n}%%", "BLOCK" },
	{ "блок.-на {n}", "BLOCK VALUE" },
}

-- The rooms inside dungeons, as the client names them where the player stands: "You are
-- here" and a wing's areas match these (Core/Areas.lua). Unconfirmed ones are listed in
-- the translation's to-check list.
L.AREA_NAMES = {
	["Aku'mai's Lair"] = "Логово Аку'Мая",
	["Anvilmar's Rest"] = "Покой Анвилмара",
	["Athenaeum"] = "Читальня",
	["Blackrock Stadium"] = "Стадион Черной горы",
	["Blackrock Stronghold"] = "Крепость Черной горы",
	-- City of Dalaran's rooms (Data/Authored/CityOfDalaran.lua's floors: Cantrips & Crows, City of
	-- Dalaran, Dalaran, Magus Commerce Exchange, Path of Renewal, Presage Plaza, Runeweaver Square, Sewer,
	-- The Eventide, The Purple Parlor, The Underbelly, The Violet Citadel, The Violet Hold): the city's
	-- own buildings name them. Most have no area id; Dalaran (279, 16558), City of Dalaran (16544, 16560)
	-- and The Eventide (17824) have, not baked yet: a scan (/aegis areas, Dev/bake_area_ids.py) can
	-- replace those three. By the names the game's Dalaran has in this language, the newest of four
	-- copies of a list of them, to be checked in game (GetSubZoneText there).
	-- Here City of Dalaran reads as Dalaran: both are on the city's floor, and the map reads only the
	-- room's name in there (roomsOnly), so the zone's name, where no room is named, never turns it
	["Cantrips & Crows"] = "Ведьма и ворон",
	["Capital Gardens"] = "Столичные сады",
	["Cavern of Mists"] = "Пещера Туманов",
	["Chamber of Atonement"] = "Чертог Искупления",
	["Chamber of Battle"] = "Чертог Битвы",
	["Chapel Gardens"] = "Церковные сады",
	["City of Dalaran"] = "Даларан",
	["Cleft of Shadow"] = "Расселина Теней",
	["Court of the Highborne"] = "Двор Высокорожденных",
	["Crag of the Everliving"] = "Утес Вечноживущего",
	["Crusader's Armory"] = "Оружейная Рыцарей",
	["Crusader's Chapel"] = "Часовня Ордена",
	["Crusaders' Square"] = "Площадь рыцарей",
	["Dalaran"] = "Даларан",
	["Dark Iron Ingress"] = "Проход Темного Железа",
	["Defias Hideout"] = "Убежище Братства Справедливости",
	["Dig One"] = "Раскоп номер один",
	["Dragonspire Hall"] = "Зал Драконов",
	["Dreamer's Rock"] = "Покои Спящего",
	["Elders' Square"] = "Площадь Старейшин",
	["Eldre' Thalas"] = "Эльдре'Талас",
	["Eldreth Row"] = "Улица Эльдрета",
	["Engineering Labs"] = "Инженерные лаборатории",
	["Excavation Center"] = "Центр раскопок",
	["Festival Lane"] = "Праздничная улица",
	["Footman's Armory"] = "Оружейная пехоты",
	["Forgewright's Tomb"] = "Гробница Кузнеца",
	["Forlorn Cloister"] = "Покинутый двор",
	["Gallery of Treasures"] = "Сокровищница",
	["Goblin Foundry"] = "Гоблинский цех",
	["Gordok Commons"] = "Общий зал Гордока",
	["Hall of Champions"] = "Чертог Защитников",
	["Hall of the Keepers"] = "Зал Хранителей",
	["Halycon's Lair"] = "Логово Халикона",
	["Honor's Tomb"] = "Гробница Доблести",
	["Hordemar City"] = "Ордамар",
	["Huntsman's Cloister"] = "Скит Охотника",
	["King's Square"] = "Королевская площадь",
	["Launch Bay"] = "Пусковой отсек",
	-- Three rooms of Gnomeregan's way in (Data/Authored/SubMaps.lua), the Loading Room, the Train
	-- Depot and the Workshop Entrance, have no area id, so they are found by these names alone, to be
	-- checked in game (GetSubZoneText there): LibBabble-SubZone's, the same in its root file (rev 237)
	-- and in the file the lib loads (rev 258)
	["Loading Room"] = "Погрузочная",
	["Magus Commerce Exchange"] = "Торговая палата волшебников",
	["Market Row"] = "Торговый ряд",
	["Mast Room"] = "Мачтовая мастерская",
	["Mok'Doom"] = "Мок'Дум",
	["Moonshrine Ruins"] = "Руины Лунного святилища",
	["Moonshrine Sanctum"] = "Святилище Лунного Света",
	["North Common Hall"] = "Северный общий зал",
	["Path of Renewal"] = "Путь обновления",
	["Pit of Fangs"] = "Змеиная яма",
	["Presage Plaza"] = "Площадь предвестника",
	["Prison of Immol'thar"] = "Тюрьма Бессмер'тера",
	["Reliquary of Kings"] = "Реликварий королей",
	["Runeweaver Square"] = "Площадь Руноплета",
	["Screaming Gully"] = "Овраг Воплей",
	["Sewer"] = "Канализация",
	["Skitterweb Tunnels"] = "Паучий лабиринт",
	["Slaughter Square"] = "Площадь Живодерни",
	["South Common Hall"] = "Южный общий зал",
	["Tazz'Alaor"] = "Тазз'Алаор",
	["Tazz'Alor"] = "Тазз'Алор",
	-- Gnomeregan's Clean Zone, a room the map follows since 0.39.21 (2026-11-12; drafted, to be checked)
	["The Clean Zone"] = "Чистая зона",
	["The Clockwerk Run"] = "Заводной проход",
	["The Dormitory"] = "Общежитие",
	["The Drowned Sacellum"] = "Затопленное святилище",
	["The Eventide"] = "Вечерняя Заря",
	["The Forgotten Pool"] = "Забытый пруд",
	["The Gauntlet"] = "Улица Испытаний",
	["The Grand Vestibule"] = "Большой вестибюль",
	["The Grinding Quarry"] = "Дробильный карьер",
	["The Hall of Gears"] = "Зал Шестеренок",
	["The Hall of Lights"] = "Зал Света",
	["The High Seat"] = "Высокий трон",
	["The Hoard"] = "Арсенал",
	["The Masonary"] = "Каменотёсня",
	["The Molten Span"] = "Огненный пролёт",
	["The Pool of Ask'ar"] = "Пруд Аск'ара",
	["The Purple Parlor"] = "Аметистовая гостиная",
	["The Rookery"] = "Гнездовье",
	["The Scarlet Bastion"] = "Бастион Алого ордена",
	["The Sealed Hall"] = "Запечатанный зал",
	["The Shrine of Eldretharr"] = "Святилище Элдретарра",
	["The Slaughter House"] = "Живодерня",
	["The Storehouse"] = "Кладовая",
	["The Underbelly"] = "Клоака",
	["The Violet Citadel"] = "Аметистовая цитадель",
	["The Violet Hold"] = "Аметистовая крепость",
	["The Wailing Caverns"] = "Пещеры Стенаний",
	["Tinkers' Court"] = "Двор Механиков",
	-- Gnomeregan's way in, as the Loading Room above
	["Train Depot"] = "Депо",
	["Training Grounds"] = "Тренировочная площадка",
	["Warpwood Quarter"] = "Квартал Криводревов",
	-- Gnomeregan's way in, as the Loading Room above
	["Workshop Entrance"] = "Вход в мастерскую",
	-- The Temple of Atal'Hakkar's way in (Data/Authored/SubMaps.lua, 2026-10-30): its nine rooms have no area id,
	-- so they are found by these names alone. Pool of Tears, Sorrowmurk and the temple's own name have ids (74,
	-- 1778, 1477): a scan (/aegis areas, Dev/bake_area_ids.py) can replace those three. LibBabble-SubZone's names,
	-- the same in its root file (rev 237) and in the file the lib loads (rev 258). Hall of Faces and Den of
	-- the Unholy are Forever's names. To be checked in game (GetSubZoneText there).
	-- The journal names the dungeon itself "Храм Атал'Хаккара"
	["Chamber of Blood"] = "Чертог Крови",
	["Den of the Caller"] = "Зал Взывающего",
	["Den of the Unholy"] = "Убежище Нечистого",
	["Hall of Bones"] = "Зал Костей",
	["Hall of Faces"] = "Зал Ликов",
	["Hall of Masks"] = "Зал Масок",
	["Hall of Ritual"] = "Ритуальный зал",
	["Pool of Tears"] = "Озеро Слез",
	["Sorrowmurk"] = "Горемрак",
	["The Broken Hall"] = "Затопленный зал",
	["The Butchery"] = "Бойня",
	["The Temple of Atal'Hakkar"] = "Храм Атал'Хаккар",
}

-- The journal's style: its question at each character's first login, each choice and what it does, and the
-- choice and boxes in the options (2026-11-03; drafted, to be checked).
L.STYLE_TITLE = "Выберите вид путеводителя"
L.STYLE_SUBTITLE = "Сколько путеводитель должен добавлять в игру? Это можно изменить в любой момент в настройках путеводителя."
L.STYLE_CLASSIC = "Классический"
L.STYLE_CLASSIC_DESC = "Путеводитель ближе к оригиналу, с меньшим числом дополнений. Боссы, добыча, задания и карты подземелий остаются."
L.STYLE_MODERN = "Современный"
L.STYLE_MODERN_DESC = "Всё, что есть в путеводителе, как сейчас: поиск снаряжения, карты путей внутрь и его отметки на карте мира."
L.STYLE_CUSTOM = "Свой"
L.STYLE_CUSTOM_DESC = "Выбираете вы. Выберите это, чтобы открыть настройки путеводителя, где у каждой функции свой флажок."
L.STYLE_STARTING = "Начальные настройки:"
L.STYLE_LINE_ON = "%s: вкл."
L.STYLE_LINE_OFF = "%s: выкл."
L.STYLE_LINE_CHOOSE = "%s: на ваш выбор"
L.STYLE_GEAR = "Поиск снаряжения и приоритет характеристик"
L.STYLE_GEAR_TIP = "Вкладка поиска снаряжения, её вкладка в окне персонажа, строки приоритета характеристик в подсказках предметов, зелёные стрелки улучшений и приоритеты путеводителя в Pawn. Все они опираются на одни и те же приоритеты, поэтому идут вместе. Только для этого персонажа."
L.STYLE_WAY_IN = "Карты путей внутрь и пещеры"
L.STYLE_WAY_IN_TIP = "Карты пути к подземелью (пещеры, здания, уровни горы) поверх карты мира и входы в пещеры и здания к ним. Собственные карты подземелий остаются. Только для этого персонажа."
L.STYLE_MARKERS = "Отметки на карте мира"
L.STYLE_MARKERS_TIP = "Отметки путеводителя на карте мира: входы в подземелья и рейды, распорядители полётов, корабли, дирижабли, трамвай и порталы, его отметки заданий, уровни зон и неисследованные области. Только для этого персонажа."
L.STYLE_CLICK = "Нажмите, чтобы выбрать"
L.STYLE_NOW = "Ваш вид сейчас"
L.STYLE_CLOSE_NOTE = "Если закрыть, останется: %s."
L.STYLE_CHOSEN = "Вид путеводителя: %s. Его можно изменить в любой момент в настройках путеводителя (/aegis options)."
L.STYLE_OPTIONS_AFTER_COMBAT = "Настройки путеводителя откроются после окончания боя."
L.STYLE_OPTION = "Вид путеводителя"
L.STYLE_OPTION_TIP = "Классический, Современный или Свой — только для этого персонажа. Если включить или выключить функцию ниже, вид станет «Свой»."
-- The Reset button under the style's dropdown, and its question (2026-11-03; drafted, to be checked).
L.STYLE_RESET = "Сбросить путеводитель по подземельям"
L.STYLE_RESET_BUTTON = "Сбросить"
L.STYLE_CHOOSE_BUTTON = "Выбрать"
L.STYLE_RESET_TIP = "Возвращает настройки путеводителя к состоянию после установки для всех ваших персонажей и снова предлагает этому персонажу выбор вида. Записи, приоритеты характеристик и вид других персонажей сохраняются."
L.STYLE_RESET_CONFIRM = "Вернуть настройки путеводителя к состоянию после установки для всех ваших персонажей и снова предложить этому персонажу выбор вида? Ваши записи, приоритеты характеристик и вид других персонажей сохранятся."
L.STYLE_GEAR_IS_OFF = "Поиск снаряжения выключен. Включите его в настройках путеводителя (/aegis options)."
-- The Record tab's box in the options, and /aegis record while it is off (2026-11-03; drafted, to be checked).
L.OPTIONS_RECORD_TAB = "Показывать вкладку «Запись»"
L.OPTIONS_RECORD_TAB_TIP = "Вкладка, которая записывает ваши походы в подземелья для нас. Выключено: вкладка скрыта, и путеводитель ничего не записывает («Записать торговца» на вкладке «Репутация» по-прежнему работает). Уже записанное сохраняется."
L.RECORD_TAB_IS_OFF = "Вкладка «Запись» выключена. Включите её в настройках путеводителя (/aegis options)."
L.LEGEND_STYLE_OFF = "Выключено в настройках путеводителя."

-- The run block (UI/RunTracker.lua, Core/Run.lua), 2026-11-11; drafted, to be checked. The client's own words where it has them.
L.RUN_BOSS_DEFEATED = "Побежден: %s"
L.RUN_COMPLETE = DUNGEON_COMPLETED or "Подземелье пройдено!"
L.RUN_EXPERIENCE = EXPERIENCE_COLON or "Опыт:"
L.RUN_MONEY = MONEY_COLON or "Деньги:"
L.RUN_ITEMS = "Предметы:"
L.RUN_PER_HOUR = "%s/ч"
L.RUN_GREED = "%d выиграно (" .. (GREED or "Не откажусь") .. ")"
L.RUN_DEFEATED = BOSS_DEAD or "Побежден"
L.RUN_NOT_DEFEATED = "Еще не побежден"
L.RUN_PARTS = "%s, затем %s"
L.RUN_COIN = "Добытые монеты"
L.RUN_ITEM_VALUE = "Предметы по цене торговца"
L.RUN_PENDING = "Предметов без цены: %d"
L.RUN_DRAG = "Перетащите заголовок, чтобы переместить блок."
L.RUN_SUMMARY = "%s: %d/%d боссов за %s"
L.RUN_SUMMARY_XP = "%s опыта"
L.RUN_SUMMARY_ITEMS = "Предметов: %d"
L.RUN_NEW = "Начат новый забег."
L.RUN_NOT_INSIDE = "Войдите в подземелье, чтобы начать новый забег."
L.RUN_HIDDEN = "Блок забега скрыт до конца этого забега. Введите /ij run, чтобы показать его снова."
L.RUN_NONE = "Забегов по подземельям пока нет."
L.RUN_IS_OFF = "Учет забегов выключен. Включите его в настройках путеводителя (/aegis options)."
L.RUN_FREE_ON = "Перетаскивайте блок забега за заголовок. /ij run lock вернет его к списку заданий."
L.RUN_FREE_OFF = "Блок забега снова у списка заданий."
L.RUN_USAGE = "/ij run показывает или скрывает блок забега (вне подземелья — ваш последний забег). /ij run new начинает новый забег. /ij run unlock позволяет перетаскивать его; /ij run lock и /ij run reset возвращают его к списку заданий. /ij run debug показывает, что было подсчитано."
L.OPTIONS_RUN = "Учет забегов по подземельям"
L.OPTIONS_RUN_TIP = "В подземелье блок у списка заданий показывает, сколько длится забег, его боссов и вашу добычу. Если выключено, ничего не считается."
L.OPTIONS_RUN_NUMBERS = "Показывать опыт и деньги"
L.OPTIONS_RUN_NUMBERS_TIP = "Опыт и деньги (добытые монеты плюс цена ваших предметов у торговца), каждое — и в час, а также сколько предметов вы получили."
L.OPTIONS_RUN_FREE = "Свободное размещение"
L.OPTIONS_RUN_FREE_TIP = "Перетащите блок за заголовок в любое место. Если выключено, он стоит у списка заданий и двигается вместе с ним."
-- The run block's dark mode: its gold art darkened, else the tracker's tint (UI/RunTracker.lua Paint), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_DARK_MODE = "Темный режим"
L.OPTIONS_RUN_DARK_MODE_TIP = "Затемняет золото заголовка и рамки блока забега. Если выключено, блок выглядит как заголовки вашего списка заданий: он темный, когда ваш интерфейс затемняет их."
L.OPTIONS_RUN_SUMMARY = "Итог в чате"
L.OPTIONS_RUN_SUMMARY_TIP = "Одна строка в чате через минуту после остановки часов забега (раньше, если вы уйдете). Незавершенный забег, который вы покинули, получает свою строку, когда он окончен: при сбросе подземелья или через полчаса снаружи."
-- The run block inside the quest tracker: an experiment, off by default (UI/RunTrackerInside.lua), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_INSIDE = "Внутри списка заданий (эксперимент)"
L.OPTIONS_RUN_INSIDE_TIP = "Блок встает в список заданий, сразу под «" .. (TRACKER_ALL_OBJECTIVES or "Все цели") .. "», а разделы списка (" .. (TRACKER_HEADER_QUESTS or "Задания") .. " и остальные) сдвигаются под него. Список, который вы передвинули в режиме редактирования, не выше заданной там высоты: если ее мало для блока, блок стоит рядом со списком, как при выключенной настройке, а кнопка ниже может сделать список выше. Это проверка: если игра сообщит о заблокированном действии, настройка выключится сама. Если она уже использовалась, полностью она выключится только после /reload."
L.RUN_INSIDE_BLOCKED = "Игра заблокировала действие путеводителя (%s), поэтому «Внутри списка заданий» теперь выключено, и блок забега вернется к списку заданий. Пожалуйста, сообщите об этой строке. Введите /reload, чтобы полностью убрать его из списка."
L.RUN_INSIDE_RELOAD = "«Внутри списка заданий» теперь выключено, и блок забега вернется к списку заданий. Введите /reload, чтобы полностью убрать его из списка."
-- The tracker too short for the block inside: the Height it needs, and the options' Make taller button (UI/RunTrackerInside.lua), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_TALLER = "Сделать список заданий выше"
L.OPTIONS_RUN_TALLER_BUTTON = "Выше"
L.OPTIONS_RUN_TALLER_TIP = "Для «Внутри списка заданий»: задает высоту списка заданий в вашем макете режима редактирования такой, какая нужна блоку забега, и сохраняет макет. Только для списка, который вы передвинули в режиме редактирования. Используйте, пока блок виден, вне боя и при закрытом режиме редактирования. Видно после /reload."
L.RUN_INSIDE_SHORT = "Блок забега стоит рядом со списком заданий: список слишком короткий для него. Чтобы сделать его выше: %s, выберите «%s», %s %d или больше. Или нажмите «%s» в настройках путеводителя (/aegis options)."
L.RUN_INSIDE_SHORT_TIP = "Список заданий слишком короткий для блока. Чтобы сделать его выше: %s, выберите «%s», %s %d или больше."
L.RUN_TALLER_COMBAT = ERR_NOT_IN_COMBAT or "Это нельзя сделать в бою."
L.RUN_TALLER_EDIT_MODE = "Сначала закройте: %s."
L.RUN_TALLER_DEFAULT = "Список заданий стоит на своем месте по умолчанию, где он доходит до низа экрана: высоту ему задавать не нужно."
L.RUN_TALLER_UNKNOWN = "Используйте это, пока виден блок забега (в подземелье или ваш последний забег через /ij run): тогда измеряется его высота."
L.RUN_TALLER_ENOUGH = "Список заданий уже достаточно высокий для блока забега."
L.RUN_TALLER_FAILED = "Не удалось изменить ваш макет режима редактирования отсюда. Задайте сами: %s, выберите «%s», %s %d или больше."
L.RUN_TALLER_DONE = "%s – %s: теперь %d в вашем макете «%s» режима редактирования. Введите /reload сейчас, чтобы увидеть."
L.RUN_TALLER_MOST = "Больше режим редактирования не позволяет, так что блок может все еще не поместиться."

-- Matched against the client's own text: the client's language's only, previewed or not.
if client then client.EQUIP_PATTERNS, client.AREA_NAMES = L.EQUIP_PATTERNS, L.AREA_NAMES end
L.EQUIP_PATTERNS, L.AREA_NAMES = nil, nil
