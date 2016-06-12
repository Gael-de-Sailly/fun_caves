
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

-- Create and initialize a table for a schematic.
function fun_caves.schematic_array(width, height, depth)
	-- Dimensions of data array.
	local s = {size={x=width, y=height, z=depth}}
	s.data = {}

	for z = 0,depth-1 do
		for y = 0,height-1 do
			for x = 0,width-1 do
				local i = z*width*height + y*width + x + 1
				s.data[i] = {}
				s.data[i].name = "air"
				s.data[i].param1 = 000
			end
		end
	end

	s.yslice_prob = {}

	return s
end

fun_caves.schematics = {}
do
	local w, h, d = 5, 8, 5
	local s = fun_caves.schematic_array(w, h, d)

	for y = 0, math.floor(h/2)-1 do
		s.data[2*d*h + y*d + 2 + 1].name = 'default:tree'
		s.data[2*d*h + y*d + 2 + 1].param1 = 255
	end

	for z = 0, d-1 do
		for y = math.floor(h/2), h-1 do
			for x = 0, w-1 do
				if y < h - 1 or (x ~= 0 and x ~= w-1 and z ~= 0 and z ~= d-1) then
					if math.random(2) == 1 then
						s.data[z*d*h + y*d + x + 1].name = 'fun_caves:leaves_black'
					else
						s.data[z*d*h + y*d + x + 1].name = 'fun_caves:sticks_default'
					end

					if y == h-1 or x == 0 or x == w-1 or z == 0 or z == d-1 then
						s.data[z*d*h + y*d + x + 1].param1 = 150
					else
						s.data[z*d*h + y*d + x + 1].param1 = 225
					end
				end
			end
		end
	end

	for z = math.floor(d/2)-1, math.floor(d/2)+1, 2 do
		for x = math.floor(w/2)-1, math.floor(w/2)+1, 2 do
			s.data[z*d*h + math.floor(h/2)*d + x + 1].name = 'default:tree'
			s.data[z*d*h + math.floor(h/2)*d + x + 1].param1 = 150
		end
	end

	for y = 0, h-1 do
		if y / 3 == math.floor(y / 3) then
			s.yslice_prob[#s.yslice_prob+1] = {ypos=y,prob=170}
		end
	end

	fun_caves.schematics['decaying_tree'] = s
end

do
	local w, h, d = 5, 8, 5
	local s = fun_caves.schematic_array(w, h, d)

	for y = 0, math.floor(h/2)-1 do
		s.data[2*d*h + y*d + 2 + 1].name = 'fun_caves:lumin_tree'
		s.data[2*d*h + y*d + 2 + 1].param1 = 255
	end

	for z = 0, d-1 do
		for y = math.floor(h/2), h-1 do
			for x = 0, w-1 do
				if y < h - 1 or (x ~= 0 and x ~= w-1 and z ~= 0 and z ~= d-1) then
					s.data[z*d*h + y*d + x + 1].name = 'fun_caves:leaves_lumin'

					if y == h-1 or x == 0 or x == w-1 or z == 0 or z == d-1 then
						s.data[z*d*h + y*d + x + 1].param1 = 150
					else
						s.data[z*d*h + y*d + x + 1].param1 = 225
					end
				end
			end
		end
	end

	for z = math.floor(d/2)-1, math.floor(d/2)+1, 2 do
		for x = math.floor(w/2)-1, math.floor(w/2)+1, 2 do
			s.data[z*d*h + math.floor(h/2)*d + x + 1].name = 'fun_caves:lumin_tree'
			s.data[z*d*h + math.floor(h/2)*d + x + 1].param1 = 150
		end
	end

	for y = 0, h-1 do
		if y / 3 == math.floor(y / 3) then
			s.yslice_prob[#s.yslice_prob+1] = {ypos=y,prob=170}
		end
	end

	fun_caves.schematics['lumin_tree'] = s
end


dofile(fun_caves.path .. "/deco_caves.lua")
--dofile(fun_caves.path.."/deco_dirt.lua")
dofile(fun_caves.path.."/deco_plants.lua")
dofile(fun_caves.path.."/deco_rocks.lua")
--dofile(fun_caves.path.."/deco_ferns.lua")
--dofile(fun_caves.path.."/deco_ferns_tree.lua")
