
-- Spider by AspireMint (fishyWET (CC-BY-SA 3.0 license for texture)

mobs:register_mob("fun_caves:tarantula", {
	docile_by_day = true,
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	reach = 1,
	damage = 1,
	hp_min = 1,
	hp_max = 2,
	armor = 200,
	collisionbox = {-0.15, -0.01, -0.15, 0.15, 0.1, 0.15},
	visual = "mesh",
	mesh = "fun_caves_spider.x",
	textures = {
		{"fun_caves_tarantula.png"},
	},
	visual_size = {x = 1, y = 1},
	makes_footstep_sound = false,
	--sounds = {
	--	random = "mobs_spider",
	--	attack = "mobs_spider",
	--},
	walk_velocity = 1,
	run_velocity = 2,
	jump = false,
	view_range = 15,
	floats = 0,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 1},
	},
	water_damage = 0,
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
	do_custom = function(self)
		if not self.fun_caves_damage_timer then
			self.fun_caves_damage_timer = 0
		end

		fun_caves.surface_damage(self)
	end,
})

mobs:register_spawn("fun_caves:tarantula", {"default:desert_sand"}, 99, 0, 2000, 2, 31000)

--mobs:register_egg("fun_caves:spider", "Deep Spider", "mobs_cobweb.png", 1)
