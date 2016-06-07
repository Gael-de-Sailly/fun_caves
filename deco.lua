
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

minetest.register_craft({
	output = "default:stick 2",
	recipe = {
		{"default:cactus"}
	}
})

minetest.add_group("default:cactus", {oddly_breakable_by_hand=1})


local biome_mod = {
	coniferous_forest_dunes = { heat_point = 35, humidity_point = 60, },
	coniferous_forest = { heat_point = 35, humidity_point = 60, },
	coniferous_forest_ocean = { heat_point = 35, humidity_point = 60, },
	deciduous_forest = { heat_point = 60, humidity_point = 60, },
	deciduous_forest_ocean = { heat_point = 60, humidity_point = 60, },
	deciduous_forest_swamp = { heat_point = 60, humidity_point = 60, },
	desert = { heat_point = 80, humidity_point = 10, },
	desert_ocean = { heat_point = 80, humidity_point = 10, },
	glacier = {},
	glacier_ocean = {},
	rainforest = { heat_point = 85, humidity_point = 70, },
	rainforest_ocean = { heat_point = 85, humidity_point = 70, },
	rainforest_swamp = { heat_point = 85, humidity_point = 70, },
	sandstone_grassland_dunes = { heat_point = 55, humidity_point = 40, },
	sandstone_grassland = { heat_point = 55, humidity_point = 40, },
	sandstone_grassland_ocean = { heat_point = 55, humidity_point = 40, },
	savanna = { heat_point = 80, humidity_point = 25, },
	savanna_ocean = { heat_point = 80, humidity_point = 25, },
	savanna_swamp = { heat_point = 80, humidity_point = 25, },
	stone_grassland_dunes = { heat_point = 35, humidity_point = 40, },
	stone_grassland = { heat_point = 35, humidity_point = 40, },
	stone_grassland_ocean = { heat_point = 35, humidity_point = 40, },
	taiga = {},
	taiga_ocean = {},
	tundra = { node_river_water = "fun_caves:thin_ice", },
	tundra_beach = { node_river_water = "fun_caves:thin_ice", },
	tundra_ocean = {},
}
local rereg = {}

for n, bi in pairs(biome_mod) do
	for i, rbi in pairs(minetest.registered_biomes) do
		if rbi.name == n then
			rereg[#rereg+1] = table.copy(rbi)
			for j, prop in pairs(bi) do
				rereg[#rereg][j] = prop
			end
		end
	end
end

minetest.clear_registered_biomes()

for _, bi in pairs(rereg) do
	minetest.register_biome(bi)
end

rereg = {}
for _, dec in pairs(minetest.registered_decorations) do
	rereg[#rereg+1] = dec
end
minetest.clear_registered_decorations()
for _, dec in pairs(rereg) do
	minetest.register_decoration(dec)
end
rereg = nil


minetest.register_biome({
	name = "desertstone_grassland",
	--node_dust = "",
	node_top = "default:dirt_with_grass",
	depth_top = 1,
	node_filler = "default:dirt",
	depth_filler = 1,
	node_stone = "default:desert_stone",
	node_riverbed = "default:sand",
	depth_riverbed = 2,
	--node_water_top = "",
	--depth_water_top = ,
	--node_water = "",
	--node_river_water = "",
	y_min = 6,
	y_max = 31000,
	heat_point = 80,
	humidity_point = 55,
})


minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 80,
	fill_ratio = 0.1,
	biomes = {"desertstone_grassland", },
	y_min = 1,
	y_max = 31000,
	decoration = "default:junglegrass",
})


dofile(fun_caves.path .. "/deco_caves.lua")
--dofile(fun_caves.path.."/deco_dirt.lua")
dofile(fun_caves.path.."/deco_plants.lua")
dofile(fun_caves.path.."/deco_rocks.lua")
--dofile(fun_caves.path.."/deco_ferns.lua")
--dofile(fun_caves.path.."/deco_ferns_tree.lua")
