GLOBAL_LIST_EMPTY(ts_ckey_blacklist)
GLOBAL_VAR_INIT(ts_count_dead, 0)
GLOBAL_VAR_INIT(ts_count_alive_awaymission, 0)
GLOBAL_VAR_INIT(ts_count_alive_station, 0)
GLOBAL_VAR_INIT(ts_death_last, 0)
GLOBAL_VAR_INIT(ts_death_window, 9000) // 15 minutes
GLOBAL_VAR_INIT(ts_default_health, 100)
GLOBAL_LIST_EMPTY(ts_spiderlist)
GLOBAL_LIST_EMPTY(ts_egg_list)
GLOBAL_LIST_EMPTY(ts_spiderling_list)

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: DEFAULTS ---------------------------------
// --------------------------------------------------------------------------------
// Because: http://tvtropes.org/pmwiki/pmwiki.php/Main/SpidersAreScary

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider
	//COSMETIC
	name = "Паучок"
	desc = "Стандартный паук. Если ты это видишь, это баг."
	gender = FEMALE
	icon = 'icons/mob/terrorspider.dmi'
	icon_state = "terror_red"
	icon_living = "terror_red"
	icon_dead = "terror_red_dead"
	attack_sound = 'sound/creatures/terrorspiders/bite.ogg'
	deathmessage = "Screams in pain and slowly stops moving."
	death_sound = 'sound/creatures/terrorspiders/death.ogg'
	var/spider_intro_text = "Если ты это видишь, это баг."
	speak_chance = 0 // quiet but deadly
	speak_emote = list("hisses")
	emote_hear = list("hisses")
	sentience_type = SENTIENCE_ARTIFICIAL
	response_disarm_simple = "gently pushes aside"
	response_help_simple = "осторожно проводит лапками по"
	footstep_type = FOOTSTEP_MOB_CLAW
	talk_sound = list('sound/creatures/terrorspiders/speech_1.ogg', 'sound/creatures/terrorspiders/speech_2.ogg', 'sound/creatures/terrorspiders/speech_3.ogg', 'sound/creatures/terrorspiders/speech_4.ogg', 'sound/creatures/terrorspiders/speech_5.ogg', 'sound/creatures/terrorspiders/speech_6.ogg')
	damaged_sound = list('sound/creatures/terrorspiders/speech_1.ogg', 'sound/creatures/terrorspiders/speech_2.ogg', 'sound/creatures/terrorspiders/speech_3.ogg', 'sound/creatures/terrorspiders/speech_4.ogg', 'sound/creatures/terrorspiders/speech_5.ogg', 'sound/creatures/terrorspiders/speech_6.ogg')
	faction = list(ROLE_TERROR_SPIDER)

	//HEALTH
	maxHealth = 100
	health = 100
	a_intent = INTENT_HARM
	var/regeneration = 1 //pure regen on life
	var/degenerate = FALSE // if TRUE, they slowly degen until they all die off.
	//also regenerates by using /datum/status_effect/terror/food_regen when wraps a carbon, wich grants full health witin ~25 seconds
	damage_coeff = list(BRUTE = 0.85, BURN = 1, TOX = 1, CLONE = 0, STAMINA = 0, OXY = 1)

	//ATTACK
	melee_damage_lower = 15
	melee_damage_upper = 20
	obj_damage = 25

	//MOVEMENT
	movement_type = GROUND
	pass_flags = PASSTABLE
	turns_per_move = 3 // number of turns before AI-controlled spiders wander around. No effect on actual player or AI movement speed!
	move_to_delay = 6
	speed = 0
	var/magpulse = 1
	// AI spider speed at chasing down targets. Higher numbers mean slower speed. Divide 20 (server tick rate / second) by this to get tiles/sec.

	//SPECIAL
	var/list/special_abillity = list()  //has spider unique abillities?
	var/can_wrap = TRUE   //can spider wrap corpses and objects?
	var/web_type = /obj/structure/spider/terrorweb
	var/delay_web = 25 // delay between starting to spin web, and finishing
	faction = list("terrorspiders")
	var/spider_opens_doors = 1 // all spiders can open firedoors (they have no security). 1 = can open depowered doors. 2 = can open powered doors
	var/ai_ventcrawls = TRUE
	var/idle_ventcrawl_chance = 15
	var/freq_ventcrawl_combat = 1800 // 3 minutes
	var/freq_ventcrawl_idle =  9000 // 15 minutes
	var/last_ventcrawl_time = -9000 // Last time the spider crawled. Used to prevent excessive crawling. Setting to freq*-1 ensures they can crawl once on spawn.
	var/ai_ventbreaker = 0
	// AI movement tracking
	var/spider_steps_taken = 0 // leave at 0, its a counter for ai steps taken.
	var/spider_max_steps = 15 // after we take X turns trying to do something, give up!
	var/ventcrawler = 1
	initial_language_holder = /datum/language_holder/terror_spiders

	// Vision
	vision_range = 10
	aggro_vision_range = 10
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	sight = SEE_TURFS|SEE_MOBS|SEE_OBJS

	// AI aggression settings
	var/ai_target_method = TS_DAMAGE_SIMPLE

	// AI player control by ghosts
	var/ai_playercontrol_allowtype = 1 // if 0, this specific class of spider is not player-controllable. Default set in code for each class, cannot be changed.

	var/ai_break_lights = TRUE // AI lightbreaking behavior
	var/freq_break_light = 600
	var/last_break_light = 0 // leave this, changed by procs.

	var/ai_spins_webs = TRUE // AI web-spinning behavior
	var/freq_spins_webs = 600
	var/last_spins_webs = 0 // leave this, changed by procs.

	var/freq_cocoon_object = 1200 // two minutes between each attempt
	var/last_cocoon_object = 0 // leave this, changed by procs.

	var/spider_awaymission = 0 // if 1, limits certain behavior in away missions
	var/spider_uo71 = 0 // if 1, spider is in the UO71 away mission
	var/spider_unlock_id_tag = "" // if defined, unlock awaymission blast doors with this tag on death
	var/spider_placed = 0

	// AI variables designed for use in procs
	var/atom/movable/cocoon_target // for queen and nurse
	var/obj/machinery/atmospherics/components/unary/vent_pump/entry_vent // nearby vent they are going to try to get to, and enter
	var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent // remote vent they intend to come out of
	var/obj/machinery/atmospherics/components/unary/vent_pump/nest_vent // home vent, usually used by queens
	var/fed = 0
	var/travelling_in_vent = 0
	var/path_to_vent = 0
	var/killcount = 0
	var/busy = 0 // leave this alone!
	var/spider_tier = TS_TIER_1 // 1 for red,gray,green. 2 for purple,black,white, 3 for prince, mother. 4 for queen
	var/wall_destroy_hardness = 50
	var/hasdied = 0
	var/list/spider_special_drops = list()
	var/attackstep = 0
	var/attackcycles = 0
	var/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/queen/spider_myqueen = null
	var/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/spider_mymother = null
	var/mylocation = null
	var/chasecycles = 0
	var/web_infects = 0
	var/spider_creation_time = 0

	var/datum/action/terrorspider/web/web_action
	var/datum/action/terrorspider/wrap/wrap_action

	// Breathing - require some oxygen, and no toxins
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 40 // Не могут жить в безвоздушном пространстве, но очень даже могут в разгерметизациях от экипажа с минимальным воздухом и без токсинов
	// Temperature
	unsuitable_atmos_damage = 6.5 // Takes 250% normal damage from being in a hot environment ("kill it with fire!")

	// DEBUG OPTIONS & COMMANDS
	var/spider_growinstantly = FALSE
	var/spider_debug = FALSE

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/Initialize(mapload)
	. = ..()

	if(ventcrawler)
		AddElement(/datum/element/ventcrawling, given_tier = VENTCRAWLER_ALWAYS)

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/get_status_tab_items()
	. = ..()
	. += "Intent: [a_intent]"

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: SHARED ATTACK CODE -----------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	// Forces terrors to use the 'bite' graphic when attacking something. Same as code/modules/mob/living/carbon/alien/larva/larva_defense.dm#L34
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_BITE
	..()

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/AttackingTarget()
	if(isterrorspider(target))
		if(target in enemies)
			enemies -= target
		var/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/T = target
		if(T.spider_tier > spider_tier)
			visible_message("<span class='notice'>[src] cowers before [target].</span>")
		else if(T.spider_tier == spider_tier)
			visible_message("<span class='notice'>[src] nuzzles [target].</span>")
		else if(T.spider_tier < spider_tier && spider_tier >= 4)
			target.attack_animal(src)
		else
			visible_message("<span class='notice'>[src] harmlessly nuzzles [target].</span>")
		T.CheckFaction()
		CheckFaction()
	else if(istype(target, /obj/structure/spider/royaljelly))
		consume_jelly(target)
	else if(istype(target, /obj/structure/spider)) // Prevents destroying coccoons (exploit), eggs (horrible misclick), etc
		to_chat(src, "Destroying things created by fellow spiders would not help us.")
	else if(istype(target, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/F = target
		if(F.density)
			if(F.welded)
				to_chat(src, "The fire door is welded shut.")
			else
				visible_message("<span class='danger'>[src] pries open the firedoor!</span>")
				F.open()
		else
			to_chat(src, "Closing fire doors does not help.")
	else if(istype(target, /turf/closed/wall))
		var/turf/closed/wall/W = target
		if (src.wall_destroy_hardness <= W.hardness)
			if (do_after(src, 100 / W.hardness * 10, target = W))
				playsound(W, 'sound/effects/meteorimpact.ogg', 100, 1)
				W.dismantle_wall(1)
	else if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target
		if (!try_open_airlock(A))
			target.attack_animal(src)
	else if(isliving(target) && (!client || a_intent == INTENT_HARM))
		var/mob/living/G = target
		if(issilicon(G))
			G.attack_animal(src)
			return
		else if(G.reagents && (iscarbon(G)))
			var/can_poison = 1
			if(ishuman(G))
				var/mob/living/carbon/human/H = G
				if(!H.physiology.tox_mod)
					can_poison = 0
			spider_specialattack(G,can_poison)
		else
			G.attack_animal(src)
	else
		target.attack_animal(src)

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/proc/spider_specialattack(mob/living/carbon/human/L, poisonable)
	L.attack_animal(src)

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/proc/consume_jelly(obj/structure/spider/royaljelly/J)
	if(health == maxHealth)
		to_chat(src, "<span class='warning'>You don't need healing!</span>")
		return
	to_chat(src, "<span class='notice'>You consume royal jelly to heal yourself!</span>")
	playsound(src.loc, 'sound/creatures/terrorspiders/jelly.ogg', 100, 1)
	apply_status_effect(STATUS_EFFECT_TERROR_REGEN)
	qdel(J)

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: PROC OVERRIDES ---------------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/examine(mob/user)
	. = ..()
	if(stat != DEAD)
		if(key)
			. += "<span class='warning'>[p_they(TRUE)] regards [p_their()] surroundings with a curious intelligence.</span>"
		if(health > (maxHealth*0.95))
			. += "<span class='notice'>[p_they(TRUE)] is in excellent health.</span>"
		else if(health > (maxHealth*0.75))
			. += "<span class='notice'>[p_they(TRUE)] has a few injuries.</span>"
		else if(health > (maxHealth*0.55))
			. += "<span class='warning'>[p_they(TRUE)] has many injuries.</span>"
		else if(health > (maxHealth*0.25))
			. += "<span class='warning'>[p_they(TRUE)] is barely clinging on to life!</span>"
		if(degenerate)
			. += "<span class='warning'>[p_they(TRUE)] appears to be dying.</span>"
		if(killcount >= 1)
			. += "<span class='warning'>[p_they(TRUE)] has blood dribbling from [p_their()] mouth.</span>"

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/New()
	..()
	GLOB.ts_spiderlist += src
	grant_language(/datum/language/terrorspiders)
	for(var/spell in special_abillity)
		src.AddSpell(new spell)

	if(spider_tier >= TS_TIER_2)
		grant_language(/datum/language/common)

	if(web_type)
		web_action = new()
		web_action.Grant(src)
	if(can_wrap)
		wrap_action = new()
		wrap_action.Grant(src)
	name += " ([rand(1, 1000)])"
	real_name = name
	msg_terrorspiders("[src] has grown in [get_area(src)].")
	if(is_away_level(z))
		spider_awaymission = 1
		GLOB.ts_count_alive_awaymission++
		if(spider_tier >= 3)
			ai_ventcrawls = FALSE // means that pre-spawned bosses on away maps won't ventcrawl. Necessary to keep prince/mother in one place.
		if(istype(get_area(src), /area/awaymission)) // if we are playing the away mission with our special spiders... // Перенести наполненную Террорами локацию в Гейт.
			spider_uo71 = 1
			if(world.time < 600)
				// these are static spiders, specifically for the UO71 away mission, make them stay in place
				ai_ventcrawls = FALSE
				spider_placed = 1
	else
		GLOB.ts_count_alive_station++
	// after 3 seconds, assuming nobody took control of it yet, offer it to ghosts.
	addtimer(CALLBACK(src, PROC_REF(CheckFaction)), 20)
	addtimer(CALLBACK(src, PROC_REF(announcetoghosts)), 30)
	var/datum/atom_hud/U = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	U.add_hud_to(src)
	spider_creation_time = world.time

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/proc/announcetoghosts()
	if(spider_awaymission)
		return
	if(stat == DEAD)
		return
	if(ckey)
		notify_ghosts("[src] (player controlled) has appeared in [get_area(src)].")
	else if(ai_playercontrol_allowtype)
		var/image/alert_overlay = image('icons/mob/terrorspider.dmi', icon_state)
		notify_ghosts("[src] has appeared in [get_area(src)].", enter_link = "<a href=?src=[REF(src)];activate=1>(Click to control)</a>", source = src, alert_overlay = alert_overlay, action = NOTIFY_ATTACK)

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/Destroy()
	GLOB.ts_spiderlist -= src
	handle_dying()
	return ..()

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/Life(seconds, times_fired)
	. = ..()
	if(stat == DEAD) // Can't use if(.) for this due to the fact it can sometimes return FALSE even when mob is alive.
		if(prob(10))
			// 10% chance every cycle to decompose
			visible_message("<span class='notice'>\The dead body of the [src] decomposes!</span>")
			gib()
	else
		if(health < maxHealth)
			adjustBruteLoss(-regeneration)
		if(degenerate)
			adjustBruteLoss(6)
		if(prob(5))
			CheckFaction()

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/proc/handle_dying()
	if(!hasdied)
		hasdied = 1
		GLOB.ts_count_dead++
		GLOB.ts_death_last = world.time
		if(spider_awaymission)
			GLOB.ts_count_alive_awaymission--
		else
			GLOB.ts_count_alive_station--

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/proc/give_intro_text()
	to_chat(src, "<center><span class='userdanger'>Вы паук ужаса!</span></center>")
	to_chat(src, "<center>Работайте сообща, помогайте своим братьям и сёстрам, саботируйте станцию, убивайте экипаж, превратите это место в своё гнездо! Чтобы общаться с другими пауками используйте :t</center>")
	to_chat(src, "<center><span class='big'>[spider_intro_text]</span></center><br>")
	SEND_SOUND(src, sound('sound/ambience/antag/terrorspider.ogg'))

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/death(gibbed)
	if(can_die())
		if(!gibbed)
			msg_terrorspiders("[src] has died in [get_area(src)].")
		handle_dying()
	return ..()

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/proc/spider_special_action()
	return

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/ObjBump(obj/O)
	if(istype(O, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/L = O
		if(L.density) // must check density here, to avoid rapid bumping of an airlock that is in the process of opening, instantly forcing it closed
			return try_open_airlock(L)
	if(istype(O, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/F = O
		if(F.density && !F.welded)
			F.open()
			return 1
	. = ..()

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/proc/msg_terrorspiders(msgtext)
	for(var/thing in GLOB.ts_spiderlist)
		var/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/T = thing
		if(T.stat != DEAD)
			to_chat(T, "<span class='terrorspider'>TerrorSense: [msgtext]</span>")

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/proc/CheckFaction()
	if(faction.len != 2 || (!("terrorspiders" in faction)) || master_commander != null)
		to_chat(src, "<span class='userdanger'>Your connection to the hive mind has been severed!</span>")
		log_runtime(EXCEPTION("Terror spider with incorrect faction list at: [atom_loc_line(src)]"))
		gib()

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/proc/try_open_airlock(obj/machinery/door/airlock/D)
	if(D.operating)
		return FALSE
	if(D.welded)
		to_chat(src, "<span class='warning'>The door is welded.</span>")
	else if(D.locked)
		to_chat(src, "<span class='warning'>The door is bolted.</span>")
	else if(D.allowed(src))
		if(D.density)
			D.open(TRUE)
		else
			D.close(TRUE)
		return TRUE
	else if(D.hasPower() && (spider_opens_doors != 2))
		to_chat(src, "<span class='warning'>The door's motors resist your efforts to force it.</span>")
	else if(!spider_opens_doors)
		to_chat(src, "<span class='warning'>Your type of spider is not strong enough to force open doors.</span>")
	else
		playsound(D, 'sound/machines/airlock_alien_prying.ogg', 100, 1)
		if (do_after(src, 20, target = D))
			if(D.density)
				D.open(TRUE)
			else
				D.close(TRUE)
		visible_message("<span class='danger'>[src] forces the door!</span>")
		playsound(src.loc, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/get_spacemove_backup()
	. = ..()
	// If we don't find any normal thing to use, attempt to use any nearby spider structure instead.
	if(!.)
		for(var/obj/structure/spider/S in range(1, get_turf(src)))
			return S

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/Stat()
	..()
	// Determines what shows in the "Status" tab for player-controlled spiders. Used to help players understand spider health regeneration mechanics.
	// Uses <font color='#X'> because the status panel does NOT accept <span class='X'>.
	if(statpanel("Status") && ckey && stat == CONSCIOUS)
		if(degenerate)
			stat(null, "<font color='#eb4034'>Hivemind Connection Severed! Dying...</font>") // color=red
			return

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/proc/DoRemoteView()
	if(!isturf(loc))
		// This check prevents spiders using this ability while inside an atmos pipe, which will mess up their vision
		to_chat(src, "<span class='warning'>You must be standing on a floor to do this.</span>")
		return
	if(client && (client.eye != client.mob))
		reset_perspective()
		return
	if(health <= (maxHealth*0.75))
		to_chat(src, "<span class='warning'>You must be at full health to do this!</span>")
		return
	var/list/targets = list()
	targets += src // ensures that self is always at top of the list
	for(var/thing in GLOB.ts_spiderlist)
		var/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/T = thing
		if(T.stat == DEAD)
			continue
		if(T.spider_awaymission != spider_awaymission)
			continue
		targets |= T // we use |= instead of += to avoid adding src to the list twice
	var/mob/living/L = input("Choose a terror to watch.", "Selection") in targets
	if(istype(L))
		reset_perspective(L)

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/CanPass(atom/movable/O)
	if(istype(O, /obj/item/projectile/terrorspider))
		return TRUE
	return ..()

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/mob_negates_gravity()
	return magpulse

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/mob_has_gravity()
	return ..() || mob_negates_gravity()

/mob/living/simple_animal/hostile/retaliate/poison/terror_spider/experience_pressure_difference(pressure_difference, direction)
	if(!magpulse)
		return ..()

/obj/item/projectile/terrorspider
	name = "basic"
	damage = 0
	icon_state = "toxin"
	damage_type = TOX

/obj/item/projectile/terrorspider/process_hit(turf/T, atom/target, atom/bumped, hit_something = FALSE)
	if(istype(target, /mob/living/simple_animal/hostile/retaliate/poison/terror_spider))
		qdel(src)
		return
	. = ..()
