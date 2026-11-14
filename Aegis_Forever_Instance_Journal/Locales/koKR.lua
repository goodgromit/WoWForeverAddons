local _, ns = ...

--[[
	The journal's interface in Korean, drafted by Claude for review by a native speaker, for a
	client set to Korean (koKR). It is laid over the English table (Locales/enUS.lua), so every file
	that already holds ns.L sees these strings, and anything not translated here stays English.
	Every other client skips it. Names new in WoW: Forever have no official Korean form yet: they
	are drafted in the game's style (the glossary's), to be checked once Blizzard names them.
]]
-- The journal's words where it speaks this language; the tables matched against the client's own
-- text where the client does, previewed or not (ns.LocaleTargets, Locales/enUS.lua).
local L, client = ns.LocaleTargets("koKR")
if not L then return end

L.JOURNAL_TITLE = "던전 도감"
L.HOME = HOME or "홈"
L.TAB_DUNGEONS = DUNGEONS or "던전"
L.TAB_RAIDS = RAIDS or "공격대"
L.TAB_REPUTATION = REPUTATION or "평판"

L.BINDING_TOGGLE = "던전 도감 열기/닫기"
L.KEY_CLAIMED = "이제 Shift+J 키를 누르면 던전 도감이 열립니다."
L.KEY_TAKEN = "Shift+J 키는 이미 %s에 지정되어 있습니다. 단축키 설정 > 애드온 > 던전 도감 열기/닫기에서 다른 키를 지정하십시오."
L.POSITION_RESET = "창 위치를 초기화했습니다."
L.DOCK_ON = "이제 창이 왼쪽 위, 게임 창 옆에서 열립니다. 끌어서 옮기면 닫을 때까지 그 자리에 있습니다."
L.DOCK_OFF = "창이 다시 자유롭게 움직입니다: 마지막으로 끌어다 놓은 곳에서 열립니다."
L.DOCK_AFTER_COMBAT = "전투가 끝나면 적용됩니다."
-- Its /aegis style sentence (2026-11-03; drafted, to be checked).
L.SLASH_HELP = "/aegis (또는 /ij): 도감을 엽니다. /aegis record: 기록을 시작하거나 중지합니다. /aegis reset: 창을 기본 위치로 되돌립니다. /aegis dock: 창을 왼쪽 위, 게임 창 옆에 고정하거나 다시 풀어 줍니다. /aegis perf: 도감의 메모리 사용량과 속도를 측정합니다. /aegis where, /aegis taxi: 현재 위치와 지도에 있는 비행 지점을 알려줍니다. /aegis travel: 세계 지도에 표시할 배, 비행선, 지하철, 차원문을 저장합니다. /aegis items: 도감에 실린 아이템 중 서버가 모르는 것을 찾습니다. /aegis gear: 장비 찾기를 엽니다. /aegis weights: 장비 찾기의 능력치 가중치를 엽니다. /aegis gearscan: 장비 찾기가 내 장비에서 읽은 내용을 저장해 점수 계산을 확인할 수 있게 합니다. /aegis options: 도감 설정을 엽니다. /aegis style: 도감 방식 질문을 다시 보여 줍니다. /aegis lang: 도감을 다른 언어로 미리 봅니다. /aegis run: 던전 공략 창을 표시하거나 숨깁니다 (던전 밖에서는 마지막 공략). /aegis run new: 새 공략을 시작합니다."
-- /aegis lang (Core/Init.lua)
L.LANG_USAGE = "/aegis lang de, fr, ru, cn, tw, es, mx, pt, ko: 다음 /reload부터 도감을 독일어, 프랑스어, 러시아어, 중국어(간체 또는 번체), 스페인어(스페인 또는 중남미), 브라질 포르투갈어, 한국어로 표시해 번역을 확인할 수 있습니다. /aegis lang off: 클라이언트 언어로 돌아갑니다. 현재: %s."
L.LANG_SET = "다음 /reload부터 도감의 언어: %s. 바뀌는 것은 도감 자체의 문구뿐이며, 게임 속 이름은 클라이언트 언어 그대로입니다. 지금 /reload를 입력하십시오. /aegis lang off로 되돌릴 수 있습니다."
L.LANG_OFF = "다음 /reload부터 도감이 다시 클라이언트 언어로 표시됩니다. 지금 /reload를 입력하십시오."
L.LANG_FONTS = "중국어를 표시하려면 중국어 클라이언트의 글꼴이 필요합니다. 현재 클라이언트에서는 일부 글자가 보이지 않을 수 있습니다."
L.LANG_FONTS_KO = "한국어를 표시하려면 한국어 클라이언트의 글꼴이 필요합니다. 현재 클라이언트에서는 일부 글자가 보이지 않을 수 있습니다."
L.LANG_ON = "도감 미리 보기 언어: %s. /aegis lang off로 끝낼 수 있습니다."
L.LANG_UNAVAILABLE = "이 클라이언트가 저장된 설정보다 도감을 먼저 불러와서 언어 미리 보기를 시작할 수 없었습니다."
L.AREAS_START = "도감에 있는 지역 이름 %d개의 클라이언트 ID를 찾는 중..."
L.AREAS_DONE = "ID를 찾은 지역 이름: %d개 (전체 %d개). 저장하려면 /reload를 입력하십시오."
L.AREAS_MISSING = "찾지 못함: %s."
L.AREAS_SCANNING = "아직 지역 이름을 찾는 중입니다."
L.AREAS_ENGLISH = "/aegis areas는 영어 클라이언트에서 실행하십시오. 찾는 이름이 영어이기 때문입니다."
L.ITEMS_START = "도감에 실린 아이템 %d개에 대해 서버에 묻는 중입니다. 약 %d초 후에 결과가 나오니 그동안 자유롭게 플레이하십시오."
L.ITEMS_SCANNING = "아직 서버에 묻는 중입니다. 곧 결과가 나옵니다."
L.ITEMS_DONE = "아이템 %d개 중 %d개는 서버가 알지 못합니다. 아직 포에버에 없는 아이템일 가능성이 높습니다. 서버나 기록된 던전 진행으로 확인될 때까지 도감에서 숨깁니다. 전체 목록은 다음 /reload 또는 로그아웃 때 저장 파일에 기록됩니다."
L.ITEMS_LINE = "  아이템 %d: %s"
L.ITEMS_MORE = "  ...외 %d개."
L.PERF_HEADER = "성능 (메모리는 KB, 시간은 밀리초 단위, 낮을수록 좋음):"
L.PERF_MEMORY = "  %s: %.0f KB"
L.PERF_TIME = "  %s: %.2f ms"
L.PERF_BUILD = "처음 열기 (창 만들기)"
L.PERF_BOOK = "처음 연 던전 (도감 만들기)"
L.PERF_OPEN = "도감 열고 닫기"
L.PERF_DUNGEON = "던전 페이지 열기"
L.PERF_TAB = "%s 탭으로 전환"
L.PERF_FACTION = "진영 페이지 열기"
L.PERF_LOOT = "전리품 페이지 다시 그리기"
L.PERF_COMBAT = "전투가 끝날 때까지 측정을 기다립니다."
L.WHERE = "지도 %s (%s)  x %.4f  y %.4f  지역 \"%s\"  미니맵 \"%s\"  높이 %s"
-- /aegis where: what the journal remembers the player as below a city, and its last changes (2026-11-06; drafted, to be checked).
L.WHERE_BELOW = "%s: 기억된 상태 %s"
L.WHERE_BELOW_BELOW = "아래"
L.WHERE_BELOW_TOP = "위"
L.WHERE_BELOW_NOTHING = "없음"
L.WHERE_BELOW_CHANGE = "  %s  %s  지도 %s  지역 \"%s\"  x %s  y %s:  %s -> %s"
L.TAXI = "지도 %s  자체 비행 지점 표시: %s  지도의 비행 지점: %d개 (%d개 발견)  %s"
L.TAXI_ATLASES = "이동 아이콘: %s"
L.YES = YES or "예"
L.NO = NO or "아니요"

L.EMPTY_DUNGEONS = "아직 도감에 등록된 던전이 없습니다."
L.EMPTY_RAIDS = "아직 도감에 등록된 공격대가 없습니다."
L.EMPTY_REPUTATION = "아직 알려진 평판 보상이 없습니다."
L.EMPTY_BRACKET = "이 레벨 구간에는 아무것도 없습니다."

L.TAB_RECORD = "기록"
L.TAB_GEAR = "장비 찾기"

-- The Gear Finder (Core/GearFinder.lua, UI/GearPanel.lua, UI/CharacterTab.lua).
L.GEAR_TITLE = "장비 찾기"
L.GEAR_PREVIEW = "미리 보기"
L.GEAR_NO_UPGRADE = "향상 아이템 없음"
L.GEAR_LOOKING = "던전 %d곳에서 찾는 중."
L.GEAR_LOOKING_ONE = "던전 1곳에서 찾는 중."
L.GEAR_LOADING = "아이템 %d개를 아직 불러오는 중입니다."
L.GEAR_LOADING_ONE = "아이템 1개를 아직 불러오는 중입니다."
L.GEAR_SCORING = "평가 기준"
L.GEAR_AUTO = "자동: %s"
L.GEAR_WHY_TALENTS = "%s (특성 기준)"
L.GEAR_WHY_LEVELLING = "%s (레벨업 중)"
L.GEAR_SUGGESTED = "추천 던전"
L.GEAR_UPGRADES_HERE = "향상 아이템 %d개"
L.GEAR_UPGRADE_HERE = "향상 아이템 1개"
L.GEAR_MORE_SLOTS = "외 %d개"
L.GEAR_DUNGEON_OF = "%d / %d"
L.GEAR_NONE = "내 레벨에 맞는 던전에 향상 아이템이 없습니다."
L.GEAR_TIP_CLICK = "클릭하면 전리품을 봅니다. Shift+클릭하면 링크합니다."
L.GEAR_TIP_CELL_CLICK = "클릭하면 상위 향상 아이템을 봅니다. 오른쪽 클릭하면 전리품을 봅니다."
L.GEAR_TIP_PICK_CLICK = "클릭하면 여기에 표시합니다. 오른쪽 클릭하면 전리품을 봅니다."
L.GEAR_TIP_PICKED = "이 부위에 고른 아이템입니다."
L.GEAR_PICK_TOP = "상위 %d개 (향상 아이템 전체 %d개)"
L.GEAR_PICK_ALL = "향상 아이템 %d개"
L.GEAR_PICK_ONE = "유일한 향상 아이템"
L.GEAR_PICK_BIGGEST = "가장 큰 향상"
L.GEAR_PICK_YOURS = "내 선택"
L.GEAR_PICK_KEPT = "선택한 아이템은 이 캐릭터에 저장됩니다."
L.GEAR_PICK_CLEAR = "내 선택 해제"
L.GEAR_TIP_NONE = "내 레벨에 맞는 던전에 이 부위의 향상 아이템이 없습니다."
L.GEAR_CHAR_BUTTON = "장비 찾기"
L.GEAR_CHAR_BUTTON_TIP = "내 능력치 가중치와, 도감의 던전에서 기다리고 있는 최고의 향상 아이템을 보여줍니다."
L.GEAR_SCAN_DONE = "장비 검사를 저장했습니다: 착용 아이템 %d개, 던전 획득 아이템 %d개. 로그아웃하거나 /reload를 입력하면 저장 파일에 기록됩니다."
L.GEAR_SCAN_ERRORS = "아이템 %d개를 읽지 못했습니다. 문제 내용은 검사 결과와 함께 저장됩니다."
L.GEAR_SCAN_LOADING = "일부 획득 아이템을 아직 불러오는 중입니다. 몇 초 기다린 후 /aegis gearscan을 다시 입력하면 더 읽어 옵니다."
L.GEAR_SLOT_FINGER1 = "손가락 1"
L.GEAR_SLOT_FINGER2 = "손가락 2"
L.GEAR_SLOT_TRINKET1 = "장신구 1"
L.GEAR_SLOT_TRINKET2 = "장신구 2"

