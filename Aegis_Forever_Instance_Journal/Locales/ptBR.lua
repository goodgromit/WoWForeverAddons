local _, ns = ...

--[[
	The journal's interface in Brazilian Portuguese, for a client set to Brazilian Portuguese.
	Drafted by Claude for review by a native speaker. It is laid over the English table
	(Locales/enUS.lua), so every file that already holds ns.L sees these strings, and anything not
	translated here stays English. Every other client skips it.
]]
-- The journal's words where it speaks this language; the tables matched against the client's own
-- text where the client does, previewed or not (ns.LocaleTargets, Locales/enUS.lua).
local L, client = ns.LocaleTargets("ptBR")
if not L then return end

L.JOURNAL_TITLE = "Diário de Masmorras"
L.HOME = HOME or "Início"
L.TAB_DUNGEONS = DUNGEONS or "Masmorras"
L.TAB_RAIDS = RAIDS or "Raides"
L.TAB_REPUTATION = REPUTATION or "Reputação"

L.BINDING_TOGGLE = "Abrir/fechar o Diário de Masmorras"
L.KEY_CLAIMED = "Shift+J agora abre o Diário de Masmorras."
L.KEY_TAKEN = "Shift+J já está atribuído a %s. Escolha uma tecla em Teclas de Atalho > AddOns > Abrir/fechar o Diário de Masmorras."
L.POSITION_RESET = "Posição da janela redefinida."
L.DOCK_ON = "A janela agora abre no canto superior esquerdo, ao lado das janelas do jogo. Arraste-a para movê-la até que ela feche."
L.DOCK_OFF = "A janela está livre de novo: ela abre onde você a arrastou por último."
L.DOCK_AFTER_COMBAT = "Isso vale quando o combate terminar."
-- Its /aegis style sentence (2026-11-03; drafted, to be checked).
L.SLASH_HELP = "/aegis (ou /ij) abre o diário. /aegis record inicia ou para a gravação. /aegis reset devolve a janela ao lugar padrão. /aegis dock encaixa a janela no canto superior esquerdo, ao lado das janelas do jogo, ou a solta de novo. /aegis perf mede a memória e a velocidade do diário. /aegis where e /aegis taxi informam onde você está e os pontos de voo do seu mapa. /aegis travel salva um barco, zepelim, metrô ou portal para o mapa-múndi. /aegis items procura os itens listados que o servidor não conhece. /aegis gear abre o Localizador de Equipamento, /aegis weights os pesos de atributos dele; /aegis gearscan salva o que ele lê do seu equipamento, para conferir a pontuação. /aegis options abre as opções do diário. /aegis style mostra de novo a pergunta de estilo do diário. /aegis lang mostra o diário em outro dos idiomas dele. /aegis run mostra ou oculta o bloco da incursão (fora de uma masmorra, sua última incursão); /aegis run new começa uma nova incursão. /aegis test abre o modo de teste."
-- /aegis lang (Core/Init.lua)
L.LANG_USAGE = "/aegis lang de, fr, ru, cn, tw, es, mx, pt ou ko mostra o diário em alemão, francês, russo, chinês (simplificado ou tradicional), espanhol (Espanha ou América Latina), português do Brasil ou coreano a partir do seu próximo /reload, para conferir uma tradução; /aegis lang off volta ao idioma do seu cliente. Agora: %s."
L.LANG_SET = "A partir do seu próximo /reload, o diário aparece neste idioma: %s. Só os textos dele mudam: os nomes do jogo continuam os do seu cliente. Digite /reload agora; /aegis lang off desfaz a mudança."
L.LANG_OFF = "A partir do seu próximo /reload, o diário volta ao idioma do seu cliente. Digite /reload agora."
L.LANG_FONTS = "O chinês precisa das fontes de um cliente chinês: no seu, alguns caracteres podem não aparecer."
L.LANG_FONTS_KO = "O coreano precisa das fontes de um cliente coreano: no seu, alguns caracteres podem não aparecer."
L.LANG_ON = "Prévia do diário em outro idioma: %s. /aegis lang off encerra a prévia."
L.LANG_UNAVAILABLE = "Este cliente carregou o diário antes das configurações salvas, então a prévia de idioma não pôde começar."
-- A map addon the owner asked us to warn about, while it is loaded: its name twice (2026-11-12; drafted, to be checked).
L.MAP_ADDON_HIDES = "%s está ativado. Ele cobre o mapa-múndi, então alguns mapas e recursos do diário podem ficar ocultos. Recomendamos desativar o %s."
L.AREAS_START = "Procurando no cliente os IDs dos %d nomes de área do diário..."
L.AREAS_DONE = "IDs encontrados para %d dos %d nomes de área. Digite /reload para salvá-los."
L.AREAS_MISSING = "Não encontrados: %s."
L.AREAS_SCANNING = "Ainda procurando os nomes de área."
L.AREAS_ENGLISH = "Use /aegis areas em um cliente em inglês: os nomes que ele procura estão em inglês."
-- Test mode (UI/TestPanel.lua, UI/TestRun.lua, UI/FogTest.lua): the owner's fog test of 2026-11-13, made test
-- mode on 2026-11-18, for this session only (2026-11-18; drafted, to be checked).
L.FOGTEST_FOG_OFF = "A névoa está desativada neste personagem, então só os marcadores mudam. Para vê-la, ative a névoa de guerra na legenda do mapa ou use o Modo Aventura."
L.FOGTEST_PIN_CLICK = "Modo de teste: clique para marcá-lo como derrotado, ou de pé outra vez."
L.TEST_TITLE = "Modo de teste"
L.TEST_PICK = "Escolha uma masmorra"
L.TEST_NO_MAP = "Esta ainda não tem mapa."
L.TEST_INSIDE = "Fingir que estou dentro"
L.TEST_INSIDE_TIP = "O bloco da incursão mostra esta masmorra como ao entrar: sem mortes, com o relógio esperando o primeiro combate (Reproduzir o inicia). Os chefes que você marcar contam nele como mortes reais. Nada disso é salvo."
L.TEST_INSIDE_RAID = "O bloco da incursão é para masmorras, não para raides."
L.TEST_INSIDE_REAL = "Você está em %s: o bloco da incursão mostra sua incursão real."
L.TEST_TRACKER_COMBAT = "Espere o combate acabar: o bloco da incursão está dentro do rastreador de missões."
L.TEST_WALK_IN = "Entrar"
L.TEST_WALK_IN_TIP = "A incursão do Monastério Escarlate espera na porta até que a primeira sala ou o primeiro combate de uma ala a nomeie. Entrar a nomeia: %s."
L.TEST_FOUND = "Mostrar como descoberta (Aventura)"
L.TEST_FOUND_TIP = "Marcada: o diário trata esta masmorra como descoberta, como se você tivesse entrado. Seus chefes, saque e missões continuam aparecendo só conforme você os descobre, ou quando uma morte de teste os desbloqueia. Desmarcada: como seu personagem a descobriu. Uma morte de teste também a descobre."
L.TEST_FOUND_OFF = "Seu personagem não está no Modo Aventura, então tudo já aparece."
L.TEST_FOUND_REAL = "Seu personagem já a descobriu."
L.TEST_BOSSES = "Chefes"
L.TEST_DEFEATED = "%d de %d derrotados"
L.TEST_TAG_RARE = "raro"
L.TEST_TAG_SUMMONED = "invocado"
L.TEST_TAG_NOT_COUNTED = "não conta"
L.TEST_TAG_MAYBE = "talvez"
L.TEST_TAG_QUEST = "missão"
L.TEST_TAG_OUTSIDE = "fora"
L.TEST_TAG_FINAL = "último"
L.TEST_TIP_RARE = "Raro: nem círculo nem linha no bloco da incursão, e ele não segura névoa."
L.TEST_TIP_SUMMONED = "Invocado: ele não segura névoa."
L.TEST_TIP_NOT_COUNTED = "Não conta: uma linha no bloco da incursão depois de morto, sem círculo."
L.TEST_TIP_MAYBE = "Talvez: só algumas incursões o encontram. Uma linha no bloco da incursão depois de morto, sem círculo."
L.TEST_TIP_QUEST = "Missão: o alvo de uma missão. Uma linha no bloco da incursão depois de morto, sem círculo. Fora do teste, o marcador dele abre a missão."
L.TEST_TIP_OUTSIDE = "Fora: ele fica fora da masmorra, então o bloco da incursão nunca o mostra."
L.TEST_TIP_FINAL = "Último: a morte dele para o relógio da incursão."
L.TEST_END = "Encerrar teste"
L.TEST_ON = "Modo de teste ativado, só nesta sessão: nada é salvo. Encerrar teste ou um /reload o desliga."
L.TEST_OFF = "Modo de teste desativado: tudo está como estava."
L.TEST_RUN_TITLE = "%s (teste)"
L.TEST_RUN_ENDED = "Você entrou em uma masmorra, então a incursão simulada do teste terminou."
L.TEST_STATE_INSIDE = "dentro"
L.TEST_STATE_DOOR = "na porta (qual ala?)"
L.TEST_STATE_OUTSIDE = "fora"
L.TEST_STATE_DEFEATED = "%d/%d derrotados"
L.TEST_STATE_FOG_ON = "névoa ativada"
L.TEST_STATE_FOG_OFF = "névoa desativada"
L.TEST_STATE_NO_FOG = "sem névoa"
L.TEST_STATE_FOUND = "mostrada como descoberta"
L.TEST_STATE_REAL = "como seu personagem"
L.TEST_STATE_KILL_FOUND = "descoberta por morte de teste"
L.TEST_STATE_REAL_INSIDE = "dentro de verdade"
L.TEST_STATE_NOT_ADVENTURE = "fora do Modo Aventura"
L.TEST_STATE_COMBAT = "em combate"
L.TEST_USAGE = "/ij test abre o modo de teste. /ij test off o encerra. /ij test debug mostra o que ele está fazendo."
L.ITEMS_START = "Consultando o servidor sobre os %d itens listados no diário. A resposta chega em cerca de %d segundos; continue jogando à vontade."
L.ITEMS_SCANNING = "Ainda consultando o servidor; a resposta chega em instantes."
L.ITEMS_DONE = "De %d itens, o servidor não conhece %d: provavelmente ainda não estão no Forever. O diário os oculta até que o servidor ou uma gravação os confirme. A lista completa vai para o arquivo salvo no seu próximo /reload ou quando você sair do jogo."
L.ITEMS_LINE = "  Item %d: %s"
L.ITEMS_MORE = "  ...e mais %d."
L.PERF_HEADER = "Desempenho (memória em KB, tempos em milissegundos; menor é melhor):"
L.PERF_MEMORY = "  %s: %.0f KB"
L.PERF_TIME = "  %s: %.2f ms"
L.PERF_BUILD = "Primeira abertura (montando a janela)"
L.PERF_BOOK = "Primeira masmorra aberta (montando o livro)"
L.PERF_OPEN = "Abrir e fechar o diário"
L.PERF_DUNGEON = "Abrir a página de uma masmorra"
L.PERF_TAB = "Mudar para a aba %s"
L.PERF_FACTION = "Abrir a página de uma facção"
L.PERF_LOOT = "Redesenhar uma página de saque"
L.PERF_COMBAT = "A medição espera até você sair de combate."
L.WHERE = "Mapa %s (%s)  x %.4f  y %.4f  área \"%s\"  minimapa \"%s\"  altura %s"
-- /aegis where: what the journal remembers the player as below a city, and its last changes (2026-11-06; drafted, to be checked).
L.WHERE_BELOW = "%s: lembrado %s"
L.WHERE_BELOW_BELOW = "embaixo"
L.WHERE_BELOW_TOP = "no topo"
L.WHERE_BELOW_NOTHING = "nada"
L.WHERE_BELOW_CHANGE = "  %s  %s  mapa %s  área \"%s\"  x %s  y %s:  %s -> %s"
L.WHERE_GAMEPAD = "Interface de controle: controle devolvido ao começar um combate: %d (o último em %s); tarde demais: %d; eventos de restrição de combate recebidos: %d; marcas de pular aguardando: %d"
L.WHERE_FLOOR = "%s: mapa no andar %d (%s), pela área \"%s\""
L.WHERE_FLOOR_KEPT = "%s: mapa no andar %d (%s), mantido: a área \"%s\" não é de nenhum andar"
L.WHERE_FLOOR_HELD = "%s: mapa no andar %d (%s), não segue a área \"%s\": um andar escolhido ou o mapa inteiro"
L.TAXI = "Mapa %s  mostra pontos de voo por conta própria: %s  pontos de voo nele: %d (%d descobertos)  %s"
L.TAXI_ATLASES = "Ícones de viagem: %s"
L.YES = YES or "Sim"
L.NO = NO or "Não"

L.EMPTY_DUNGEONS = "Ainda não há masmorras com entradas no diário."
L.EMPTY_RAIDS = "Ainda não há raides com entradas no diário."
L.EMPTY_REPUTATION = "Nenhuma recompensa de facção conhecida ainda."
L.EMPTY_BRACKET = "Nada nesta faixa de nível."

L.TAB_RECORD = "Gravar"
L.TAB_GEAR = "Localizador de Equipamento"

