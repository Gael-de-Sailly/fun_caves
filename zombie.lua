-- Originally by Blockmen(?)

if mobs.mod and mobs.mod == "redo" then
	mobs:register_mob("fun_caves:zombie", {
		type = "monster",
		visual = "mesh",
		mesh = "creatures_mob.x",
		textures = {
			{"mobs_zombie.png"},
		},
		collisionbox = {-0.25, -1, -0.3, 0.25, 0.75, 0.3},
		animation = {
			speed_normal = 10,		speed_run = 15,
			stand_start = 0,		stand_end = 79,
			walk_start = 168,		walk_end = 188,
			run_start = 168,		run_end = 188
		},
		makes_footstep_sound = true,
		sounds = {
			random = "mobs_zombie.1",
			war_cry = "mobs_zombie.3",
			attack = "mobs_zombie.2",
			damage = "mobs_zombie_hit",
			death = "mobs_zombie_death",
		},
		hp_min = 12,
		hp_max = 35,
		armor = 200,
		knock_back = 1,
		lava_damage = 10,
		damage = 4,
		reach = 2,
		attack_type = "dogfight",
		group_attack = true,
		view_range = 10,
		walk_chance = 75,
		walk_velocity = 0.5,
		run_velocity = 0.5,
		jump = false,
		drops = {
			{name = "mobs_zombie:rotten_flesh", chance = 1, min = 1, max = 3,}
		},
		lifetimer = 180,		-- 3 minutes
		shoot_interval = 135,	-- (lifetimer - (lifetimer / 4)), borrowed for do_custom timer
	})

	--name, nodes, neighbors, min_light, max_light, interval, chance, active_object_count, min_height, max_height
	mobs:spawn_specific("fun_caves:zombie",
		{"fun_caves:polluted_dirt"},
		{"air", "fun_caves:water_poison_flowing"},
		-1, 20, 30, 2000, 2, -31000, 0)
	mobs:register_egg("fun_caves:zombie", "Zombie", "zombie_head.png", 0)
	

-- rotten flesh
	minetest.register_craftitem("fun_caves:rotten_flesh", {
		description = "Rotten Flesh",
		inventory_image = "mobs_rotten_flesh.png",
		on_use = minetest.item_eat(1),
	})
end