-- Stat weights (Core/ItemScore.lua, UI/WeightsEditor.lua). Pawn's own Korean calls a scale
-- "능력치 비율", its Export and Import buttons "내보내기" and "가져오기", an upgrade "향상".
L.WEIGHTS_TITLE = "능력치 가중치"
L.WEIGHTS_EDIT = "능력치 가중치 편집..."
L.WEIGHTS_SOURCE_DEFAULT = "도감의 가중치"
L.WEIGHTS_SOURCE_LEVELLING = "도감의 가중치 (레벨업 중)"
L.WEIGHTS_SOURCE_CUSTOM = "내 가중치"
L.WEIGHTS_SOURCE_PAWN = "Pawn에서 가져온 내 가중치: %s"
L.WEIGHTS_TIP = "이 특성에서 각 능력치 1포인트가 지니는 가치입니다. 가중치를 클릭하면 바꿀 수 있습니다. 직접 정한 가중치는 녹색으로 표시되며 이 캐릭터에 저장됩니다."
L.WEIGHTS_RESET = "초기화"
L.WEIGHTS_RESET_TIP = "이 특성에 대한 도감의 가중치로 되돌립니다."
L.WEIGHTS_PAWN = "Pawn..."
-- The Pawn... button's tooltip names WoWSims' Pawn export (2026-11-03; drafted, to be checked).
L.WEIGHTS_PAWN_TIP = "Pawn에서 능력치 비율을 가져오거나, WoWSims의 Pawn 내보내기를 붙여넣습니다."
L.WEIGHTS_PAWN_HELP = "Pawn에서 능력치 비율을 고르고 내보내기를 선택한 다음, 텍스트를 복사해 여기에 붙여넣으십시오."
L.WEIGHTS_IMPORT = "가져오기"
L.WEIGHTS_CANCEL = "취소"
L.WEIGHTS_BACK = "뒤로"
L.WEIGHTS_OPEN_FINDER = "장비 찾기 열기"
L.WEIGHTS_IMPORTED = "가중치 %d개를 가져왔습니다. 출처: %s."
L.WEIGHTS_UNUSED = "사용하지 않음: %s."
L.WEIGHTS_NOT_PAWN = "Pawn 능력치 비율이 아닙니다. Pawn에서 내보내기를 선택하고 텍스트 전체를 복사하십시오."
L.WEIGHTS_OTHER_CLASS = "이 능력치 비율은 %s용이며, 이 캐릭터의 직업용이 아닙니다."
L.WEIGHTS_FOR = "특성"
-- WoWSims' weights, the Gear Finder's defaults for the specs the sim has, and its Pawn export (2026-11-03; drafted, to be checked).
L.WEIGHTS_SOURCE_SIMS = "WoWSims의 가중치: %s"
L.WEIGHTS_PAWN_SIMS = "WoWSims(wowsims.com/forever)의 Pawn 내보내기도 Pawn 없이 사용할 수 있으며, 도감의 WoWSims 가중치와 같게 점수를 매깁니다. 치유량, 계열별 주문 공격력, 주문 관통력, 변신 상태 전투력, 방어 숙련도, 방패 막기, 저항력에 대한 가중치는 없습니다."
L.WEIGHTS_NO_STATS = "이 Pawn 능력치 비율에는 도감이 사용할 수 있는 가중치가 없습니다."
-- The journal's page in the game's options (Options > AddOns).
L.OPTIONS_TITLE = "Aegis Instance Journal"
L.OPTIONS_BOSS_LEVELS = "우두머리 목록에 우두머리 레벨 표시"
L.OPTIONS_BOSS_LEVELS_TIP = "각 우두머리 초상화에 레벨 배지를 표시합니다. 배지 색은 그 우두머리가 나에게 얼마나 어려운지에 따라 회색, 녹색, 노란색, 주황색, 빨간색으로 표시됩니다."
L.OPTIONS_ARROWS = "향상 아이템에 녹색 화살표 표시"
L.OPTIONS_MINIMAP = "미니맵 버튼 표시"
L.OPTIONS_PAWN_WEIGHTS = "장비 찾기에서 Pawn의 능력치 가중치 사용"
L.OPTIONS_PAWN_WEIGHTS_TIP = "Pawn이 설치되어 있으면 Pawn의 아이템 툴팁과 향상 화살표가 표시됩니다. 선택하면: 장비 찾기가 내 특성의 Pawn 능력치 비율로 아이템을 평가합니다. 선택하지 않으면: Pawn이 대신 도감의 능력치 비율로 내 특성에 대한 도감의 가중치를 보여주며, 이 옵션을 선택할 때까지 이 캐릭터에서는 Pawn 자체의 능력치 비율이 숨겨집니다."
-- Asked once, when Pawn is installed too (Core/PawnLink.lua).
L.PAWN_ASK = "Pawn도 설치되어 있습니다. Pawn의 아이템 툴팁과 향상 화살표가 표시됩니다.\n\nPawn과 장비 찾기가 함께 사용할 능력치 가중치를 고르십시오.\n\n도감 가중치: Pawn이 내 특성에 맞춰 표시하며, 이 캐릭터에서는 Pawn 자체의 능력치 비율을 숨깁니다.\nPawn 가중치: 장비 찾기가 내 Pawn 능력치 비율을 사용합니다."
L.PAWN_USE_PAWN = "Pawn 가중치"
L.PAWN_USE_JOURNAL = "도감 가중치"
-- The journal's scale for a spec, as Pawn lists it.
L.PAWN_SCALE = "도감: %s"
-- After the journal's scales in Pawn change, where Baganator draws Pawn's arrows.
L.PAWN_RELOAD = "Baganator 가방에 표시되는 Pawn의 향상 화살표는 UI를 다시 불러온 뒤에야 바뀝니다. Baganator는 장비가 바뀔 때까지 Pawn의 결과를 그대로 두기 때문입니다.\n\n지금 다시 불러올까요?"
L.PAWN_RELOAD_NOW = "다시 불러오기"
L.PAWN_RELOAD_LATER = "나중에"
L.WEIGHTS_SOURCE_PAWN_LIVE = "Pawn의 %s 능력치 비율. Pawn에서 바꾸거나, 설정에서 도감 가중치를 선택하십시오."
L.OPTIONS_MINIMAP_TIP = "미니맵 가장자리에 있는 도감 버튼입니다. 클릭하면 도감을 열고, 오른쪽 클릭하면 이 설정을 열며, 끌어서 옮길 수 있습니다."
L.OPTIONS_DOCK = "창을 왼쪽 위에 고정"
L.OPTIONS_DOCK_TIP = "선택하면: 도감이 화면 왼쪽 위, 게임이 자체 창을 여는 곳에서 열리고, 그곳에 게임 창이 열리면 게임 창끼리 그러하듯 옆으로 비켜납니다. 둘 다 들어갈 자리가 없으면 게임이 먼저 연 창을 닫습니다. 끌어서 아무 곳으로나 옮길 수 있으며, 다음에 열 때 다시 고정됩니다. 선택하지 않으면: 마지막으로 끌어다 놓은 곳에서 열립니다."
-- The minimap button's tooltip.
L.MINIMAP_LEFT_CLICK = "클릭하면 도감을 열거나 닫습니다."
L.MINIMAP_RIGHT_CLICK = "오른쪽 클릭하면 설정을 엽니다."
L.MINIMAP_DRAG = "끌어서 미니맵 둘레로 옮길 수 있습니다."
L.OPTIONS_ARROWS_TIP = "장비 찾기가 판단하기에 내 특성에 향상이 되는 아이템에 녹색 화살표를 표시합니다. 가방, 전리품 창, 주사위 굴림 창에 표시됩니다."
L.WEIGHTS_SHOW_GAINS = "툴팁에 능력치 가중치 표시"
L.WEIGHTS_SHOW_GAINS_TIP = "모든 아이템 아래에 내 특성마다 한 줄씩 표시합니다: 그 특성의 가중치로 매긴 아이템의 가치와, 향상 아이템이면 녹색 화살표와 함께 내 장비에 더해지는 값. 장비 찾기가 켜진 모든 캐릭터에 적용됩니다. Pawn이 설치되어 있으면 대신 Pawn에서 도감의 능력치 비율을 표시하거나 숨기며, 그에 따라 도감 가중치에 대한 Pawn의 향상 화살표도 표시하거나 숨깁니다. Pawn은 표시 중인 능력치 비율에 대해서만 향상 아이템을 표시합니다."
L.OPTIONS_SOURCES = "툴팁에 아이템 획득처 표시"
L.OPTIONS_SOURCES_TIP = "도감의 던전과 공격대에서 얻을 수 있는 모든 아이템 아래에 그 아이템을 떨어뜨리는 우두머리와 던전을 한 줄로 표시합니다. 가방, 캐릭터 창, 대화창 링크, 상인 등 게임이 아이템을 보여 주는 모든 곳에 표시됩니다. 모든 캐릭터에 적용됩니다."
L.GEAR_WHY_CUSTOM = "%s (내 가중치)"
--[[
	The specs' names, as the Korean client's talent tabs name them, and the units their weights
	count in, by spec key and by the English unit. The Korean client names two specs by class:
	Protection (the warrior's 방어, the paladin's 보호) and Restoration (the shaman's 복원, the
	druid's 회복). The journal asks by spec key only, for the player's own class, so those two are
	told apart here by the player's class.
]]
local SPEC_BY_CLASS = {
	Protection = { WARRIOR = "방어", PALADIN = "보호" },
	Restoration = { SHAMAN = "복원", DRUID = "회복" },
}
L.GEAR_SPEC_NAMES = setmetatable({
	Arms = "무기", Fury = "분노", Holy = "신성", Retribution = "징벌",
	BeastMastery = "야수", Marksmanship = "사격", Survival = "생존",
	Assassination = "암살", Combat = "전투", Subtlety = "잠행", Discipline = "수양", Shadow = "암흑",
	Elemental = "정기", Enhancement = "고양", EnhancementTank = "고양 (방어 전담)",
	Arcane = "비전", Fire = "화염", Frost = "냉기", Affliction = "고통",
	Demonology = "악마", Destruction = "파괴", Balance = "조화", FeralBear = "야성 (곰)",
	FeralCat = "야성 (표범)",
}, { __index = function(_, spec)
	local names = SPEC_BY_CLASS[spec]
	if not names then return nil end
	local classFile = UnitClass and select(2, UnitClass("player"))
	return names[classFile] or names.WARRIOR or names.SHAMAN
end })
L.GEAR_UNITS = {
	["attack power"] = "전투력", ["ranged attack power"] = "원거리 전투력",
	["spell damage"] = "주문 공격력", healing = "치유량", Stamina = "체력",
}
L.WEIGHT_GROUPS = {
	PRIMARY = "기본 능력치", WEAPONS = "무기", SPELLS = "주문", DEFENSE = "방어",
	RESISTANCE = "저항력",
}
L.STAT_NAMES = {
	STRENGTH = "힘", AGILITY = "민첩성", STAMINA = "체력", INTELLECT = "지능", SPIRIT = "정신력",
	DPS = "무기 초당 공격력", ["RANGED DPS"] = "원거리 무기 초당 공격력", ["ATTACK POWER"] = "전투력",
	["RANGED ATTACK POWER"] = "원거리 전투력", ["FERAL ATTACK POWER"] = "변신 상태 전투력", HIT = "적중률",
	CRIT = "치명타", ["RANGED CRIT"] = "원거리 치명타", HASTE = "공격 속도", ["RANGED HASTE"] = "원거리 공격 속도",
	["SPELL POWER"] = "주문 공격력 및 치유량", ["SPELL DAMAGE"] = "주문 공격력", HEALING = "치유량", ["SPELL HIT"] = "주문 적중률",
	["SPELL CRIT"] = "주문 극대화", ["HOLY CRIT"] = "신성 주문 극대화", ["HOLY DAMAGE"] = "신성 주문 공격력",
	["FIRE DAMAGE"] = "화염 주문 공격력", ["FROST DAMAGE"] = "냉기 주문 공격력", ["NATURE DAMAGE"] = "자연 주문 공격력",
	["SHADOW DAMAGE"] = "암흑 주문 공격력", ["ARCANE DAMAGE"] = "비전 주문 공격력", ["SPELL PENETRATION"] = "주문 관통력",
	MANA = "마나", ["MANA PER 5"] = "5초당 마나 회복", ["CASTING REGEN"] = "시전 중 마나 회복",
	ARMOR = "방어도", HEALTH = "생명력", ["HEALTH PER 5"] = "5초당 생명력 회복", DEFENSE = "방어 숙련도", DODGE = "회피",
	PARRY = "무기 막기", BLOCK = "방패 막기", ["BLOCK VALUE"] = "방패 피해 방어량",
	["HOLY RESISTANCE"] = "신성 저항력", ["FIRE RESISTANCE"] = "화염 저항력",
	["NATURE RESISTANCE"] = "자연 저항력", ["FROST RESISTANCE"] = "냉기 저항력",
	["SHADOW RESISTANCE"] = "암흑 저항력", ["ARCANE RESISTANCE"] = "비전 저항력",
}
L.RECORD_START = "기록 시작"
L.RECORD_STOP = "기록 중지"
L.RECORD_CLEAR = "지우기"
L.RECORD_CLEAR_CONFIRM = "지금까지 기록한 내용을 모두 버릴까요? 되돌릴 수 없습니다."
L.RECORD_STATUS_ON = "기록 중 (시작: %s)"
L.RECORD_STATUS_OFF = "기록하지 않음"
L.RECORD_COMBATLOG = "던전에서 전투 기록 저장"
L.RECORD_COMBATLOG_TIP = "우두머리의 능력은 게임의 전투 기록에서 가져옵니다. 도감은 던전에 들어가면 전투 기록을 켜고 나오면 다시 끕니다. 직접 시작한 전투 기록은 그대로 둡니다. 보내려면 Log Reader 페이지에서 내 기록에 로그 파일을 추가하십시오 (복사를 누르면 링크가 나옵니다)."
L.RECORD_RECENT = "최근"
L.RECORD_NOTHING_YET = "아직 기록된 것이 없습니다. 기록을 켜고 던전에 들어가서 평소처럼 몬스터를 처치하고, 전리품을 줍고, 퀘스트를 하십시오."
L.RECORD_STARTED = "기록을 시작했습니다. /aegis record로 중지합니다."
L.RECORD_STOPPED = "기록을 중지했습니다."
L.RECORD_LOG_STARTED = "기록을 시작했습니다."
L.RECORD_LOG_STOPPED = "기록을 중지했습니다."
L.RECORD_LOG_CLEARED = "기록을 지웠습니다."
L.RECORD_LOG_ENTERED = "입장: %s."
L.RECORD_LOG_LEFT = "던전에서 나왔습니다."
L.RECORD_LOG_AREA = "새 지역: %s."
L.RECORD_LOG_PULL = "전투 개시: %s."
L.RECORD_LOG_KILL = "처치: %s."
L.RECORD_LOG_WIPE = "전멸: %s."
L.RECORD_LOG_LOOT = "전리품: 새 아이템 %d개."
L.RECORD_LOG_QUEST_OFFERED = "퀘스트 제공: %s."
L.RECORD_LOG_QUEST_DONE = "퀘스트 완료: %s."
L.RECORD_LOG_ENTRANCE = "%s 입구를 기록했습니다."
L.RECORD_LOG_NO_ENTRANCE = "%s 입구를 기록하지 못했습니다: %s."
L.RECORD_NO_MAP = "로딩 화면이 시작될 때 게임이 지도를 알려주지 않음"
L.RECORD_NO_POSITION = "로딩 화면이 시작될 때 게임이 위치를 알려주지 않음"
L.RECORD_IN_DUNGEON_MAP = "던전 지도에서 로딩 화면이 시작됨"
L.RECORD_LOG_COMBATLOG_ON = "전투 기록 켬: Logs\\%s."
L.RECORD_LOG_COMBATLOG_OFF = "전투 기록 끔."

L.LEVEL_RANGE = "레벨 %d-%d"
L.LEVEL_ALL = "모든 레벨"
L.LEVEL_BRACKET = "레벨 %d~%d"
L.TRASH_DROPS = "일반 몬스터 전리품"
L.UNTESTED = "아직 검증되지 않음"
L.UNTESTED_NOTE = "아직 검증되지 않음: 여기 있는 내용은 블리자드의 발표에서 가져온 것으로, 불완전할 수 있습니다. 기록 탭을 켜고 진행하면 우두머리, 전리품, 입구 정보가 채워집니다."
L.COMING_SOON = "추가 예정"
L.COMING_SOON_TEXT = "아직 월드 오브 워크래프트: 포에버에 열리지 않았습니다. 우두머리, 전리품, 지도는 플레이어들이 진행을 기록하는 대로 추가됩니다. 기록하셨나요? 디스코드에 올려 주시면 도감 기여자 목록에 이름이 실립니다."
L.COMING_SOON_PARTLY = "아직 월드 오브 워크래프트: 포에버에 열리지 않았습니다. 여기 있는 내용은 블리자드의 발표에서 가져온 것입니다. 진행을 기록하셨나요? 디스코드에 올려 주시면 도감 기여자 목록에 이름이 실립니다."
L.DISCORD_COPY_HINT = "클릭한 다음 Ctrl+C"
L.FOREVER_MARK = "월드 오브 워크래프트: 포에버 신규"
L.RECORD_LOG_VENDOR = "%s: 상품 %d개 저장, 도감에 새로 추가된 상품 %d개."
L.RECORD_CAUGHT = "%d개 기록됨, 마지막 복사 이후 신규 %d개"
L.RECORD_COPY = "복사"
L.RECORD_AUTO = "던전에서 자동으로 기록"
L.RECORD_AUTO_TIP = "던전이나 공격대에 들어가면 기록이 저절로 시작되고, 나오면 중지됩니다. 직접 시작한 기록은 자동으로 중지되지 않습니다."
L.RECORD_RECORDER = "기록기"
L.RECORD_SEND = "저희에게 보내 주십시오"
L.RECORD_HELP_TEXT = "복사를 누른 다음 디스코드에 텍스트를 붙여넣으십시오:"
L.RECORD_CREDIT = "기여자 이름:"
L.RECORD_CREDIT_TIP = "도감 기여자 목록에 내 기록이 올라갈 이름입니다. 비워 두면 캐릭터 이름이 사용됩니다."
L.RECORD_CONTRIBUTORS = "기여자"
L.RECORD_CONTRIBUTORS_NONE = "아직 아무도 없습니다. 첫 번째 기여자가 되어 보십시오."
L.RECORD_CONTRIBUTORS_FOOT = "기록을 보내 주시면 여기에 이름이 실립니다."
L.RECORD_COPY_TITLE = "텍스트로 된 내 기록"
L.RECORD_COPY_HINT = "전체가 선택되어 있습니다. Ctrl+C를 누른 다음 디스코드에 붙여넣으십시오."
L.RECORD_COPY_HINT_LOG = "Ctrl+C를 누른 다음 전투 기록 파일(%s, 게임의 Logs 폴더)과 함께 Log Reader에 붙여넣으십시오. 그 결과를 디스코드에 올려 주십시오."
L.RECORD_MORE_LOGS = "%s 외 이전 파일 %d개"
L.RECORD_BACK = "뒤로"
L.RECORD_CAUGHT_TITLE = "기록한 내용"
L.RECORD_ITEM = "아이템 %s"
L.RECORD_ONE_VISIT = "방문 1회"
L.RECORD_VISITS = "방문 %d회"
L.RECORD_ENTRANCE_YES = "입구 기록됨"
L.RECORD_ENTRANCE_NO = "입구 아직 기록 안 됨"
L.RECORD_AREAS = "지역 %d곳"
L.RECORD_KILLED = "처치: %s"
L.RECORD_KILLED_TIMES = "%s (%d)"
L.RECORD_DROPS = "획득: 신규 %s개, 도감에 이미 있음 %s개"
L.RECORD_OFF = "%s에게서 획득"
L.RECORD_OFF_TRASH = "일반 몬스터에게서 획득"
L.RECORD_OFF_GROUP = "파티가 획득"
L.RECORD_OFF_OBJECTS = "상자와 식물에서 획득"
L.RECORD_QUESTS = "퀘스트"
L.RECORD_QUEST_DONE = "완료함"
L.RECORD_NEW = "신규"
L.RECORD_QUARTERMASTERS = "병참장교"
L.RECORD_WARES = "%s: 상품 %d개, 신규 %s개"
L.RECORD_TRAVEL = "이동 지점: %d"
L.FOREVER_LINE = "월드 오브 워크래프트: 포에버에 새로 추가되었습니다."
L.LOCATION_LINE = "위치: %s"

-- The dungeon's round icon at the top of its left page: its tooltip, under the dungeon's name (2026-11-04; drafted, to be checked).
L.INSTANCE_ICON_OVERVIEW = "클릭하면 개요를 봅니다."

L.TAB_OVERVIEW = OVERVIEW or "개요"
L.TAB_LOOT = LOOT_NOUN or "전리품"
L.TAB_ABILITIES = ABILITIES or "능력"
L.TAB_MODEL = MODEL or "모델"
L.TAB_QUESTS = QUESTS_LABEL or "퀘스트"
L.ALL_CLASSES = ALL_CLASSES or "모든 직업"
L.ALL_ARMOR = "모든 방어구"
L.ALL_TYPES = "모든 종류"
-- The loot pages' Type menu: the kinds of item, "All ..." atop the two with a submenu, and one of each.
L.LOOT_KIND = {
	EQUIPMENT = "장비", RECIPE = "제조법", CONSUMABLE = "소비용품", MOUNT = "탈것", PET = "애완동물",
	TOY = "장난감", BAG = "가방", TRADE = "직업용품", QUEST = "퀘스트 아이템", OTHER = "기타",
}
L.LOOT_KIND_ALL = { EQUIPMENT = "모든 장비", RECIPE = "모든 제조법" }
L.LOOT_KIND_ONE = { MOUNT = "탈것", PET = "애완동물", TOY = "장난감" }
L.LOOT_RECIPE = "제조법"
L.LOOT_FAVORITES = "즐겨찾기"
L.LOOT_FAVORITES_ONLY = "즐겨찾기만"
L.LOOT_FAVORITE = "즐겨찾기에 추가"
L.LOOT_UNFAVORITE = "즐겨찾기에서 제거"
L.LOOT_PINNED = "고정됨"
L.LOOT_ALL = "전리품"
L.LOOT_TRASH = "던전 일반 몬스터"
L.DROPS_FROM_BOSS = "획득처: %s (%s)"
L.DROPS_FROM_TRASH = "획득처: 일반 몬스터 (%s)"
L.DROPS_FROM_BOSSES = "획득처: 우두머리 %d명 (%s)"
L.DROPS_IN = "획득처: %s"
L.DROPS_ALSO_IN = "다른 획득처: %s"
-- The world map legend's entries, each a switch (UI/MapLegend.lua).
L.LEGEND_CLICK_HIDE = "클릭하면 지도에서 숨깁니다."
L.LEGEND_CLICK_SHOW = "숨겨져 있습니다. 클릭하면 지도에 다시 표시합니다."
-- The legend's Quest entry, the journal's own switch for its ! marks: what it does (2026-11-06; drafted, to be checked).
L.LEGEND_QUEST_TIP = "도감의 ! 표시: 받을 수 있는 퀘스트와 아직 열리지 않은 회색 퀘스트를 지도에 표시합니다."
L.LEGEND_GAME_FILTER = "지도의 필터 메뉴와 같은, 게임 자체의 지도 필터입니다. 진행 중인 퀘스트와 완료할 수 있는 퀘스트가 필터 하나를 함께 씁니다."
L.LEGEND_GAME_FILTER_MENU = "지도의 필터 메뉴에서 표시하거나 숨깁니다: %s."
-- Before you go, on a dungeon's overview: its key and the quests to it, a hidden boss to prepare for.
L.PREPARE_TITLE = "출발 전에"
L.PREPARE_PROGRESS = "퀘스트 %d개를 완료했습니다 (전체 %d개)."
-- The same for a key with one quest (2026-10-30; drafted, to be checked).
L.PREPARE_PROGRESS_ONE = "퀘스트를 아직 완료하지 않았습니다."
L.PREPARE_HAVE = "이미 가지고 있습니다."
L.PREPARE_QUEST_HINT = "클릭하면 퀘스트 탭에서 봅니다."
-- The Quests tab's dropdown of the dungeon's own quests (after its key, if it has one).
L.QUESTS_DUNGEON = "던전 퀘스트"
-- The same on a raid's Quests tab (2026-10-30; drafted, to be checked).
L.QUESTS_RAID = "공격대 퀘스트"
-- The Quests tab's dropdown of the quests for the player's class alone (2026-11-03; drafted, to be checked).
L.QUESTS_CLASS = "직업 퀘스트"
-- The trash's entry in a dungeon's boss list, and its page.
L.TRASH = "일반 몬스터"
L.TRASH_DESCRIPTION = "던전의 다른 몬스터들이 떨어뜨리는 아이템 중 알아 둘 만한 것입니다: 희귀 및 영웅 장비, 제조법, 퀘스트 아이템."
L.LOOT_BOSS_LINE = BOSS_INFO_STRING or "우두머리: %s"
L.LOOT_FILTER_BAR = "필터: %s"
L.LOOT_RETRIEVING = RETRIEVING_ITEM_INFO or "아이템 정보를 가져오는 중"
L.LOOT_NO_DATA = "아이템 %d"
L.LOOT_NO_DATA_TOOLTIP = "서버가 이 아이템의 정보를 보내지 않았습니다. 아직 게임에 없는 아이템일 수 있습니다."
L.LOOT_UNIDENTIFIED_TOOLTIP = "아직 확인되지 않음: 출처에 이름은 나오지만 아이템 ID는 없습니다. 기록 중에 획득하면 추가됩니다."
L.LOOT_TOOLTIP_PIN = "오른쪽 클릭하면 이 아이템을 목록 맨 위에 고정합니다."
L.LOOT_TOOLTIP_UNPIN = "오른쪽 클릭하면 고정을 해제합니다."
L.LOOT_NONE = "아직 알려진 전리품이 없습니다."
L.LOOT_NO_MATCH = "필터에 맞는 항목이 없습니다. 위의 X를 눌러 필터를 지우십시오."
L.ABILITY_LOADING = RETRIEVING_DATA or "데이터를 가져오는 중..."
L.ABILITIES_NONE = "이 우두머리 전투의 능력이 아직 알려지지 않았습니다. 기록 탭에서 진행을 기록하면 수집됩니다."
L.STATS_HIT = "타격 %s"
L.STATS_TICK = "주기 피해 %s"
L.STATS_FIRST = "첫 시전 %d초"
L.STATS_EVERY = "이후 %s초마다"
L.QUEST_NONE = "이 던전에서 내 진영의 퀘스트가 알려지지 않았습니다."
L.QUEST_STATUS_READY = "완료: 보고할 수 있음"
L.QUEST_STATUS_NEEDS = "필요 조건: %s"
L.QUEST_STATUS_LEVEL = "요구 레벨 %d"
L.QUEST_DESCRIPTION = QUEST_DESCRIPTION or "설명"
L.QUEST_START_ITEM = "시작 아이템:"
-- A count, worded as QUEST_PART_OF words it, so it is not read as one step (2026-11-04; drafted, to be checked).
L.QUEST_PARTS = "%s (총 %d단계)"
-- A row for the quests of one chain that share a name: which of them its page shows (2026-11-04; drafted, to be checked).
L.QUEST_PART_OF = "%d단계 (총 %d단계)"
-- One of them as a row of its own, in a chain: which part it is (2026-11-06; drafted, to be checked).
L.QUEST_PART_NAME = "%s (%d단계)"
-- A step any one of several quests will do (2026-10-30; drafted, to be checked).
L.QUEST_STATUS_NEEDS_VERSION = "필요 조건: %d가지 버전 중 하나 (%s)"
L.QUEST_STATUS_NEEDS_ONE_OF = "필요 조건: 다음 중 하나 - %s"
-- A quest given only while another is in the log (2026-11-03; drafted, to be checked).
L.QUEST_STATUS_NEEDS_IN_LOG = "필요 조건: 퀘스트 목록에 있는 %s"
L.QUEST_OR = " 또는 "
L.QUEST_LIST_COMMA = ", "
L.QUEST_ONE_OF_VERSIONS = "이 퀘스트는 %d가지 버전이 있습니다. 어느 것이든 됩니다."
L.QUEST_ONE_OF_ANY = "이 퀘스트들 중 어느 것이든 됩니다."
L.QUEST_SHOW_START = "시작 지점 보기"
L.QUEST_SHOW_END = "완료 지점 보기"
L.QUEST_PLACE_UNKNOWN = "아직 위치를 모릅니다. 기록 탭을 켠 채로 이 퀘스트를 받거나 완료하면 추가됩니다."
L.QUEST_OFFERED_BY = "퀘스트 제공: %s"
L.QUEST_HAND_IN_TO = "완료 보고: %s"
L.QUESTMAP_DUNGEON_QUEST = "던전 퀘스트: %s"
L.QUESTMAP_RAID_QUEST = "공격대 퀘스트: %s"
L.QUESTMAP_LEFT_CLICK = "왼쪽 클릭하면 도감에서 엽니다"
L.QUESTMAP_WAYPOINT_SET = "지도 핀 설정: %s."
L.QUESTMAP_WAYPOINT_SET_IN = "지도 핀 설정: %s (%s)."
L.WAYPOINT_OFFER = "%s 링크를 클릭하면 지도 핀이 설정됩니다."
L.QUESTMAP_ONE_OF = "항상 같은 곳에 있지 않습니다: %d곳 중 한 곳."
-- What is looted, used or explored for a quest inside a dungeon, on its mark's tooltip, after the game's dash: the
-- item to take, the same for a name with no "the" in English, the thing to use, a place to explore (2026-11-11;
-- translation drafted, to be checked).
L.QUESTMAP_OBJECTIVE_TAKE = "획득: %s"
L.QUESTMAP_OBJECTIVE_TAKE_NAMED = "획득: %s"
L.QUESTMAP_TITLE_QUOTED = "“%s”"
L.QUESTMAP_OBJECTIVE_USE = "사용: %s"
L.QUESTMAP_OBJECTIVE_EXPLORE = "이곳을 탐험하기"
-- A Matrix Punchograph's step, what goes in, then what comes out, in short words ("Yellow > Blue"), and the punch
-- cards' colors, as the cards' own names in the language have them (2026-11-12, the owner's "Blue > Red"; drafted, to
-- be checked); where what goes in drops (2026-11-12; drafted, to be checked).
L.QUESTMAP_OBJECTIVE_STEP = "%s > %s"
L.QUESTMAP_CARD_WHITE = "백색"
L.QUESTMAP_CARD_YELLOW = "황색"
L.QUESTMAP_CARD_BLUE = "청색"
L.QUESTMAP_CARD_RED = "적색"
L.QUESTMAP_CARD_PRISMATIC = "오색"
L.QUESTMAP_NOTE_INPUT_DROPS = "이 터널의 몹이 %s 아이템을 떨어뜨립니다."
-- A machine used again once its quest is done: it takes another of what it cleans (2026-11-12; drafted, to be checked).
L.QUESTMAP_REPEAT_AGAIN = "반복 가능: %s 아이템을 하나 더 넣으세요."
-- What a boss is to a quest, on his tooltip under his quest badge: one to kill, one that drops what the quest needs,
-- the same for a name with no "the" in English, one whose drop starts the quest; who gives or takes it there,
-- himself or by name; a quest's mob more than a boss (2026-11-11; translation drafted, to be checked).
L.QUEST_BADGE_KILL = "이 퀘스트를 위해 처치"
L.QUEST_BADGE_DROPS = "전리품: %s"
L.QUEST_BADGE_DROPS_NAMED = "전리품: %s"
L.QUEST_BADGE_STARTS = "전리품: %s (퀘스트 시작)"
L.QUEST_BADGE_STARTS_NAMED = "전리품: %s (퀘스트 시작)"
L.QUEST_BADGE_GIVES = "이 퀘스트를 줍니다"
L.QUEST_BADGE_GIVES_WHO = "이곳에서 퀘스트를 주는 대상: %s"
L.QUEST_BADGE_TAKES = "이곳에서 완료"
L.QUEST_BADGE_TAKES_WHO = "이곳에서 완료: %s"
L.QUEST_TARGET = "퀘스트 대상"
L.MAP_ONE_OF = "항상 같은 곳에 있지 않습니다: %d곳 중 한 곳."
L.QUEST_REWARDS = REWARDS or "보상"
L.QUEST_YOU_RECEIVE = YOU_RECEIVE or "받게 될 보상:"
L.QUEST_XP = "경험치 %s"
-- XP that is only the original game's number, not yet confirmed on Forever: a note after it, and
-- its tooltip (2026-10-30; drafted, to be checked).
L.QUEST_XP_ORIGINAL = "(원래 게임)"
L.QUEST_XP_ORIGINAL_TIP = "원래 게임에서 이 퀘스트가 주던 값입니다. Forever에서는 더 많이 줄 수도 있습니다. Forever에서는 아직 확인되지 않았습니다. 기록 탭을 켠 채로 이 퀘스트를 완료하면 Forever에서 주는 값이 추가됩니다."
L.QUEST_REPUTATION = "평판 %d (%s)"
L.QUEST_CHOOSE = REWARD_CHOICES or "다음 보상 중 하나를 선택할 수 있습니다:"
L.QUEST_ALSO = REWARD_ITEMS or "다음 보상도 받습니다:"
L.REP_REWARDS = "보상 %d개"
L.REP_REWARD_ONE = "보상 1개"
L.REP_ALL_REWARDS = "보상"
-- The group for wares that need no standing (2026-11-12; drafted, to be checked)
L.REP_ANY_STANDING = "평판 무관"
L.REP_UNKNOWN = "만나지 않음"
L.REP_CARD_CLICK = "클릭하면 보상을 봅니다."
L.REP_YOUR_STANDING = "내 평판: %s"
L.REP_NOT_MET = "아직 이 진영을 만나지 않았습니다."
L.REP_PROGRESS = "%s / %s"
L.REP_QUARTERMASTER = "병참장교: %s"
L.REP_CAPTURE = "상인 기록"
L.REP_CAPTURE_TIP = "평판 병참장교에게 가서 상점을 연 다음 이 버튼을 누르십시오. 판매하는 모든 것이 저장됩니다: 각 상품의 가격, 그 밖의 비용, 필요한 평판. 상품은 곧바로 해당 진영의 보상에 추가되며, 기록 탭에서 복사를 누를 때 함께 들어갑니다."
L.REP_CAPTURE_READY = "상점이 열렸습니다: 상인 기록을 누르십시오."
L.REP_CAPTURE_HINT = "병참장교의 상점을 열면 상품을 기록할 수 있습니다."
L.REP_CAPTURED = "%s: 상품 %d개 (%s), 신규 %d개."
L.REP_CAPTURED_NONE = "%s: 상품 %d개 저장, 평판이 필요한 상품 없음."
L.REP_CAPTURED_UNKNOWN = "%s: 상품 %d개가 게임이 이름을 밝히지 않은 진영의 평판을 요구합니다. 진영 이름이 나오는 상품이 생길 때까지 저장해 둡니다."
L.REP_NOT_CAPTURED = "아직 기록되지 않음"
L.REP_NOT_CAPTURED_TIP = "아직 아무도 이 진영의 병참장교를 기록하지 않았습니다."
L.REP_NOT_CAPTURED_TEXT = "아직 아무도 이 진영의 병참장교를 기록하지 않았습니다. 병참장교를 찾아 상점을 열고 평판 탭에서 상인 기록을 누른 다음, 기록을 디스코드에 올려 주십시오. 도감 기여자 목록에 이름이 실립니다."
L.REP_LISTED_TIP = "이 보상은 게임의 아이템 데이터에서 가져온 것으로, 아직 병참장교에게서 확인되지 않았습니다."
L.REP_LISTED_TEXT = "이 보상들은 병참장교가 아니라 게임의 아이템 데이터에서 가져온 것이라 가격이 없고, 일부는 실제로 판매되지 않을 수도 있습니다. 이 진영의 병참장교를 찾아 상점을 열고 평판 탭에서 상인 기록을 누른 다음, 기록을 디스코드에 올려 주십시오. 도감 기여자 목록에 이름이 실립니다."
L.REP_COMING_SOON_TEXT = "월드 오브 워크래프트: 포에버에 새로 추가되는 진영으로, 아직 기록되지 않았습니다. 게임에 나오면 병참장교를 찾아 상점을 열고 평판 탭에서 상인 기록을 누른 다음, 기록을 디스코드에 올려 주십시오."
L.MAP_SHOW = ENCOUNTER_JOURNAL_SHOW_MAP or "지도 보기"
L.MAP_SHOW_UNEXPLORED = "탐험하지 않은 지역 표시"
L.OPTIONS_UNEXPLORED_TIP = "세계 지도에서 아직 탐험하지 않은 지역 부분을 어둡게 표시합니다."
-- The map legend's switches, in the map's filter menu too (UI/ZoneMap.lua).
L.MAP_FILTER_QUESTS = "받을 수 있는 퀘스트"
L.MAP_FILTER_DUNGEONS = "던전 입구"
L.MAP_FILTER_RAIDS = "공격대 입구"
L.MAP_FILTER_FLIGHT = "비행 지점"
L.MAP_FILTER_CAVES = "동굴 입구"
L.MAP_FILTER_TRANSPORT = "배, 비행선, 지하철, 차원문"
L.MAP_PIN_OPEN = "클릭하면 도감에서 엽니다."
L.MAP_DEFEATED = DUNGEON_ENCOUNTER_DEFEATED or "처치함"
L.MAP_LEVEL = "레벨 %d"
L.MAP_FLOOR = "%d층"
L.MAP_GO_TO = "이동: %s"
L.MAP_YOU_ARE_HERE = "현재 위치"
L.ENTRANCE_DUNGEON = LFG_TYPE_DUNGEON or "던전"
L.ENTRANCE_RAID = LFG_TYPE_RAID or "공격대"
L.ENTRANCE_DUNGEONS = DUNGEONS or "던전"
L.ENTRANCE_RAIDS = RAIDS or "공격대"
L.ENTRANCE_LEFT_CLICK = "왼쪽 클릭하면 던전 도감을 엽니다"
L.ENTRANCE_CHOOSE_LEFT_CLICK = "왼쪽 클릭하면 던전 도감에서 열 곳을 고릅니다"
L.ENTRANCE_RIGHT_CLICK = "오른쪽 클릭하면 지도 핀을 설정합니다"
L.ENTRANCE_WAYPOINT_SET = "%s 입구에 지도 핀을 설정했습니다."
L.ENTRANCE_VIA = "차원문은 아래쪽 %s에 있습니다. 동굴 입구에서 내려가십시오."
L.ENTRANCE_WAYPOINT_VIA = "%s 아래로 내려가는 길에 지도 핀을 설정했습니다. 목적지: %s."
L.CAVE_LABEL = "동굴 입구"
L.BUILDING_LABEL = "입구"
L.ENTRANCE_VIA_BUILDING = "포털은 %s 안에 있습니다. 입구로 들어가세요."
L.CAVE_LEADS_TO = "%s 가는 길"
L.CAVE_LEFT_CLICK = "왼쪽 클릭하면 %s 지도를 봅니다"
L.CAVE_WAYPOINT_SET = "%s 아래로 내려가는 길에 지도 핀을 설정했습니다."
L.FLIGHT_POINT = MAP_LEGEND_FLIGHTPOINT or "비행 지점"
L.CLICK_FOR_WAYPOINT = "클릭하면 지도 핀을 설정합니다"
L.FLIGHT_WAYPOINT_SET = "%s의 비행 조련사에게 지도 핀을 설정했습니다."
L.TRAVEL_KINDS = { boat = "배", zeppelin = "비행선", airship = "비공정", tram = "지하철", portal = "차원문" }
L.TRAVEL_FACTIONS = { Alliance = FACTION_ALLIANCE or "얼라이언스", Horde = FACTION_HORDE or "호드" }
L.TRAVEL_ROUTE = "%s (%s행)"
L.TRAVEL_AND = "%s 및 %s"
L.TRAVEL_ROUTE_NOTE = "%s: %s"
L.TRAVEL_HELP = "부두, 비행선 탑, 지하철 또는 차원문 앞에 서서 /aegis travel boat (또는 zeppelin, airship, tram, portal)를 입력하고 그 뒤에 목적지를 쓰십시오. 예: /aegis travel boat 아우버다인. 끝에 alliance, horde, neutral을 붙이면 어느 진영이 이용하는지 정할 수 있고, 괄호 안에 누가 이용할 수 있는지 메모를 남길 수 있습니다. 예: /aegis travel portal 달라란 (스카이본 전용). /aegis travel list: 저장된 목록을 봅니다. /aegis travel undo: 마지막 항목을 취소합니다."
L.TRAVEL_NO_POSITION = "여기서는 게임이 위치를 알려주지 않아 아무것도 저장하지 않았습니다."
L.TRAVEL_SAVED = "%s 저장함 (위치: %s). /aegis travel undo로 취소할 수 있습니다."
L.TRAVEL_UNDONE = "%s 취소함 (위치: %s)."
L.TRAVEL_NOTHING = "취소할 항목이 없습니다."
L.TRAVEL_LIST_EMPTY = "아직 저장된 이동 지점이 없습니다. 방법을 보려면 /aegis travel을 입력하십시오."
L.TRAVEL_LIST_LINE = "%d. %s - 위치: %s (지도 %d, %.4f, %.4f)"
L.TRAVEL_WAYPOINT_SET = "%s에 지도 핀을 설정했습니다."
L.LEGEND_TRANSPORT = "교통수단"
L.LEGEND_TRANSPORT_TOOLTIP = "배, 비행선, 지하철, 차원문입니다. 파란색은 얼라이언스, 빨간색은 호드, 금색은 모두가 이용합니다."
L.LEGEND_CAVE_TOOLTIP = "던전 입구가 있는 동굴로 들어가는 길입니다. 지도에서 클릭하면 안쪽을 볼 수 있습니다."
L.LEGEND_BUILDING_TOOLTIP = "던전 입구가 있는 건물, 산속 전당 또는 지역 아래층으로 들어가는 길입니다. 지도에서 클릭하면 안쪽을 볼 수 있습니다."
L.SEARCH_SHOW_ALL = SEARCH_RESULTS_SHOW_COUNT or "결과 %d개 모두 보기"
L.SEARCH_RESULTS = ENCOUNTER_JOURNAL_SEARCH_RESULTS or "\"%s\" 검색 결과 (%d)"
L.SEARCH_TYPE_BOSS = "우두머리"
L.SEARCH_TYPE_ABILITY = "능력"
L.SEARCH_TYPE_ITEM = "아이템"
L.SEARCH_TYPE_QUEST = "퀘스트"
L.SEARCH_TYPE_FACTION = FACTION or "진영"
L.MAP_PIN_CLEAR = "클릭하면 이 핀을 제거합니다."
L.MAP_PIN_COMBAT = "전투 중에는 지도를 열 수 없습니다."
L.MAP_PIN_IN_ZONE = "%s: %s 지도에 표시했습니다."
L.MAP_LEVEL_LINK_CLICK = "왼쪽 클릭하면 그 층의 지도를 봅니다"
L.DOOR_SPIRE_ONE_INSTANCE = "검은바위 첨탑 하층과 상층은 입구가 하나인 하나의 인스턴스입니다."
L.DOOR_SPIRE_LOWER = "검은바위 첨탑 하층: 최대 10명이지만, 퀘스트는 5명 이하의 파티로만 완료할 수 있습니다."
L.DOOR_SPIRE_UPPER = "검은바위 첨탑 상층: 더 안쪽, 승천의 인장이 필요한 봉인된 문 너머에 있습니다. 최대 10명."

L.RARE_SUFFIX = " (희귀)"
L.AND_MORE = "외 %d개"
L.BULLET_AREA = "위치: %s."
L.BULLET_RARE = "희귀 몬스터: 매번 나타나지는 않습니다."
L.BULLET_SUMMONED = "직접 소환하는 숨겨진 우두머리입니다. 소환 방법은 위의 메모를 참고하십시오."
-- A quest's mob, on the map only, on his page (2026-11-11; translation drafted, to be checked).
L.BULLET_QUEST_TARGET = "던전의 우두머리가 아닌 퀘스트 대상입니다."
L.BULLET_LEVEL = "레벨 %d 우두머리 전투입니다."
L.BULLET_ABILITIES = "시전 확인: %s."
L.BULLET_LOOT = "아이템 %d개를 떨어뜨립니다. 예: %s."
L.BULLET_ADDS = "함께 등장: %s."
L.ADD_DESCRIPTION = "%s 곁에서 싸웁니다."
L.BULLET_NOTHING_YET = "이 우두머리 전투에 대해 아직 알려진 것이 없습니다."

--[[
	The Korean client's classic "Equip:" wordings ("착용 효과:", taken off before these are tried),
	drafted from the client's wordings as Pawn's Korean tooltip parsing reads them; check against
	items in game. Korean puts the number after the stat ("치명타를 적중시킬 확률이 1%만큼
	증가합니다"), so each pattern names the stat first. First match wins: specific before general.
]]
L.EQUIP_PATTERNS = {
	-- Bonuses against undead or demons only, effects with a chance on being struck or on a hit,
	-- and expertise (not a stat the scoring counts): worth nothing.
	{ "언데드", false },
	{ "악마", false },
	{ "확률로", false },
	{ "회피당하거나", false },
	{ "신성.-극대화.-{n}", "HOLY CRIT" },
	{ "극대화.-{n}", "SPELL CRIT" },
	{ "원거리.-치명타.-{n}", "RANGED CRIT" },
	{ "치명타.-원거리.-{n}", "RANGED CRIT" },
	{ "치명타.-{n}", "CRIT" },
	{ "주문.-적중.-{n}", "SPELL HIT" },
	{ "적중률.-{n}", "HIT" },
	{ "피해.-치유량.-최대%s*{n}", { "SPELL POWER", "HEALING" } },
	{ "공격력.-치유량.-최대%s*{n}", { "SPELL POWER", "HEALING" } },
	{ "효과.-치유량.-최대%s*{n}", "HEALING" },
	{ "신성 계열.-최대%s*{n}", "HOLY DAMAGE" },
	{ "신성 주문.-최대%s*{n}", "HOLY DAMAGE" },
	{ "화염.-최대%s*{n}", "FIRE DAMAGE" },
	{ "냉기.-최대%s*{n}", "FROST DAMAGE" },
	{ "자연.-최대%s*{n}", "NATURE DAMAGE" },
	{ "암흑.-최대%s*{n}", "SHADOW DAMAGE" },
	{ "비전.-최대%s*{n}", "ARCANE DAMAGE" },
	{ "주문.-피해.-최대%s*{n}", "SPELL DAMAGE" },
	{ "주문.-공격력.-최대%s*{n}", "SPELL DAMAGE" },
	{ "시전.-{n}%%.-마나", "CASTING REGEN" },
	{ "시전.-마나.-{n}%%", "CASTING REGEN" },
	{ "마나.-{n}%%.-시전", "CASTING REGEN" },
	{ "{n}%%.-마나.-시전", "CASTING REGEN" },
	{ "대상.-저항력.-{n}", "SPELL PENETRATION" },
	{ "주문 관통.-{n}", "SPELL PENETRATION" },
	{ "전투 시", false },
	{ "싸울 때", false },
	{ "%+{n} 원거리 전투력", "RANGED ATTACK POWER" },
	{ "원거리 전투력.-{n}", "RANGED ATTACK POWER" },
	{ "표범.-전투력.-{n}", "FERAL ATTACK POWER" },
	{ "변신.-전투력.-{n}", "FERAL ATTACK POWER" },
	{ "%+{n} 전투력", "ATTACK POWER" },
	{ "전투력.-{n}", "ATTACK POWER" },
	{ "5초.-{n}%D-마나", "MANA PER 5" },
	{ "5초.-마나.-{n}", "MANA PER 5" },
	{ "5초.-{n}%D-생명력", "HEALTH PER 5" },
	{ "5초.-생명력.-{n}", "HEALTH PER 5" },
	{ "방어 숙련.-{n}", "DEFENSE" },
	{ "회피.-확률.-{n}", "DODGE" },
	{ "무기 막기.-확률.-{n}", "PARRY" },
	{ "방어량.-{n}", "BLOCK VALUE" },
	{ "방패.-확률.-{n}", "BLOCK" },
	{ "공격 속도.-{n}", "HASTE" },
}

-- The rooms inside dungeons, as the client names them where the player stands: "You are
-- here" and a wing's areas match these (Core/Areas.lua). Unconfirmed ones are listed in
-- the translation's to-check list.
L.AREA_NAMES = {
	["Aku'mai's Lair"] = "아쿠마이의 둥지",
	["Anvilmar's Rest"] = "앤빌마의 휴식처",
	["Athenaeum"] = "도서관",
	["Blackrock Stadium"] = "검은바위 투기장",
	["Blackrock Stronghold"] = "검은바위 요새",
	-- City of Dalaran's rooms (Data/Authored/CityOfDalaran.lua's floors: Cantrips & Crows, City of
	-- Dalaran, Dalaran, Magus Commerce Exchange, Path of Renewal, Presage Plaza, Runeweaver Square, Sewer,
	-- The Eventide, The Purple Parlor, The Underbelly, The Violet Citadel, The Violet Hold): the city's
	-- own buildings name them. Most have no area id; Dalaran (279, 16558), City of Dalaran (16544, 16560)
	-- and The Eventide (17824) have, not baked yet: a scan (/aegis areas, Dev/bake_area_ids.py) can
	-- replace those three. By the names the game's Dalaran has in this language, the newest of four
	-- copies of a list of them, to be checked in game (GetSubZoneText there).
	-- Here City of Dalaran reads as Dalaran: both are on the city's floor, and the map reads only the
	-- room's name in there (roomsOnly), so the zone's name, where no room is named, never turns it
	["Cantrips & Crows"] = "마법과 까마귀 선술집",
	["Capital Gardens"] = "수도 정원",
	["Cavern of Mists"] = "안개 동굴",
	["Chamber of Atonement"] = "속죄의 방",
	["Chamber of Battle"] = "전투의 방",
	["Chapel Gardens"] = "예배당 정원",
	["City of Dalaran"] = "달라란",
	["Cleft of Shadow"] = "어둠의 틈",
	["Court of the Highborne"] = "귀족 왕궁",
	["Crag of the Everliving"] = "영생의 바위굴",
	["Crusader's Armory"] = "십자군 무기고",
	["Crusader's Chapel"] = "십자군 예배당",
	["Crusaders' Square"] = "십자군 광장",
	["Dalaran"] = "달라란",
	["Dark Iron Ingress"] = "검은무쇠 침투지",
	["Deeprun Tram"] = "깊은굴 지하철",
	["Defias Hideout"] = "데피아즈단 은신처",
	["Dig One"] = "제1 발굴지",
	["Dragonspire Hall"] = "용첨탑 전당",
	["Dreamer's Rock"] = "꿈꾸는 자의 바위",
	["Elders' Square"] = "장로의 광장",
	["Eldre' Thalas"] = "엘드레탈라스",
	["Eldreth Row"] = "엘드레스 거리",
	["Engineering Labs"] = "기계공학 연구소",
	["Excavation Center"] = "발굴 본부",
	["Festival Lane"] = "축제의 거리",
	["Footman's Armory"] = "보병 무기고",
	["Forgewright's Tomb"] = "대장장이의 무덤",
	["Forlorn Cloister"] = "쓸쓸한 회랑",
	["Gallery of Treasures"] = "보물 전시실",
	["Goblin Foundry"] = "고블린 주물 공장",
	["Gordok Commons"] = "고르독 광장",
	["Hall of Champions"] = "용사의 전당",
	["Hall of the Keepers"] = "수호자의 전당",
	["Halycon's Lair"] = "할리콘의 둥지",
	["Honor's Tomb"] = "명예의 무덤",
	["Hordemar City"] = "호드마르 도시",
	["Huntsman's Cloister"] = "사냥꾼의 회랑",
	["Ironclad Cove"] = "철갑 동굴",
	["Ironforge"] = "아이언포지",
	["King's Alley"] = "왕의 골목",
	["King's Square"] = "왕의 광장",
	["Launch Bay"] = "출격실",
	-- Three rooms of Gnomeregan's way in (Data/Authored/SubMaps.lua), the Loading Room, the Train
	-- Depot and the Workshop Entrance, have no area id, so they are found by these names alone, to be
	-- checked in game (GetSubZoneText there): LibBabble-SubZone's, the same in its root file (rev 237)
	-- and in the file the lib loads (rev 258)
	["Loading Room"] = "선적실",
	["Lordaeron Graveyard"] = "로데론 무덤",
	["Lordamere Overlook"] = "로다미어 전망대",
	["Lost Dig Site"] = "잃어버린 발굴 현장",
	["Lost Marsh"] = "잃어버린 늪",
	["Magus Commerce Exchange"] = "마법사 교역소",
	["Market Row"] = "상가",
	["Market Street"] = "시장 거리",
	["Mast Room"] = "목재 작업장",
	["Mok'Doom"] = "모크둠",
	["Moonshrine Ruins"] = "달의 제단 폐허",
	["Moonshrine Sanctum"] = "달의 제단 성소",
	["Mount Hyjal"] = "하이잘 산",
	["North Common Hall"] = "북쪽 공용 전당",
	["Path of Renewal"] = "소생의 길",
	["Pit of Fangs"] = "송곳니 구덩이",
	["Presage Plaza"] = "예언의 광장",
	["Prison of Immol'thar"] = "이몰타르의 감옥",
	["Reliquary of Kings"] = "왕가의 성물 보관소",
	["Riverglades"] = "강물터",
	["Runeweaver Square"] = "룬위버 광장",
	["Screaming Gully"] = "울부짖는 협곡",
	["Sewer"] = "하수구",
	["Shen'dralas"] = "셴드랄라스",
	["Site of the Guardian"] = "수호자의 터",
	["Skitterweb Tunnels"] = "그물걸이 통로",
	["Slaughter Square"] = "학살의 광장",
	["South Common Hall"] = "남쪽 공용 전당",
	["Stalker's Thicket"] = "추적자의 숲",
	["Tazz'Alaor"] = "타즈알라올",
	["Tazz'Alor"] = "타즈알로",
	-- Gnomeregan's Clean Zone, a room the map follows since 0.39.21 (2026-11-12; drafted, to be checked)
	["The Clean Zone"] = "청정 지역",
	["The Clockwerk Run"] = "태엽장치 통로",
	["The Deadmines"] = "죽음의 폐광",
	["The Dormitory"] = "거주 지구",
	["The Drowned Sacellum"] = "가라앉은 제단",
	["The Eventide"] = "어스름 거리",
	["The Forgotten Pool"] = "잊혀진 웅덩이",
	["The Gauntlet"] = "투쟁의 거리",
	["The Grand Vestibule"] = "대현관",
	["The Grinding Quarry"] = "분쇄 채석장",
	["The Hall of Gears"] = "톱니바퀴의 전당",
	["The Hall of Lights"] = "보물 전시실",
	["The High Seat"] = "왕좌",
	["The Hoard"] = "보병 무기고",
	["The Masonary"] = "석공장",
	["The Molten Span"] = "녹아내린 다리",
	["The Pool of Ask'ar"] = "아스카르 연못",
	["The Purple Parlor"] = "화려한 응접실",
	["The Rookery"] = "부화장",
	["The Scarlet Bastion"] = "붉은십자군 성채",
	["The Sealed Hall"] = "봉인된 전당",
	["The Shrine of Eldretharr"] = "엘드레사르 제단",
	["The Slaughter House"] = "도살장",
	["The Storehouse"] = "창고",
	["The Underbelly"] = "마법의 뒤안길",
	["The Violet Citadel"] = "보랏빛 성채",
	["The Violet Hold"] = "보랏빛 요새",
	["The Wailing Caverns"] = "통곡의 동굴",
	["Tinkers' Court"] = "땜장이 왕실",
	-- Gnomeregan's way in, as the Loading Room above
	["Train Depot"] = "병참 보급창",
	["Training Grounds"] = "훈련장",
	["Warpwood Quarter"] = "굽이나무 지구",
	-- Gnomeregan's way in, as the Loading Room above
	["Workshop Entrance"] = "작업장 입구",
	-- The Temple of Atal'Hakkar's way in (Data/Authored/SubMaps.lua, 2026-10-30): its nine rooms have no area id,
	-- so they are found by these names alone. Pool of Tears, Sorrowmurk and the temple's own name have ids (74,
	-- 1778, 1477): a scan (/aegis areas, Dev/bake_area_ids.py) can replace those three. LibBabble-SubZone's names,
	-- the same in its root file (rev 237) and in the file the lib loads (rev 258). Hall of Faces and Den of
	-- the Unholy are Forever's names. To be checked in game (GetSubZoneText there)
	["Chamber of Blood"] = "피의 집회장",
	["Den of the Caller"] = "소환사의 방",
	["Den of the Unholy"] = "부정의 굴",
	["Hall of Bones"] = "뼈의 전당",
	["Hall of Faces"] = "얼굴의 전당",
	["Hall of Masks"] = "가면의 전당",
	["Hall of Ritual"] = "의식의 전당",
	["Pool of Tears"] = "눈물의 연못",
	["Sorrowmurk"] = "슬픔의 그늘",
	["The Broken Hall"] = "파괴된 전당",
	["The Butchery"] = "도살장",
	["The Temple of Atal'Hakkar"] = "아탈학카르 신전",
}

