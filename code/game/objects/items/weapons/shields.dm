//** Shield Helpers
//These are shared by various items that have shield-like behaviour

//bad_arc is the ABSOLUTE arc of directions from which we cannot block. If you want to fix it to e.g. the user's facing you will need to rotate the dirs yourself.
/proc/check_shield_arc(mob/user, var/bad_arc, atom/damage_source = null, mob/attacker = null)
	//check attack direction
	var/attack_dir = 0 //direction from the user to the source of the attack
	if(istype(damage_source, /obj/item/projectile))
		var/obj/item/projectile/P = damage_source
		attack_dir = get_dir(get_turf(user), P.starting)
	else if(attacker)
		attack_dir = get_dir(get_turf(user), get_turf(attacker))
	else if(damage_source)
		attack_dir = get_dir(get_turf(user), get_turf(damage_source))

	if(!(attack_dir && (attack_dir & bad_arc)))
		return 1
	return 0

/proc/default_parry_check(mob/user, mob/attacker, atom/damage_source)
	//parry only melee attacks
	if(istype(damage_source, /obj/item/projectile) || (attacker && get_dist(user, attacker) > 1) || user.incapacitated())
		return 0

	//block as long as they are not directly behind us
	var/bad_arc = reverse_direction(user.dir) //arc of directions from which we cannot block
	if(!check_shield_arc(user, bad_arc, damage_source, attacker))
		return 0

	return 1

/obj/item/weapon/shield
	name = "shield"
	armor = list(melee = 20, bullet = 20, energy = 20, bomb = 0, bio = 0, rad = 0)
	var/base_block_chance = 50
	var/slowdown_time = 1

/obj/item/weapon/shield/handle_shield(mob/user, var/damage, atom/damage_source = null, mob/attacker = null, var/def_zone = null, var/attack_text = "the attack")
	if(user.incapacitated())
		return 0

	//block as long as they are not directly behind us
	var/bad_arc = reverse_direction(user.dir) //arc of directions from which we cannot block
	if(check_shield_arc(user, bad_arc, damage_source, attacker))
		if(prob(get_block_chance(user, damage, damage_source, attacker)))
			user.visible_message(SPAN_DANGER("\The [user] blocks [attack_text] with \the [src]!"))
			return 1
	return 0

/obj/item/weapon/shield/proc/get_block_chance(mob/user, var/damage, atom/damage_source = null, mob/attacker = null)
	return base_block_chance

/obj/item/weapon/shield/attack(mob/M, mob/user)
	if(isliving(M))
		var/mob/living/L = M
		if(L.slowdown < slowdown_time * 3)
			L.slowdown += slowdown_time
	return ..()

/obj/item/weapon/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "riot"
	item_state = "riot"
	flags = CONDUCT
	slot_flags = SLOT_BACK
	force = WEAPON_FORCE_PAINFUL
	throwforce = WEAPON_FORCE_PAINFUL
	throw_speed = 1
	throw_range = 4
	w_class = ITEM_SIZE_BULKY
	origin_tech = list(TECH_MATERIAL = 2)
	matter = list(MATERIAL_GLASS = 5, MATERIAL_STEEL = 5, MATERIAL_PLASTEEL = 10)
	price_tag = 500
	attack_verb = list("shoved", "bashed")
	var/cooldown = 0 //shield bash cooldown. based on world.time
	var/is_covered = FALSE

/obj/item/weapon/shield/riot/handle_shield(mob/user)
	. = ..()
	if(.) playsound(user.loc, 'sound/weapons/Genhit.ogg', 50, 1)

/obj/item/weapon/shield/riot/get_block_chance(mob/user, var/damage, atom/damage_source = null, mob/attacker = null)
	if(MOVING_QUICKLY(user))
		return 0
	if(MOVING_DELIBERATELY(user))
		return base_block_chance

/obj/item/weapon/shield/riot/New()
	START_PROCESSING(SSobj, src)
	return

/obj/item/weapon/shield/riot/Process()
	update_icon()
	update_wear_icon()

