/obj/item/tool/tape_roll
	name = "duct tape"
	desc = "The technomancer's eternal friend. Fixes just about anything, for a while at least."
	icon = 'icons/obj/tools.dmi'
	icon_state = "taperoll"
	w_class = ITEM_SIZE_SMALL
	tool_qualities = list(QUALITY_ADHESIVE = 35, QUALITY_SEALING = 35)
	matter = list(MATERIAL_PLASTIC = 3)
	worksound = WORKSOUND_TAPE
	use_stock_cost = 0.15
	max_stock = 100
	degradation = 0 //its consumable anyway
	flags = NOBLUDGEON //Its not a weapon
	preloaded_reagents = list("glue" = 1, "plasticide" = 2)
	max_upgrades = 0 //These are consumable, so no wasting upgrades on them
	price_tag = 15

/obj/item/tool/tape_roll/web
	name = "web tape"
	desc = "A strip of fabric covered in an all-natural adhesive. Holds things together with the power of thoughts and prayers."
	tool_qualities = list(QUALITY_ADHESIVE = 15, QUALITY_SEALING = 15)
	use_stock_cost = 0.17
	max_stock = 30
	alpha = 150
	preloaded_reagents = null
	price_tag = 3

/obj/item/tool/tape_roll/glue
	name = "superglue"
	desc = "A bucket of milky white fluid. Can be used to stick things together, but unlike tape, it cannot be used to seal things."
	icon = 'icons/obj/tools.dmi'
	icon_state = "glue"
	tool_qualities = list(QUALITY_ADHESIVE = 40, QUALITY_CAUTERIZING = 5, QUALITY_BONE_GRAFTING = 15) // Better than duct tape, but can't seal things and is mostly used in crafting - also, it's glue, so it can be used as an extremely shitty way of sealing wounds and repairing bones.
	matter = list(MATERIAL_PLASTIC = 15)
	worksound = NO_WORKSOUND
	preloaded_reagents = list("glue" = 30)
	price_tag = 12

/obj/item/tool/tape_roll/fiber
	name = "fiber tape"
	desc = "A roll of flexible adhesive polymer mesh, which sets as strong as welded steel."
	icon_state = "fiber_tape"
	tool_qualities = list(QUALITY_ADHESIVE = 50, QUALITY_SEALING = 50)
	matter = list(MATERIAL_PLASTIC = 20)
	use_stock_cost = 0.10
	max_stock = 100
	preloaded_reagents = list("glue" = 15, "plasticide" = 5)
	price_tag = 30

/obj/item/tool/tape_roll/repair_goo
	name = "repair goo"
	desc = "A wad of sticky gray goo capable of repairing tools and sealing cracks."
	icon_state = "repair_goo"
	tool_qualities = list(QUALITY_ADHESIVE = 50, QUALITY_SEALING = 50, QUALITY_CAUTERIZING = 5, QUALITY_BONE_GRAFTING = 65)
	matter = list(MATERIAL_PLASTIC = 20)
	use_stock_cost = 0.10
	max_stock = 100
	preloaded_reagents = list("glue" = 15, "plasticide" = 5)

/obj/item/tool/tape_roll/flextape
	name = "flex tape"
	desc = "To fix a lot of damage! PS: It doesn't repair the Supermatter."
	icon_state = "flextaperoll"
	tool_qualities = list(QUALITY_ADHESIVE = 100, QUALITY_SEALING = 100)
	matter = list(MATERIAL_PLASTIC = 40)
	use_stock_cost = 0.10
	preloaded_reagents = list("glue" = 200, "plasticide" = 50) //A bucket
	max_stock = 100
	price_tag = 1000 // Mythical

/obj/item/tool/tape_roll/bonegel //Five stacks is too little for how often bones break. Tape-based stock system works just as fine.
	name = "bone gel"
	desc = "A gel-like calcium composite used as a surgical substitute for broken or missing bone pieces."
	icon = 'icons/obj/stack/items.dmi'
	icon_state = "bonegel"
	item_state = "bonegel"
	w_class = ITEM_SIZE_TINY
	worksound = NO_WORKSOUND
	matter = list(MATERIAL_PLASTIC = 20)
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 3)
	preloaded_reagents = list("milk" = 5)
	tool_qualities = list(QUALITY_BONE_GRAFTING = 80)
	max_stock = 200
	use_stock_cost = 1
	price_tag = 20

/obj/item/tool/tape_roll/bonegel/si
	name = "bone super gel"
	desc = "A gel-like calcium composite used as a surgical substitute for broken or missing bone pieces."
	icon = 'icons/obj/stack/items.dmi'
	icon_state = "bonegel_SI"
	matter = list(MATERIAL_PLASTIC = 30, MATERIAL_STEEL = 3)
	tool_qualities = list(QUALITY_BONE_GRAFTING = 150)
	max_stock = 500
	preloaded_reagents = null
	price_tag = 200

