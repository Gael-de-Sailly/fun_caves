local fortress_depth = -3  -- close to y / 80


local seed_noise = {offset = 0, scale = 32768, seed = 5202, spread = {x = 80, y = 80, z = 80}, octaves = 2, persist = 0.4, lacunarity = 2}
local fortress_noise = {offset = 0, scale = 1, seed = -4082, spread = {x = 7, y = 7, z = 7}, octaves = 4, persist = 1, lacunarity = 2}


-- These may speed up function access.
local rand = math.random
local min = math.min
local floor = math.floor

-- This tables looks up nodes that aren't already stored.
local node = setmetatable({}, {
	__index = function(t, k)
		t[k] = minetest.get_content_id(k)
		return t[k]
	end})

local data = {}
local p2data = {}  -- vm rotation data buffer


-- Create a table of biome ids, so I can use the biomemap.
local get_biome_id = minetest.get_biome_id
local biome_ids = {}
for name, desc in pairs(minetest.registered_biomes) do
	biome_ids[get_biome_id(desc.name)] = desc.name
end

--local function get_decoration(biome)
--	for i, deco in pairs(fun_caves.decorations) do
--		if not deco.biomes or deco.biomes[biome] then
--			local range = 1000
--			if deco.deco_type == "simple" then
--				if deco.fill_ratio and rand(range) - 1 < deco.fill_ratio * 1000 then
--					return deco.decoration
--				end
--			else
--				-- nop
--			end
--		end
--	end
--end

fun_caves.is_fortress = function(pos, cs, debug)
	-- Fix this to get csize, somehow.
	-- Remember that this function may be called
	--  before any chunks are generated.

	local cs = cs or {x=80, y=80, z=80}
	local offset = floor(cs.y / 2) - 8 + 1

	local y = floor((pos.y + offset) / cs.y)

	-- Fortresses show up below ground.
	-- Calls from the first dungeon level should return false.
	if y > fortress_depth or (pos.y + offset) % cs.y > cs.y - 5 then
		return false
	end

	local x = floor((pos.x + offset) / cs.x)
	local z = floor((pos.z + offset) / cs.z)

	local n = minetest.get_perlin(fortress_noise):get3d({x=x, y=y, z=z})
	if fun_caves.DEBUG and floor((n * 10000) % 4) == 1 then
		print('fortress ('..x..','..y..','..zn..')')
		return true
	end
	if floor((n * 10000) % 19) == 1 then
		return true
	end

	return false
end


fun_caves.underzones = {
	Caina = {
		name = 'Caina',
		ceiling = -4852,
		ceiling_node = 'default:ice',
		column_node = 'default:ice',
		column_node_rare  =  'fun_caves:thin_ice',
		floor = -4972,
		floor_node = 'default:ice',
		lower_bound = -4992,
		regular_columns = false,
		stalactite = 'fun_caves:icicle_down',
		stalactite_chance = 12,
		stone_depth = 2,
		upper_bound = -4832,
		vary = true,
	},
	Phlegethos = {
		name = 'Phlegethos',
		ceiling = -9892,
		ceiling_node = 'fun_caves:black_sand',
		column_node = 'default:stone',
		column_node_rare  =  'fun_caves:hot_stone',
		floor = -10012,
		floor_node = 'fun_caves:hot_cobble',
		fluid = 'default:lava_source',
		fluid_chance = 1200,
		lake = 'default:lava_source',
		lake_level = 5,
		lower_bound = -10032,
		regular_columns = false,
		stone_depth = 1,
		upper_bound = -9872,
		vary = true,
	},
	Dis = {
		name = 'Dis',
		ceiling = -14914,
		ceiling_node = 'fun_caves:hot_brass',
		column_node = 'default:steelblock',
		floor = -14982,
		floor_node = 'fun_caves:hot_brass',
		lower_bound = -14992,
		regular_columns = true,
		stone_depth = 1,
		upper_bound = -14912,
		vary = false,
	},
	Minauros = {
		name = 'Minauros',
		ceiling = -19812,
		ceiling_node = 'fun_caves:black_sand',
		column_node = 'fun_caves:polluted_dirt',
		column_node_rare  =  'fun_caves:glowing_fungal_stone',
		floor = -19932,
		floor_node = 'fun_caves:polluted_dirt',
		fluid = 'fun_caves:water_poison_source',
		fluid_chance = 2000,
		lake = 'fun_caves:water_poison_source',
		lake_level = 10,
		lower_bound = -19952,
		regular_columns = false,
		stone_depth = 2,
		upper_bound = -19792,
		vary = true,
	},
	Styx = {
		name = 'Styx',
		ceiling = -29812,
		ceiling_node = 'default:dirt',
		floor = -30012,
		floor_node = 'default:dirt',
		lower_bound = -30032,
		regular_columns = false,
		stone_depth = 2,
		sealevel = -29842,
		upper_bound = -29792,
		vary = true,
	},
}