/obj/item/weapon/shield/riot/on_update_icon()
	var/mob/living/carbon/human/user = loc
	if(!istype(user))
		is_covered = FALSE
		return
	if(MOVING_QUICKLY(user))
		item_state = "[initial(item_state)]_run"
		armor = list(melee = 0, bullet = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
		if(is_covered)
			visible_message("[user] lets go of their cover.")
			is_covered = FALSE
	else
		item_state = "[initial(item_state)]_walk"
		armor = initial(armor)
		if(!is_covered)
			visible_message("[user] raises [src], covering themselves with it!")
			is_covered = TRUE

/obj/item/weapon/shield/riot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/melee/baton))
		on_bash(W, user)
	else
		..()

/obj/item/weapon/shield/riot/proc/on_bash(var/obj/item/weapon/W, var/mob/user)
	if(cooldown < world.time - 25)
		user.visible_message(SPAN_WARNING("[user] bashes [src] with [W]!"))
		playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
		cooldown = world.time

/*
 * Handmade shield
 */

/obj/item/weapon/shield/riot/handmade
	name = "round handmade shield"
	desc = "A handmade stout shield, but with a small size."
	icon_state = "buckler"
	flags = null
	throw_speed = 2
	throw_range = 6
	matter = list(MATERIAL_STEEL = 6)
	base_block_chance = 35


/obj/item/weapon/shield/riot/handmade/get_block_chance(mob/user, var/damage, atom/damage_source = null, mob/attacker = null)
	return base_block_chance


/obj/item/weapon/shield/riot/handmade/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/extinguisher) || istype(W, /obj/item/weapon/storage/toolbox) || istype(W, /obj/item/weapon/melee))
		on_bash(W, user)
	else
		..()

/obj/item/weapon/shield/riot/handmade/tray
	name = "tray shield"
	desc = "This one is thin, but compensate it with a good size."
	icon_state = "tray_shield"
	flags = CONDUCT
	throw_speed = 2
	throw_range = 4
	matter = list(MATERIAL_STEEL = 4)
	base_block_chance = 35


/obj/item/weapon/shield/riot/handmade/tray/get_block_chance(mob/user, var/damage, atom/damage_source = null, mob/attacker = null)
	if(istype(damage_source, /obj/item))
		var/obj/item/I = damage_source
		if((is_sharp(I) && damage > 10) || istype(damage_source, /obj/item/projectile/beam))
			return 20
	return base_block_chance

/*
 * Energy Shield
 */

/obj/item/weapon/shield/energy
	name = "energy combat shield"
	desc = "A shield capable of stopping most projectile and melee attacks. It can be retracted, expanded, and stored anywhere."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "eshield0" // eshield1 for expanded
	flags = CONDUCT
	force = 3
	throwforce = 5
	throw_speed = 1
	throw_range = 4
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_COVERT = 4)
	attack_verb = list("shoved", "bashed")
	var/active = 0

/obj/item/weapon/shield/energy/handle_shield(mob/user)
	if(!active)
		return 0 //turn it on first!
	. = ..()

	if(.)
		var/datum/effect/effect/system/spark_spread/spark_system = new
		spark_system.set_up(5, 0, user.loc)
		spark_system.start()
		playsound(user.loc, 'sound/weapons/blade1.ogg', 50, 1)

/obj/item/weapon/shield/energy/get_block_chance(mob/user, var/damage, atom/damage_source = null, mob/attacker = null)
	if(istype(damage_source, /obj/item/projectile))
		var/obj/item/projectile/P = damage_source
		if((is_sharp(P) && damage > 10) || istype(P, /obj/item/projectile/beam))
			return (base_block_chance - round(damage / 3)) //block bullets and beams using the old block chance
	return base_block_chance

/obj/item/weapon/shield/energy/attack_self(mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		to_chat(user, SPAN_WARNING("You beat yourself in the head with [src]."))
		user.take_organ_damage(5)
	active = !active
	if (active)
		force = WEAPON_FORCE_PAINFUL
		update_icon()
		w_class = ITEM_SIZE_BULKY
		playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
		to_chat(user, SPAN_NOTICE("\The [src] is now active."))

	else
		force = 3
		update_icon()
		w_class = ITEM_SIZE_TINY
		playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
		to_chat(user, SPAN_NOTICE("\The [src] can now be concealed."))

	add_fingerprint(user)
	return

/obj/item/weapon/shield/energy/on_update_icon()
	icon_state = "eshield[active]"
	update_wear_icon()
	if(active)
		set_light(1.5, 1.5, COLOR_LIGHTING_BLUE_BRIGHT)
	else
		set_light(0)

