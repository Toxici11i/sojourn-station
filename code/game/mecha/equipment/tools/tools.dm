/*
 * Contains
 * /obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp
 * /obj/item/mecha_parts/mecha_equipment/tool/drill
 * /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill
 * /obj/item/mecha_parts/mecha_equipment/tool/extinguisher
 * /obj/item/mecha_parts/mecha_equipment/tool/rcd
 * /obj/item/mecha_parts/mecha_equipment/teleporter
 * /obj/item/mecha_parts/mecha_equipment/wormhole_generator
 * /obj/item/mecha_parts/mecha_equipment/gravcatapult
 * /obj/item/mecha_parts/mecha_equipment/armor_booster
 * /obj/item/mecha_parts/mecha_equipment/armor_booster/anticcw_armor_booster
 * /obj/item/mecha_parts/mecha_equipment/armor_booster/antiproj_armor_booster
 * /obj/item/mecha_parts/mecha_equipment/repair_droid
 * /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
 * /obj/item/mecha_parts/mecha_equipment/generator
 * /obj/item/mecha_parts/mecha_equipment/generator/nuclear
 * /obj/item/mecha_parts/mecha_equipment/tool/safety_clamp
 * /obj/item/mecha_parts/mecha_equipment/tool/passenger
 * /obj/item/mecha_parts/mecha_equipment/thruster
 */

/obj/item/mecha_parts/mecha_equipment/tool
	matter = list(MATERIAL_STEEL = 15)

/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp
	name = "hydraulic clamp"
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 10
	var/dam_force = 20
	var/obj/mecha/working/ripley/cargo_holder
	required_type = list(/obj/mecha/working, /obj/mecha/combat, /obj/mecha/medical)

	attach(obj/mecha/M as obj)
		..()
		cargo_holder = M
		return

	action(atom/target)
		if(!action_checks(target)) return
		if(!cargo_holder) return

		//loading
		if(isobj(target))
			var/obj/O = target
			if(O.buckled_mob)
				return
			if(locate(/mob/living) in O)
				occupant_message(SPAN_WARNING("You can't load living things into the cargo compartment."))
				return
			if(istype(target, /obj/structure/scrap))
				occupant_message(SPAN_NOTICE("\The [chassis] begins compressing \the [O] with \the [src]."))
				if(do_after_cooldown(O))
					if(istype(O, /obj/structure/scrap))
						var/obj/structure/scrap/S = O
						S.make_cube()
						occupant_message(SPAN_NOTICE("\The [chassis] compresses \the [O] into a cube with \the [src]."))
				return
			if(O.anchored && !istype(O, /obj/structure/salvageable))
				occupant_message(SPAN_WARNING("[target] is firmly secured."))
				return
			if(cargo_holder.cargo.len >= cargo_holder.cargo_capacity)
				occupant_message(SPAN_WARNING("Not enough room in cargo compartment."))
				return


			occupant_message("You lift [target] and start to load it into cargo compartment.")
			playsound(src,'sound/mecha/hydraulic.ogg',100,1)
			chassis.visible_message("[chassis] lifts [target] and starts to load it into cargo compartment.")
			set_ready_state(0)
			chassis.use_power(energy_drain)
			O.anchored = 1
			var/T = chassis.loc
			if(do_after_cooldown(target))
				if(T == chassis.loc && src == chassis.selected)
					cargo_holder.cargo += O
					O.loc = chassis
					O.anchored = 0
					occupant_message(SPAN_NOTICE("[target] succesfully loaded."))
					log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]")
				else
					occupant_message(SPAN_WARNING("You must hold still while handling objects."))
					O.anchored = initial(O.anchored)

		//attacking
		else if(isliving(target))
			var/mob/living/M = target
			if(M.stat>1) return
			if(chassis.occupant.a_intent == I_HURT)
				M.take_overall_damage(dam_force)
				M.adjustOxyLoss(round(dam_force/2))
				M.updatehealth()
				occupant_message(SPAN_WARNING("You squeeze [target] with [src.name]. Something cracks."))
				chassis.visible_message(SPAN_WARNING("[chassis] squeezes [target]."))
			else
				step_away(M,chassis)
				occupant_message("You push [target] out of the way.")
				chassis.visible_message("[chassis] pushes [target] out of the way.")
			set_ready_state(0)
			chassis.use_power(energy_drain)
			do_after_cooldown()
		return 1

