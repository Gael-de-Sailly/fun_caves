
-- I like having different stone scattered about. Sandstone forms
--  in layers. Desert stone... doesn't exist, but let's assume it's
--  another sedementary rock and place it similarly.
minetest.register_ore({ore_type="sheet", ore="default:sandstone", wherein="default:stone", clust_num_ores=250, clust_scarcity=60, clust_size=10, y_min=-1000, y_max=31000, noise_threshhold=0.1, noise_params={offset=0, scale=1, spread={x=256, y=256, z=256}, seed=4130293965, octaves=5, persist=0.60}, random_factor=1.0})
minetest.register_ore({ore_type="sheet", ore="default:desert_stone", wherein="default:stone", clust_num_ores=250, clust_scarcity=60, clust_size=10, y_min=-1000, y_max=31000, noise_threshhold=0.1, noise_params={offset=0, scale=1, spread={x=256, y=256, z=256}, seed=163281090, octaves=5, persist=0.60}, random_factor=1.0})

minetest.register_node("fun_caves:sand_with_rocks", {
	description = "Sand and rocks",
	tiles = {"fun_caves_sand_with_rocks.png"},
	groups = {crumbly = 3, falling_node = 1, sand = 1},
	sounds = default.node_sound_sand_defaults(),
	drop = {max_items=2, items={{items={"fun_caves:small_rocks"}, rarity=1}, {items={"default:sand"}, rarity=1}}},
})

--minetest.register_decoration({
--	deco_type = "simple",
--	place_on = {"default:dirt_with_grass"},
--	sidelen = 80,
--	fill_ratio = 0.1,
--	biomes = {"rainforest", "desertstone_grassland"},
--	y_min = 1,
--	y_max = 31000,
--	decoration = "default:junglegrass",
--})

minetest.register_craft({
	output = "default:stick 2",
	recipe = {
		{"default:cactus"}
	}
})

minetest.add_group("default:cactus", {oddly_breakable_by_hand=1})

dofile(fun_caves.path.."/deco_caves.lua")
--dofile(fun_caves.path.."/deco_coral.lua")
--dofile(fun_caves.path.."/deco_dirt.lua")
--dofile(fun_caves.path.."/deco_trees.lua")
--dofile(fun_caves.path.."/deco_plants.lua")
--dofile(fun_caves.path.."/deco_rocks.lua")
--dofile(fun_caves.path.."/deco_fungal_tree.lua")
--dofile(fun_caves.path.."/deco_ferns.lua")
--dofile(fun_caves.path.."/deco_ferns_tree.lua")
--dofile(fun_caves.path.."/deco_water.lua")
