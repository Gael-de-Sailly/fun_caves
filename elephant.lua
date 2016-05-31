
-- elephant from dmobs by D00Med (LGPL v2.1, textures CC-BY-SA v3.0)

mobs:register_mob("fun_caves:elephant", {
	type = "monster",
	passive = false,
	reach = 3,
	damage = 4,
	attack_type = "dogfight",
	hp_min = 12,
	hp_max = 22,
	armor = 130,
	collisionbox = {-0.9, -1.2, -0.9, 0.9, 0.9, 0.9},
	visual = "mesh",
	mesh = "fun_caves_elephant.b3d",
	textures = {
		{"fun_caves_elephant.png"},
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x=2.5, y=2.5},
	makes_footstep_sound = true,
	walk_velocity = 1.1,
	run_velocity = 1.2,
	jump = false,
	water_damage = 2,
	lava_damage = 2,
	light_damage = 0,
	replace_rate = 10,
	replace_what = {"default:dry_grass_3", "default:dry_grass_4", "default:dry_grass_5", "farming:straw", "fun_caves:dry_fiber"},
	replace_with = "air",
	follow = {"farming:wheat"},
	view_range = 9,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 1},
	},
	animation = {
		speed_normal = 5,
		speed_run = 10,
		walk_start = 3,
		walk_end = 19,
		stand_start = 20,
		stand_end = 30,
		run_start = 3,
		run_end = 19,

	},
	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end

		mobs:capture_mob(self, clicker, 0, 5, 50, false, nil)
	end,
})

mobs:register_spawn("fun_caves:elephant", {"default:dirt_with_dry_grass","default:desert_sand"}, 20, 10, 17000, 2, 31000)

mobs:register_egg("fun_caves:elephant", "Elephant", "default_dry_grass.png", 1)
