
-- Spider by AspireMint (fishyWET (CC-BY-SA 3.0 license for texture)

function fun_caves.climb(self)
	if self.state == "stand" and math.random() < 0.2 then
		if self.fall_speed == 2 then
			self.fall_speed = -2
		else
			self.fall_speed = 2
		end
	elseif self.state == "attack" and self.fall_speed ~= -2 then
		self.fall_speed = -2
	end
end

mobs:register_mob("fun_caves:dangler", {
	description = "Dangling Spider",
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	attacks_monsters = true,
	reach = 2,
	damage = 1,
	hp_min = 10,
	hp_max = 20,
	armor = 200,
	collisionbox = {-0.32, -0.0, -0.25, 0.25, 0.25, 0.25},
	visual = "mesh",
	mesh = "fun_caves_spider.x",
	drawtype = "front",
	textures = {
		{"mobs_spider.png"},
	},
	visual_size = {x = 1.5, y = 1.5},
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
		{name = "mobs:meat_raw", chance = 2, min = 1, max = 1},
		{name = "farming:cotton", chance = 2, min = 1, max = 2},
	},
	water_damage = 0,
	lava_damage = 5,
	cold_damage = 1,
	light_damage = 0,
	fall_damage = 0,
	lifetimer = 360,
	follow = nil,
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
	replace_rate = 50,
	--replace_what = {"mobs:cobweb", "fun_caves:glowing_fungal_wood", "fun_caves:sap",},
	--replace_with = "air",
	--replace_offset = -1,
	do_custom = function(self)
		if not fun_caves.custom_ready(self) then
			return
		end

		fun_caves.climb(self)
		fun_caves.search_replace(self.object:getpos(), 100, {"air"}, "mobs:cobweb")

		fun_caves.surface_damage(self)
	end,
})

mobs:register_spawn("fun_caves:dangler", {"fun_caves:stone_with_moss", "fun_caves:stone_with_lichen", "fun_caves:stone_with_algae"}, 14, 0, 2500, 3, 31000)

mobs:register_egg("fun_caves:dangler", "Dangling Spider", "mobs_cobweb.png", 1)


-- cobweb
if not minetest.registered_nodes['mobs:cobweb'] then
	minetest.register_node(":mobs:cobweb", {
		description = "Cobweb",
		drawtype = "plantlike",
		visual_scale = 1.1,
		tiles = {"mobs_cobweb.png"},
		inventory_image = "mobs_cobweb.png",
		paramtype = "light",
		sunlight_propagates = true,
		liquid_viscosity = 11,
		liquidtype = "source",
		liquid_alternative_flowing = "mobs:cobweb",
		liquid_alternative_source = "mobs:cobweb",
		liquid_renewable = false,
		liquid_range = 0,
		walkable = false,
		groups = {snappy = 1, liquid = 3},
		drop = "farming:cotton",
		sounds = default.node_sound_leaves_defaults(),
	})

	minetest.register_craft({
		output = "mobs:cobweb",
		recipe = {
			{"farming:string", "", "farming:string"},
			{"", "farming:string", ""},
			{"farming:string", "", "farming:string"},
		}
	})
end

minetest.register_abm({
	nodenames = {"mobs:cobweb"},
	interval = 500,
	chance = 50,
	action = function(pos, node)
		minetest.set_node(pos, {name = "air"})
	end
})