-- The journal's style: its question at each character's first login, each choice and what it does, and the
-- choice and boxes in the options (2026-11-03; drafted, to be checked).
L.STYLE_TITLE = "도감 방식 선택"
L.STYLE_SUBTITLE = "도감이 게임에 얼마나 더할까요? 언제든 도감 설정에서 바꿀 수 있습니다."
L.STYLE_CLASSIC = "클래식"
L.STYLE_CLASSIC_DESC = "원래 방식에 더 가까운 도감으로, 추가 기능이 적습니다. 우두머리, 전리품, 퀘스트, 던전 지도는 모두 그대로 있습니다."
L.STYLE_MODERN = "모던"
L.STYLE_MODERN_DESC = "지금처럼 도감의 모든 기능: 장비 찾기, 들어가는 길 지도, 세계 지도의 표시."
L.STYLE_CUSTOM = "사용자 설정"
L.STYLE_CUSTOM_DESC = "직접 고릅니다. 이것을 고르면 도감 설정이 열리고, 기능마다 체크 상자가 있습니다."
L.STYLE_STARTING = "시작 설정:"
L.STYLE_LINE_ON = "%s: 켬"
L.STYLE_LINE_OFF = "%s: 끔"
L.STYLE_LINE_CHOOSE = "%s: 직접 선택"
L.STYLE_GEAR = "장비 찾기와 능력치 가중치"
L.STYLE_GEAR_TIP = "장비 찾기 탭, 캐릭터 창의 탭, 아이템 툴팁의 능력치 가중치 줄, 녹색 향상 화살표, Pawn에 넣은 도감의 가중치. 모두 같은 가중치를 쓰므로 함께 켜고 끕니다. 이 캐릭터에만 적용됩니다."
L.STYLE_WAY_IN = "들어가는 길 지도와 동굴"
L.STYLE_WAY_IN_TIP = "세계 지도 위에 던전으로 가는 길의 지도(동굴, 건물, 산의 층)와 그곳으로 가는 동굴과 건물 입구. 던전 자체의 지도는 남습니다. 이 캐릭터에만 적용됩니다."
L.STYLE_MARKERS = "세계 지도 표시"
L.STYLE_MARKERS_TIP = "세계 지도에 있는 도감의 표시: 던전과 공격대 입구, 비행 조련사, 배, 비행선, 지하철과 차원문, 도감의 퀘스트 표시, 지역 레벨, 탐험하지 않은 지역. 이 캐릭터에만 적용됩니다."
L.STYLE_CLICK = "클릭하여 선택"
L.STYLE_NOW = "현재 방식"
L.STYLE_CLOSE_NOTE = "닫으면 %s 방식이 유지됩니다."
L.STYLE_CHOSEN = "도감 방식: %s. 언제든 도감 설정에서 바꿀 수 있습니다 (/aegis options)."
L.STYLE_OPTIONS_AFTER_COMBAT = "전투가 끝나면 도감 설정이 열립니다."
L.STYLE_OPTION = "도감 방식"
L.STYLE_OPTION_TIP = "클래식, 모던 또는 사용자 설정. 이 캐릭터에만 적용됩니다. 아래 기능을 켜거나 끄면 사용자 설정이 됩니다."
-- The Reset button under the style's dropdown, and its question (2026-11-03; drafted, to be checked).
L.STYLE_RESET = "던전 도감 초기화"
L.STYLE_RESET_BUTTON = "초기화"
L.STYLE_CHOOSE_BUTTON = "선택"
L.STYLE_RESET_TIP = "모든 캐릭터의 도감 설정을 설치했을 때로 되돌리고, 이 캐릭터에게 방식을 다시 묻습니다. 기록, 능력치 가중치, 다른 캐릭터의 방식은 그대로 남습니다."
L.STYLE_RESET_CONFIRM = "모든 캐릭터의 도감 설정을 설치했을 때로 되돌리고, 이 캐릭터에게 방식을 다시 물을까요? 기록, 능력치 가중치, 다른 캐릭터의 방식은 그대로 남습니다."
L.STYLE_GEAR_IS_OFF = "장비 찾기가 꺼져 있습니다. 도감 설정에서 켜세요 (/aegis options)."
-- The Record tab's box in the options, and /aegis record while it is off (2026-11-03; drafted, to be checked).
L.OPTIONS_RECORD_TAB = "기록 탭 표시"
L.OPTIONS_RECORD_TAB_TIP = "던전 진행을 기록해 저희에게 보낼 수 있는 탭입니다. 선택하지 않으면: 탭이 숨겨지고 도감이 아무것도 기록하지 않습니다(평판 탭의 상인 기록은 계속 작동합니다). 이미 기록한 내용은 남습니다."
L.RECORD_TAB_IS_OFF = "기록 탭이 꺼져 있습니다. 도감 설정에서 켜세요 (/aegis options)."
L.LEGEND_STYLE_OFF = "도감 설정에서 꺼져 있습니다."

