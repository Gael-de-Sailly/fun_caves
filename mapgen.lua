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
local node_match_cache = {}


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
	if debug then
		print(x, y, z, n, floor((n * 10000) % 19))
	end
	if floor((n * 10000) % 19) == 1 or fun_caves.DEBUG then
		return true
	end

	return false
end


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
	local underzone, dis_map = nil, {}
	if minp.y < -4000 and minp.y % 4960 < 160 and maxp.y % 4960 > 0 then
		underzone = floor(minp.y / -4960 + 0.5)
		if underzone == 3 then
			for i = 0, 10, 2 do
				dis_map[i] = {}
				for j = 0, 10, 2 do
					dis_map[i][j] = rand(4)
				end
			end
		end
	end

	if not underzone and fun_caves.is_fortress(minp, csize) then
	--if not underzone then
		fun_caves.fortress(minp, maxp, data, area, node)
		write = true
	else
		write = fun_caves.cavegen(minp, maxp, data, area, node, heightmap, underzone)

		write, write_p2 = fun_caves.decogen(minp, maxp, data, p2data, area, node, heightmap, biome_ids, underzone, dis_map)
	end


	if write then
		vm:set_data(data)
		if write_p2 then
			vm:set_param2_data(p2data)
		end

		if fun_caves.DEBUG then
			vm:set_lighting({day = 10, night = 10})
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
