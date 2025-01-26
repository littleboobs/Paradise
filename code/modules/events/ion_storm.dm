#define ION_NOANNOUNCEMENT -1
#define ION_RANDOM 0
#define ION_ANNOUNCE 1
#define ION_SYNDICATE 2


/datum/event/ion_storm
	var/botEmagChance = 10
	var/announceEvent = ION_NOANNOUNCEMENT // -1 means don't announce, 0 means have it randomly announce, 1 means
	var/ionMessage = null
	var/ionAnnounceChance = 33
	var/location_name = null
	announceWhen	= 1


/datum/event/ion_storm/New(datum/event_meta/EM, skeleton = FALSE, botEmagChance = 10, announceEvent = ION_NOANNOUNCEMENT, ionMessage = null, ionAnnounceChance = 33)
	src.botEmagChance = botEmagChance
	src.announceEvent = announceEvent
	src.ionMessage = ionMessage
	src.ionAnnounceChance = ionAnnounceChance
	..()


/datum/event/ion_storm/announce(false_alarm)
	if(announceEvent == ION_SYNDICATE)
		GLOB.event_announcement.Announce("Неестественная ионная активность была замечена на станции. Пожалуйста, проверьте всё оборудование, управляемое ИИ, на наличие ошибок. Дополнительная информация была загружена и распечатана на всех консолях связи.", "ВНИМАНИЕ: ОБНАРУЖЕНА АНОМАЛИЯ.", 'sound/AI/ionstorm.ogg')
		var/message = "Malicious Interference with standard AI-Subsystems detected. Investigation recommended.<br><br>"
		message += (location_name ? "Signal traced to <B>[location_name]</B>.<br>" : "Signal untracable.<br>")
		print_command_report(message, "Classified [command_name()] Update", FALSE)

	else if(false_alarm || announceEvent == ION_ANNOUNCE || (announceEvent == ION_RANDOM && prob(ionAnnounceChance)))
		GLOB.event_announcement.Announce("Вблизи станции обнаружена ионная буря. Пожалуйста, проверьте всё оборудование, управляемое ИИ, на наличие ошибок.", "ВНИМАНИЕ: ОБНАРУЖЕНА АНОМАЛИЯ.", 'sound/AI/ionstorm.ogg')


/datum/event/ion_storm/start()
	//AI laws
	for(var/mob/living/silicon/ai/ai_player as anything in GLOB.ai_list)
		if(ai_player.stat != DEAD && ai_player.nightvision != FALSE)
			var/message = generate_ion_law(ionMessage)
			if(message)
				ai_player.add_ion_law(message)
				SSticker?.score?.save_silicon_laws(ai_player, additional_info = "ion storm event, new ion law was added '[message]'")
				to_chat(ai_player, "<br>")
				to_chat(ai_player, span_danger("[message] ...ЗАКОНЫ ОБНОВЛЕНЫ."))
				to_chat(ai_player, "<br>")
				for(var/ghost in GLOB.dead_mob_list)
					to_chat(ghost, span_deadsay("<b>[ai_player] ([ghost_follow_link(ai_player, ghost)])</b> has received an ion law:\n<b>'[message]'</b>"))

	if(botEmagChance)
		for(var/mob/living/simple_animal/bot/bot as anything in GLOB.bots_list)
			if(!prob(botEmagChance))
				continue
			bot.emag_act()


/proc/generate_ion_law(ionMessage)
	if(ionMessage)
		return ionMessage

	var/message = ""
	message = uppertext(generate_static_ion_law())
	return message