/obj/item/mecha_parts/mecha_equipment/tool/drill
	name = "drill"
	desc = "This is the drill that'll pierce the heavens! (Can be attached to: Combat and Engineering Exosuits)"
	icon_state = "mecha_drill"
	equip_cooldown = 30
	energy_drain = 10
	price_tag = 150
	force = WEAPON_FORCE_DANGEROUS
	required_type = list(/obj/mecha/working, /obj/mecha/combat, /obj/mecha/medical)

	action(atom/target)
		if(!action_checks(target)) return
		if(isobj(target))
			var/obj/target_obj = target
			if(!target_obj.vars.Find("unacidable") || target_obj.unacidable)	return
		set_ready_state(0)
		chassis.use_power(energy_drain)
		chassis.visible_message(SPAN_DANGER("\The [chassis] starts to drill \the [target]"), SPAN_WARNING("You hear a large drill."))
		occupant_message(SPAN_DANGER("You start to drill \the [target]"))
		playsound(src,'sound/mecha/mechdrill.ogg',40,1)
		var/T = chassis.loc
		var/C = target.loc	//why are these backwards? we may never know -Pete
		if(do_after_cooldown(target))
			if(T == chassis.loc && src == chassis.selected)
				if(istype(target, /turf/simulated/wall))
					var/turf/simulated/wall/W = target
					if(W.reinf_material)
						occupant_message(SPAN_WARNING("\The [target] is too durable to drill through."))
					else
						log_message("Drilled through \the [target]")
						target.ex_act(2)
				else if(istype(target, /turf/simulated/mineral))
					for(var/turf/simulated/mineral/M in trange(1, chassis))
						if(get_dir(chassis,M)&chassis.dir)
							M.GetDrilled()
					log_message("Drilled through \the [target]")
					if(locate(/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp) in chassis.equipment)
						var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in chassis:cargo
						if(ore_box)
							for(var/obj/item/stack/ore/ore in range(chassis,1))
								if(get_dir(chassis,ore)&chassis.dir)
									ore.Move(ore_box)
				else if(istype(target, /turf/simulated/floor/asteroid))
					for(var/turf/simulated/floor/asteroid/M in trange(1, chassis))
						if(get_dir(chassis,M)&chassis.dir)
							M.gets_dug()
					log_message("Drilled through \the [target]")
					if(locate(/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp) in chassis.equipment)
						var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in chassis:cargo
						if(ore_box)
							for(var/obj/item/stack/ore/ore in range(chassis,1))
								if(get_dir(chassis,ore)&chassis.dir)
									ore.Move(ore_box)
				else if(target.loc == C)
					log_message("Drilled through \the [target]")
					target.ex_act(2)
		return 1

/obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill
	name = "diamond drill"
	desc = "This is an upgraded version of the drill that'll pierce the heavens! (Can be attached to: Combat and Engineering Exosuits)"
	icon_state = "mecha_diamond_drill"
	origin_tech = list(TECH_MATERIAL = 4, TECH_ENGINEERING = 3)
	matter = list(MATERIAL_STEEL = 15, MATERIAL_DIAMOND = 3)
	equip_cooldown = 10 // 3 diamonds for 3x the speed!
	force = 25 //Lets not be out classed by a wrench...

	action(atom/target)
		if(!action_checks(target)) return
		if(isobj(target))
			var/obj/target_obj = target
			if(target_obj.unacidable)	return
		set_ready_state(0)
		chassis.use_power(energy_drain)
		chassis.visible_message(SPAN_DANGER("\The [chassis] starts to drill \the [target]"), SPAN_WARNING("You hear a large drill."))
		occupant_message(SPAN_DANGER("You start to drill \the [target]"))
		playsound(src,'sound/mecha/mechdrill.ogg',40,1)
		var/T = chassis.loc
		var/C = target.loc	//why are these backwards? we may never know -Pete
		if(do_after_cooldown(target))
			if(T == chassis.loc && src == chassis.selected)
				if(istype(target, /turf/simulated/wall))
					var/turf/simulated/wall/W = target
					if(!W.reinf_material || do_after_cooldown(target))//To slow down how fast mechs can drill through the station
						log_message("Drilled through \the [target]")
						target.ex_act(3)
				else if(istype(target, /turf/simulated/mineral))
					for(var/turf/simulated/mineral/M in trange(1, chassis))
						if(get_dir(chassis,M)&chassis.dir)
							M.GetDrilled()
					log_message("Drilled through \the [target]")
					if(locate(/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp) in chassis.equipment)
						var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in chassis:cargo
						if(ore_box)
							for(var/obj/item/stack/ore/ore in range(chassis,1))
								if(get_dir(chassis,ore)&chassis.dir)
									ore.Move(ore_box)
				else if(istype(target,/turf/simulated/floor/asteroid))
					for(var/turf/simulated/floor/asteroid/M in trange(1, target))
						M.gets_dug()
					log_message("Drilled through \the [target]")
					if(locate(/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp) in chassis.equipment)
						var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in chassis:cargo
						if(ore_box)
							for(var/obj/item/stack/ore/ore in range(target,1))
								ore.Move(ore_box)
				else if(target.loc == C)
					log_message("Drilled through \the [target]")
					target.ex_act(2)
		return 1

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher
	name = "extinguisher"
	desc = "Exosuit-mounted extinguisher (Can be attached to: Engineering exosuits)"
	icon_state = "mecha_exting"
	equip_cooldown = 5
	energy_drain = 0
	range = MECHA_MELEE|MECHA_RANGED
	required_type = /obj/mecha/working
	price_tag = 100
	var/spray_particles = 5
	var/spray_amount = 5	//units of liquid per particle. 5 is enough to wet the floor - it's a big fire extinguisher, so should be fine
	var/max_water = 1000

	New()
		reagents = new/datum/reagents(max_water)
		reagents.my_atom = src
		reagents.add_reagent("water", max_water)
		..()
		return

	action(atom/target) //copypasted from extinguisher. TODO: Rewrite from scratch.
		if(!action_checks(target) || get_dist(chassis, target)>3) return
		if(get_dist(chassis, target)>2) return
		set_ready_state(0)
		if(do_after_cooldown(target))
			if( istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(chassis,target) <= 1)
				var/obj/o = target
				var/amount = o.reagents.trans_to_obj(src, 200)
				occupant_message(SPAN_NOTICE("[amount] units transferred into internal tank."))
				playsound(chassis, 'sound/effects/refill.ogg', 50, 1, -6)
				return

			if (src.reagents.total_volume < 1)
				occupant_message(SPAN_WARNING("\The [src] is empty."))
				return

			playsound(chassis, 'sound/effects/extinguish.ogg', 75, 1, -3)

			var/direction = get_dir(chassis,target)

			var/turf/T = get_turf(target)
			var/turf/T1 = get_step(T,turn(direction, 90))
			var/turf/T2 = get_step(T,turn(direction, -90))

			var/list/the_targets = list(T,T1,T2)

			for(var/a = 1 to 5)
				spawn(0)
					var/obj/effect/effect/water/W = new(get_turf(chassis))
					var/turf/my_target
					if(a == 1)
						my_target = T
					else if(a == 2)
						my_target = T1
					else if(a == 3)
						my_target = T2
					else
						my_target = pick(the_targets)
					W.create_reagents(5)
					if(!W || !src)
						return
					reagents.trans_to_obj(W, spray_amount)
					W.set_color()
					W.set_up(my_target)
			return 1

	get_equip_info()
		return "[..()] \[[src.reagents.total_volume]\]"

	on_reagent_change()
		return