-- The Gear Finder (Core/GearFinder.lua, UI/GearPanel.lua, UI/CharacterTab.lua).
L.GEAR_TITLE = "Localizador de Equipamento"
L.GEAR_PREVIEW = "Prévia"
L.GEAR_NO_UPGRADE = "Nenhuma melhoria encontrada"
L.GEAR_LOOKING = "Procurando em %d masmorras."
L.GEAR_LOOKING_ONE = "Procurando em 1 masmorra."
L.GEAR_LOADING = "%d itens ainda carregando."
L.GEAR_LOADING_ONE = "1 item ainda carregando."
L.GEAR_SCORING = "Pontuação para"
L.GEAR_AUTO = "Automático: %s"
L.GEAR_WHY_TALENTS = "%s (talentos)"
L.GEAR_WHY_LEVELLING = "%s (subindo de nível)"
L.GEAR_SUGGESTED = "Masmorra sugerida"
L.GEAR_UPGRADES_HERE = "%d melhorias aqui"
L.GEAR_UPGRADE_HERE = "1 melhoria aqui"
L.GEAR_MORE_SLOTS = "e mais %d"
L.GEAR_DUNGEON_OF = "%d de %d"
L.GEAR_NONE = "Nenhuma melhoria nas masmorras perto do seu nível."
L.GEAR_TIP_CLICK = "Clique para ver o saque; Shift+clique para criar um link no bate-papo."
L.GEAR_TIP_CELL_CLICK = "Clique para ver as maiores melhorias; clique com o botão direito para ver o saque."
L.GEAR_TIP_PICK_CLICK = "Clique para mostrá-lo aqui; clique com o botão direito para ver o saque."
L.GEAR_TIP_PICKED = "Sua escolha para este espaço."
L.GEAR_PICK_TOP = "As %d maiores de %d melhorias"
L.GEAR_PICK_ALL = "%d melhorias"
L.GEAR_PICK_ONE = "A única melhoria"
L.GEAR_PICK_BIGGEST = "Maior"
L.GEAR_PICK_YOURS = "Sua escolha"
L.GEAR_PICK_KEPT = "As escolhas ficam salvas para este personagem."
L.GEAR_PICK_CLEAR = "Limpar minha escolha"
L.GEAR_TIP_NONE = "Nenhuma melhoria para este espaço nas masmorras perto do seu nível."
L.GEAR_CHAR_BUTTON = "Localizador de Equipamento"
L.GEAR_CHAR_BUTTON_TIP = "Seus pesos de atributos e as maiores melhorias à sua espera nas masmorras do diário."
L.GEAR_SCAN_DONE = "Leitura do equipamento salva: %d itens equipados e %d itens de masmorras. Saia do jogo ou use /reload para gravá-la no arquivo salvo."
L.GEAR_SCAN_ERRORS = "%d itens não puderam ser lidos; o que deu errado fica salvo com a leitura."
L.GEAR_SCAN_LOADING = "Alguns itens ainda estão carregando: espere alguns segundos e digite /aegis gearscan de novo para obter mais."
L.GEAR_SLOT_FINGER1 = "Dedo 1"
L.GEAR_SLOT_FINGER2 = "Dedo 2"
L.GEAR_SLOT_TRINKET1 = "Berloque 1"
L.GEAR_SLOT_TRINKET2 = "Berloque 2"

-- Stat weights (Core/ItemScore.lua, UI/WeightsEditor.lua).
L.WEIGHTS_TITLE = "Pesos de Atributos"
L.WEIGHTS_EDIT = "Editar pesos de atributos..."
L.WEIGHTS_SOURCE_DEFAULT = "Os pesos do diário"
L.WEIGHTS_SOURCE_LEVELLING = "Os pesos do diário, para subir de nível"
L.WEIGHTS_SOURCE_CUSTOM = "Seus próprios pesos"
L.WEIGHTS_SOURCE_PAWN = "Seus pesos, do Pawn: %s"
L.WEIGHTS_TIP = "Quanto vale um ponto de cada atributo para esta especialização. Clique em um peso para alterá-lo; seus próprios pesos aparecem em verde e ficam salvos para este personagem."
L.WEIGHTS_RESET = "Redefinir"
L.WEIGHTS_RESET_TIP = "Volta aos pesos do diário para esta especialização."
L.WEIGHTS_PAWN = "Pawn..."
-- The Pawn... button's tooltip names WoWSims' Pawn export (2026-11-03; drafted, to be checked).
L.WEIGHTS_PAWN_TIP = "Importar uma escala do Pawn ou colar uma exportação do Pawn feita no WoWSims."
L.WEIGHTS_PAWN_HELP = "No Pawn, escolha a escala, clique em Exportar, copie o texto e cole aqui."
L.WEIGHTS_IMPORT = "Importar"
L.WEIGHTS_CANCEL = "Cancelar"
L.WEIGHTS_BACK = "Voltar"
L.WEIGHTS_OPEN_FINDER = "Abrir o Localizador de Equipamento"
L.WEIGHTS_IMPORTED = "%d pesos importados de %s."
L.WEIGHTS_UNUSED = "Não usados: %s."
L.WEIGHTS_NOT_PAWN = "Isso não é uma escala do Pawn. No Pawn, escolha Exportar e copie o texto inteiro."
L.WEIGHTS_OTHER_CLASS = "Essa escala é da classe %s, não da classe deste personagem."
L.WEIGHTS_FOR = "Para"
-- WoWSims' weights, the Gear Finder's defaults for the specs the sim has, and its Pawn export (2026-11-03; drafted, to be checked).
L.WEIGHTS_SOURCE_SIMS = "Os pesos do WoWSims: %s"
L.WEIGHTS_PAWN_SIMS = "Uma exportação do Pawn feita no WoWSims (wowsims.com/forever) também funciona, com ou sem o Pawn, e pontua como os pesos do WoWSims do diário. Ela não tem pesos para cura, dano por escola, penetração de feitiço, poder de ataque feral, defesa, bloqueio nem resistências."
L.WEIGHTS_NO_STATS = "Essa escala do Pawn não tem pesos que o diário possa usar."
-- The journal's page in the game's options (Options > AddOns).
L.OPTIONS_TITLE = "Aegis Instance Journal"
L.OPTIONS_BOSS_LEVELS = "Mostrar o nível dos chefes"
L.OPTIONS_BOSS_LEVELS_TIP = "Um selo no retrato de cada chefe com o nível dele, colorido conforme a dificuldade do chefe para você: cinza, verde, amarelo, laranja ou vermelho."
L.OPTIONS_ARROWS = "Marcar melhorias com seta verde"
L.OPTIONS_MINIMAP = "Mostrar o botão do minimapa"
L.OPTIONS_PAWN_WEIGHTS = "Usar os pesos do Pawn"
L.OPTIONS_PAWN_WEIGHTS_TIP = "Com o Pawn instalado, as dicas de item e as setas de melhoria dele são as exibidas. Marcado: o Localizador de Equipamento pontua os itens com a sua escala do Pawn para a sua especialização. Desmarcado: o Pawn mostra os pesos do diário para a sua especialização, como uma escala do diário, e as escalas próprias dele ficam ocultas neste personagem até você marcar esta opção."
L.PAWN_ASK = "O Pawn também está instalado. As dicas de item e as setas de melhoria dele serão exibidas.\n\nQuais pesos de atributos o Pawn e o Localizador de Equipamento devem usar?\n\nOs do diário: o Pawn os mostra para a sua especialização e oculta as escalas próprias dele neste personagem.\nOs do Pawn: o Localizador de Equipamento usa as suas escalas do Pawn."
L.PAWN_USE_PAWN = "Os do Pawn"
L.PAWN_USE_JOURNAL = "Os do diário"
L.PAWN_SCALE = "Diário: %s"
L.PAWN_RELOAD = "As setas de melhoria do Pawn nas suas bolsas do Baganator só mudam depois de recarregar a interface: o Baganator guarda as respostas do Pawn até o seu equipamento mudar.\n\nRecarregar agora?"
L.PAWN_RELOAD_NOW = "Recarregar"
L.PAWN_RELOAD_LATER = "Depois"
L.WEIGHTS_SOURCE_PAWN_LIVE = "Escala %s do Pawn. Altere-a no Pawn ou escolha os pesos do diário nas opções do diário."
L.OPTIONS_MINIMAP_TIP = "O botão do diário na borda do minimapa: clique nele para abrir o diário, clique com o botão direito para abrir estas opções e arraste-o para movê-lo."
-- The journal's line in the minimap's addon menu, its box beside the minimap button's (UI/Options.lua; 2026-11-20; drafted, to be checked).
L.OPTIONS_ADDON_MENU = "Mostrar no menu de addons"
L.OPTIONS_ADDON_MENU_TIP = "A linha do diário no menu de addons do minimapa, o botãozinho com um número: clique nela para abrir o diário e clique com o botão direito para abrir estas opções. Desmarcada, ela sai do menu após um /reload."
L.OPTIONS_DOCK = "Fixar no alto à esquerda"
L.OPTIONS_DOCK_TIP = "Marcada: o diário abre no canto superior esquerdo da tela, onde o jogo abre as próprias janelas, e se afasta quando uma delas abre ali, como elas fazem entre si; se não houver espaço para as duas, o jogo fecha a mais antiga. Arraste-o para movê-lo para qualquer lugar: ele volta a se fixar na próxima vez que abrir. Desmarcada: ele abre onde você o arrastou por último."
-- Test mode's button, last on the options' page (UI/Options.lua; 2026-11-18; drafted, to be checked).
L.OPTIONS_TEST = "Modo de teste"
L.OPTIONS_TEST_BUTTON = "Abrir"
L.OPTIONS_TEST_TIP = "Veja o mapa, a névoa e o bloco da incursão de qualquer masmorra sem entrar: escolha uma masmorra, marque chefes como derrotados, finja que está dentro. Só nesta sessão: nada é salvo, e um /reload o encerra."
L.OPTIONS_DUNGEON_FOG = "Névoa nos mapas de masmorra"
L.OPTIONS_DUNGEON_FOG_TIP = "Os mapas de masmorras começam sob névoa, só com a entrada visível. Cada chefe que seu grupo derrota revela as salas dele e o caminho de volta, e o último revela o mapa inteiro; o que foi revelado continua visível. A névoa fica sempre ativa no Modo Aventura. Só para este personagem."
-- Adventure Mode's news: the chat line for new finds, the minimap button's line while it glows, and their two
-- boxes in the options (2026-11-11; translation drafted, to be checked).
L.ADVENTURE_NEWS = "Novo no seu diário: %s"
L.MINIMAP_NEWS = "Há algo novo no seu diário."
L.OPTIONS_ADVENTURE_CHAT = "Descobertas no bate-papo"
L.OPTIONS_ADVENTURE_CHAT_TIP = "No Modo Aventura, uma linha no bate-papo quando você encontra algo novo para o diário: uma masmorra, um chefe, saque, uma missão, uma facção ou uma rota de voo. Clique em um nome para abrir a página dele (uma rota de voo não tem). Para todos os seus personagens."
L.OPTIONS_ADVENTURE_GLOW = "Brilho do botão do minimapa"
L.OPTIONS_ADVENTURE_GLOW_TIP = "No Modo Aventura, o botão do minimapa brilha quando você encontrou algo novo desde a última vez que abriu o diário, até você abri-lo. Para todos os seus personagens."
L.MINIMAP_LEFT_CLICK = "Clique para abrir ou fechar o diário."
L.MINIMAP_RIGHT_CLICK = "Clique com o botão direito para ver as opções."
L.MINIMAP_DRAG = "Arraste para movê-lo pela borda do minimapa."
L.OPTIONS_ARROWS_TIP = "Uma seta verde nos itens que são melhorias para a sua especialização, segundo o Localizador de Equipamento: nas suas bolsas, na janela de saque e nas rolagens de saque."
L.WEIGHTS_SHOW_GAINS = "Mostrar pesos nas dicas"
L.WEIGHTS_SHOW_GAINS_TIP = "Abaixo de cada item, uma linha para cada uma das suas especializações: quanto o item vale segundo os pesos dela e, quando ele é uma melhoria, uma seta verde com o que ele acrescenta ao seu equipamento. Para todos os seus personagens com o Localizador de Equipamento ligado. Com o Pawn instalado, isto mostra ou oculta, em vez disso, a escala do diário no Pawn e, com ela, as setas de melhoria do Pawn para os pesos do diário: o Pawn só marca melhorias para as escalas que exibe."
L.OPTIONS_SOURCES = "Mostrar a origem dos itens"
L.OPTIONS_SOURCES_TIP = "Abaixo de cada item obtido nas masmorras e raides do diário, uma linha com o chefe e a masmorra: nas suas bolsas, no seu personagem, nos links do bate-papo, nos vendedores e em qualquer outro lugar onde o jogo mostre o item. Para todos os seus personagens."
L.GEAR_WHY_CUSTOM = "%s (seus pesos)"
-- The specs' names (the classic talent trees) and the units their weights count in, by spec key
-- and by the English unit.
L.GEAR_SPEC_NAMES = {
	Arms = "Armas", Fury = "Fúria", Protection = "Proteção", Holy = "Sagrado", Retribution = "Retribuição",
	BeastMastery = "Domínio das Feras", Marksmanship = "Precisão", Survival = "Sobrevivência",
	Assassination = "Assassinato", Combat = "Combate", Subtlety = "Subterfúgio", Discipline = "Disciplina", Shadow = "Sombra",
	Elemental = "Elemental", Enhancement = "Aperfeiçoamento", EnhancementTank = "Aperfeiçoamento (tanque)",
	Restoration = "Restauração", Arcane = "Arcano", Fire = "Fogo", Frost = "Gélido", Affliction = "Suplício",
	Demonology = "Demonologia", Destruction = "Destruição", Balance = "Equilíbrio", FeralBear = "Combate Feral (urso)",
	FeralCat = "Combate Feral (felino)",
}
L.GEAR_UNITS = {
	["attack power"] = "poder de ataque", ["ranged attack power"] = "poder de ataque de longo alcance",
	["spell damage"] = "dano mágico", healing = "cura", Stamina = "Vigor",
}
L.WEIGHT_GROUPS = {
	PRIMARY = "Atributos Primários", WEAPONS = "Armas", SPELLS = "Feitiços", DEFENSE = "Defesa",
	RESISTANCE = "Resistências",
}
L.STAT_NAMES = {
	STRENGTH = "Força", AGILITY = "Agilidade", STAMINA = "Vigor", INTELLECT = "Intelecto", SPIRIT = "Espírito",
	DPS = "DPS da Arma", ["RANGED DPS"] = "DPS da Arma de Longo Alcance", ["ATTACK POWER"] = "Poder de Ataque",
	["RANGED ATTACK POWER"] = "Poder de Ataque de Longo Alcance", ["FERAL ATTACK POWER"] = "Poder de Ataque Feral", HIT = "Acerto",
	CRIT = "Acerto Crítico", ["RANGED CRIT"] = "Crítico de Longo Alcance", HASTE = "Velocidade de Ataque", ["RANGED HASTE"] = "Velocidade de Longo Alcance",
	["SPELL POWER"] = "Dano e Cura", ["SPELL DAMAGE"] = "Dano Mágico", HEALING = "Cura", ["SPELL HIT"] = "Acerto de Feitiço",
	["SPELL CRIT"] = "Crítico de Feitiço", ["HOLY CRIT"] = "Crítico Sagrado", ["HOLY DAMAGE"] = "Dano Sagrado",
	["FIRE DAMAGE"] = "Dano de Fogo", ["FROST DAMAGE"] = "Dano de Gelo", ["NATURE DAMAGE"] = "Dano de Natureza",
	["SHADOW DAMAGE"] = "Dano de Sombra", ["ARCANE DAMAGE"] = "Dano Arcano", ["SPELL PENETRATION"] = "Penetração de Feitiço",
	MANA = "Mana", ["MANA PER 5"] = "Mana a cada 5 s", ["CASTING REGEN"] = "Regeneração ao Lançar Feitiços",
	ARMOR = "Armadura", HEALTH = "Vida", ["HEALTH PER 5"] = "Vida a cada 5 s", DEFENSE = "Defesa", DODGE = "Esquiva",
	PARRY = "Aparo", BLOCK = "Bloqueio", ["BLOCK VALUE"] = "Valor de Bloqueio",
	["HOLY RESISTANCE"] = "Resistência a Sagrado", ["FIRE RESISTANCE"] = "Resistência a Fogo",
	["NATURE RESISTANCE"] = "Resistência a Natureza", ["FROST RESISTANCE"] = "Resistência a Gelo",
	["SHADOW RESISTANCE"] = "Resistência a Sombra", ["ARCANE RESISTANCE"] = "Resistência a Arcano",
}
L.RECORD_START = "Iniciar gravação"
L.RECORD_STOP = "Parar gravação"
L.RECORD_CLEAR = "Limpar"
L.RECORD_CLEAR_CONFIRM = "Descartar tudo o que foi gravado até agora? Não é possível desfazer."
L.RECORD_STATUS_ON = "Gravando desde %s"
L.RECORD_STATUS_OFF = "Sem gravação"
L.RECORD_COMBATLOG = "Gravar o registro de combate nas masmorras"
L.RECORD_COMBATLOG_TIP = "As habilidades dos chefes vêm do registro de combate do jogo. O diário o liga dentro das masmorras e o desliga de novo na saída; um registro que você mesmo iniciou não é alterado. Para enviá-lo, adicione o arquivo de registro à sua gravação na página do Log Reader (Copiar mostra o link)."
L.RECORD_RECENT = "Recentes"
L.RECORD_NOTHING_YET = "Nada capturado ainda. Entre em uma masmorra com a gravação ligada e mate, saqueie e faça missões como sempre."
L.RECORD_STARTED = "Gravação iniciada. /aegis record a interrompe."
L.RECORD_STOPPED = "Gravação interrompida."
L.RECORD_LOG_STARTED = "Gravação iniciada."
L.RECORD_LOG_STOPPED = "Gravação interrompida."
L.RECORD_LOG_CLEARED = "Gravações apagadas."
L.RECORD_LOG_ENTERED = "Você entrou em %s."
L.RECORD_LOG_LEFT = "Você saiu da masmorra."
L.RECORD_LOG_AREA = "Nova área: %s."
L.RECORD_LOG_PULL = "Combate iniciado contra %s."
L.RECORD_LOG_KILL = "Você derrotou %s."
L.RECORD_LOG_WIPE = "Grupo derrotado por %s."
L.RECORD_LOG_LOOT = "Saque: %d item(ns) novo(s)."
L.RECORD_LOG_QUEST_OFFERED = "Missão oferecida: %s."
L.RECORD_LOG_QUEST_DONE = "Missão entregue: %s."
L.RECORD_LOG_ENTRANCE = "Entrada de %s gravada."
L.RECORD_LOG_NO_ENTRANCE = "Entrada de %s não gravada: %s."
L.RECORD_NO_MAP = "o jogo não informou nenhum mapa quando a tela de carregamento começou"
L.RECORD_NO_POSITION = "o jogo não informou nenhuma posição quando a tela de carregamento começou"
L.RECORD_IN_DUNGEON_MAP = "a tela de carregamento começou no mapa de uma masmorra"
L.RECORD_LOG_COMBATLOG_ON = "Registro de combate ligado: Logs\\%s."
L.RECORD_LOG_COMBATLOG_OFF = "Registro de combate desligado."

