/obj/structure/closet/secure_closet/reinforced/preacher
	name = "prime's locker"
	req_access = list(access_chapel_office)
	icon_state = "head_preacher"

/obj/structure/closet/secure_closet/reinforced/preacher/populate_contents()
	if(prob(25))
		new /obj/item/weapon/storage/backpack/neotheology(src)
	else if(prob(25))
		new /obj/item/weapon/storage/backpack/sport/neotheology(src)
	else
		new /obj/item/weapon/storage/backpack/satchel/neotheology(src)
	new /obj/item/clothing/under/rank/preacher(src)
	new /obj/item/clothing/under/rank/preacher(src)
	new /obj/item/device/radio/headset/church(src)
	new /obj/item/weapon/storage/belt/utility/neotheology(src)
	new /obj/item/clothing/shoes/reinforced(src)
	new /obj/item/clothing/shoes/reinforced(src)
	new /obj/item/clothing/suit/storage/chaplain(src)
	new /obj/item/clothing/suit/storage/chaplain(src)
	new /obj/item/clothing/suit/storage/chaplain/holiday(src)
	new /obj/item/clothing/gloves/thick(src)
	new /obj/item/clothing/gloves/thick(src)
	new /obj/item/weapon/storage/fancy/candle_box(src)
	new /obj/item/weapon/storage/fancy/candle_box(src)
	new /obj/item/weapon/deck/tarot(src)
	new /obj/item/weapon/computer_hardware/hard_drive/portable/design/nt_boards(src)
	new /obj/item/weapon/gun/projectile/mk58/wood(src)
	new /obj/item/ammo_magazine/a10mm(src)
	new /obj/item/ammo_magazine/a10mm(src)
	new /obj/item/ammo_magazine/a10mm/rubber(src)
	new /obj/item/ammo_magazine/a10mm/rubber(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/implant/core_implant/cruciform(src)
	new /obj/item/weapon/tool/knife/neotritual(src)
	new /obj/item/clothing/suit/space/void/prime(src)
