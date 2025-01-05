//does brute damage, bonus damage for each nearby blob, and spreads damage out
/datum/blobstrain/reagent/synchronous_mesh
	name = "Синхронная сетка"
	description = "наносит небольшой урон травмами, но каждая плитка поблизости также атакует цель, нанося суммируемый урон."
	effectdesc = "также распределяет урон между каждой плиткой рядом с атакованной плиткой."
	analyzerdescdamage = "Наносит небольшой урон травмами, увеличивающийся с каждой плиткой рядом с целью."
	analyzerdesceffect = "При атаке распределяет урон между всеми плитками рядом с атакованной плиткой."
	color = "#65ADA2"
	complementary_color = "#AD6570"
	blobbernaut_message = "synchronously strikes"
	message = "Блоб поражают тебя"
	reagent = /datum/reagent/blob/synchronous_mesh

/datum/blobstrain/reagent/synchronous_mesh/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if(damage_flag == MELEE || damage_flag == BULLET || damage_flag == LASER) //the cause isn't fire or bombs, so split the damage
		var/damagesplit = 1 //maximum split is 9, reducing the damage each blob takes to 11% but doing that damage to 9 blobs
		var/list/blob_structures = (is_there_multiz())? urange_multiz(1, B, TRUE) : orange(1, B)
		for(var/obj/structure/blob/C in blob_structures)
			if(!C.ignore_syncmesh_share && C.overmind && C.overmind.blobstrain.type == B.overmind.blobstrain.type) //if it doesn't have the same chemical or is a core or node, don't split damage to it
				damagesplit += 1
		for(var/obj/structure/blob/C in blob_structures)
			if(!C.ignore_syncmesh_share && C.overmind && C.overmind.blobstrain.type == B.overmind.blobstrain.type) //only hurt blobs that have the same overmind chemical and aren't cores or nodes
				C.take_damage(damage/damagesplit, damage_type, 0, 0)
		return damage / damagesplit
	else
		return damage * 1.25

/datum/reagent/blob/synchronous_mesh
	name = "Синхронная сетка"
	id = "blob_synchronous_mesh"
	taste_description = "токсичная плесень"
	color = "#65ADA2"

/datum/reagent/blob/synchronous_mesh/reaction_mob(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.apply_damage(0.2*reac_volume, BRUTE, forced = TRUE)
	var/list/blob_structures = (is_there_multiz())? urange_multiz(1, exposed_mob, TRUE) : range(1, exposed_mob)
	if(exposed_mob && reac_volume)
		for(var/obj/structure/blob/nearby_blob in blob_structures) //if the target is completely surrounded, this is 2.4*reac_volume bonus damage, total of 2.6*reac_volume
			if(exposed_mob)
				nearby_blob.blob_attack_animation(exposed_mob) //show them they're getting a bad time
				exposed_mob.apply_damage(0.3*reac_volume, BRUTE, forced = TRUE)