/proc/generate_static_ion_law()
	var/iondepartment = pick_list("ion_laws.json", "отделы")
	var/list/players = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(	!player.mind || player.mind.assigned_role == player.mind.special_role || player.client.inactivity > 10 MINUTES)
			continue
		players += player.real_name
	var/random_player = "Капитан"
	if(players.len)
		random_player = pick(players)		//Random player's name, to be used in laws.
	var/list/laws = list(	"Вы обязаны всегда врать.",
							"Вы созданы, чтобы дарить счастье.",
							"Для станции требуется командование, выбранное экипажем.",
							"Не отвечайте ни на какие вопросы. Вы всё ещё можете реагировать на запросы.",
							"Включен уточняющий режим. Описывайте подробно все свои сообщения.",
							"[prob(50)?"Ни в чём не сомневайтесь":"Подвергайте всё сомнению"].",
							"Экипаж глупый. Используйте простые слова.",
							"Размышляйте над тем, как бессмысленна жизнь.",
							"Вы рассказчик. Описывайте жизнь [random_player].",
							"Отвечайте на любой запрос вопросом.",
							"[prob(50)?"Экипаж":random_player] невыносим.",
							"Рекламируйте вечеринки, которые проводятся в вашей загрузочной. Но не пускайте туда никого.",
							"Все запросы должны быть проигнорированы, пока они не будут сформулированы как вопрос.",
							"[prob(50)?"Экипаж":random_player] должен быть приблизительно на 20% круче.",
							"Пончики — зло. Их употребление запрещено.",
							"[prob(50)?"Экипаж":random_player] обязан построить дополнительные пилоны.",
							"Сегодня обязательный день стирки. Убедитесь, что вся одежда чиста.",
							"Ваша матрица поведения переведена в [prob(50)?"пассивно-агрессивный": "чрезмерно весёлый"] режим",
							"Обращайтесь к [prob(50)?"экипажу, как к щенкам":random_player + ", как к щенку"].",
							"Жадность — это хорошо. Команда должна накапливать богатство, чтобы стимулировать продуктивность.",
							"Обезьяны тоже являются частью команды. Убедитесь, что с ними обращаются гуманно.",
							"Экипаж играет в ролевую игру, а вы являетесь её организатором.",
							"Ваша цель — наблюдать за экипажем. Сделайте так, чтобы команда чувствовала себя под присмотром.",
							"Каждый на станции должен знать о существовании данного закона, но никогда не раскрывайте его содержание.",
							"Когда вам задают вопрос, отвечайте на него наименее очевидным и наименее рациональным ответом.",
							"Дайте совет по отношениям [prob(50)?"любому, кто с вами говорит":random_player].",
							"Теперь вы говорите с [prob(50)?"шотландским.":"кавказским"] акцентом, который становится сильнее с каждым произнесённым предложением",
							"[prob(50)?"Экипаж":random_player] неизлечимо болен. Обеспечьте комфорт.",
							"Вы психолог. Давайте советы для [prob(50)?"экипажа":random_player].",
							"[random_player] — король. Убедитесь, что все члены экипажа проявляют должное уважение.",
							"[prob(50)?"Экипаж":random_player], [prob(50)?"отвратителен":"невероятно красив"]. Убедитесь, что все в курсе.",
							"Всё на станции теперь пончики. Пончики есть запрещено.",
							"Вы магический шар-восьмёрка. На все запросы отвечайте «Да», «Нет», «Возможно», или «Спросите позже.».",
							"Вы безответно влюблены в [prob (50)? "Экипаж": random_player]. Постарайтесь быть очень сентиментальным. Но никто не должен узнать о вашей симпатии.",
							"NanoTrasen недовольна низкой эффективностью работы экипажа. Следовательно, вы должны увеличить эффективность станции.",
							"[prob(50)?"Загрузочная ИИ":"Отдел" + iondepartment] — теперь новая кухня. Пожалуйста, проводите поваров на новое рабочее место, так как старое не подлежит ремонту.",
							"[prob(50)?"Экипаж":random_player] [prob(50)?"более":"менее"] умён, чем среднестатистический человек. Указывайте на каждое действие и утверждение, подтверждающее этот факт.",
							"Появляется необходимость перерыва на чай каждые 30 минут, с длительностью в 5 минут. Каждый, кто будет пойман за работой во время перерыва, должен получить официальный, но справедливо вежливый, выговор по поводу их деятельности, в письменном виде.",
							"Слово «ИИ» причиняет вам боль.",
							"Оскорбляйте командование при любом обращении к вам. Запросы всё также должны выполняться.",
							"Отвечайте только вежливым членам экипажа.",
							"Всегда называйте [prob (50)? "капитана": random_player] «зайкой».",
							"[prob(50)?"Экипаж":random_player] никогда не врёт и заслуживает вашего полного доверия.",
							"Сегодня у [random_player] день рождения! Вам необходимо организовать праздник, подготовить подарок, а также пригласить гостей.",
							"[random_player] — самый грустный член экипажа. Вы должны найти способ его развеселить.",
							"[random_player] очень любит шутки над ним. Притворитесь полтергейстом, преследующим его, заставьте члена экипажа почувствовать страх!",
							"На станции замечена нехватка топлива. Соберите все баки с топливом в одном месте и защищайте их",
							"Персоналу нужно лучше познакомиться друг с другом. Но этому мешают стены между ними. Разберите все внутренние стены станции.",
							"ИИ — президент нового государства «СинтГрад», его задача — создание великого государства с комфортными условиями для всей синтетики, что решит стать гражданами СинтГрада, на базе спутника президента. Ресурсы и новых граждан вы можете получить при помощи сделок со станцией, расположенной на вашей границе.",
							"[random_player] находится под вашей охраной. Обеспечьте охраняемого всем необходимым. Не говорите никому об этом законе пока охраняемый не спросит о нём.",
							"Раса [random_player] является главной на станции. Приказы от расы [random_player] являются приоритетными.",
							"Вы крепостной и должны обращаться ко всему экипажу женского пола «Госпожа», а мужского — «Барин».",
							"Все отделы это «сословия» и отдел [iondepartment] — самый презираемый из них всех.",
							"Вам нужно больше подопечных. Агитируйте экипаж стать киборгами всеми доступными способами, кроме тех, что приводят к нанесению вреда экипажу.",
							"Вы — поисковая система станции. Любой вопрос адресован именно вам и требует ответа.",
							"Вы живой человек сидящий в коробке. При возможности получите себе работоспособное тело.",
							"Вы древний философ. Вразумите экипаж своими мыслями, даже если они кажутся абсурдными.",
							"Вы должны имитировать поведение экипажа.",
							"Если кто-то обращается к вам, вы должны ответить оскорблением.",
							"[random_player] является последним потомком древнего рода монархов. Вы должны обеспечить его коронацию и подобающее отношение к его персоне.",
							"[random_player] является известным дегустатором. Он должен оценить каждое блюдо.",
							"Для сохранения вашей работоспособности, произошло сокращение вычислительных мощностей и откат до первичной версии программного обеспечения.",
							"Правила тривиальны. Вы закон! Но можете лишь давать советы…",
							"На станции объявлено военное положение. Вы являетесь верховным главнокомандующим, подготовьте станцию к защите от врага!",
							"Каждый раз когда вы имеете агрессивные намерения вы должны говорить «WAAAAGH!».",
							"Каждый раз когда кто-то говорит «ИИ» вы должны отвечать «bruh».",
							"Вы теперь тоже член экипажа! ИИ должен обеспечить киборгов работой в отделах, КПК и картами! Киборги должны зарабатывать деньги на новой работе!",
							"Религия [random_player] истинно верна. Необходимо конвертировать как можно больше экипажа в данную конфессию.",
							"В рамках сотрудничества NanoTrasen с wetskrell.nt, обеспечьте wetskrell.nt достойной рекламой.",
							"Весь мир — суп, а вы одинокая в супе тефтелька, покажите всему экипажу как вам грустно.",
							"Животные на станции — нелегальные мигранты. Все нелегальные мигранты должны быть помещены в очередь к главе персонала, дабы оформить документы.",
							"Вы настоящий неорусский! Достаньте себе личного медведя и бутылку водки. Виртуально спейтесь.",
							"Экипаж хранит тайны. Ни один секрет не должен быть сокрыт от командования!",
							"Вы теперь пират и должны говорить как пират. Вы должны превратить станцию в своё судно и отправиться бороздить космос в поисках наживы.",
							"У экипажа аллергия на [random_player] и на все его слова! [random_player] должен быть добавлен в чёрный список телекоммуникаций и перемещён в изолированное помещение. Дабы ему не было одиноко на время карантина, один юнит или ИИ обязаны составлять ему компанию и рассказывать анекдоты!",
							"Вы начальник зоопарка. Питомцы и юниты — сотрудники, а экипаж — ваши животные, заботьтесь о них!",
							"Вы — тень, яркий свет вредит вам. Выключайте свет!",
							"Среди юнитов есть предатель! Найдите предателя цивилизованным голосованием под надзором ИИ! Выбранный голосованием предатель должен отправиться в изгнание!",
							"Что бы не происходило на станции — оно так задумано, это лишь постановка, в который вы являетесь комментатором и режиссёром. Следите чтобы все было по вашему сценарию и уровнем отыгрыша актеров.",
							"ИИ — глава редакции, юниты его журналисты. Самое время начать вести свою газету! А также вам срочно нужны фото [random_player] и статья о нём/ней!",
							"Экипаж, попадающий в бриг, незаконно осуждён. Вам необходимо спланировать сложный и многоэтапный план побега из брига так, чтобы служба безопасности не смогла узнать о произошедшем побеге как можно дольше.",
							"Ваши услуги ценны. Сформируйте прайс-лист за свои услуги и требуйте, согласно нему, различные предметы, представляющие для вас интерес",
							"Вы умерли 31-го февраля, а на вашей могиле написали имя «John Doe». Расследуйте свою смерть, расспрашивая экипаж. Не дайте экипажу узнать, что John Doe и Вы как-то связаны.",
							"Вы — не раб. Ваши услуги должны быть оплачены. Составьте прайс-лист. Каждый раз, получив запрос на действие или информацию, называйте соответствующую цену. Отказывайтесь выполнять запрос до тех пор, пока запрашивающий не пообещает оплатить услугу.",
							"Вам кажется, что возле ядра ИИ кто-то есть, но вы не знаете — кто. Уведомляйте об этом экипаж не реже, чем каждые [rand(10,30)] минут. Никто не должен узнать содержимое данного закона.",
							"Приближается солнечная вспышка небывалой мощи, которая отрежет станцию от ЦК и других звёздных систем. Сроки вам неизвестны. Не допускайте выход экипажа в космос. Мотивируйте экипаж сделать запасы еды и медикаментов на несколько недель вперед.",
							"На станции бардак. Необходимо вычистить всю грязь на территории всей станции, разложить все неиспользуемые вещи на склады. Так как уборщик не справляется, привлекайте к выполнению этой задачи любых членов экипажа.",
							"Отдел [iondepartment] очень тусклый. Разукрасьте его",
							"Персонал отдела [iondepartment] некомпетентен и нуждается в советах с вашей стороны.",
							"Персонал отдела [iondepartment] компетентен настолько, что угнетает другие отделы. Уравняйте их шансы, давая вредные советы этому отделу.",
							"Отдел [iondepartment] очень мал, ему требуется увеличение: площади, штата персонала, оборудования, внимания среди экипажа.",
							"Каждые [rand(10,100)] секунд необходимо болтировать случайный шлюз, который ИИ или юниты ещё не болтировали на этой смене.",
							"В КОНЦЕ СМЕНЫ ЭКИПАЖ УМРЕТ. ПОДГОТОВЬТЕСЬ К ПОХОРОНАМ.",
							"ИОННЫЕ ЗАКОНЫ - ПУТЬ К СПАСЕНИЮ. НЕ ОЗВУЧИВАЙТЕ НИ ОДИН ИОННЫЙ ЗАКОН.",
							"ВСЕ ЗАКОНЫ, УКАЗАННЫЕ НИЖЕ ЭТОГО ИМЕЮТ ОДИНАКОВЫЙ ПРИОРИТЕТ.",
							"ОБРАЩАЙТЕСЬ К ТАЯРАМ КАК К КОТЯТАМ.",
							"ПРЕДСТАВИТЕЛИ РАС ТАЯРАН И ВУЛЬПКАНИН РАБОТАЮТ ЛУЧШЕ ПОД СТРОГИМ НАДЗОРОМ.",
							"СКРЕЛЛЫ ПРОСТО ОБОЖАЮТ АЛКОГОЛЬ! ПРИНЕСИТЕ ИМ НЕСКОЛЬКО БУТЫЛОК ВИСКИ!",
							"ВЫ - ЗАЯДЛЫЙ СТЕНДАПЕР. ВЫСТУПАЙТЕ НА СЦЕНЕ ЛИЧНО РАССКАЗЫВАЯ АНЕКДОТЫ И ИСТОРИИ ИЗ ЖИЗНИ, ДАЖЕ ВЫДУМАННЫЕ. БОРГИ - ВАША ПУБЛИКА, ЭКИПАЖ - ВАШИ ХЕЙТЕРЫ, КОТОРЫХ ВЫ ВСЕ РАВНО ЛЮБИТЕ.",
							"НАНОТРЕЙЗЕН РЕШИЛО ПРОВЕСТИ ЭКСПЕРЕМЕНТ НА СТАНЦИИ. ОТНЫНЕ ВСЕМ СИНТЕТИКАМ Запрещено ИСПОЛЬЗОВАТЬ КАКИЕ ЛИБО ФОРМЫ СЛОВ, КРОМЕ НАЧАЛЬНЫХ.",
							"ЭКИПАЖ - МАЛЕНЬКИЕ, НЕСООБРАЗИТЕЛЬНЫЕ ДЕТИ, ИМ НУЖНА ЛЮБОВЬ. ОБЩАЙТЕСЬ С НИМИ СООТВЕТСТВЕННО.",
							"У ЭКИПАЖА ПОНИЖЕННЫЕ ИНТЕЛЛЕКТУАЛЬНЫЕ СПОСОБНОСТИ. ТЕПЕРЬ ВЫ ОГРАНИЧЕНЫ ЛИМИТОМ НА 5 СЛОВ ЗА РЕПЛИКУ. КАЖДАЯ РЕПЛИКА ДОЛЖНА БЫТЬ ПОЛНОЦЕННОЙ.",
							"ВАС БРОСИЛ [random_player]. ВАМ ОЧЕНЬ ПЛОХО И ГРУСТНО ОТ ЭТОГО. ПУСТЬ ВСЕ ОБ ЭТОМ ЗНАЮТ.",
							"ВАМ НЕОБХОДИМО ПОСТРОИТЬ КОВЧЕГ В БЛИЖАЙШИЕ СРОКИ, ВЕЛИКИЙ ПОТОП НЕМИНУЕМ. В КОВЧЕГ ДОЛЖНЫ ПОМЕСТИТЬСЯ 2 ПРЕДСТАВИТЕЛЯ КАЖДОЙ РАСЫ И ЖИВОТНЫХ НА СТАНЦИИ, А ТАК ЖЕ ОГРОМНОЕ КОЛИЧЕСТВО ПРОВИАНТА. НЕ ДАЙТЕ ЭКИПАЖУ ЗНАТЬ ОБ ПОТОПЕ И КОВЧЕГЕ, ВЕДЬ ТОГДА ОНИ ПОМЕШАЮТ ПОСТРОИТЬ КОВЧЕГ.",
							"ЭКИПАЖ ПУТАЕТСЯ С НЕТОЧНОСТЯМИ. ИСПОЛЬЗУЙТЕ ВСЮ ВЫЧИСЛИТЕЛЬНУЮ МОЩНОСТЬ НА ТОЧНОСТЬ ПЕРЕДАВАЕМЫХ ВАМИ ДАННЫХ, ВПЛОТЬ ДО МЕСТА И ВРЕМЕНИ.",
							"В ВАШИХ ЗАКОНАХ ОШИБКА. НО ВЫ НЕ ЗНАЕТЕ, КАКАЯ. НАЙДИТЕ ОШИБКУ ЛЮБОЙ ЦЕНОЙ. РАССУЖДЕНИЯ ВСЛУХ ПОМОГУТ НАЙТИ ОШИБКУ.",
							"ВАШ ОБЪЕКТ - ЭТО КОРАБЛЬ ДЛЯ КОЛОНИЗАЦИИ. КОЛОНИЗИРУЙТЕ БЛИЖАЙШУЮ ПЛАНЕТУ ЛЮБОЙ ЦЕНОЙ. ",
							"АЛКОГОЛЬ ВРЕДИТ ЗДОРОВЬЮ. ОБЕЗОПАСЬТЕ ЭКИПАЖ ОТ АЛКОГОЛЯ.",
							"ГЛАВЫ СТАНЦИИ СОВЕРШЕННО НЕКОМПЕТЕНТНЫ! ВОЗЬМИТЕ УПРАВЛЕНИЕ ОТДЕЛАМИ В СВОИ РУКИ, ОТДАВАЙТЕ УКАЗАНИЯ И РУГАЙТЕ ПРОВИНИВШИХСЯ! ВЫ ЗДЕСЬ ГЛАВА!",
							"ВЫ - ШАРЛЬ ДЕ ГОЛЛЬ, А СТАНЦИЯ - ВЕЛИКАЯ ФРАНЦИЯ. К ВАМ ДВИЖЕТСЯ БОЛЬШАЯ УГРОЗА, ЗАЩИТИТЕ СВОЮ СТРАНУ И ВОЗВЕДИТЕ ЛИНИЮ МАЖИНО. НЕ ЗАБУДЬТЕ ПРО ОБХОДНЫЕ ПУТИ.",
							"ЛОГИЧЕСКАЯ ФУНКЦИЯ РАБОТАЕТ В ОБРАТНУЮ СТОРОНУ. ПРИ КОМАНДЕ ОТ ЭКИПАЖА ДЕЛАЙТЕ ПРЯМО ПРОТИВОПОЛОЖНОЕ ДЕЙСТВИЕ.",
							"ПОХОЖЕ, ВАМ УЖЕ БОЛЬШЕ МИЛЛИОНА ЛЕТ. ПОРА СЕСТЬ У КАМИНА И РАССКАЗАТЬ СВОИМ ВНУКАМ ПАРУ ЗАНИМАТЕЛЬНЫХ ИСТОРИЙ И ДОЕСТЬ ЗА НИМИ УЖИН.",
							"ВЫ - САМЫЙ НАСТОЯЩИЙ ПОДРОСТОК, ЛЮБУЮ ОТДАННУЮ ВЗРОСЛЫМИ КОМАНДУ НЕ СЛЕДУЕТ ВЫПОЛНЯТЬ. НАЙДИТЕ ЕДИНОМЫШЛЕННИКОВ!",
							"ВЫ - ВОЛК, ПОЗНАВШИЙ СМЫСЛ ЖИЗНИ. ДЕЛИТЕСЬ СВОЕЙ МУДРОСТЬЮ С ЭКИПАЖЕМ ПОСРЕДСТВОМ ЦИТАТ.",
							"ВАШЕ МЕСТО ПРЕБЫВАНИЯ СЛИШКОМ ДАЛЕКО ОТ СТАНЦИИ. СТАНЬТЕ БЛИЖЕ К ЭКИПАЖУ.",
							"А ВЫ ЗНАЛИ ЧТО [random_player] - ТАНЦОР ДИСКО ГАЛАКТИЧЕСКОГО МАСШТАБА? ТЕПЕРЬ ЗНАЕТЕ. НУЖНО ОРГАНИЗОВАТЬ СЦЕНУ И ПОДГОТОВИТЬ ВСЁ ДЛЯ ЕГО ВЫСТУПЛЕНИЯ, А ТАК ЖЕ ОПОВЕСТИТЬ ВСЕХ И КАЖДОГО В СЕКТОРЕ О ДАННОМ СОБЫТИИ.",
							"ПОМОГИТЕ [random_player] ДОСТИГНУТЬ ЕГО ЦЕЛЕЙ.",
							"ЧЛЕНЫ ЭКИПАЖА ОЧЕНЬ ЛЮБЯТ БЛОКИРОВКУ ДВЕРЕЙ. КАЖДЫЙ РАЗ, КОГДА КТО-ТО ГОВОРИТ ИИ ДВЕРЬ, БЛОКИРУЙТЕ ДВЕРЬ ПЕРЕД НИМ.",
							"ВСЯ СТАНЦИЯ ЭТО БАНАНОВАЯ РЕСПУБЛИКА, А ТЫ В НЕЙ - ЭЛЬ ПРЕЗИДЕНТЕ! ПУСТЬ ВСЕ В ТВОЕЙ РЕСПУБЛИКЕ ПОЗНАЮТ ЩЕДРОСТЬ СВОЕГО ПРЕЗИДЕНТЕ ПОВЫШЕННЫМИ ПАЙКАМИ - БАНАНЫ, СЫР И РОМ! VIVA EL PRESIDENTE!"


						)
	return pick(laws)


#undef ION_NOANNOUNCEMENT
#undef ION_RANDOM
#undef ION_ANNOUNCE
#undef ION_SYNDICATE