L.LEVEL_RANGE = "Nível %d-%d"
L.LEVEL_ALL = "Todos os Níveis"
L.LEVEL_BRACKET = "Nível %d a %d"
L.TRASH_DROPS = "Saque de inimigos comuns"
L.UNTESTED = "Ainda não testado"
L.UNTESTED_NOTE = "Ainda não testada: o que está aqui vem do anúncio da Blizzard e pode estar incompleto. Percorra-a com a gravação ligada (aba Gravar) para completar os chefes, o saque e a entrada."
L.COMING_SOON = "Em breve"
L.COMING_SOON_TEXT = "Ainda não está aberta no WoW: Forever. Os chefes, o saque e o mapa chegam conforme os jogadores gravam suas incursões. Gravou uma? Publique no nosso Discord, e o seu nome entra para os colaboradores do diário."
L.COMING_SOON_PARTLY = "Ainda não está aberta no WoW: Forever: o que está aqui vem do anúncio da Blizzard. Gravou uma incursão? Publique no nosso Discord, e o seu nome entra para os colaboradores do diário."
L.DISCORD_COPY_HINT = "Clique e depois Ctrl+C"
L.FOREVER_MARK = "Novo no WoW: Forever"
L.RECORD_LOG_VENDOR = "%s: %d itens à venda salvos, %d novos no diário."
L.RECORD_CAUGHT = "%d capturados, %d novos desde a sua última cópia"
L.RECORD_COPY = "Copiar"
L.RECORD_AUTO = "Gravar automaticamente nas masmorras"
L.RECORD_AUTO_TIP = "A gravação começa sozinha quando você entra em uma masmorra ou raide e para quando você sai. Uma gravação que você mesmo iniciou nunca é interrompida automaticamente."
L.RECORD_RECORDER = "Gravador"
L.RECORD_SEND = "Envie para nós"
L.RECORD_HELP_TEXT = "Clique em Copiar e cole o texto no nosso Discord:"
L.RECORD_CREDIT = "Meu nome nos créditos:"
L.RECORD_CREDIT_TIP = "O nome com que as suas gravações aparecem entre os colaboradores do diário. Se ficar vazio, será o nome do seu personagem."
L.RECORD_CONTRIBUTORS = "Colaboradores"
L.RECORD_CONTRIBUTORS_NONE = "Ninguém ainda: seja o primeiro."
L.RECORD_CONTRIBUTORS_FOOT = "Envie a sua gravação: o seu nome aparece aqui."
L.RECORD_COPY_TITLE = "Sua gravação, em texto"
L.RECORD_COPY_HINT = "Já está tudo selecionado: pressione Ctrl+C e cole no nosso Discord."
L.RECORD_COPY_HINT_LOG = "Pressione Ctrl+C e cole no Log Reader junto com o seu registro de combate (%s, na pasta Logs do jogo). Publique o resultado no nosso Discord."
L.RECORD_MORE_LOGS = "%s e %d mais antigos"
L.RECORD_BACK = "Voltar"
L.RECORD_CAUGHT_TITLE = "O que você capturou"
L.RECORD_ITEM = "Item %s"
L.RECORD_ONE_VISIT = "1 visita"
L.RECORD_VISITS = "%d visitas"
L.RECORD_ENTRANCE_YES = "entrada gravada"
L.RECORD_ENTRANCE_NO = "entrada ainda não gravada"
L.RECORD_AREAS = "%d áreas"
L.RECORD_KILLED = "Derrotados: %s"
L.RECORD_KILLED_TIMES = "%s (%d)"
L.RECORD_DROPS = "Saque: %s novos, %s já no diário"
L.RECORD_OFF = "De %s"
L.RECORD_OFF_TRASH = "De inimigos comuns"
L.RECORD_OFF_GROUP = "Saqueado pelo seu grupo"
L.RECORD_OFF_OBJECTS = "De baús e plantas"
L.RECORD_QUESTS = "Missões"
L.RECORD_QUEST_DONE = "entregue"
L.RECORD_NEW = "nova"
L.RECORD_QUARTERMASTERS = "Intendentes"
L.RECORD_WARES = "%s: %d itens à venda, %s novos"
L.RECORD_TRAVEL = "Pontos de viagem: %d"
L.RECORD_MODELS = "Modelos: %d"
L.FOREVER_LINE = "Novo no WoW: Forever."
L.LOCATION_LINE = "Localização: %s"

-- The dungeon's round icon at the top of its left page: its tooltip, under the dungeon's name (2026-11-04; drafted, to be checked).
L.INSTANCE_ICON_OVERVIEW = "Clique para ver a visão geral."