/obj/item/mecha_parts/mecha_equipment/tool/rcd
	name = "mounted RCD"
	desc = "An exosuit-mounted Rapid Construction Device. (Can be attached to: Any exosuit)"
	icon_state = "mecha_rcd"
	origin_tech = list(TECH_MATERIAL = 4, TECH_BLUESPACE = 3, TECH_MAGNET = 4, TECH_POWER = 4)
	equip_cooldown = 10
	energy_drain = 250
	range = MECHA_MELEE|MECHA_RANGED
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_PLASMA = 15, MATERIAL_URANIUM = 15)
	price_tag = 1500
	var/mode = 0 //0 - deconstruct, 1 - wall or floor, 2 - airlock.
	var/disabled = 0 //malf

	action(atom/target)
		if(istype(target,/area/shuttle)||istype(target, /turf/space/transit))//>implying these are ever made -Sieve
			disabled = 1
		else
			disabled = 0
		if(!istype(target, /turf) && !istype(target, /obj/machinery/door/airlock))
			target = get_turf(target)
		if(!action_checks(target) || disabled || get_dist(chassis, target)>3) return
		playsound(chassis, 'sound/machines/click.ogg', 50, 1)
		//meh
		switch(mode)
			if(0)
				if (istype(target, /turf/simulated/wall))
					occupant_message("Deconstructing [target]...")
					set_ready_state(0)
					if(do_after_cooldown(target))
						if(disabled) return
						chassis.spark_system.start()
						target:ChangeTurf(/turf/simulated/floor/plating)
						playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
						chassis.use_power(energy_drain)
				else if (istype(target, /turf/simulated/floor))
					occupant_message("Deconstructing [target]...")
					set_ready_state(0)
					if(do_after_cooldown(target))
						if(disabled) return
						chassis.spark_system.start()
						target:ChangeTurf(get_base_turf_by_area(target))
						playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
						chassis.use_power(energy_drain)
				else if (istype(target, /obj/machinery/door/airlock))
					occupant_message("Deconstructing [target]...")
					set_ready_state(0)
					if(do_after_cooldown(target))
						if(disabled) return
						chassis.spark_system.start()
						qdel(target)
						playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
						chassis.use_power(energy_drain)
			if(1)
				if(istype(target, /turf/space) || istype(target,get_base_turf_by_area(target)))
					occupant_message("Building Floor...")
					set_ready_state(0)
					if(do_after_cooldown(target))
						if(disabled) return
						target:ChangeTurf(/turf/simulated/floor/plating)
						playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
						chassis.spark_system.start()
						chassis.use_power(energy_drain*2)
				else if(istype(target, /turf/simulated/floor))
					occupant_message("Building Wall...")
					set_ready_state(0)
					if(do_after_cooldown(target))
						if(disabled) return
						target:ChangeTurf(/turf/simulated/wall)
						playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
						chassis.spark_system.start()
						chassis.use_power(energy_drain*2)
			if(2)
				if(istype(target, /turf/simulated/floor))
					occupant_message("Building Airlock...")
					set_ready_state(0)
					if(do_after_cooldown(target))
						if(disabled) return
						chassis.spark_system.start()
						var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock(target)
						T.autoclose = 1
						playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
						playsound(target, 'sound/effects/sparks2.ogg', 50, 1)
						chassis.use_power(energy_drain*2)
		return


	Topic(href,href_list)
		..()
		if(href_list["mode"])
			mode = text2num(href_list["mode"])
			switch(mode)
				if(0)
					occupant_message("Switched RCD to Deconstruct.")
				if(1)
					occupant_message("Switched RCD to Construct.")
				if(2)
					occupant_message("Switched RCD to Construct Airlock.")
		return

	get_equip_info()
		return "[..()] \[<a href='?src=\ref[src];mode=0'>D</a>|<a href='?src=\ref[src];mode=1'>C</a>|<a href='?src=\ref[src];mode=2'>A</a>\]"