/obj/item/tool/tape_roll/attack(var/mob/living/carbon/human/H, var/mob/user)
	if(istype(H) && has_quality(QUALITY_ADHESIVE))
		if(user.targeted_organ == BP_EYES)

			if(!H.organs_by_name[BP_HEAD])
				to_chat(user, SPAN_WARNING("\The [H] doesn't have a head."))
				return
			if(!H.has_eyes())
				to_chat(user, SPAN_WARNING("\The [H] doesn't have any eyes."))
				return
			if(H.glasses)
				to_chat(user, SPAN_WARNING("\The [H] is already wearing something on their eyes."))
				return
			if(H.head && (H.head.body_parts_covered & FACE))
				to_chat(user, SPAN_WARNING("Remove their [H.head] first!"))
				return
			user.visible_message(SPAN_DANGER("\The [user] begins taping over \the [H]'s eyes!"))

			if(!use_tool(user, H, 70, QUALITY_ADHESIVE))
				return

			// Repeat failure checks.
			if(!H || !src || !H.organs_by_name[BP_HEAD] || !H.has_eyes() || H.glasses || (H.head && (H.head.body_parts_covered & FACE)))
				return

			user.visible_message(SPAN_DANGER("\The [user] has taped up \the [H]'s eyes!"))
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/blindfold/tape(H), slot_glasses)

		else if(user.targeted_organ == BP_MOUTH || user.targeted_organ == BP_HEAD)
			if(!H.organs_by_name[BP_HEAD])
				to_chat(user, SPAN_WARNING("\The [H] doesn't have a head."))
				return
			if(!H.check_has_mouth())
				to_chat(user, SPAN_WARNING("\The [H] doesn't have a mouth."))
				return
			if(H.wear_mask)
				to_chat(user, SPAN_WARNING("\The [H] is already wearing a mask."))
				return
			if(H.head && (H.head.body_parts_covered & FACE))
				to_chat(user, SPAN_WARNING("Remove their [H.head] first."))
				return
			user.visible_message(SPAN_DANGER("\The [user] begins taping up \the [H]'s mouth!"))

			if(!use_tool(user, H, 70, QUALITY_ADHESIVE))
				return

			// Repeat failure checks.
			if(!H || !src || !H.organs_by_name[BP_HEAD] || !H.check_has_mouth() || H.wear_mask || (H.head && (H.head.body_parts_covered & FACE)))
				return

			user.visible_message(SPAN_DANGER("\The [user] has taped up \the [H]'s mouth!"))
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/muzzle/tape(H), slot_wear_mask)

		else if(user.targeted_organ == BP_R_ARM || user.targeted_organ == BP_L_ARM)
			if(use_tool(user, H, 90, QUALITY_ADHESIVE))
				var/obj/item/handcuffs/cable/tape/T = new(user)
				if(!T.place_handcuffs(H, user))
					user.unEquip(T)
					qdel(T)
		else
			return ..()
		return 1

/obj/item/tool/tape_roll/stick(var/obj/item/target, var/mob/user)
	if (!istype(target) || target.anchored)
		return

	if (target.w_class > ITEM_SIZE_SMALL)
		to_chat(user, SPAN_WARNING("The [target] is too big to stick with tape!"))
		return
	if (istype(target.loc, /obj))
		return
	consume_resources(10, user)
	user.drop_from_inventory(target)
	var/obj/item/ducttape/tape = new(get_turf(src))
	tape.attach(target)
	user.put_in_hands(tape)
	return TRUE


/obj/item/ducttape
	name = "tape"
	desc = "A piece of sticky tape."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "tape"
	w_class = ITEM_SIZE_TINY
	layer = 4
	anchored = 1 //it's sticky, no you cant move it

	var/obj/item/stuck = null

/obj/item/ducttape/New()
	..()
	flags |= NOBLUDGEON

/obj/item/ducttape/update_plane()
	..()
	update_icon()


/obj/item/ducttape/examine(mob/user)
	return stuck.examine(user)

/obj/item/ducttape/proc/attach(var/obj/item/W)
	stuck = W
	W.forceMove(src)
	update_icon()
	name = W.name + " (taped)"

/obj/item/ducttape/update_icon()
	if (!stuck)
		return

	if (istype(stuck, /obj/item/paper))
		icon_state = stuck.icon_state
		cut_overlays()
		copy_overlays(stuck.overlays + "tape_overlay", TRUE)
	else
		var/mutable_appearance/MA = new(stuck)
		MA.layer = layer-0.1
		MA.plane = plane
		MA.pixel_x = 0
		MA.pixel_y = 0
		underlays.Cut()
		underlays += MA

/obj/item/ducttape/attack_self(mob/user)
	if(!stuck)
		return

	to_chat(user, "You remove \the [initial(name)] from [stuck].")

	user.drop_from_inventory(src)
	stuck.forceMove(get_turf(src))
	user.put_in_hands(stuck)
	stuck = null
	cut_overlays()
	qdel(src)

/obj/item/ducttape/afterattack(var/A, mob/user, flag, params)

	if(!in_range(user, A) || istype(A, /obj/machinery/door) || !stuck)
		return

	var/turf/target_turf = get_turf(A)
	var/turf/source_turf = get_turf(user)

	var/dir_offset = 0
	if(target_turf != source_turf)
		dir_offset = get_dir(source_turf, target_turf)
		if(!(dir_offset in cardinal))
			to_chat(user, "You cannot reach that from here.") // can only place stuck papers in cardinal directions, to
			return											  // reduce papers around corners issue.

	user.drop_from_inventory(src)
	forceMove(source_turf)

	if(params)
		var/list/mouse_control = params2list(params)
		if(mouse_control["icon-x"])
			pixel_x = text2num(mouse_control["icon-x"]) - 16
			if(dir_offset & EAST)
				pixel_x += 32
			else if(dir_offset & WEST)
				pixel_x -= 32
		if(mouse_control["icon-y"])
			pixel_y = text2num(mouse_control["icon-y"]) - 16
			if(dir_offset & NORTH)
				pixel_y += 32
			else if(dir_offset & SOUTH)
				pixel_y -= 32
