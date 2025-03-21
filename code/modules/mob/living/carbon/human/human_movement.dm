/mob/living/carbon/human/movement_delay()

	var/tally = ..()
	if(species.slowdown)
		tally += species.slowdown
	if (istype(loc, /turf/space)) // It's hard to be slowed down in space by... anything
		return tally

	if(embedded_flag)
		handle_embedded_objects() //Moving with objects stuck in you can cause bad times.
	if(CE_SPEEDBOOST in chem_effects)
		tally -= chem_effects[CE_SPEEDBOOST]
	if(CE_SLOWDOWN in chem_effects)
		tally += chem_effects[CE_SLOWDOWN]
	if(isturf(loc))
		var/turf/T = loc
		if(T.get_lumcount() < 0.6)
			if(stats.getPerk(PERK_NIGHTCRAWLER))
				tally -= 0.5
			else if(see_invisible != SEE_INVISIBLE_NOLIGHTING)
				tally += 0.5
	if(stats.getPerk(PERK_FAST_WALKER))
		tally -= 0.5
	if(stats.getPerk(PERK_NANITE_MUSCLE))
		tally -= 0.4
	if(stats.getPerk(PERK_SCUTTLEBUG))
		tally -= 0.3
	if(stats.getPerk(PERK_REZ_SICKNESS))
		tally += 0.90

	var/obj/item/implant/core_implant/cruciform/C = get_core_implant(/obj/item/implant/core_implant/cruciform)
	if(C && C.active)
		var/obj/item/cruciform_upgrade/upgrade = C.upgrade
		if(upgrade && upgrade.active && istype(upgrade, CUPGRADE_SPEED_OF_THE_CHOSEN))
			var/obj/item/cruciform_upgrade/speed_of_the_chosen/sotc = upgrade
			tally -= sotc.speed_increase

	var/health_deficiency = (maxHealth - health)
	var/hunger_deficiency = (MOB_BASE_MAX_HUNGER - nutrition)
	if((hunger_deficiency >= 200) && species.reagent_tag != IS_SYNTHETIC)
		tally += (hunger_deficiency / 100) //If youre starving, movement slowdown can be anything up to 4.
	if(health_deficiency >= 40)
		tally += (health_deficiency / 25)

	if (!(species && (species.flags & NO_PAIN)))
		if(halloss >= 10) tally += (halloss / 20) //halloss shouldn't slow you down if you can't even feel it
	if(istype(buckled, /obj/structure/bed/chair/wheelchair))
		//Not porting bay's silly organ checking code here
		tally += 1 //Small slowdown so wheelchairs aren't turbospeed
	else
		if(wear_suit && !src.stats.getPerk(PERK_SECOND_SKIN))
			tally += wear_suit.slowdown
		if(shoes)
			tally += shoes.slowdown

	if(shock_stage >= 10) tally += 3

	//if(stats.getPerk(/datum/perk/timeismoney)?.is_active())
		//tally -= 2

	if (bodytemperature < 283.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75
	tally += stance_damage // missing/damaged legs or augs affect speed

	if(slowdown)
		tally += 1

	tally += (r_hand?.slowdown_hold + l_hand?.slowdown_hold)

	return tally


/mob/living/carbon/human/allow_spacemove()
	//Can we act?
	if(restrained())	return 0

	//Do we have a working jetpack?
	var/obj/item/tank/jetpack/thrust = get_jetpack()

	if(thrust)
		if(thrust.allow_thrust(JETPACK_MOVE_COST, src))
			if (thrust.stabilization_on)
				return TRUE
			return -1

	//If no working jetpack then use the other checks
	return ..()

/mob/living/carbon/human/slip_chance(var/prob_slip = 5)
	if(!..())
		return 0

	//Check hands and mod slip
	if(!l_hand)
		prob_slip -= 2
	else if(l_hand.w_class <= ITEM_SIZE_SMALL)
		prob_slip -= 1
	if (!r_hand)
		prob_slip -= 2
	else if(r_hand.w_class <= ITEM_SIZE_SMALL)
		prob_slip -= 1

	return prob_slip

/mob/living/carbon/human/check_shoegrip()
	if(species.flags & NO_SLIP)
		return 1
	if(shoes && (shoes.item_flags & NOSLIP) && istype(shoes, /obj/item/clothing/shoes/magboots))  //magboots + dense_object = no floating
		return 1
	return 0


/mob/living/carbon/human/add_momentum(direction)
	if(momentum_dir == direction)
		momentum_speed++
	else if(momentum_dir == reverse_dir[direction])
		momentum_speed = 0
		momentum_dir = direction
	else
		momentum_speed--
		momentum_dir = direction
	momentum_speed = CLAMP(momentum_speed, 0, 10)
	update_momentum()

/mob/living/carbon/human/proc/update_momentum()
	if(momentum_speed)
		momentum_reduction_timer = addtimer(CALLBACK(src, .proc/calc_momentum), 1 SECONDS, TIMER_STOPPABLE)
	else
		momentum_speed = 0
		deltimer(momentum_reduction_timer)

/mob/living/carbon/human/proc/calc_momentum()
	momentum_speed--
	update_momentum()