-- The run block (UI/RunTracker.lua, Core/Run.lua), 2026-11-11; drafted, to be checked. The client's own words where it has them.
L.RUN_BOSS_DEFEATED = "%s 처치"
L.RUN_COMPLETE = DUNGEON_COMPLETED or "던전 완료!"
L.RUN_EXPERIENCE = EXPERIENCE_COLON or "경험치:"
L.RUN_MONEY = MONEY_COLON or "돈:"
L.RUN_ITEMS = "아이템:"
L.RUN_PER_HOUR = "시간당 %s"
L.RUN_GREED = (GREED or "차비") .. "로 %d개 획득"
L.RUN_DEFEATED = BOSS_DEAD or "처치함"
L.RUN_NOT_DEFEATED = "아직 처치하지 않음"
L.RUN_PARTS = "%s, 그다음 %s"
L.RUN_COIN = "획득한 돈"
L.RUN_ITEM_VALUE = "아이템 상점 판매가"
L.RUN_PENDING = "가격을 기다리는 아이템 %d개"
L.RUN_DRAG = "제목을 끌어 옮기세요."
L.RUN_SUMMARY = "%s: 우두머리 %d/%d, %s 소요"
L.RUN_SUMMARY_XP = "경험치 %s"
L.RUN_SUMMARY_ITEMS = "아이템 %d개"
L.RUN_NEW = "새 공략을 시작합니다."
L.RUN_NOT_INSIDE = "새 공략을 시작하려면 던전에 들어가세요."
L.RUN_HIDDEN = "이번 공략 동안 공략 창을 숨깁니다. 다시 보려면 /ij run을 입력하세요."
L.RUN_NONE = "아직 던전 공략 기록이 없습니다."
L.RUN_IS_OFF = "던전 공략 추적이 꺼져 있습니다. 도감 설정에서 켜세요 (/aegis options)."
L.RUN_FREE_ON = "공략 창의 제목을 끌어 옮기세요. /ij run lock을 입력하면 퀘스트 추적기 옆으로 돌아갑니다."
L.RUN_FREE_OFF = "공략 창이 퀘스트 추적기 옆으로 돌아갔습니다."
L.RUN_USAGE = "/ij run: 공략 창을 표시하거나 숨깁니다 (던전 밖에서는 마지막 공략). /ij run new: 새 공략을 시작합니다. /ij run unlock: 창을 옮길 수 있습니다. /ij run lock, /ij run reset: 퀘스트 추적기 옆으로 돌려놓습니다. /ij run debug: 집계한 내용을 보여 줍니다."
L.OPTIONS_RUN = "던전 공략 추적"
L.OPTIONS_RUN_TIP = "던전 안에서 퀘스트 추적기 옆의 창에 공략에 걸린 시간, 우두머리, 획득한 것을 보여 줍니다. 끄면 아무것도 집계하지 않습니다."
L.OPTIONS_RUN_NUMBERS = "경험치와 돈 표시"
L.OPTIONS_RUN_NUMBERS_TIP = "경험치와 돈(획득한 돈과 받은 아이템의 상점 판매가)을 각각 시간당 수치와 함께, 그리고 얻은 아이템 수를 보여 줍니다."
L.OPTIONS_RUN_FREE = "자유롭게 배치"
L.OPTIONS_RUN_FREE_TIP = "창의 제목을 끌어 화면 어디에나 둡니다. 끄면 퀘스트 추적기 옆에 붙어 함께 움직입니다."
-- The run block's dark mode: its gold art darkened, else the tracker's tint (UI/RunTracker.lua Paint), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_DARK_MODE = "어두운 모드"
L.OPTIONS_RUN_DARK_MODE_TIP = "공략 창의 머리글과 테두리의 금색을 어둡게 합니다. 끄면 퀘스트 추적기 머리글의 모습을 따르므로, 인터페이스가 머리글을 어둡게 하면 창도 어두워집니다."
L.OPTIONS_RUN_SUMMARY = "채팅에 요약 표시"
L.OPTIONS_RUN_SUMMARY_TIP = "공략 시간이 멈추고 1분 뒤(그 전에 떠나면 바로) 채팅에 한 줄로 보여 줍니다. 끝내지 않고 떠난 공략은 공략이 끝났을 때, 즉 던전이 초기화되거나 밖에서 30분이 지나면 보여 줍니다."
-- The run block inside the quest tracker: an experiment, off by default (UI/RunTrackerInside.lua), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_INSIDE = "퀘스트 추적기 안에 넣기 (실험)"
L.OPTIONS_RUN_INSIDE_TIP = "창이 퀘스트 추적기 안, \"" .. (TRACKER_ALL_OBJECTIVES or "모든 목표") .. "\" 바로 아래로 들어가고, 추적기의 다른 항목(" .. (TRACKER_HEADER_QUESTS or "퀘스트") .. " 등)은 그 아래로 내려갑니다. 편집 모드에서 옮긴 추적기는 거기서 정한 높이만큼만 큽니다. 그 높이가 창을 담기에 너무 짧으면 꺼져 있을 때처럼 추적기 옆에 붙고, 아래 버튼으로 추적기를 더 높게 할 수 있습니다. 시험 기능입니다: 게임이 차단된 동작을 알리면 저절로 꺼집니다. 한 번 사용한 뒤에는 /reload를 해야 완전히 꺼집니다."
L.RUN_INSIDE_BLOCKED = "게임이 도감의 동작을 차단했습니다(%s). 그래서 \"퀘스트 추적기 안에 넣기\"가 꺼졌고 공략 창은 추적기 옆으로 돌아갑니다. 이 줄을 알려 주세요. /reload를 입력하면 추적기에서 완전히 빠집니다."
L.RUN_INSIDE_RELOAD = "\"퀘스트 추적기 안에 넣기\"가 꺼졌고 공략 창은 추적기 옆으로 돌아갑니다. /reload를 입력하면 추적기에서 완전히 빠집니다."
-- The tracker too short for the block inside: the Height it needs, and the options' Make taller button (UI/RunTrackerInside.lua), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_TALLER = "퀘스트 추적기 높이기"
L.OPTIONS_RUN_TALLER_BUTTON = "높이기"
L.OPTIONS_RUN_TALLER_TIP = "\"퀘스트 추적기 안에 넣기\"용: 편집 모드 레이아웃에서 퀘스트 추적기의 높이를 공략 창에 필요한 만큼으로 정하고 레이아웃을 저장합니다. 편집 모드에서 옮긴 추적기에만 해당합니다. 창이 보이는 동안, 전투 중이 아닐 때, 편집 모드를 닫은 상태에서 사용하세요. /reload 후에 보입니다."
L.RUN_INSIDE_SHORT = "공략 창이 퀘스트 추적기 옆에 있습니다: 추적기가 창을 담기에 너무 짧습니다. 더 높게 하려면: %s, \"%s\" 선택, %s %d 이상. 또는 도감 설정(/aegis options)의 \"%s\" 버튼을 사용하세요."
L.RUN_INSIDE_SHORT_TIP = "퀘스트 추적기가 창을 담기에 너무 짧습니다. 더 높게 하려면: %s, \"%s\" 선택, %s %d 이상."
L.RUN_TALLER_COMBAT = ERR_NOT_IN_COMBAT or "전투 중에는 할 수 없습니다."
L.RUN_TALLER_EDIT_MODE = "먼저 %s를 닫으세요."
L.RUN_TALLER_DEFAULT = "퀘스트 추적기가 기본 위치에 있어 화면 아래까지 닿습니다: 정할 높이가 없습니다."
L.RUN_TALLER_UNKNOWN = "공략 창이 보이는 동안(던전 안, 또는 /ij run으로 본 마지막 공략) 사용하세요: 그때 창의 높이를 잽니다."
L.RUN_TALLER_ENOUGH = "퀘스트 추적기가 이미 공략 창에 충분히 높습니다."
L.RUN_TALLER_FAILED = "여기서는 편집 모드 레이아웃을 바꿀 수 없었습니다. 직접 정하세요: %s, \"%s\" 선택, %s %d 이상."
L.RUN_TALLER_DONE = "%s – %s: 이제 %d (편집 모드 레이아웃 \"%s\"). 보려면 지금 /reload를 입력하세요."
L.RUN_TALLER_MOST = "편집 모드가 허용하는 최대치라서, 창이 여전히 들어가지 않을 수 있습니다."

-- Matched against the client's own text: the client's language's only, previewed or not.
if client then client.EQUIP_PATTERNS, client.AREA_NAMES = L.EQUIP_PATTERNS, L.AREA_NAMES end
L.EQUIP_PATTERNS, L.AREA_NAMES = nil, nil