/obj/item/mecha_parts/mecha_equipment/teleporter
	name = "teleporter"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	icon_state = "mecha_teleport"
	origin_tech = list(TECH_BLUESPACE = 6)
	equip_cooldown = 150
	energy_drain = 1000
	range = MECHA_RANGED

	action(atom/target)
		if(!action_checks(target) || src.loc.z == 6) return
		var/turf/T = get_turf(target)
		if(T)
			set_ready_state(0)
			chassis.use_power(energy_drain)
			do_teleport(chassis, T, 4)
			do_after_cooldown()
		return


/obj/item/mecha_parts/mecha_equipment/wormhole_generator
	name = "wormhole generator"
	desc = "An exosuit module that allows generating of small quasi-stable wormholes."
	icon_state = "mecha_wholegen"
	origin_tech = list(TECH_BLUESPACE = 3)
	equip_cooldown = 50
	energy_drain = 300
	range = MECHA_RANGED


	action(atom/target)
		if(!action_checks(target) || src.loc.z == 6) return
		var/list/theareas = list()
		for(var/area/AR in orange(100, chassis))
			if(AR in theareas) continue
			theareas += AR
		if(!theareas.len)
			return
		var/area/thearea = pick(theareas)
		var/list/L = list()
		var/turf/pos = get_turf(src)
		for(var/turf/T in get_area_turfs(thearea.type))
			if(!T.density && pos.z == T.z)
				var/clear = 1
				for(var/obj/O in T)
					if(O.density)
						clear = 0
						break
				if(clear)
					L+=T
		if(!L.len)
			return
		var/turf/target_turf = pick(L)
		if(!target_turf)
			return
		chassis.use_power(energy_drain)
		set_ready_state(0)
		new /obj/effect/portal/wormhole(get_turf(target), rand(150, 300), target_turf)
		do_after_cooldown()

/obj/item/mecha_parts/mecha_equipment/gravcatapult
	name = "gravitational catapult"
	desc = "An exosuit mounted Gravitational Catapult."
	icon_state = "mecha_teleport"
	origin_tech = list(TECH_BLUESPACE = 2, TECH_MAGNET = 3)
	equip_cooldown = 10
	energy_drain = 100
	range = MECHA_MELEE|MECHA_RANGED
	var/atom/movable/locked
	var/mode = 1 //1 - gravsling 2 - gravpush

	var/last_fired = 0  //Concept stolen from guns.
	var/fire_delay = 10 //Used to prevent spam-brute against humans.

	action(atom/movable/target)

		if(world.time >= last_fired + fire_delay)
			last_fired = world.time
		else
			if (world.time % 3)
				occupant_message(SPAN_WARNING("[src] is not ready to fire again!"))
			return 0

		switch(mode)
			if(1)
				if(!action_checks(target) && !locked) return
				if(!locked)
					if(!istype(target) || target.anchored)
						occupant_message("Unable to lock on [target]")
						return
					locked = target
					occupant_message("Locked on [target]")
					send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
					return
				else if(target!=locked)
					if(locked in view(chassis))
						locked.throw_at(target, 14, 1.5, chassis)
						locked = null
						send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
						set_ready_state(0)
						chassis.use_power(energy_drain)
						do_after_cooldown()
					else
						locked = null
						occupant_message("Lock on [locked] disengaged.")
						send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
			if(2)
				if(!action_checks(target)) return
				var/list/atoms = list()
				if(isturf(target))
					atoms = range(target,3)
				else
					atoms = orange(target,3)
				for(var/atom/movable/A in atoms)
					if(A.anchored) continue
					spawn(0)
						var/iter = 5-get_dist(A,target)
						for(var/i=0 to iter)
							step_away(A,target)
							sleep(2)
				set_ready_state(0)
				chassis.use_power(energy_drain)
				do_after_cooldown()
		return

	get_equip_info()
		return "[..()] [mode==1?"([locked||"Nothing"])":null] \[<a href='?src=\ref[src];mode=1'>S</a>|<a href='?src=\ref[src];mode=2'>P</a>\]"

	Topic(href, href_list)
		..()
		if(href_list["mode"])
			mode = text2num(href_list["mode"])
			send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
		return


/obj/item/mecha_parts/mecha_equipment/armor_booster
	name = "armor booster"
	desc = "Powered armor-enhancing mech equipment."
	icon_state = "mecha_abooster_proj"
	equip_cooldown = 10
	energy_drain = 50
	range = 0
	var/deflect_coeff = 1
	var/damage_coeff = 1
	var/melee

	attach(obj/mecha/M as obj)
		..()
		activate_boost()
		return

	detach()
		if(equip_ready)
			deactivate_boost()
		..()
		return

	get_equip_info()
		if(!chassis) return
		return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name]"

	proc/activate_boost()
		if(!src.chassis)
			return 0
		return 1

	proc/deactivate_boost()
		if(!src.chassis)
			return 0
		return 1

	set_ready_state(state)
		if(state && !equip_ready)
			activate_boost()
		else if(equip_ready)
			deactivate_boost()
		..()


