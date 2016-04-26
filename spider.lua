
-- Spider by AspireMint (fishyWET (CC-BY-SA 3.0 license for texture)

mobs:register_mob("fun_caves:spider", {
	docile_by_day = true,
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	reach = 2,
	damage = 3,
	hp_min = 20,
	hp_max = 40,
	armor = 200,
	collisionbox = {-0.9, -0.01, -0.7, 0.7, 0.6, 0.7},
	visual = "mesh",
	mesh = "fun_caves_spider.x",
	textures = {
		{"mobs_spider.png"},
	},
	visual_size = {x = 7, y = 7},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_spider",
		attack = "mobs_spider",
	},
	walk_velocity = 1,
	run_velocity = 3,
	jump = true,
	view_range = 15,
	floats = 0,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 3},
		{name = "wool:black", chance = 1, min = 1, max = 3},
	},
	water_damage = 5,
	lava_damage = 5,
	light_damage = 0,
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 1,
		stand_end = 1,
		walk_start = 20,
		walk_end = 40,
		run_start = 20,
		run_end = 40,
		punch_start = 50,
		punch_end = 90,
	},
})

mobs:register_spawn("fun_caves:spider", {"fun_caves:stone_with_moss", "fun_caves:stone_with_lichen", "fun_caves:stone_with_algae"}, 14, 0, 5000, 2, 31000)

mobs:register_egg("fun_caves:spider", "Spider", "mobs_cobweb.png", 1)

-- compatibility
mobs:alias_mob("mobs:spider", "fun_caves:spider")
