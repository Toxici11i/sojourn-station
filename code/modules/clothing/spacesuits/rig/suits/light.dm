// Light rigs are not space-capable, but don't suffer excessive slowdown or sight issues when depowered.
/obj/item/rig/light
	name = "light suit control module"
	desc = "A lighter, less armoured rig suit."
	icon_state = "ninja_rig"
	suit_type = "light suit"
	armor_list = list(
		melee = 25,
		bullet = 20,
		energy = 20,
		bomb = 25,
		bio = 100,
		rad = 25
	)
	emp_protection = 10
	slowdown = 0
	obscuration = 0
	item_flags = STOPPRESSUREDAMAGE | THICKMATERIAL | DRAG_AND_DROP_UNEQUIP | EQUIP_SOUNDS
	offline_slowdown = 0
	offline_vision_restriction = 0
	drain = 2

	chest_type = /obj/item/clothing/suit/space/rig/light
	helm_type =  /obj/item/clothing/head/helmet/space/rig/light
	boot_type =  /obj/item/clothing/shoes/magboots/rig/light
	glove_type = /obj/item/clothing/gloves/rig/light

/obj/item/clothing/suit/space/rig/light
	name = "suit"

/obj/item/clothing/gloves/rig/light
	name = "gloves"

/obj/item/clothing/shoes/magboots/rig/light
	name = "shoes"

/obj/item/clothing/head/helmet/space/rig/light
	name = "hood"

/obj/item/rig/light/ultra_light
	name = "SI 'Proto-Spacer' control module"
	desc = "An ultra light, unarmoured rig suit. The precursor to the Soteria retainer model, quite lacking in armor and EMP protection but capable of fitting hardsuit modules."
	icon_state = "hacker_rig"
	suit_type = "light suit"
	armor_list = list(
		melee = 10,
		bullet = 5,
		energy = 0,
		bomb = 25,
		bio = 100,
		rad = 45
	)
	slowdown = -0.2 //We speed up the user at cost of horrable armor
	emp_protection = 0
	matter = list(MATERIAL_STEEL = 30, MATERIAL_PLASTIC = 30, MATERIAL_GLASS = 10) //Costly!

	chest_type = /obj/item/clothing/suit/space/rig/light/ultra_light
	helm_type =  /obj/item/clothing/head/helmet/space/rig/light/ultra_light
	boot_type =  /obj/item/clothing/shoes/magboots/rig/light/ultra_light
	glove_type = /obj/item/clothing/gloves/rig/light/ultra_light

/obj/item/clothing/suit/space/rig/light/ultra_light
	name = "SI 'Spacer' suit"

/obj/item/clothing/gloves/rig/light/ultra_light
	name = "SI 'Spacer' gloves"

/obj/item/clothing/shoes/magboots/rig/light/ultra_light
	name = "SI 'Spacer' shoes"

/obj/item/clothing/head/helmet/space/rig/light/ultra_light
	name = "SI 'Spacer' hood"
	flags_inv = 0

/obj/item/rig/light/hacker/steward
	name = "SI 'Retainer' control module"
	desc = "A Soteria Institute modification of the traditional light rig built for equal parts utility and defense."
	armor_list = list(
		melee = 30,
		bullet = 25,
		energy = 30,
		bomb = 30,
		bio = 100,
		rad = 30
	)
	emp_protection = 20
	seal_delay = 5
	icon_state = "hacker_rig"
	req_access = list(access_hop)

	initial_modules = list(
		/obj/item/rig_module/mounted/taser,
		/obj/item/rig_module/device/flash,
		/obj/item/rig_module/vision/medhud,
		/obj/item/rig_module/device/healthscanner,
		/obj/item/rig_module/modular_injector/medical,
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/storage
		)



/obj/item/rig/light/hacker
	name = "cybersuit control module"
	suit_type = "cyber"
	desc = "An advanced powered armour suit with many cyberwarfare enhancements. Comes with built-in insulated gloves for safely tampering with electronics."
	icon_state = "hacker_rig"

	req_access = list(access_syndicate)

	airtight = 0
	seal_delay = 5 //not being vaccum-proof has an upside I guess

	helm_type = /obj/item/clothing/head/lightrig/hacker
	chest_type = /obj/item/clothing/suit/lightrig/hacker
	glove_type = /obj/item/clothing/gloves/lightrig/hacker
	boot_type = /obj/item/clothing/shoes/lightrig/hacker

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/power_sink,
		/obj/item/rig_module/datajack,
		/obj/item/rig_module/electrowarfare_suite,
		/obj/item/rig_module/voice,
		/obj/item/rig_module/vision,
		)

//The cybersuit is not space-proof. It does however, have good siemens_coefficient values
/obj/item/clothing/head/lightrig/hacker
	name = "HUD"
	siemens_coefficient = 0.4
	flags = 0

/obj/item/clothing/suit/lightrig/hacker
	siemens_coefficient = 0.4

/obj/item/clothing/shoes/lightrig/hacker
	siemens_coefficient = 0.4
	flags = NOSLIP //All the other rigs have magboots anyways, hopefully gives the hacker suit something more going for it.

/obj/item/clothing/gloves/lightrig/hacker
	siemens_coefficient = 0

/obj/item/rig/light/ninja
	name = "ominous suit control module"
	suit_type = "ominous"
	desc = "A unique, vaccum-proof suit of nano-enhanced armor designed specifically for assassins."
	icon_state = "ninja_rig"
	armor_list = list(
		melee = 30,
		bullet = 30,
		energy = 20,
		bomb = 25,
		bio = 100,
		rad = 25
	)
	emp_protection = 40 //change this to 30 if too high.
	slowdown = 0

	chest_type = /obj/item/clothing/suit/space/rig/light/ninja
	glove_type = /obj/item/clothing/gloves/rig/light/ninja

	req_access = list(access_syndicate)

	initial_modules = list(
		/obj/item/rig_module/teleporter,
		/obj/item/rig_module/stealth_field,
		/obj/item/rig_module/held/energy_blade,
		/obj/item/rig_module/vision,
		/obj/item/rig_module/voice,
		/obj/item/rig_module/fabricator/energy_net,
		/obj/item/rig_module/modular_injector,
		/obj/item/rig_module/grenade_launcher,
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/power_sink,
		/obj/item/rig_module/datajack,
		/obj/item/rig_module/self_destruct
		)

/obj/item/clothing/gloves/rig/light/ninja
	name = "insulated gloves"
	siemens_coefficient = 0

/obj/item/clothing/suit/space/rig/light/ninja
	breach_threshold = 38 //comparable to regular hardsuits

/obj/item/rig/light/stealth
	name = "stealth suit control module"
	suit_type = "stealth"
	desc = "A highly advanced and expensive suit designed for covert operations."
	icon_state = "ninja_rig"

	req_access = list(access_syndicate)

	initial_modules = list(
		/obj/item/rig_module/stealth_field,
		/obj/item/rig_module/vision
		)
