
-- Sand Monster by PilzAdam

mobs:register_mob("fun_caves:tar_monster", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	pathfinding = true,
	reach = 2,
	damage = 2,
	hp_min = 15,
	hp_max = 40,
	armor = 100,
	collisionbox = {-0.4, -1, -0.4, 0.4, 0.8, 0.4},
	visual = "mesh",
	mesh = "mobs_sand_monster.b3d",
	textures = {
		{"fun_caves_tar_monster.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_sandmonster",
	},
	walk_velocity = 1.5,
	run_velocity = 4,
	view_range = 15,
	jump = true,
	floats = 0,
	drops = {
		{name = "default:coal_lump", chance = 1, min = 3, max = 5},
	},
	water_damage = 1,
	lava_damage = 2,
	light_damage = 1,
	fear_height = 4,
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 0,
		stand_end = 39,
		walk_start = 41,
		walk_end = 72,
		run_start = 74,
		run_end = 105,
		punch_start = 74,
		punch_end = 105,
	},
--[[
	custom_attack = function(self, p)
		local pos = self.object:getpos()
		minetest.add_item(pos, "default:sand")
	end,
]]
})

mobs:register_spawn("fun_caves:tar_monster", {"fun_caves:black_sand"}, 20, 0, 4000, 1, 31000)

mobs:register_egg("fun_caves:tar_monster", "Tar Monster", "fun_caves_black_sand.png", 1)
