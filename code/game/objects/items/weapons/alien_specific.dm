//This file contains xenoborg specic weapons.

/obj/item/melee/energy/alien_claws
	name = "energy claws"
	desc = "A set of alien energy claws."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-laser-claws"
	icon_state_on = "borg-laser-claws"
	force = 15
	force_on = 15
	throwforce = 5
	throwforce_on = 5
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	w_class_on = WEIGHT_CLASS_SMALL
	attack_verb = list("атаковал", "полоснул", "пронзил", "поранил", "порезал")
	attack_verb_on = list()

//Bottles for borg liquid squirters. PSSH PSSH
/obj/item/reagent_containers/spray/alien
	name = "liquid synthesizer"
	desc = "squirts alien liquids."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-default"

/obj/item/reagent_containers/spray/alien/smoke
	name = "smoke synthesizer"
	desc = "squirts smokey liquids."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-spray-smoke"

/obj/item/reagent_containers/spray/alien/smoke/afterattack(atom/A, mob/user, proximity, params)
	if(istype(A, /obj/structure/reagent_dispensers) && get_dist(src,A) <= 1)
		if(!A.reagents.total_volume && A.reagents)
			to_chat(user, "<span class='notice'>\The [A] is empty.</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='notice'>\The [src] is full.</span>")
			return
	reagents.remove_reagent(reagents.get_master_reagent_id(),25)
	var/datum/effect_system/smoke_spread/bad/smoke = new
	smoke.set_up(5, 0, user.loc)
	smoke.start()
	playsound(user.loc, 'sound/effects/bamf.ogg', 50, 2)

/obj/item/reagent_containers/spray/alien/acid
	name = "acid synthesizer"
	desc = "squirts burny liquids."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-spray-acid"

/obj/item/reagent_containers/spray/alien/stun
	name = "paralytic toxin synthesizer"
	desc = "squirts viagra."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-spray-stun"
	volume = 80

/obj/item/reagent_containers/spray/alien/stun/afterattack(atom/A, mob/user, proximity, params)
	reagents.remove_reagent(reagents.get_master_reagent_id(),25)
	var/location = get_turf(user)
	var/datum/reagents/reagents_list = new (250)
	reagents_list.add_reagent("cryogenic_liquid", 245)
	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(reagents_list, location)
	smoke.start(3)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)

//SKREEEEEEEEEEEE tool

/obj/item/flash/cyborg/alien
	name = "eye flash"
	desc = "Useful for taking pictures, making friends and flash-frying chips."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-flash"