/obj/item/mecha_parts/mecha_equipment/armor_booster/anticcw_armor_booster //what is that noise? A BAWWW from TK mutants.
	name = "\improper CCW armor booster"
	desc = "Close-combat armor booster. Boosts exosuit armor against armed melee attacks. Requires energy to operate."
	icon_state = "mecha_abooster_ccw"
	origin_tech = list(TECH_MATERIAL = 4)
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_SILVER = 5)
	deflect_coeff = 1.15
	damage_coeff = 0.8
	melee = 1
	price_tag = 600

	activate_boost()
		if(..())
			chassis.m_deflect_coeff *= deflect_coeff
			chassis.m_damage_coeff *= damage_coeff
			chassis.mhit_power_use += energy_drain


	deactivate_boost()
		if(..())
			chassis.m_deflect_coeff /= deflect_coeff
			chassis.m_damage_coeff /= damage_coeff
			chassis.mhit_power_use -= energy_drain


/obj/item/mecha_parts/mecha_equipment/armor_booster/antiproj_armor_booster
	name = "\improper RW armor booster"
	desc = "Ranged-weaponry armor booster. Boosts exosuit armor against ranged attacks. Completely blocks taser shots, but requires energy to operate."
	icon_state = "mecha_abooster_proj"
	origin_tech = list(TECH_MATERIAL = 4)
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_GOLD = 5)
	deflect_coeff = 1.15
	damage_coeff = 0.8
	melee = 0
	price_tag = 600

	activate_boost()
		if(..())
			chassis.r_deflect_coeff *= deflect_coeff
			chassis.r_damage_coeff *= damage_coeff
			chassis.rhit_power_use += energy_drain

	deactivate_boost()
		if(..())
			chassis.r_deflect_coeff /= deflect_coeff
			chassis.r_damage_coeff /= damage_coeff
			chassis.rhit_power_use -= energy_drain


/obj/item/mecha_parts/mecha_equipment/repair_droid
	name = "repair droid"
	desc = "Automated repair droid. Scans exosuit for damage and repairs it. Can fix almost any type of external or internal damage."
	icon_state = "repair_droid"
	origin_tech = list(TECH_MAGNET = 3, TECH_DATA = 3)
	equip_cooldown = 20
	energy_drain = 100
	range = 0
	matter = list(MATERIAL_STEEL = 10, MATERIAL_GOLD = 10, MATERIAL_SILVER = 2, MATERIAL_GLASS = 5)
	price_tag = 1200
	var/health_boost = 2
	var/datum/global_iterator/pr_repair_droid
	var/icon/droid_overlay
	var/list/repairable_damage = list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH)

	New()
		..()
		pr_repair_droid = new /datum/global_iterator/mecha_repair_droid(list(src),0)
		pr_repair_droid.set_delay(equip_cooldown)
		return

	Destroy()
		qdel(pr_repair_droid)
		pr_repair_droid = null
		. = ..()

	attach(obj/mecha/M as obj)
		..()
		droid_overlay = new(src.icon, icon_state = "repair_droid")
		M.add_overlay(droid_overlay)
		return

	destroy()
		chassis.cut_overlay(droid_overlay)
		..()
		return

	detach()
		chassis.cut_overlay(droid_overlay)
		pr_repair_droid.stop()
		..()
		return

	get_equip_info()
		if(!chassis) return
		return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name] - <a href='?src=\ref[src];toggle_repairs=1'>[pr_repair_droid.active()?"Dea":"A"]ctivate</a>"


	Topic(href, href_list)
		..()
		if(href_list["toggle_repairs"])
			chassis.cut_overlay(droid_overlay)
			if(pr_repair_droid.toggle())
				droid_overlay = new(src.icon, icon_state = "repair_droid_a")
				log_message("Activated.")
			else
				droid_overlay = new(src.icon, icon_state = "repair_droid")
				log_message("Deactivated.")
				set_ready_state(1)
			chassis.add_overlay(droid_overlay)
			send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
		return


/datum/global_iterator/mecha_repair_droid

	Process(var/obj/item/mecha_parts/mecha_equipment/repair_droid/RD as obj)
		if(!RD.chassis)
			stop()
			RD.set_ready_state(1)
			return
		var/health_boost = RD.health_boost
		var/repaired = 0
		if(RD.chassis.hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
			health_boost *= -2
		else if(RD.chassis.hasInternalDamage() && prob(15))
			for(var/int_dam_flag in RD.repairable_damage)
				if(RD.chassis.hasInternalDamage(int_dam_flag))
					RD.chassis.clearInternalDamage(int_dam_flag)
					repaired = 1
					break
		if(health_boost<0 || RD.chassis.health < initial(RD.chassis.health))
			RD.chassis.health += min(health_boost, initial(RD.chassis.health)-RD.chassis.health)
			repaired = 1
		if(repaired)
			if(RD.chassis.use_power(RD.energy_drain))
				RD.set_ready_state(0)
			else
				stop()
				RD.set_ready_state(1)
				return
		else
			RD.set_ready_state(1)
		return


/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	name = "energy relay"
	desc = "Wirelessly drains energy from any available power channel in area. The performance index is quite low."
	icon_state = "tesla"
	origin_tech = list(TECH_MAGNET = 4, TECH_ILLEGAL = 2)
	matter = list(MATERIAL_STEEL = 10, MATERIAL_GOLD = 2, MATERIAL_SILVER = 3, MATERIAL_GLASS = 2)
	equip_cooldown = 10
	energy_drain = 0
	range = 0
	price_tag = 900
	var/datum/global_iterator/pr_energy_relay
	var/coeff = 100
	var/list/use_channels = list(STATIC_EQUIP,STATIC_ENVIRON,STATIC_LIGHT)

	New()
		..()
		pr_energy_relay = new /datum/global_iterator/mecha_energy_relay(list(src),0)
		pr_energy_relay.set_delay(equip_cooldown)
		return

	Destroy()
		qdel(pr_energy_relay)
		pr_energy_relay = null
		. = ..()

	detach()
		pr_energy_relay.stop()
		..()
		return

	attach(obj/mecha/M)
		..()
		return

	proc/get_power_channel(var/area/A)
		var/pow_chan
		if(A)
			for(var/c in use_channels)
				if(A.powered(c))
					pow_chan = c
					break
		return pow_chan

	Topic(href, href_list)
		..()
		if(href_list["toggle_relay"])
			if(pr_energy_relay.toggle())
				set_ready_state(0)
				log_message("Activated.")
			else
				set_ready_state(1)
				log_message("Deactivated.")
		return

	get_equip_info()
		if(!chassis) return
		return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name] - <a href='?src=\ref[src];toggle_relay=1'>[pr_energy_relay.active()?"Dea":"A"]ctivate</a>"