L.TAB_OVERVIEW = OVERVIEW or "Visão Geral"
L.TAB_LOOT = LOOT_NOUN or "Saque"
L.TAB_ABILITIES = ABILITIES or "Habilidades"
L.TAB_MODEL = MODEL or "Modelo"
L.TAB_QUESTS = QUESTS_LABEL or "Missões"
L.ALL_CLASSES = ALL_CLASSES or "Todas as Classes"
L.ALL_ARMOR = "Todas as Armaduras"
L.ALL_TYPES = "Todos os Tipos"
-- The loot pages' Type menu: the kinds of item, "All ..." atop the two with a submenu, and one of each.
L.LOOT_KIND = {
	EQUIPMENT = "Equipamento", RECIPE = "Receitas", CONSUMABLE = "Consumíveis", MOUNT = "Montarias", PET = "Mascotes",
	TOY = "Brinquedos", BAG = "Bolsas", TRADE = "Mercadorias", QUEST = "Itens de Missão", OTHER = "Outros",
}
L.LOOT_KIND_ALL = { EQUIPMENT = "Todo o Equipamento", RECIPE = "Todas as Receitas" }
L.LOOT_KIND_ONE = { MOUNT = "Montaria", PET = "Mascote", TOY = "Brinquedo" }
L.LOOT_RECIPE = "Receita"
-- A loot row's type where the client cannot describe the item (2026-11-19; drafted, to be checked). Junk: the
-- Brazilian client's own word for it may be "Sucata" rather than "Lixo"; to be checked against it.
L.LOOT_QUEST_ITEM = "Item de Missão"
L.LOOT_WORDS = {
	Alchemy = "Alquimia", Blacksmithing = "Ferraria", Cooking = "Culinária", Enchanting = "Encantamento",
	Engineering = "Engenharia", ["First Aid"] = "Primeiros Socorros", Fishing = "Pesca", Leatherworking = "Couraria",
	Tailoring = "Alfaiataria", Book = "Livro", Blueprint = "Projeto", Bag = "Bolsa", ["Ammo Pouch"] = "Algibeira",
	Quiver = "Aljava", Arrow = "Flecha", Bullet = "Bala", Consumable = "Consumível",
	["Food & Drink"] = "Comidas e Bebidas", Potions = "Poções", Junk = "Lixo", Key = "Chave", Other = "Outro",
	Parts = "Peças", Reagent = "Reagente", Weapon = "Arma", Cloth = "Tecido", Leather = "Couro", Mail = "Malha",
	Plate = "Placas", Shield = "Escudo", Idol = "Ídolo", Libram = "Tomo", Totem = "Totem", Axe = "Machado",
	Bow = "Arco", Crossbow = "Besta", Dagger = "Adaga", ["Fist Weapon"] = "Arma de Punho", Gun = "Arma de Fogo",
	Mace = "Maça", Polearm = "Arma de Haste", Staff = "Bordão", Sword = "Espada", Wand = "Varinha",
}
L.LOOT_FAVORITES = "Favoritos"
L.LOOT_FAVORITES_ONLY = "Só favoritos"
L.LOOT_FAVORITE = "Adicionar aos favoritos"
L.LOOT_UNFAVORITE = "Remover dos favoritos"
L.LOOT_PINNED = "Fixado"
L.LOOT_ALL = "Saque"
L.LOOT_TRASH = "Inimigos comuns da masmorra"
L.LOOT_BOSSES_AND_RARES = "Qualquer chefe ou inimigo raro"
L.LOOT_BOSSES_AND_RARES_NOTE = "Saque dos chefes e inimigos raros da masmorra, não dos inimigos comuns."
-- A Recipes page's row the bosses drop, and a row not seen dropping yet (2026-11-20; drafted, to be checked).
L.LOOT_ANY_BOSS = "Qualquer chefe"
L.LOOT_ANY_BOSS_NOTE = "Saque dos chefes da masmorra, não dos inimigos comuns."
L.LOOT_NOT_SEEN_NOTE = "Ainda não visto como saque."
L.DROPS_FROM_BOSS = "Saque: %s (%s)"
L.DROPS_FROM_TRASH = "Saque: inimigos comuns (%s)"
L.DROPS_FROM_BOSSES = "Saque: %d chefes (%s)"
L.DROPS_FROM_BOSSES_AND_RARES = "Saque: chefes e inimigos raros (%s)"
L.DROPS_FROM_ANY_BOSS = "Saque: chefes (%s)"
L.DROPS_IN = "Saque em: %s"
L.DROPS_ALSO_IN = "Saque também em: %s"
L.LEGEND_CLICK_HIDE = "Clique para ocultá-los no mapa."
L.LEGEND_CLICK_SHOW = "Ocultos. Clique para mostrá-los no mapa de novo."
-- The legend's Quest entry, the journal's own switch for its ! marks: what it does (2026-11-06; drafted, to be checked).
L.LEGEND_QUEST_TIP = "As marcas ! do diário nos mapas: missões que você pode pegar e, em cinza, as que ainda não estão abertas."
L.LEGEND_GAME_FILTER = "O filtro do próprio jogo, como no menu de filtros do mapa: missões em andamento e prontas para entregar compartilham o mesmo."
L.LEGEND_GAME_FILTER_MENU = "Mostrados ou ocultados pelo menu de filtros do mapa: %s."
L.PREPARE_TITLE = "Antes de ir"
L.PREPARE_PROGRESS = "Você concluiu %d de %d missões."
-- The same for a key with one quest (2026-10-30; drafted, to be checked).
L.PREPARE_PROGRESS_ONE = "Você ainda não concluiu a missão."
L.PREPARE_HAVE = "Você já tem."
-- A chain of quests done, Before you go (2026-11-12; drafted, to be checked).
L.PREPARE_CHAIN_DONE = "Você já concluiu as missões."
-- Before you go's line on a dungeon's overview, pointing to the Quests tab (2026-11-13; drafted, to be checked).
L.PREPARE_POINTER = "Antes de ir: %d notas, na aba Missões."
L.PREPARE_POINTER_ONE = "Antes de ir: 1 nota, na aba Missões."
-- The Play button beside the lore, which plays Spoken's recorded story; "Spoken" kept as it is (2026-11-13; drafted, to be checked).
L.SPOKEN_PLAY = "Reproduzir a história"
L.SPOKEN_REPLAY = "Reproduzir a história de novo"
L.SPOKEN_STOP = "Parar"
L.SPOKEN_BY = "Lida em voz alta pelo Spoken."
L.SPOKEN_REQUIRES = "Requer Spoken"
L.SPOKEN_ABOUT_PLACE = "Lê em voz alta a história deste lugar."
L.SPOKEN_ABOUT_BOSS = "Lê em voz alta a história deste chefe."
L.SPOKEN_NO_STORY_PLACE = "O Spoken não tem uma história gravada deste lugar."
L.SPOKEN_NO_STORY_BOSS = "O Spoken não tem uma história gravada deste chefe."
-- Spoken's own story API says no, the reason not known (2026-11-14; drafted, to be checked).
L.SPOKEN_NO_STORY_YET = "O Spoken ainda não tem uma história que possa reproduzir aqui."
L.SPOKEN_NEEDS_BOSS_VOICES = "Precisa das vozes de chefes do Spoken, que não estão instaladas."
L.SPOKEN_NEEDS_PLACE_VOICES = "Precisa das vozes de lugares do Spoken, que não estão instaladas."
L.SPOKEN_OFF = "Desativado nas configurações do Spoken."
L.SPOKEN_LOCKED_PLACE = "O Spoken conta esta história depois que você encontrar este lugar."
L.SPOKEN_LOCKED_BOSS = "O Spoken conta esta história depois que você encontrar este chefe."
L.QUESTS_DUNGEON = "Missões da Masmorra"
-- The same on a raid's Quests tab (2026-10-30; drafted, to be checked).
L.QUESTS_RAID = "Missões da Raide"
-- The Quests tab's dropdown of the quests for the player's class alone (2026-11-03; drafted, to be checked).
L.QUESTS_CLASS = "Missões de Classe"
L.TRASH = "Inimigos comuns"
L.TRASH_DESCRIPTION = "O que as outras criaturas da masmorra deixam cair que vale a pena conhecer: equipamentos raros e épicos, receitas e itens de missão."
-- The recipes' entry in a dungeon's boss list, and its page (drafted, to be checked).
L.RECIPES = "Receitas"
L.RECIPES_DESCRIPTION = "As receitas de profissão que os chefes e as outras criaturas da masmorra deixam cair. A receita própria de um chefe também aparece na página desse chefe."
L.LOOT_BOSS_LINE = BOSS_INFO_STRING or "Chefe: %s"
L.LOOT_FILTER_BAR = "Filtro: %s"
L.LOOT_RETRIEVING = RETRIEVING_ITEM_INFO or "Obtendo informações do item"
L.LOOT_NO_DATA = "Item %d"
L.LOOT_NO_DATA_TOOLTIP = "O servidor não enviou os detalhes deste item. Talvez ele ainda não esteja no jogo."
L.LOOT_UNIDENTIFIED_TOOLTIP = "Ainda não identificado: a fonte o cita, mas não informa o ID do item. Saqueie-o durante uma gravação para adicioná-lo."
L.LOOT_TOOLTIP_PIN = "Clique com o botão direito para fixar este item no topo da lista."
L.LOOT_TOOLTIP_UNPIN = "Clique com o botão direito para desafixar."
L.LOOT_NONE = "Nenhum saque conhecido para isto ainda."
L.LOOT_NO_MATCH = "Nada aqui corresponde aos filtros. Limpe-os com o X acima."
L.ABILITY_LOADING = RETRIEVING_DATA or "Obtendo dados..."
L.ABILITIES_NONE = "Nenhuma habilidade conhecida para este encontro ainda. Grave uma incursão pela aba Gravar para capturá-las."
L.STATS_HIT = "Causa %s"
L.STATS_TICK = "pulsos de %s"
L.STATS_FIRST = "primeiro lançamento aos %d s"
L.STATS_EVERY = "depois a cada %s s"
L.QUEST_NONE = "Nenhuma missão conhecida para a sua facção nesta masmorra."
L.QUEST_STATUS_READY = "Concluída: pronta para entregar"
L.QUEST_STATUS_NEEDS = "Requer: %s"
L.QUEST_STATUS_LEVEL = "Requer nível %d"
L.QUEST_DESCRIPTION = QUEST_DESCRIPTION or "Descrição"
L.QUEST_START_ITEM = "Começa com:"
L.QUEST_PARTS = "%s (%d partes)"
-- A row for the quests of one chain that share a name: which of them its page shows (2026-11-04; drafted, to be checked).
L.QUEST_PART_OF = "Parte %d de %d"
-- One of them as a row of its own, in a chain: which part it is (2026-11-06; drafted, to be checked).
L.QUEST_PART_NAME = "%s (Parte %d)"
-- A step any one of several quests will do (2026-10-30; drafted, to be checked).
L.QUEST_STATUS_NEEDS_VERSION = "Requer uma das %d versões de %s"
L.QUEST_STATUS_NEEDS_ONE_OF = "Requer uma destas: %s"
-- A quest given only while another is in the log (2026-11-03; drafted, to be checked).
L.QUEST_STATUS_NEEDS_IN_LOG = "Requer: %s no seu registro de missões"
L.QUEST_OR = " ou "
L.QUEST_LIST_COMMA = ", "
L.QUEST_ONE_OF_VERSIONS = "Esta missão tem %d versões. Qualquer uma delas serve."
L.QUEST_ONE_OF_ANY = "Qualquer uma destas missões serve."
L.QUEST_SHOW_START = "Mostrar início"
L.QUEST_SHOW_END = "Mostrar fim"
L.QUEST_PLACE_UNKNOWN = "Local ainda desconhecido. Aceite ou entregue esta missão com a aba Gravar ativa para adicioná-lo."
L.QUEST_OFFERED_BY = "Missão oferecida por %s"
L.QUEST_HAND_IN_TO = "Entregar a %s"
L.QUESTMAP_DUNGEON_QUEST = "Missão de masmorra: %s"
L.QUESTMAP_RAID_QUEST = "Missão de raide: %s"
L.QUESTMAP_LEFT_CLICK = "Clique com o botão esquerdo para abri-la no diário"
L.QUESTMAP_WAYPOINT_SET = "Marcador no mapa definido para %s."
L.QUESTMAP_WAYPOINT_SET_IN = "Marcador no mapa definido para %s, em %s."
L.WAYPOINT_OFFER = "Clique em %s para definir o marcador no mapa."
L.QUESTMAP_ONE_OF = "Nem sempre no mesmo lugar: um entre %d locais."
-- What is looted, used or explored for a quest inside a dungeon, on its mark's tooltip, after the game's dash: the
-- item to take, the same for a name with no "the" in English, the thing to use, a place to explore (2026-11-11;
-- translation drafted, to be checked).
L.QUESTMAP_OBJECTIVE_TAKE = "Pegar: %s"
L.QUESTMAP_OBJECTIVE_TAKE_NAMED = "Pegar: %s"
L.QUESTMAP_TITLE_QUOTED = "“%s”"
L.QUESTMAP_OBJECTIVE_USE = "Usar: %s"
L.QUESTMAP_OBJECTIVE_EXPLORE = "Explorar este lugar"
-- At the Drowned City's tablets of I'lalai, a rubbing with the hide and charcoal (2026-11-12; drafted, to be checked).
L.QUESTMAP_OBJECTIVE_RUBBING = "Fazer um decalque com o couro e o carvão"
-- A Matrix Punchograph's step, what goes in, then what comes out, in short words ("Yellow > Blue"), and the punch
-- cards' colors, as the cards' own names in the language have them (2026-11-12, the owner's "Blue > Red"; drafted, to
-- be checked); where what goes in drops (2026-11-12; drafted, to be checked).
L.QUESTMAP_OBJECTIVE_STEP = "%s > %s"
L.QUESTMAP_CARD_WHITE = "Branco"
L.QUESTMAP_CARD_YELLOW = "Amarelo"
L.QUESTMAP_CARD_BLUE = "Azul"
L.QUESTMAP_CARD_RED = "Vermelho"
L.QUESTMAP_CARD_PRISMATIC = "Prismático"
L.QUESTMAP_NOTE_INPUT_DROPS = "Os inimigos destes túneis deixam cair %s."
-- A machine used again once its quest is done: it takes another of what it cleans (2026-11-12; drafted, to be checked).
L.QUESTMAP_REPEAT_AGAIN = "Repetível: coloque outro exemplar de %s."
-- What a boss is to a quest, on his tooltip under his quest badge: one to kill, one that drops what the quest needs,
-- the same for a name with no "the" in English, one whose drop starts the quest; who gives or takes it there,
-- himself or by name; a quest's mob more than a boss (2026-11-11; translation drafted, to be checked).
L.QUEST_BADGE_KILL = "Matar para esta missão"
L.QUEST_BADGE_DROPS = "Deixa cair: %s"
L.QUEST_BADGE_DROPS_NAMED = "Deixa cair: %s"
L.QUEST_BADGE_STARTS = "Deixa cair: %s (inicia uma missão)"
L.QUEST_BADGE_STARTS_NAMED = "Deixa cair: %s (inicia uma missão)"
L.QUEST_BADGE_GIVES = "Dá esta missão"
L.QUEST_BADGE_GIVES_WHO = "%s dá esta missão aqui"
L.QUEST_BADGE_TAKES = "Entregue aqui"
L.QUEST_BADGE_TAKES_WHO = "Entregue aqui a: %s"
L.QUEST_TARGET = "Alvo de missão"
L.MAP_ONE_OF = "Nem sempre no mesmo lugar: um entre %d locais."
L.QUEST_REWARDS = REWARDS or "Recompensas"
L.QUEST_YOU_RECEIVE = YOU_RECEIVE or "Você receberá:"
L.QUEST_XP = "%s de experiência"
-- XP that is only the original game's number, not yet confirmed on Forever: a note after it, and
-- its tooltip (2026-10-30; drafted, to be checked).
L.QUEST_XP_ORIGINAL = "(jogo original)"
L.QUEST_XP_ORIGINAL_TIP = "É o que a missão dava no jogo original. O Forever pode dar mais. Isso ainda não foi verificado no Forever. Entregue-a com a aba Gravar ativa para adicionar o que o Forever dá."
L.QUEST_REPUTATION = "%d de reputação com %s"
L.QUEST_CHOOSE = REWARD_CHOICES or "Você poderá escolher uma destas recompensas:"
L.QUEST_ALSO = REWARD_ITEMS or "Você também receberá:"
L.REP_REWARDS = "%d recompensas"
L.REP_REWARD_ONE = "1 recompensa"
L.REP_ALL_REWARDS = "Recompensas"
-- The group for wares that need no standing (2026-11-12; drafted, to be checked)
L.REP_ANY_STANDING = "Qualquer reputação"
L.REP_UNKNOWN = "Desconhecida"
L.REP_CARD_CLICK = "Clique para ver as recompensas."
L.REP_YOUR_STANDING = "Sua reputação: %s"
L.REP_NOT_MET = "Você ainda não conheceu esta facção."
L.REP_PROGRESS = "%s / %s"
L.REP_QUARTERMASTER = "Intendente: %s"
L.REP_CAPTURE = "Capturar vendedor"
L.REP_CAPTURE_TIP = "Vá até um intendente de reputação, abra a loja dele e clique aqui. Tudo o que ele vende fica salvo: o preço de cada item, qualquer outro custo e a reputação exigida. Os itens entram nas recompensas da facção na hora e são incluídos quando você clica em Copiar na aba Gravar."
L.REP_CAPTURE_READY = "Loja aberta: clique em Capturar vendedor."
L.REP_CAPTURE_HINT = "Abra a loja de um intendente para capturar os itens à venda."
L.REP_CAPTURED = "%s: %d itens à venda para %s, %d novos."
L.REP_CAPTURED_NONE = "%s: %d itens salvos; nenhum exige reputação."
L.REP_CAPTURED_UNKNOWN = "%s: %d itens exigem reputação com uma facção que o jogo não nomeia; ficam salvos até que um item a nomeie."
L.REP_NOT_CAPTURED = "Ainda não capturada"
L.REP_NOT_CAPTURED_TIP = "Ninguém capturou o intendente desta facção ainda."
L.REP_NOT_CAPTURED_TEXT = "Ninguém capturou o intendente desta facção ainda. Encontre um, abra a loja dele e clique em Capturar vendedor na aba Reputação; depois publique a sua gravação no nosso Discord. O seu nome entra para os colaboradores do diário."
L.REP_LISTED_TIP = "As recompensas vêm dos dados de itens do jogo e ainda não foram confirmadas com um intendente."
L.REP_LISTED_TEXT = "Estas recompensas vêm dos dados de itens do jogo, ainda não de um intendente, então não têm preço e algumas talvez nem sejam vendidas. Encontre um dos intendentes desta facção, abra a loja dele e clique em Capturar vendedor na aba Reputação; depois publique a sua gravação no nosso Discord. O seu nome entra para os colaboradores do diário."
L.REP_COMING_SOON_TEXT = "Nova no WoW: Forever e ainda não capturada. Quando ela estiver no jogo, encontre o intendente dela, abra a loja dele e clique em Capturar vendedor na aba Reputação; depois publique a sua gravação no nosso Discord."
-- The Reputation tab's Vendors: a page for each currency a vendor takes for wares that need no standing (2026-11-12; drafted, to be checked).
L.REP_VENDORS = "Vendedores"
L.CURRENCY_YOU_HAVE = "Você tem %s"
L.CURRENCY_VENDOR = "Vendedor: %s"
L.CURRENCY_CARD_CLICK = "Clique para ver os itens à venda."
L.REP_CAPTURED_CURRENCY = "%s: %d itens salvos, vendidos por %s."
-- Where Carved Centaur Totems come from, on its Vendors card and page (2026-11-13; drafted, to be checked: %s is the item's name as the client writes it; the quests keep their English names, their names in this language not known).
L.CURRENCY_NOTE_CENTAUR_TOTEM = "%s: centauros de qualquer clã em Desolação os deixam cair, e a missão \"Khan Hratha\" dá dez. A missão \"Carved Centaur Totems\" pede cinco, tanto para a Aliança quanto para a Horda."
L.MAP_SHOW = ENCOUNTER_JOURNAL_SHOW_MAP or "Mostrar mapa"
L.MAP_SHOW_UNEXPLORED = "Mostrar áreas inexploradas"
L.OPTIONS_UNEXPLORED_TIP = "Sombreia no mapa-múndi as partes de cada zona que você ainda não explorou."
-- The map legend's Fog of War switch, the last of Movement's, and its tooltip (2026-11-11; translation drafted, to be checked).
L.LEGEND_FOG = "Névoa de guerra"
L.LEGEND_FOG_TOOLTIP = "Esconde as partes de uma zona que você ainda não explorou e as partes do mapa de uma masmorra que seu grupo ainda não revelou."
L.LEGEND_FOG_ZONE_HIDDEN = "O mapa mostra só as partes desta zona que você explorou."
L.LEGEND_FOG_ZONE_SHOWN = "As partes desta zona que você não explorou também aparecem, um pouco mais escuras."
L.LEGEND_FOG_ZONE_SHOW = "Clique para mostrar as partes inexploradas."
L.LEGEND_FOG_ZONE_HIDE = "Clique para mostrar só as partes exploradas."
L.LEGEND_FOG_DUNGEON_ON = "A névoa cobre as partes deste mapa que você ainda não revelou. Cada chefe que seu grupo derrota revela as salas dele."
L.LEGEND_FOG_DUNGEON_OFF = "A névoa está desativada: o mapa inteiro aparece."
L.LEGEND_FOG_DUNGEON_CLEARED = "A névoa se dissipou: o mapa inteiro está visível."
L.LEGEND_FOG_DUNGEON_LIFT = "Clique para desativar a névoa."
L.LEGEND_FOG_DUNGEON_LAY = "Clique para ativar a névoa."
L.LEGEND_FOG_ADVENTURE = "Não pode ser desativada no Modo Aventura."
L.LEGEND_FOG_NONE = "Não há névoa de guerra neste mapa."
L.LEGEND_FOG_ZONE_EXPLORED = "Você explorou esta zona inteira."
L.MAP_FILTER_QUESTS = "Missões disponíveis"
L.MAP_FILTER_DUNGEONS = "Entradas de masmorras"
L.MAP_FILTER_RAIDS = "Entradas de raides"
L.MAP_FILTER_FLIGHT = "Pontos de voo"
L.MAP_FILTER_CAVES = "Entradas de cavernas"
L.MAP_FILTER_TRANSPORT = "Barcos, zepelins, metrô e portais"
L.MAP_PIN_OPEN = "Clique para abrir no diário."
L.MAP_DEFEATED = DUNGEON_ENCOUNTER_DEFEATED or "Derrotado"
L.MAP_FOG_HINT = "Derrote-o para dissipar a névoa aqui."
L.MAP_UNMET_HINT = "Nenhum encontro ainda."
L.MAP_LEVEL = "Nível %d"
L.MAP_FLOOR = "Andar %d"
L.MAP_GO_TO = "Para %s"
-- Under a way between floors, where two lead to one floor (the Drowned City's), where it comes out
-- (2026-11-17; drafted, to be checked).
L.MAP_WAY_OUT_SOUTHWEST = "Sai na ponta sudoeste"
L.MAP_WAY_OUT_NORTHEAST = "Sai na ponta nordeste"
L.MAP_WAY_OUT_DEEP_ARCHIVES = "Sai nos Arquivos Profundos"
L.MAP_WAY_OUT_CENTRAL_POOL = "Sai no lago central"
L.MAP_YOU_ARE_HERE = "Você está aqui"
L.ENTRANCE_DUNGEON = LFG_TYPE_DUNGEON or "Masmorra"
L.ENTRANCE_RAID = LFG_TYPE_RAID or "Raide"
L.ENTRANCE_DUNGEONS = DUNGEONS or "Masmorras"
L.ENTRANCE_RAIDS = RAIDS or "Raides"
L.ENTRANCE_LEFT_CLICK = "Clique com o botão esquerdo para abrir o Diário de Masmorras"
L.ENTRANCE_CHOOSE_LEFT_CLICK = "Clique com o botão esquerdo para escolher qual abrir no Diário de Masmorras"
L.ENTRANCE_RIGHT_CLICK = "Clique com o botão direito para definir um marcador no mapa"
L.ENTRANCE_WAYPOINT_SET = "Marcador no mapa definido na entrada de %s."
L.ENTRANCE_VIA = "O portal fica mais abaixo, em %s: desça pela entrada da caverna."
L.ENTRANCE_WAYPOINT_VIA = "Marcador no mapa definido na descida para %s, a caminho de %s."
L.CAVE_LABEL = "Entrada de Caverna"
L.BUILDING_LABEL = "Entrada"
L.ENTRANCE_VIA_BUILDING = "O portal fica lá dentro, em %s: entre pela entrada."
L.CAVE_LEADS_TO = "O caminho para %s"
L.CAVE_LEFT_CLICK = "Clique com o botão esquerdo para ver o mapa de %s"
L.CAVE_WAYPOINT_SET = "Marcador no mapa definido na descida para %s."
L.FLIGHT_POINT = MAP_LEGEND_FLIGHTPOINT or "Ponto de Voo"
L.CLICK_FOR_WAYPOINT = "Clique para definir um marcador no mapa"
L.FLIGHT_WAYPOINT_SET = "Marcador no mapa definido no mestre de voo de %s."
L.TRAVEL_KINDS = { boat = "Barco", zeppelin = "Zepelim", airship = "Aeronave", tram = "Metrô", portal = "Portal" }
L.TRAVEL_FACTIONS = { Alliance = FACTION_ALLIANCE or "Aliança", Horde = FACTION_HORDE or "Horda" }
L.TRAVEL_ROUTE = "%s para %s"
L.TRAVEL_AND = "%s e %s"
L.TRAVEL_ROUTE_NOTE = "%s: %s"
L.TRAVEL_HELP = "Fique em um cais, torre de zepelim, metrô ou portal e digite /aegis travel boat (ou zeppelin, airship, tram, portal) seguido do destino, por exemplo /aegis travel boat Auberdine. Acrescente alliance, horde ou neutral no final para dizer a quem ele serve, e uma nota entre parênteses para dizer quem pode usá-lo, por exemplo /aegis travel portal Dalaran (somente Celonatos). /aegis travel list mostra o que está salvo; /aegis travel undo desfaz o último."
L.TRAVEL_NO_POSITION = "O jogo não informa nenhuma posição aqui, então nada foi salvo."
L.TRAVEL_SAVED = "%s salvo em %s. /aegis travel undo desfaz."
L.TRAVEL_UNDONE = "Desfeito: %s em %s."
L.TRAVEL_NOTHING = "Nada para desfazer."
L.TRAVEL_LIST_EMPTY = "Nenhum ponto de viagem salvo ainda. Digite /aegis travel para ver como."
L.TRAVEL_LIST_LINE = "%d. %s em %s (mapa %d, %.4f, %.4f)"
L.TRAVEL_WAYPOINT_SET = "Marcador no mapa definido para %s."
L.LEGEND_TRANSPORT = "Transporte"
L.LEGEND_TRANSPORT_TOOLTIP = "Barcos, zepelins, o metrô e portais. Azul atende a Aliança; vermelho, a Horda; dourado, todos."
L.LEGEND_CAVE_TOOLTIP = "O caminho para dentro de uma caverna, onde fica a porta de uma masmorra. Clique nele no mapa para ver o interior."
L.LEGEND_BUILDING_TOOLTIP = "O caminho para dentro de um edifício, dos salões de uma montanha ou de um nível abaixo da zona, onde fica a porta de uma masmorra. Clique nele no mapa para ver o interior."
L.SEARCH_SHOW_ALL = SEARCH_RESULTS_SHOW_COUNT or "Mostrar todos os %d resultados"
L.SEARCH_RESULTS = ENCOUNTER_JOURNAL_SEARCH_RESULTS or "Resultados da busca por “%s” (%d)"
L.SEARCH_TYPE_BOSS = "Encontro"
L.SEARCH_TYPE_ABILITY = "Habilidade"
L.SEARCH_TYPE_ITEM = "Item"
L.SEARCH_TYPE_QUEST = "Missão"
L.SEARCH_TYPE_FACTION = FACTION or "Facção"
L.MAP_PIN_CLEAR = "Clique para remover este marcador."
L.MAP_PIN_COMBAT = "Não é possível abrir o mapa em combate."
L.GAMEPAD_HUD_UP = "Saia primeiro do modo HUD da interface de controle e tente de novo."
L.MAP_PIN_IN_ZONE = "%s está marcado no mapa de %s."
L.MAP_LEVEL_LINK_CLICK = "Clique com o botão esquerdo para ver o mapa desse nível"
-- A place worth knowing on a dungeon's map (UI/DungeonMap.lua's MapSpot): its kind's name, and the Drowned City's
-- hidden chest's line under it (2026-11-17; drafted, to be checked).
L.MAP_SPOT_CHEST = "Baú escondido"
L.MAP_SPOT_DROWNED_CHEST = "No barco naufragado, depois de Min'loth, a Serpente. Ele não está trancado: qualquer um pode abri-lo para obter itens e materiais aleatórios."
L.DOOR_SPIRE_ONE_INSTANCE = "O Pico da Rocha Negra Inferior e o Superior são uma só instância, com uma só porta."
L.DOOR_SPIRE_LOWER = "Pico da Rocha Negra Inferior: até 10 jogadores, mas suas missões só podem ser concluídas num grupo de 5 ou menos."
L.DOOR_SPIRE_UPPER = "Pico da Rocha Negra Superior: mais adiante, atrás de uma porta selada que exige o Selo da Ascensão. Até 10 jogadores."

L.RARE_SUFFIX = " (Raro)"
L.AND_MORE = "e mais %d"
L.BULLET_AREA = "Encontra-se em %s."
L.BULLET_RARE = "Uma criatura rara: nem toda incursão a encontra."
L.BULLET_SUMMONED = "Um chefe oculto que você mesmo invoca: a nota acima explica como."
-- The same where his note names several bosses, not a hidden boss (2026-11-19; drafted, to be checked).
L.BULLET_CALLED_UP = "Um chefe que você mesmo invoca: a nota acima explica como."
-- A quest's mob, on the map only, on his page (2026-11-11; translation drafted, to be checked).
L.BULLET_QUEST_TARGET = "Um alvo de missão, não um dos chefes da masmorra."
L.BULLET_LEVEL = "Um encontro de nível %d."
L.BULLET_ABILITIES = "Visto lançando: %s."
L.BULLET_LOOT = "Deixa cair %d itens, incluindo %s."
L.BULLET_ADDS = "Conta com a ajuda de %s."
L.ADD_DESCRIPTION = "Luta ao lado de %s."
L.BULLET_NOTHING_YET = "Ainda não se sabe nada sobre este encontro."

-- The Brazilian Portuguese client's classic "Equip:" wordings ("Equipado:"), on the line in lower
-- case (drafted; check against items in game). Specific before general, as in Core/ItemScore.lua.
L.EQUIP_PATTERNS = {
	-- Bonuses against undead only, and attack power against one kind of creature: worth nothing.
	{ "mortos%-vivos", false },
	-- Critical strikes: "Aumenta em 1% a chance de realizar acertos críticos (com feitiços)."
	{ "em {n}%%.-crític.-sagrad", "HOLY CRIT" },
	{ "em {n}%%.-crític.-feitiços e ataques", { "SPELL CRIT", "CRIT" } },
	{ "em {n}%%.-crític.-feitiço", "SPELL CRIT" },
	{ "em {n}%%.-crític.-longo alcance", "RANGED CRIT" },
	{ "em {n}%%.-crític.-distância", "RANGED CRIT" },
	{ "em {n}%%.-crític", "CRIT" },
	-- Hit: "Aumenta em 1% a chance de acerto." / "Aumenta em 1% sua chance de acertar com feitiços."
	{ "em {n}%%.-acert.-feitiços e ataques", { "SPELL HIT", "HIT" } },
	{ "em {n}%%.-acert.-feitiço", "SPELL HIT" },
	{ "em {n}%%.-acert", "HIT" },
	-- "Aumenta em até 23 o dano causado e a cura realizada por feitiços e efeitos mágicos."
	{ "até {n}.-dano.-e a cura", { "SPELL POWER", "HEALING" } },
	{ "até {n}.-cura.-e o dano", { "SPELL POWER", "HEALING" } },
	-- "Aumenta em até 44 a cura realizada por feitiços e efeitos mágicos."
	{ "até {n}.-cura", "HEALING" },
	-- "Aumenta em até 20 o dano causado por feitiços e efeitos de Fogo." (Sagrados, Arcanos...)
	{ "até {n}.-dano.-sagrad", "HOLY DAMAGE" },
	{ "até {n}.-dano.-fogo", "FIRE DAMAGE" },
	{ "até {n}.-dano.-gelo", "FROST DAMAGE" },
	{ "até {n}.-dano.-natureza", "NATURE DAMAGE" },
	{ "até {n}.-dano.-sombra", "SHADOW DAMAGE" },
	{ "até {n}.-dano.-arcan", "ARCANE DAMAGE" },
	{ "até {n}.-dano.-mágic", "SPELL DAMAGE" },
	{ "até {n}.-dano.-feitiço", "SPELL DAMAGE" },
	-- "Permite que 15% da sua regeneração de mana continue durante o lançamento de feitiços."
	{ "{n}%%.-regenera.-mana", "CASTING REGEN" },
	{ "{n}%%.-mana.-continu", "CASTING REGEN" },
	-- "Reduz em 10 as resistências mágicas dos alvos dos seus feitiços."
	{ "em {n}.-resist.-mágicas", "SPELL PENETRATION" },
	{ "resist.-mágicas.-em {n}", "SPELL PENETRATION" },
	{ "em {n}.-penetração de feitiço", "SPELL PENETRATION" },
	-- "+45 de poder de ataque ao lutar contra demônios."
	{ "poder de ataque ao lutar", false },
	{ "poder de ataque contra", false },
	-- "+24 de poder de ataque de longo alcance." / "Aumenta o poder de ataque de longo alcance em 24."
	{ "^%+{n}.-poder de ataque de longo alcance", "RANGED ATTACK POWER" },
	{ "^%+{n}.-poder de ataque à distância", "RANGED ATTACK POWER" },
	{ "poder de ataque de longo alcance.-em {n}", "RANGED ATTACK POWER" },
	{ "em {n}.-poder de ataque de longo alcance", "RANGED ATTACK POWER" },
	-- "+120 de poder de ataque sob forma de Felino, Urso e Urso Hediondo."
	{ "^%+{n}.-poder de ataque.-felino", "FERAL ATTACK POWER" },
	{ "em {n}.-poder de ataque.-felino", "FERAL ATTACK POWER" },
	{ "^%+{n}.-poder de ataque", "ATTACK POWER" },
	{ "em {n}.-poder de ataque", "ATTACK POWER" },
	{ "poder de ataque em {n}", "ATTACK POWER" },
	-- "Restaura 4 de mana a cada 5 s." / "Recupera 4 pontos de vida a cada 5 s."
	{ "{n}.-mana a cada 5", "MANA PER 5" },
	{ "{n}.-vida a cada 5", "HEALTH PER 5" },
	{ "restaura {n}.-vida", "HEALTH PER 5" },
	{ "recupera {n}.-vida", "HEALTH PER 5" },
	-- "Defesa aumentada em 7."
	{ "defesa aumentada em {n}", "DEFENSE" },
	{ "defesa %+{n}", "DEFENSE" },
	{ "em {n}.-defesa", "DEFENSE" },
	-- "Aumenta em 1% a chance de esquivar-se de ataques." / "... de aparar ataques." / "... de bloquear
	-- ataques com o escudo." (not "serem esquivados ou aparados", which is no dodge nor parry)
	{ "em {n}%%.-de esquivar", "DODGE" },
	{ "em {n}%%.-se esquivar", "DODGE" },
	{ "em {n}%%.-de aparar", "PARRY" },
	{ "em {n}%%.-de bloquear", "BLOCK" },
	-- "Aumenta em 15 o valor de bloqueio do seu escudo."
	{ "em {n}.-valor de bloqueio", "BLOCK VALUE" },
	{ "valor de bloqueio.-em {n}", "BLOCK VALUE" },
	-- "Aumenta em 1% a sua velocidade de ataque."
	{ "em {n}%%.-velocidade de ataque", "HASTE" },
	{ "velocidade de ataque.-em {n}", "HASTE" },
}

-- The rooms inside dungeons, as the client names them where the player stands: "You are
-- here" and a wing's areas match these (Core/Areas.lua). Unconfirmed ones are listed in
-- the translation's to-check list.
L.AREA_NAMES = {
	-- The Drowned City's areas (Data/Authored/Upcoming.lua's floors: Abyssal Dais, Altar of the Serpent, Deep
	-- Archives, Eternal Amphitheater, the Flooded Shrine (the central pool) and Sunken Hollow on the city's map,
	-- Ataal'Byzal and Atal'Byzal on Atal'byzal), as a player's English recording (2026-11-13) and the client's
	-- English tables (2026-11-17) name them: drafted, to be checked (GetSubZoneText there)
	["Abyssal Dais"] = "Tablado Abissal",
	["Aku'mai's Lair"] = "Covil de Aku'mai",
	-- Alcaz Prison's two names for its rooms (Data/Authored/Upcoming.lua's floors: Alcaz Prison on the first,
	-- Maximum Security on the second), as the client's English tables name them (2026-11-17): drafted, to be checked
	-- (GetSubZoneText there); Alcaz Prison as the dungeon's name in this language
	["Alcaz Prison"] = "Prisão de Alcaz",
	-- (the Drowned City's, drafted: see Abyssal Dais)
	["Altar of the Serpent"] = "Altar da Serpente",
	["Anvilmar's Rest"] = "Repouso de Sidermar",
	-- (the Drowned City's shrine: its rooms' area and the building's own name, drafted: see Abyssal Dais)
	["Ataal'Byzal"] = "Ataal'Byzal",
	["Atal'Byzal"] = "Atal'Byzal",
	["Athenaeum"] = "Ateneu",
	-- Blackmaw Hold's areas (Data/Authored/Upcoming.lua's floors: Blackmaw Grove, Blackmaw Stillwater, Bonesnout's
	-- Thicket, the Festering Grotto and the depths' four levels), by the labels on Santiago Reyes's maps, not read in
	-- game yet: drafted, to be checked (GetSubZoneText there). The client's tables keep the hold's own names in
	-- encrypted rows
	["Blackmaw Grove"] = "Bosque Bocanera",
	["Blackmaw Stillwater"] = "Remanso Bocanera",
	["Blackrock Stadium"] = "Estádio Rocha Negra",
	["Blackrock Stronghold"] = "Fortaleza Rocha Negra",
	-- (Blackmaw Hold's, drafted: see Blackmaw Grove)
	["Bonesnout's Thicket"] = "Matagal de Bonesnout",
	-- City of Dalaran's rooms (Data/Authored/CityOfDalaran.lua's floors: Cantrips & Crows, City of
	-- Dalaran, Dalaran, Magus Commerce Exchange, Path of Renewal, Presage Plaza, Runeweaver Square, Sewer,
	-- The Eventide, The Purple Parlor, The Underbelly, The Violet Citadel, The Violet Hold): the city's
	-- own buildings name them. Most have no area id; Dalaran (279, 16558), City of Dalaran (16544, 16560)
	-- and The Eventide (17824) have, not baked yet: a scan (/aegis areas, Dev/bake_area_ids.py) can
	-- replace those three. By the names the game's Dalaran has in this language, the newest of four
	-- copies of a list of them, to be checked in game (GetSubZoneText there).
	-- Here City of Dalaran reads as Dalaran: both are on the city's floor, and the map reads only the
	-- room's name in there (roomsOnly), so the zone's name, where no room is named, never turns it.
	-- The Violet Citadel and The Eventide follow the newest copy against three older ones ("A Cidadela
	-- Violeta", "O Anoitecer"): check these two first in game
	["Cantrips & Crows"] = "Urubus e Urucubacas",
	["Capital Gardens"] = "Jardins Capitais",
	["Cavern of Mists"] = "Caverna das Brumas",
	["Chamber of Atonement"] = "Câmara da Redenção",
	["Chamber of Battle"] = "Câmara de Batalha",
	["Chapel Gardens"] = "Jardins da Capela",
	["City of Dalaran"] = "Dalaran",
	["Cleft of Shadow"] = "Antro das Sombras",
	["Court of the Highborne"] = "A Corte dos Altaneiros",
	["Crag of the Everliving"] = "Rochedo do Sempre-vivo",
	["Crusader's Armory"] = "Armaria do Cruzado",
	["Crusader's Chapel"] = "Capela do Cruzado",
	["Crusaders' Square"] = "Praça dos Cruzados",
	["Dalaran"] = "Dalaran",
	["Dark Iron Ingress"] = "Passagem Ferro Negro",
	-- (the Drowned City's, drafted: see Abyssal Dais)
	["Deep Archives"] = "Arquivos Profundos",
	["Deeprun Tram"] = "Metrô Correfundo",
	["Defias Hideout"] = "Esconderijo Défias",
	-- (Blackmaw Hold's, drafted: see Blackmaw Grove)
	["Depths of Forbidden Magic"] = "Profundezas da Magia Proibida",
	["Depths of the Burrow"] = "Profundezas da Toca",
	["Depths of the Elders"] = "Profundezas dos Anciãos",
	["Depths of the Fallen Grove"] = "Profundezas do Bosque Caído",
	["Dig One"] = "Escavação Um",
	["Dragonspire Hall"] = "Salão do Espinodrago",
	["Dreamer's Rock"] = "Rocha do Sonhador",
	["Elders' Square"] = "Praça dos Anciãos",
	["Eldre' Thalas"] = "Eldre'Thalas",
	["Eldreth Row"] = "Fileira Eldreth",
	["Engineering Labs"] = "Laboratório de Engenharia",
	-- (the Drowned City's, drafted: see Abyssal Dais)
	["Eternal Amphitheater"] = "Anfiteatro Eterno",
	["Excavation Center"] = "Centro de Escavação",
	-- (Blackmaw Hold's, drafted: see Blackmaw Grove)
	["Festering Grotto"] = "Gruta Pestilenta",
	["Festival Lane"] = "Alameda do Festival",
	-- (the Drowned City's, drafted: see Abyssal Dais)
	["Flooded Shrine"] = "Santuário Inundado",
	["Footman's Armory"] = "Armaria do Soldado",
	-- City of Dalaran's city rooms a player's recording read (Data/Authored/CityOfDalaran.lua, 2026-11-13: Forge of
	-- Fate, Talismanic Textiles, Tempered Tomes, The Atrium of Fortune, The Silver Enclave, Violet Plates and
	-- Framing), with no area id. Drafted, to be checked in game (GetSubZoneText there)
	["Forge of Fate"] = "Forja do Destino",
	["Forgewright's Tomb"] = "Tumba do Forjador",
	["Forlorn Cloister"] = "Claustro Esquecido",
	["Gallery of Treasures"] = "Galeria dos Tesouros",
	["Goblin Foundry"] = "Fundição dos Goblins",
	["Gordok Commons"] = "Pátio Gordok",
	["Hall of Champions"] = "Salão dos Campeões",
	["Hall of the Keepers"] = "Salão dos Guardiões",
	["Halycon's Lair"] = "Covil de Halycon",
	["Honor's Tomb"] = "Tumba de Honra",
	["Hordemar City"] = "Hordamar",
	["Huntsman's Cloister"] = "Claustro do Guarda-caça",
	["Ironclad Cove"] = "Covil Encouraçado",
	["Ironforge"] = "Altaforja",
	["King's Alley"] = "Beco do Rei",
	["King's Square"] = "Praça Real",
	["Launch Bay"] = "Baia de Lançamento",
	-- Three rooms of Gnomeregan's way in (Data/Authored/SubMaps.lua), the Loading Room, the Train
	-- Depot and the Workshop Entrance, have no area id, so they are found by these names alone, to be
	-- checked in game (GetSubZoneText there): LibBabble-SubZone's, the same in its root file (rev 237)
	-- and in the file the lib loads (rev 258)
	["Loading Room"] = "Galpão de Carregamento",
	["Lordaeron Graveyard"] = "Cemitério de Lordaeron",
	["Lordamere Overlook"] = "Mirante de Lordaeron",
	["Lost Dig Site"] = "Sítio de Escavação Perdido",
	["Lost Marsh"] = "Charco Perdido",
	["Magus Commerce Exchange"] = "Área Comercial Magus",
	["Market Row"] = "Travessa do Comércio",
	["Market Street"] = "Rua do Mercado",
	-- (Alcaz Prison's lower floor, drafted: see Alcaz Prison)
	["Maximum Security"] = "Segurança Máxima",
	["Mast Room"] = "Sala do Mastro",
	["Mok'Doom"] = "Mok'Doom",
	["Moonshrine Ruins"] = "Ruínas do Sacrário Lunar",
	["Moonshrine Sanctum"] = "Sacrário Lunar",
	["Mount Hyjal"] = "Monte Hyjal",
	["North Common Hall"] = "Salão Comunal Norte",
	["Path of Renewal"] = "Caminho da Renovação",
	["Pit of Fangs"] = "Fosso das Presas",
	["Presage Plaza"] = "Praça do Presságio",
	["Prison of Immol'thar"] = "Prisão de Immol'thar",
	["Reliquary of Kings"] = "Relicário dos Reis",
	["Riverglades"] = "Sendas do Rio",
	["Runeweaver Square"] = "Praça Fiarruna",
	["Screaming Gully"] = "Barranca Estridente",
	["Sewer"] = "Esgoto",
	["Shen'dralas"] = "Shen'dralas",
	["Site of the Guardian"] = "Sítio do Guardião",
	["Skitterweb Tunnels"] = "Túneis Tremeteia",
	["Slaughter Square"] = "Praça do Massacre",
	["South Common Hall"] = "Salão Comunal Sul",
	-- Razorfen Downs' rooms (Data/Instances/RazorfenDowns.lua: Spiral of Thorns, The Bone Pile, The Caller's Chamber
	-- and The Murder Pens), as a player's recording read them in English (2026-11-13): the dungeon building's own
	-- names, with no area id. Drafted, to be checked in game (GetSubZoneText there)
	["Spiral of Thorns"] = "Espiral de Espinhos",
	["Stalker's Thicket"] = "Matagal do Espreitador",
	-- (the Drowned City's, drafted: see Abyssal Dais)
	["Sunken Hollow"] = "Depressão Submersa",
	-- (City of Dalaran's, drafted: see Forge of Fate)
	["Talismanic Textiles"] = "Tecidos Talismânicos",
	["Tazz'Alaor"] = "Tazz'Alaor",
	["Tazz'Alor"] = "Tazz'Alor",
	-- (City of Dalaran's, drafted: see Forge of Fate)
	["Tempered Tomes"] = "Tomos Temperados",
	-- (City of Dalaran's, drafted: see Forge of Fate)
	["The Atrium of Fortune"] = "Átrio da Fortuna",
	-- (Razorfen Downs', drafted: see Spiral of Thorns)
	["The Bone Pile"] = "Pilha de Ossos",
	-- (Razorfen Downs', drafted: see Spiral of Thorns)
	["The Caller's Chamber"] = "Câmara do Invocador",
	-- Gnomeregan's Clean Zone, a room the map follows since 0.39.21 (2026-11-12; drafted, to be checked)
	["The Clean Zone"] = "A Zona Limpa",
	["The Clockwerk Run"] = "Corredor dos Mecanismos",
	["The Deadmines"] = "Minas Mortas",
	["The Dormitory"] = "Alojamentos",
	["The Drowned Sacellum"] = "O Sacelo Inundado",
	["The Eventide"] = "Anoitecer",
	["The Forgotten Pool"] = "Charcos Esquecidos",
	["The Gauntlet"] = "Forquilha",
	["The Grand Vestibule"] = "O Grande Vestíbulo",
	["The Grinding Quarry"] = "A Pedreira Trituradora",
	["The Hall of Gears"] = "Salão das Engrenagens",
	["The Hall of Lights"] = "O Salão das Luzes",
	["The High Seat"] = "A Sala do Trono",
	["The Hoard"] = "O Cofre",
	["The Masonary"] = "A Alvenaria",
	["The Molten Span"] = "A Ponte Derretida",
	-- (Razorfen Downs', drafted: see Spiral of Thorns)
	["The Murder Pens"] = "Currais da Matança",
	["The Pool of Ask'ar"] = "O Poço de Ask'Ar",
	["The Purple Parlor"] = "Salão Púrpura",
	["The Rookery"] = "O Viveiro",
	["The Scarlet Bastion"] = "O Bastião Escarlate",
	["The Sealed Hall"] = "O Salão Selado",
	["The Shrine of Eldretharr"] = "Altar de Eldretharr",
	-- (City of Dalaran's, drafted: see Forge of Fate)
	["The Silver Enclave"] = "Enclave Prateado",
	["The Slaughter House"] = "O Matadouro",
	["The Storehouse"] = "O Armazém",
	["The Underbelly"] = "Os Esgotos",
	["The Violet Citadel"] = "Cidadela Violeta",
	["The Violet Hold"] = "Castelo Violeta",
	["The Wailing Caverns"] = "Caverna Ululante",
	["Tinkers' Court"] = "Paço dos Faz-tudo",
	-- Gnomeregan's way in, as the Loading Room above
	["Train Depot"] = "Depósito Ferroviário",
	["Training Grounds"] = "Campo de Treinamento",
	-- (City of Dalaran's, drafted: see Forge of Fate)
	["Violet Plates and Framing"] = "Placas e Molduras Violeta",
	["Warpwood Quarter"] = "Distrito Lenhatorta",
	-- Wailing Caverns' Winding Chasm (Data/Authored/WailingCaverns.lua, 2026-11-13): the game's name for it in this language, to be checked in game
	["Winding Chasm"] = "Fenda Sinuosa",
	-- Gnomeregan's way in, as the Loading Room above
	["Workshop Entrance"] = "Entrada da Oficina",
	-- (Blackmaw Hold's, drafted: see Blackmaw Grove; Zedrik's Rest a best guess from the label on a newer version
	-- of Santiago Reyes's whole hold, 2026-11-18)
	["Zedrik's Rest"] = "Repouso de Zedrik",
	-- The Temple of Atal'Hakkar's way in (Data/Authored/SubMaps.lua, 2026-10-30): its nine rooms have no area id,
	-- so they are found by these names alone. Pool of Tears, Sorrowmurk and the temple's own name have ids (74,
	-- 1778, 1477): a scan (/aegis areas, Dev/bake_area_ids.py) can replace those three. LibBabble-SubZone's names,
	-- the same in its root file (rev 237) and in the file the lib loads (rev 258). Hall of Faces and Den of
	-- the Unholy are Forever's names. To be checked in game (GetSubZoneText there)
	["Chamber of Blood"] = "Câmara de Sangue",
	["Den of the Caller"] = "Covil do Arauto",
	["Den of the Unholy"] = "Covil do Profano",
	["Hall of Bones"] = "Salão dos Ossos",
	["Hall of Faces"] = "Salão dos Rostos",
	["Hall of Masks"] = "Salão das Máscaras",
	["Hall of Ritual"] = "Salão do Ritual",
	["Pool of Tears"] = "Poço de Lágrimas",
	["Sorrowmurk"] = "Penumbra das Mágoas",
	["The Broken Hall"] = "Salão Partido",
	["The Butchery"] = "O Matadouro",
	["The Temple of Atal'Hakkar"] = "Templo de Atal'Hakkar",
}

-- The journal's style: its question at each character's first login, each choice and what it does, and the
-- choice and boxes in the options (2026-11-03; drafted, to be checked).
L.STYLE_TITLE = "Escolha seu diário"
L.STYLE_SUBTITLE = "Quanto o diário deve acrescentar ao seu jogo? Você pode mudar isso a qualquer momento nas opções do diário."
L.STYLE_CLASSIC = "Clássico"
L.STYLE_CLASSIC_DESC = "Um diário mais no estilo original, com menos extras. Os chefes, o saque, as missões e os mapas das masmorras continuam lá."
L.STYLE_MODERN = "Moderno"
L.STYLE_MODERN_DESC = "Tudo o que o diário tem, como é agora: o Localizador de Equipamento, mapas dos acessos e suas marcas no mapa-múndi."
L.STYLE_CUSTOM = "Personalizado"
L.STYLE_CUSTOM_DESC = "Você escolhe. Escolha isto para abrir as configurações do diário, onde cada recurso tem sua própria caixa para marcar."
-- Adventure Mode, in the options' list of styles, and what it does (2026-11-05; drafted, to be checked).
L.STYLE_ADVENTURE = "Modo Aventura"
L.STYLE_ADVENTURE_DESC = "O diário começa vazio e se completa conforme você joga: masmorras, chefes, saque e missões aparecem quando você os encontra."
-- Adventure Mode's name on its box in the question at login, one word like Classic and Modern (2026-11-07).
L.STYLE_ADVENTURE_BOX = "Aventura"
-- Adventure Mode's pages: an unmet boss's line, the closed tabs' tooltips, the loot list with nothing seen
-- yet, and an item seen with its boss unknown (2026-11-05; drafted, to be checked).
L.ADVENTURE_BOSS_UNMET = "Você ainda não o encontrou."
L.ADVENTURE_ABILITIES_CLOSED = "Lute contra este chefe para conhecer suas habilidades."
L.ADVENTURE_MODEL_CLOSED = "Encontre este chefe para vê-lo aqui."
L.ADVENTURE_LOOT_NONE = "Ainda não se viu nada cair aqui."
L.ADVENTURE_LOOT_IN_DUNGEON = "Cai em: %s"
-- Adventure Mode's Quests tab, a step not offered yet and no quests found yet; the Reputation tab, no
-- faction met yet, and a faction's rewards not seen yet (2026-11-05; drafted, to be checked).
L.ADVENTURE_QUEST_UNKNOWN = "Esta missão ainda não foi oferecida a você."
L.ADVENTURE_QUESTS_NONE = "Nenhuma missão desta masmorra foi encontrada ainda."
L.ADVENTURE_REP_NONE = "Você ainda não conheceu nenhuma destas facções."
L.ADVENTURE_REP_TITLE = "Recompensas a descobrir"
L.ADVENTURE_REP_SEEN = "As recompensas aparecem aqui quando você as vê com o intendente da facção."
L.ADVENTURE_REP_SEEN_AT = "As recompensas aparecem aqui quando você as vê com o intendente da facção, %s."
L.ADVENTURE_REP_NONE_SEEN = "Nenhuma das recompensas foi vista ainda."
L.ADVENTURE_DOOR_TITLE = "Um boato"
L.ADVENTURE_DOOR_LINE = "“%s”"
L.ADVENTURE_DOOR_UNKNOWN = "Ainda se sabe pouco sobre este lugar."
L.ADVENTURE_DOOR_DUNGEON = "Masmorra desconhecida"
L.ADVENTURE_DOOR_RAID = "Raide desconhecida"
L.ADVENTURE_DOOR_NTH = "%s %d"
L.ADVENTURE_DOOR_CHOICE = "%s (%s)"
L.ADVENTURE_DOOR_VIA = "O portal fica mais abaixo: desça pela entrada da caverna."
L.ADVENTURE_DOOR_VIA_BUILDING = "O portal fica lá dentro: entre pela entrada."
L.ADVENTURE_DOOR_WAYPOINT_SET = "Marcador no mapa definido onde o boato leva."
L.ADVENTURE_CAVE_LEADS_TO = "O caminho para um lugar cercado de boatos"
L.ADVENTURE_CAVE_LEFT_CLICK = "Clique com o botão esquerdo para ver o mapa do caminho de entrada"
-- Adventure Mode's quest marks on the world map (UI/QuestMap.lua): a quest not offered yet is a faint "!", a
-- rumor, under "A rumor" (ADVENTURE_DOOR_TITLE) and in ADVENTURE_DOOR_LINE's quotation marks: there may be work
-- there, from someone or something (inside a dungeon, a tablet or a crest). It names no quest, dungeon or
-- place (2026-11-11; translation drafted, to be checked).
L.ADVENTURE_QUEST_RUMOR = "Pode haver trabalho para você aqui."
-- Adventure Mode's Gear Finder: an upgrade not seen to drop yet, a rumour's place (zone, level range), the
-- tooltip's line for one not seen, the click lines, and Show on map for a rumour's door (2026-11-10; translation
-- drafted, to be checked).
L.GEAR_ADVENTURE_BETTER = "Algo melhor"
L.GEAR_ADVENTURE_PLACE = "%s · %s"
L.GEAR_ADVENTURE_UNSEEN = "Você ainda não o viu cair."
L.GEAR_ADVENTURE_CELL_CLICK = "Clique para ver as maiores melhorias; clique com o botão direito para ver a masmorra."
L.GEAR_ADVENTURE_PICK_CLICK = "Clique para mostrá-lo aqui; clique com o botão direito para ver a masmorra."
L.GEAR_ADVENTURE_ROW_CLICK = "Clique para ver a masmorra."
L.GEAR_ADVENTURE_MAP_CLICK = "Clique para ver o caminho no mapa-múndi."
L.GEAR_ADVENTURE_NO_DOOR = "Ainda não se sabe onde fica a entrada."
L.GEAR_ADVENTURE_SHOW_MAP = "Mostrar no mapa"
-- The Gear Finder's rumour slot with upgrades to pick: its picture leads to the door, its words to the picks;
-- and the picks' right-click where the slot has no link (2026-11-10; translation drafted, to be checked).
L.GEAR_ADVENTURE_MAP_PICK_CLICK = "Clique no ícone para ver o caminho no mapa-múndi; clique no texto para ver as melhorias que você pode escolher."
L.GEAR_ADVENTURE_RUMOUR_PICKS = "Clique com o botão direito para ver as melhorias que você pode escolher."
L.STYLE_STARTING = "Configurações iniciais:"
L.STYLE_LINE_ON = "%s: ativado"
L.STYLE_LINE_OFF = "%s: desativado"
L.STYLE_LINE_ADVENTURE_HIDDEN = "Masmorras, chefes e saque começam ocultos"
L.STYLE_LINE_ADVENTURE_FOG = "Mapas sob névoa até os chefes caírem"
L.STYLE_LINE_ADVENTURE_ON = "Localizador de Equipamento, mapas de acesso e marcas ativados"
L.STYLE_GEAR = "Localizador e pesos de atributos"
L.STYLE_GEAR_TIP = "A aba do Localizador de Equipamento, sua aba no painel do personagem, as linhas de pesos nas dicas dos itens, as setas verdes de melhoria e os pesos do diário no Pawn. Todos usam os mesmos pesos, então andam juntos. Só para este personagem."
L.STYLE_WAY_IN = "Mapas de acesso e cavernas"
L.STYLE_WAY_IN_TIP = "Mapas do caminho até uma masmorra (cavernas, construções, níveis de uma montanha) sobre o mapa-múndi, e suas entradas de caverna e de construção. Os mapas das próprias masmorras ficam. Só para este personagem."
L.STYLE_MARKERS = "Marcas no mapa-múndi"
L.STYLE_MARKERS_TIP = "As marcas do diário no mapa-múndi: entradas de masmorras e raides, mestres de voo, barcos, zepelins, metrôs e portais, suas marcas de missão, níveis das zonas e áreas inexploradas. Só para este personagem."
L.STYLE_CLICK = "Clique para escolher"
L.STYLE_NOW = "Seu estilo agora"
L.STYLE_CLOSE_NOTE = "Fechar mantém %s."
L.STYLE_CHOSEN = "Estilo do diário: %s. Você pode mudá-lo a qualquer momento nas opções do diário (/aegis options)."
L.STYLE_OPTIONS_AFTER_COMBAT = "As opções do diário se abrem quando o combate terminar."
L.STYLE_OPTION = "Estilo do diário"
L.STYLE_OPTION_TIP = "Clássico, Moderno, Modo Aventura ou Personalizado, só para este personagem. Marcar ou desmarcar um recurso abaixo o torna Personalizado (o Modo Aventura continua ativo)."
-- The Reset button under the style's dropdown, and its question (2026-11-03; drafted, to be checked).
L.STYLE_RESET = "Redefinir o Diário de Masmorras"
L.STYLE_RESET_BUTTON = "Redefinir"
L.STYLE_CHOOSE_BUTTON = "Escolher"
L.STYLE_RESET_TIP = "Devolve as opções do diário ao que eram na instalação, para todos os seus personagens, e faz de novo a pergunta de estilo a este personagem. As gravações, os pesos de atributos e o estilo dos seus outros personagens são mantidos."
L.STYLE_RESET_CONFIRM = "Devolver as opções do diário ao que eram na instalação, para todos os seus personagens, e fazer de novo a pergunta de estilo a este personagem? Suas gravações, seus pesos de atributos e o estilo dos seus outros personagens são mantidos."
L.STYLE_GEAR_IS_OFF = "O Localizador de Equipamento está desativado. Ative-o nas opções do diário (/aegis options)."
-- The Record tab's box in the options, and /aegis record while it is off (2026-11-03; drafted, to be checked).
L.OPTIONS_RECORD_TAB = "Mostrar a aba Gravar"
L.OPTIONS_RECORD_TAB_TIP = "A aba que grava suas masmorras para nós. Desmarcada: a aba fica oculta e o diário não grava nada (Capturar vendedor na aba Reputação continua funcionando). O que você já gravou é mantido."
L.RECORD_TAB_IS_OFF = "A aba Gravar está desativada. Ative-a nas opções do diário (/aegis options)."
L.LEGEND_STYLE_OFF = "Desativado nas opções do diário."

-- The run block (UI/RunTracker.lua, Core/Run.lua), 2026-11-11; drafted, to be checked. The client's own words where it has them.
L.RUN_BOSS_DEFEATED = "%s derrotado"
L.RUN_COMPLETE = DUNGEON_COMPLETED or "Masmorra concluída!"
L.RUN_EXPERIENCE = EXPERIENCE_COLON or "Experiência:"
L.RUN_MONEY = MONEY_COLON or "Dinheiro:"
L.RUN_ITEMS = "Itens:"
L.RUN_PER_HOUR = "%s/h"
L.RUN_GREED = "Ganhos por " .. (GREED or "Ganância") .. ": %d"
L.RUN_DEFEATED = BOSS_DEAD or "Derrotado"
L.RUN_NOT_DEFEATED = "Ainda não derrotado"
L.RUN_PARTS = "%s, depois %s"
L.RUN_COIN = "Moedas saqueadas"
L.RUN_ITEM_VALUE = "Itens pelo preço do vendedor"
L.RUN_PENDING = "Aguardando um preço: %d"
L.RUN_DRAG = "Arraste o cabeçalho para movê-lo."
L.RUN_SUMMARY = "%s: %d/%d chefes em %s"
L.RUN_SUMMARY_XP = "%s XP"
L.RUN_SUMMARY_ITEMS = "Itens: %d"
L.RUN_NEW = "Uma nova incursão começa agora."
L.RUN_NOT_INSIDE = "Entre em uma masmorra para começar uma nova incursão."
L.RUN_HIDDEN = "O bloco da incursão está oculto nesta incursão. Digite /ij run para mostrá-lo de novo."
L.RUN_NONE = "Nenhuma incursão em masmorra ainda."
L.RUN_IS_OFF = "O acompanhamento de incursões está desativado. Ative-o nas opções do diário (/aegis options)."
L.RUN_FREE_OFF = "O bloco da incursão voltou para perto do rastreador de missões."
-- The run block's header lock and its chat lines, /ij run lock and unlock now the lock's, and /ij run's usage reworded for them (2026-11-17; drafted, to be checked).
L.RUN_USAGE = "/ij run mostra ou oculta o bloco da incursão (fora de uma masmorra, sua última incursão). /ij run new começa uma nova incursão. /ij run lock e /ij run unlock o travam no lugar ou deixam você movê-lo de novo, como o cadeado do cabeçalho; /ij run reset o devolve para perto do rastreador de missões. /ij run debug mostra o que ele contou."
L.RUN_LOCKED = "Travado"
L.RUN_LOCKED_TIP = "Clique para destravá-lo e depois arraste o bloco pelo cabeçalho."
L.RUN_UNLOCKED = "Destravado"
L.RUN_UNLOCKED_TIP = "Arraste o bloco pelo cabeçalho para movê-lo. Clique para travá-lo no lugar."
L.RUN_LOCK_ON = "O bloco da incursão está travado no lugar."
L.RUN_LOCK_OFF = "O bloco da incursão está destravado: arraste-o pelo cabeçalho para movê-lo."
L.RUN_LOCK_NOT_FREE = "Ele só se move quando é posicionado livremente (\"%s\" nas opções)."
-- The clock's buttons on the run block, between the time and the count (2026-11-14; drafted, to be checked).
L.RUN_CLOCK_START = "Iniciar o relógio agora"
L.RUN_CLOCK_WAITING = "Senão, ele começa sozinho no primeiro combate."
L.RUN_CLOCK_PAUSE = "Pausar o relógio"
L.RUN_CLOCK_RESUME = "Retomar o relógio"
L.RUN_CLOCK_DONE = "A incursão terminou, então o relógio parou."
L.RUN_RESTART = "Nova incursão"
L.RUN_RESTART_CONFIRM = "Começar uma nova incursão? Isso apaga os chefes derrotados e reinicia o relógio."
-- The run block's one line inside a Scarlet Monastery wing before the wing is known (2026-11-17; drafted, to be checked).
L.RUN_WHICH_WING = "Qual ala?"
-- /ij run new or New run before the wing is known: the new run starts once it is (2026-11-17; drafted, to be checked).
L.RUN_NEW_WING = "Uma nova incursão começa assim que a ala for conhecida."
L.OPTIONS_RUN = "Acompanhamento de incursões"
L.OPTIONS_RUN_TIP = "Dentro de uma masmorra, um bloco perto do rastreador de missões mostra quanto tempo a incursão já levou, seus chefes e o que você ganhou. Desativado, nada é contado."
L.OPTIONS_RUN_NUMBERS = "Mostrar experiência e dinheiro"
L.OPTIONS_RUN_NUMBERS_TIP = "Experiência e dinheiro (moedas saqueadas mais o preço de venda dos seus itens), cada um com seu ritmo por hora, e quantos itens você conseguiu."
L.OPTIONS_RUN_FREE = "Posicionar livremente"
-- "Place it freely" on by default since 0.39.23: its tip says so, and what unticking it does (2026-11-17; drafted, to be checked).
L.OPTIONS_RUN_FREE_TIP = "Arraste o bloco pelo cabeçalho para qualquer lugar. Ativado por padrão: até você movê-lo, ele espera perto do rastreador de missões. Desativado, ele fica perto do rastreador de missões e se move com ele. \"No rastreador de missões\" tem prioridade sobre esta opção."
-- The run block's dark mode: its gold art darkened, else the tracker's tint (UI/RunTracker.lua Paint), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_DARK_MODE = "Modo escuro"
L.OPTIONS_RUN_DARK_MODE_TIP = "Escurece o dourado do cabeçalho e da moldura do bloco da incursão. Desativado, o bloco segue a aparência dos cabeçalhos do seu rastreador de missões: fica escuro quando a sua interface os escurece."
L.OPTIONS_RUN_SUMMARY = "Resumo no bate-papo"
L.OPTIONS_RUN_SUMMARY_TIP = "Uma linha no bate-papo um minuto depois que o relógio de uma incursão para (antes, se você sair). Uma incursão que você deixa inacabada recebe sua linha quando termina: quando a masmorra é reiniciada ou depois de meia hora fora."
-- The run block inside the quest tracker: off by default (the owner's call of 2026-11-13; on in 0.39.22's tests), its tip warning of blocked actions in combat until a /reload once the block has been inside the tracker (the owner's words, 2026-11-13), its name marked as a test (UI/RunTrackerInside.lua), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_INSIDE = "No rastreador de missões (teste)"
-- Its tip: beside the tracker with this off only while "Place it freely" is unticked too, since that is on by default (2026-11-17; drafted, to be checked).
L.OPTIONS_RUN_INSIDE_TIP = "O bloco entra no rastreador de missões, logo abaixo de \"" .. (TRACKER_ALL_OBJECTIVES or "Todos os objetivos") .. "\", e as seções do rastreador (" .. (TRACKER_HEADER_QUESTS or "Missões") .. " e as demais) descem para baixo dele. Desativado por padrão. Um rastreador que você moveu no Modo de Edição só é tão alto quanto a altura dele lá: se for baixa demais para o bloco, o diário aumenta essa altura uma vez no seu layout do Modo de Edição e avisa no bate-papo (aparece após um /reload; o botão abaixo faz isso de novo). Até lá, o bloco fica ao lado dele, como desativado e com \"Posicionar livremente\" desmarcado. Depois que o bloco esteve no rastreador, pode causar ações bloqueadas em combate até um /reload. É um teste: se o jogo relatar uma ação bloqueada, ele se desativa sozinho. Depois de usado, só fica totalmente desativado após um /reload."
L.RUN_INSIDE_BLOCKED = "O jogo bloqueou uma ação do diário (%s), então \"No rastreador de missões\" está desativado agora e o bloco da incursão volta para perto do rastreador. Por favor, relate esta linha. Digite /reload para tirá-lo do rastreador por completo."
L.RUN_INSIDE_RELOAD = "\"No rastreador de missões\" está desativado agora e o bloco da incursão volta para perto do rastreador. Digite /reload para tirá-lo do rastreador por completo."
-- The tracker too short for the block inside: the Height it needs, and the options' Make taller button (UI/RunTrackerInside.lua), 2026-11-12; drafted, to be checked.
L.OPTIONS_RUN_TALLER = "Ampliar o rastreador de missões"
L.OPTIONS_RUN_TALLER_BUTTON = "Mais alto"
L.OPTIONS_RUN_TALLER_TIP = "Para \"No rastreador de missões\": define a altura do rastreador de missões no seu layout do Modo de Edição com o que o bloco da incursão precisa e salva o layout. Só para um rastreador que você moveu no Modo de Edição. Use enquanto o bloco aparece, fora de combate e com o Modo de Edição fechado. Aparece após um /reload."
L.RUN_INSIDE_SHORT = "O bloco da incursão fica ao lado do rastreador de missões: o rastreador é baixo demais para contê-lo. Para deixá-lo mais alto: %s, selecione \"%s\", %s %d ou mais. Ou use \"%s\" nas opções do diário (/aegis options)."
L.RUN_INSIDE_SHORT_TIP = "O rastreador de missões é baixo demais para o bloco. Para deixá-lo mais alto: %s, selecione \"%s\", %s %d ou mais."
L.RUN_TALLER_COMBAT = ERR_NOT_IN_COMBAT or "Você não pode fazer isso em combate."
L.RUN_TALLER_EDIT_MODE = "Feche o %s primeiro."
L.RUN_TALLER_DEFAULT = "O rastreador de missões está no lugar padrão, onde vai até a parte de baixo da tela: não há altura para ajustar."
L.RUN_TALLER_UNKNOWN = "Use isto enquanto o bloco da incursão aparece (numa masmorra, ou a sua última incursão com /ij run): a altura dele é medida então."
L.RUN_TALLER_ENOUGH = "O rastreador de missões já é alto o bastante para o bloco da incursão."
L.RUN_TALLER_FAILED = "Não foi possível mudar o seu layout do Modo de Edição daqui. Ajuste você mesmo: %s, selecione \"%s\", %s %d ou mais."
L.RUN_TALLER_DONE = "%s – %s: agora %d no seu layout \"%s\" do Modo de Edição. Digite /reload agora para ver."
L.RUN_TALLER_MOST = "É o máximo que o Modo de Edição permite, então o bloco ainda pode não caber."
-- The tracker's Height raised once by the journal itself when too short, 0.39.22 (UI/RunTrackerInside.lua AutoTaller), 2026-11-12; drafted, to be checked.
L.RUN_INSIDE_AUTO = "O rastreador de missões era baixo demais para o bloco da incursão, então o diário mudou a %s dele de %d para %d no seu layout \"%s\" do Modo de Edição. Digite /reload para ver. Você pode voltar atrás no %s."
L.RUN_INSIDE_SAVED_TIP = "Seu layout do Modo de Edição agora dá ao rastreador de missões uma %s de %d. Digite /reload para ver."
-- Edit Mode opened before the /reload after the journal saved a Height: its old copy (UI/RunTrackerInside.lua EditModeEntered), 2026-11-12; drafted, to be checked.
L.RUN_INSIDE_EDIT_MODE_OLD = "O %s ainda mostra a %s antiga do rastreador de missões até você digitar /reload. Se salvar algo lá agora, a antiga volta."

-- Matched against the client's own text: the client's language's only, previewed or not.
if client then client.EQUIP_PATTERNS, client.AREA_NAMES = L.EQUIP_PATTERNS, L.AREA_NAMES end
L.EQUIP_PATTERNS, L.AREA_NAMES = nil, nil