fun_caves.cave_biomes = {
	algae = {
		biome_val_low = 0,
		biome_val_high = 0.2,
		ceiling_node = 'fun_caves:stone_with_algae',
		dirt = 'default:dirt',
		dirt_chance = 10,
		floor_node = 'fun_caves:stone_with_algae',
		fungi = true,
		stalactite = 'fun_caves:stalactite_slimy',
		stalactite_chance = 12,
		stalagmite = 'fun_caves:stalagmite_slimy',
		stalagmite_chance = 12,
		stone_depth = 1,
		underwater = true,
	},
	coal = {
		biome_val_low = 0.5,
		biome_val_high = 0.6,
		ceiling_node = 'fun_caves:black_sand',
		deco = 'default:coalblock',
		deco_chance = 100,
		floor_node = 'fun_caves:black_sand',
		stalagmite = 'fun_caves:constant_flame',
		stalagmite_chance = 50,
		stone_depth = 2,
		underwater = false,
	},
	hot = {
		biome_val_low = 0.6,
		biome_val_high = 99,
		ceiling_node = 'fun_caves:hot_cobble',
		floor_node = 'fun_caves:hot_cobble',
		fluid = 'default:lava_source',
		fluid_chance = 300,
		stalagmite = fun_caves.hot_spikes,
		stalagmite_chance = 50,
		stone_depth = 1,
		underwater = false,
	},
	ice = {
		biome_val_low = -99,
		biome_val_high = -0.6,
		ceiling_node = 'default:ice',
		floor_node = 'default:ice',
		stalactite = 'fun_caves:icicle_down',
		stalactite_chance = 12,
		stalagmite = 'fun_caves:icicle_up',
		stalagmite_chance = 12,
		stone_depth = 2,
		underwater = true,
	},
	ice_thin = {
		biome_val_low = -0.6,
		biome_val_high = -0.5,
		ceiling_node = 'fun_caves:thin_ice',
		floor_node = 'fun_caves:thin_ice',
		stone_depth = 2,
		underwater = true,
	},
	lichen = {
		biome_val_low = -0.3,
		biome_val_high = 0,
		ceiling_node = 'fun_caves:stone_with_lichen',
		dirt = 'default:dirt',
		dirt_chance = 10,
		floor_node = 'fun_caves:stone_with_lichen',
		fungi = true,
		stalactite = 'fun_caves:stalactite',
		stalactite_chance = 12,
		stalagmite = 'fun_caves:stalagmite',
		stalagmite_chance = 12,
		stone_depth = 1,
		underwater = true,
	},
	lichen_dead = {
		biome_val_low = -0.6,
		biome_val_high = -0.5,
		ceiling_node = 'fun_caves:stone_with_lichen',
		floor_node = 'fun_caves:stone_with_lichen',
		stalactite = 'fun_caves:stalactite',
		stalactite_chance = 12,
		stalagmite = 'fun_caves:stalagmite',
		stalagmite_chance = 12,
		stone_depth = 1,
		underwater = true,
	},
	moss = {
		biome_val_low = -0.5,
		biome_val_high = -0.3,
		ceiling_node = 'fun_caves:stone_with_moss',
		deco = 'fun_caves:glowing_fungal_stone',
		deco_chance = 50,
		floor_node = 'fun_caves:stone_with_moss',
		fluid = 'default:water_source',
		fluid_chance = 300,
		stalactite = 'fun_caves:stalactite_mossy',
		stalactite_chance = 12,
		stalagmite = 'fun_caves:stalagmite_mossy',
		stalagmite_chance = 12,
		stone_depth = 1,
		underwater = true,
	},
	salt = {
		biome_val_low = 0.2,
		biome_val_high = 0.35,
		ceiling_node = 'fun_caves:stone_with_salt',
		deco = 'fun_caves:radioactive_ore',
		deco_chance = 500,
		floor_node = 'fun_caves:stone_with_salt',
		stone_depth = 2,
		underwater = false,
	},
	sand = {
		biome_val_low = 0.35,
		biome_val_high = 0.5,
		ceiling_node = 'default:sand',
		floor_node = 'default:sand',
		stone_depth = 2,
		underwater = true,
	},
}


local function generate(p_minp, p_maxp, seed)
	local minp, maxp = p_minp, p_maxp
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	vm:get_data(data)
	p2data = vm:get_param2_data()
	local heightmap = minetest.get_mapgen_object("heightmap")
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local csize = vector.add(vector.subtract(maxp, minp), 1)

	-- use the same seed (based on perlin noise).
	math.randomseed(minetest.get_perlin(seed_noise):get2d({x=minp.x, y=minp.z}))

	local write = false
	local write_p2 = false
	local underzone
	for _, uz in pairs(fun_caves.underzones) do
		local avg = (minp.y + maxp.y) / 2
		if avg <= uz.upper_bound and avg >= uz.lower_bound then
			underzone = uz
		end
	end

	if not underzone and fun_caves.is_fortress(minp, csize) then
	--if not underzone then
		fun_caves.fortress(minp, maxp, data, area, node)
		write = true
	else
		local write1, write2
		write1 = fun_caves.cavegen(minp, maxp, data, area, node, heightmap, underzone)
		write2, write_p2 = fun_caves.decogen(minp, maxp, data, p2data, area, node, heightmap, biome_ids, underzone)
		write = write1 or write2
	end


	if write then
		vm:set_data(data)
		if write_p2 then
			vm:set_param2_data(p2data)
		end

		if fun_caves.DEBUG then
			vm:set_lighting({day = 15, night = 15})
		else
			-- set_lighting causes shadows
			--vm:set_lighting({day = 0, night = 0})
			vm:calc_lighting({x=minp.x,y=emin.y,z=minp.z}, maxp)
		end
		vm:update_liquids()
		vm:write_to_map()
	end

	-- Deal with memory issues. This, of course, is supposed to be automatic.
	minetest.after(0, function()
		if math.floor(collectgarbage("count")/1024) > 400 then
			print("Fun Caves: Manually collecting garbage...")
			collectgarbage("collect")
		end
	end)
end


dofile(fun_caves.path .. "/cavegen.lua")
dofile(fun_caves.path .. "/decogen.lua")
dofile(fun_caves.path .. "/fortress.lua")


-- Inserting helps to ensure that fun_caves operates first.
table.insert(minetest.registered_on_generateds, 1, generate)