/datum/global_iterator/mecha_energy_relay

	Process(var/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/ER)
		if(!ER.chassis || ER.chassis.hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
			stop()
			ER.set_ready_state(1)
			return
		var/cur_charge = ER.chassis.get_charge()
		if(isnull(cur_charge) || !ER.chassis.cell)
			stop()
			ER.set_ready_state(1)
			ER.occupant_message("No powercell detected.")
			return
		if(cur_charge<ER.chassis.cell.maxcharge)
			var/area/A = get_area(ER.chassis)
			if(A)
				var/pow_chan
				for(var/c in list(STATIC_EQUIP,STATIC_ENVIRON,STATIC_LIGHT))
					if(A.powered(c))
						pow_chan = c
						break
				if(pow_chan)
					var/delta = min(12, ER.chassis.cell.maxcharge-cur_charge)
					ER.chassis.give_power(delta)
					A.use_power(delta*ER.coeff, pow_chan)
		return



/obj/item/mecha_parts/mecha_equipment/generator
	name = "plasma generator"
	desc = "Generates power using solid plasma as fuel. Pollutes the environment."
	icon_state = "plasma"
	origin_tech = list(TECH_PLASMA = 2, TECH_POWER = 2, TECH_ENGINEERING = 1)
	equip_cooldown = 10
	energy_drain = 0
	range = MECHA_MELEE
	matter = list(MATERIAL_STEEL = 10, MATERIAL_SILVER = 5, MATERIAL_GLASS = 1)
	var/datum/global_iterator/pr_mech_generator
	var/coeff = 100
	var/obj/item/stack/material/fuel
	var/max_fuel = 120
	var/fuel_per_cycle_idle = 1
	var/fuel_per_cycle_active = 5
	var/power_per_cycle = 25

	New()
		..()
		init()
		return

	Destroy()
		qdel(pr_mech_generator)
		pr_mech_generator = null
		. = ..()

	proc/init()
		fuel = new /obj/item/stack/material/plasma(src)
		fuel.amount = 0
		pr_mech_generator = new /datum/global_iterator/mecha_generator(list(src),0)
		pr_mech_generator.set_delay(equip_cooldown)
		return

	detach()
		pr_mech_generator.stop()
		..()
		return


	Topic(href, href_list)
		..()
		if(href_list["toggle"])
			if(pr_mech_generator.toggle())
				set_ready_state(0)
				log_message("Activated.")
			else
				set_ready_state(1)
				log_message("Deactivated.")
		return

	get_equip_info()
		var/output = ..()
		if(output)
			return "[output] \[[fuel]: [fuel.amount] sheets\] - <a href='?src=\ref[src];toggle=1'>[pr_mech_generator.active()?"Dea":"A"]ctivate</a>"
		return

	action(target)
		if(chassis)
			var/result = load_fuel(target)
			var/message
			if(isnull(result))
				message = SPAN_WARNING("[fuel] traces in target minimal. [target] cannot be used as fuel.")
			else if(!result)
				message = "Unit is full."
			else
				message = "[result] unit\s of [fuel] successfully loaded."
				send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
			occupant_message(message)
		return

	proc/load_fuel(var/obj/item/stack/material/P)
		if(P.type == fuel.type && P.amount)
			var/to_load = max(max_fuel - fuel.amount,0)
			if(to_load)
				var/units = min(to_load, P.amount)
				if(units)
					fuel.amount += units
					P.use(units)
					return units
			else
				return 0
		return

	attackby(weapon,mob/user)
		var/result = load_fuel(weapon)
		if(isnull(result))
			user.visible_message("[user] tries to shove [weapon] into [src]. What a dumb-ass.",SPAN_WARNING("[fuel] traces minimal. [weapon] cannot be used as fuel."))
		else if(!result)
			to_chat(user, "Unit is full.")
		else
			user.visible_message("[user] loads [src] with [fuel].","[result] unit\s of [fuel] successfully loaded.")
		return

	critfail()
		..()
		var/turf/simulated/T = get_turf(src)
		if(!T)
			return
		var/datum/gas_mixture/GM = new
		if(prob(10))
			T.assume_gas("plasma", 100, 1500+T0C)
			T.visible_message("The [src] suddenly disgorges a cloud of heated plasma.")
			destroy()
		else
			T.assume_gas("plasma", 5, istype(T) ? T.air.temperature : T20C)
			T.visible_message("The [src] suddenly disgorges a cloud of plasma.")
		T.assume_air(GM)
		return

/datum/global_iterator/mecha_generator

	Process(var/obj/item/mecha_parts/mecha_equipment/generator/EG)
		if(!EG.chassis)
			stop()
			EG.set_ready_state(1)
			return 0
		if(EG.fuel.amount<=0)
			stop()
			EG.log_message("Deactivated - no fuel.")
			EG.set_ready_state(1)
			return 0
		var/cur_charge = EG.chassis.get_charge()
		if(isnull(cur_charge))
			EG.set_ready_state(1)
			EG.occupant_message("No powercell detected.")
			EG.log_message("Deactivated.")
			stop()
			return 0
		var/use_fuel = EG.fuel_per_cycle_idle
		if(cur_charge<EG.chassis.cell.maxcharge)
			use_fuel = EG.fuel_per_cycle_active
			EG.chassis.give_power(EG.power_per_cycle)
		EG.fuel.amount -= min(use_fuel,EG.fuel.amount)
		EG.update_equip_info()
		return 1


/obj/item/mecha_parts/mecha_equipment/generator/nuclear
	name = "\improper ExoNuclear reactor"
	desc = "Generates power using uranium recklessly. Radiates the environment."
	icon_state = "uranium"
	origin_tech = list(TECH_POWER = 3, TECH_ENGINEERING = 3)
	matter = list(MATERIAL_STEEL = 10, MATERIAL_SILVER = 5, MATERIAL_GLASS = 10)
	max_fuel = 50000
	fuel_per_cycle_idle = 10
	fuel_per_cycle_active = 30
	power_per_cycle = 50
	var/rad_per_cycle = 0.3

	init()
		fuel = new /obj/item/stack/material/uranium(src)
		fuel.amount = 0
		pr_mech_generator = new /datum/global_iterator/mecha_generator/nuclear(list(src),0)
		pr_mech_generator.set_delay(equip_cooldown)
		return

	critfail()
		return

/datum/global_iterator/mecha_generator/nuclear

	Process(var/obj/item/mecha_parts/mecha_equipment/generator/nuclear/EG)
		if(..())
			for(var/mob/living/carbon/M in view(EG.chassis))
				if(ishuman(M))
					M.apply_effect((EG.rad_per_cycle*3),IRRADIATE)
				else
					M.apply_effect(EG.rad_per_cycle, IRRADIATE)
		return 1



//This is pretty much just for the death-ripley so that it is harmless
/obj/item/mecha_parts/mecha_equipment/tool/safety_clamp
	name = "\improper KILL CLAMP"
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 0
	var/dam_force = 90
	var/obj/mecha/working/ripley/cargo_holder
	required_type = list(/obj/mecha/working, /obj/mecha/combat, /obj/mecha/medical)

	attach(obj/mecha/M as obj)
		..()
		cargo_holder = M
		return

	action(atom/target)
		if(!action_checks(target)) return
		if(!cargo_holder) return
		if(isobj(target))
			var/obj/O = target
			if(!O.anchored)
				if(cargo_holder.cargo.len < cargo_holder.cargo_capacity)
					chassis.occupant_message("You lift [target] and start to load it into cargo compartment.")
					chassis.visible_message("[chassis] lifts [target] and starts to load it into cargo compartment.")
					set_ready_state(0)
					chassis.use_power(energy_drain)
					O.anchored = 1
					var/T = chassis.loc
					if(do_after_cooldown(target))
						if(T == chassis.loc && src == chassis.selected)
							cargo_holder.cargo += O
							O.loc = chassis
							O.anchored = 0
							chassis.occupant_message(SPAN_NOTICE("[target] succesfully loaded."))
							chassis.log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]")
						else
							chassis.occupant_message(SPAN_WARNING("You must hold still while handling objects."))
							O.anchored = initial(O.anchored)
				else
					chassis.occupant_message(SPAN_WARNING("Not enough room in cargo compartment."))
			else
				chassis.occupant_message(SPAN_WARNING("[target] is firmly secured."))

		else if(isliving(target))
			var/mob/living/M = target
			if(M.stat>1) return
			if(chassis.occupant.a_intent == I_HURT)
				chassis.occupant_message(SPAN_DANGER("You obliterate [target] with [src.name], leaving blood and guts everywhere."))
				chassis.visible_message(SPAN_DANGER("[chassis] destroys [target] in an unholy fury."))
				M.take_overall_damage(dam_force)
				M.adjustOxyLoss(round(dam_force/9))
				M.updatehealth()
			if(chassis.occupant.a_intent == I_DISARM)
				chassis.occupant_message(SPAN_DANGER("You tear at [target]'s limbs with [src.name]."))
				chassis.visible_message(SPAN_DANGER("[chassis] rips [target]'s."))
				M.take_overall_damage(dam_force/6)
				M.adjustOxyLoss(round(dam_force/2))
				M.updatehealth()
			else
				step_away(M,chassis)
				chassis.occupant_message("You smash into [target], sending them flying.")
				chassis.visible_message("[chassis] tosses [target] like a piece of paper.")
			set_ready_state(0)
			chassis.use_power(energy_drain)
			do_after_cooldown()
		return 1

/obj/item/mecha_parts/mecha_equipment/tool/passenger
	name = "passenger compartment"
	desc = "A mountable passenger compartment for exo-suits. Rather cramped."
	icon_state = "mecha_abooster_ccw"
	origin_tech = list(TECH_ENGINEERING = 1, TECH_BIO = 1)
	matter = list(MATERIAL_STEEL = 20, MATERIAL_GLASS = 5)
	energy_drain = 10
	range = MECHA_MELEE
	equip_cooldown = 20
	var/mob/living/carbon/occupant = null
	var/door_locked = 1
	salvageable = 0

/obj/item/mecha_parts/mecha_equipment/tool/passenger/destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
		to_chat(AM, SPAN_DANGER("You tumble out of the destroyed [src.name]!"))
	return ..()

/obj/item/mecha_parts/mecha_equipment/tool/passenger/Exit(atom/movable/O)
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/passenger/proc/move_inside(var/mob/user)
	if (chassis)
		chassis.visible_message(SPAN_NOTICE("[user] starts to climb into [chassis]."))

	if(do_after(user, 40, src, needhand=0))
		if(!src.occupant)
			user.forceMove(src)
			occupant = user
			log_message("\The [user] boarded.")
			occupant_message("\The [user] boarded.")
		else if(src.occupant != user)
			to_chat(user, SPAN_WARNING("[src.occupant] was faster. Try better next time, loser."))
	else
		to_chat(user, "You stop entering the exosuit.")

/obj/item/mecha_parts/mecha_equipment/tool/passenger/verb/eject()
	set name = "Eject"
	set category = "Exosuit Interface"
	set src = usr.loc
	set popup_menu = 0

	if(usr != occupant)
		return
	to_chat(occupant, "You climb out from \the [src].")
	go_out()
	occupant_message("[occupant] disembarked.")
	log_message("[occupant] disembarked.")
	add_fingerprint(usr)

/obj/item/mecha_parts/mecha_equipment/tool/passenger/proc/go_out()
	if(!occupant)
		return
	occupant.forceMove(get_turf(src))
	occupant.reset_view()
	/*
	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	*/
	occupant = null
	return

/obj/item/mecha_parts/mecha_equipment/tool/passenger/attach()
	..()
	if (chassis)
		chassis.verbs |= /obj/mecha/proc/move_inside_passenger

/obj/item/mecha_parts/mecha_equipment/tool/passenger/detach()
	if(occupant)
		occupant_message("Unable to detach [src] - equipment occupied.")
		return

	var/obj/mecha/M = chassis
	..()
	if (M && !(locate(/obj/item/mecha_parts/mecha_equipment/tool/passenger) in M))
		M.verbs -= /obj/mecha/proc/move_inside_passenger

/obj/item/mecha_parts/mecha_equipment/tool/passenger/get_equip_info()
	return "[..()] <br />[occupant? "\[Occupant: [occupant]\]|" : ""]Exterior Hatch: <a href='?src=\ref[src];toggle_lock=1'>Toggle Lock</a>"

/obj/item/mecha_parts/mecha_equipment/tool/passenger/Topic(href,href_list)
	..()
	if (href_list["toggle_lock"])
		door_locked = !door_locked
		occupant_message("Passenger compartment hatch [door_locked? "locked" : "unlocked"].")
		if (chassis)
			chassis.visible_message("The hatch on \the [chassis] [door_locked? "locks" : "unlocks"].", "You hear something latching.")


#define LOCKED 1
#define OCCUPIED 2

/obj/mecha/proc/move_inside_passenger()
	set category = "Object"
	set name = "Enter Passenger Compartment"
	set src in oview(1)

	//check that usr can climb in
	if (usr.stat || !ishuman(usr))
		return

	if (!usr.Adjacent(src))
		return

	if (!isturf(usr.loc))
		to_chat(usr, SPAN_DANGER("You can't reach the passenger compartment from here."))
		return

	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(C.handcuffed)
			to_chat(usr, SPAN_DANGER("Kinda hard to climb in while handcuffed don't you think?"))
			return

	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			to_chat(usr, SPAN_DANGER("You're too busy getting your life sucked out of you."))
			return

	//search for a valid passenger compartment
	var/feedback = 0 //for nicer user feedback
	for(var/obj/item/mecha_parts/mecha_equipment/tool/passenger/P in src)
		if (P.occupant)
			feedback |= OCCUPIED
			continue
		if (P.door_locked)
			feedback |= LOCKED
			continue

		//found a boardable compartment
		P.move_inside(usr)
		return

	//didn't find anything
	switch (feedback)
		if (OCCUPIED)
			to_chat(usr, SPAN_DANGER("The passenger compartment is already occupied!"))
		if (LOCKED)
			to_chat(usr, SPAN_WARNING("The passenger compartment hatch is locked!"))
		if (OCCUPIED|LOCKED)
			to_chat(usr, SPAN_DANGER("All of the passenger compartments are already occupied or locked!"))
		if (0)
			to_chat(usr, SPAN_WARNING("\The [src] doesn't have a passenger compartment."))

#undef LOCKED
#undef OCCUPIED
