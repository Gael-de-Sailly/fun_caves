local deco_depth = -30  -- place cave stuff this far beneath the surface
local light_depth = -13  -- depth above which to place corals/sea plants
local water_level = 1
local fortress_depth = -3  -- close to y / 80
local max_depth = 31000
local cave_width = 0.05  -- figurative width
local fluid_compression = -200  -- the depth to start planting lava/water
local dirt_ratio = 10  -- place this many stones for every dirt in caves
local radioactive_ratio = 500  -- place this much salt for every radioactive ore
local coalblock_ratio = 100  -- place this many sand for every coalblock
local fungal_stone_ratio = 50  -- place this many stones for every glowing fungus
local water_lily_ratio = 15  -- place this many water for every lily

local water_lily_biomes = {}
for _, i in pairs({"rainforest_swamp", "rainforest", "savanna_swamp", "savanna",  "deciduous_forest_swamp", "deciduous_forest", "desertstone_grassland", }) do
	water_lily_biomes[i] = true
end
local coral_biomes = {}
for _, i in pairs({"desert_ocean", "savanna_ocean", "rainforest_ocean", }) do
	coral_biomes[i] = true
end


local cave_noise_1 = {offset = 0, scale = 1, seed = 3901, spread = {x = 40, y = 10, z = 40}, octaves = 3, persist = 1, lacunarity = 2}
local cave_noise_2 = {offset = 0, scale = 1, seed = -8402, spread = {x = 40, y = 20, z = 40}, octaves = 3, persist = 1, lacunarity = 2}
local cave_noise_3 = {offset = 15, scale = 10, seed = 3721, spread = {x = 40, y = 40, z = 40}, octaves = 3, persist = 1, lacunarity = 2}
local seed_noise = {offset = 0, scale = 32768, seed = 5202, spread = {x = 80, y = 80, z = 80}, octaves = 2, persist = 0.4, lacunarity = 2}
local biome_noise = {offset = 0.0, scale = 1.0, spread = {x = 400, y = 400, z = 400}, seed = 903, octaves = 3, persist = 0.5, lacunarity = 2.0}
local fortress_noise = {offset = 0, scale = 1, seed = -4082, spread = {x = 7, y = 7, z = 7}, octaves = 4, persist = 1, lacunarity = 2}
local plant_noise = {offset = 0.0, scale = 1.0, spread = {x = 200, y = 200, z = 200}, seed = 33, octaves = 3, persist = 0.7, lacunarity = 2.0}


-- These may speed up function access.
local rand = math.random
local max = math.max
local min = math.min
local log = math.log
local ceil = math.ceil
local floor = math.floor
local abs = math.abs
local find_nodes_in_area = minetest.find_nodes_in_area

-- This tables looks up nodes that aren't already stored.
local node = setmetatable({}, {
	__index = function(t, k)
		t[k] = minetest.get_content_id(k)
		return t[k]
	end})

local data = {}
--local p2data = {}  -- vm rotation data buffer
local node_match_cache = {}


-- Create a table of biome ids, so I can use the biomemap.
local get_biome_id = minetest.get_biome_id
local biome_ids = {}
for name, desc in pairs(minetest.registered_biomes) do
	biome_ids[get_biome_id(desc.name)] = desc.name
end

--local function place_schematic(pos, schem, center)
--	local rot = rand(4) - 1
--	local yslice = {}
--	if schem.yslice_prob then
--		for _, ys in pairs(schem.yslice_prob) do
--			yslice[ys.ypos] = ys.prob
--		end
--	end
--
--	if center then
--		pos.x = pos.x - floor(schem.size.x / 2)
--		pos.z = pos.z - floor(schem.size.z / 2)
--	end
--
--	for z1 = 0, schem.size.z - 1 do
--		for x1 = 0, schem.size.x - 1 do
--			local x, z
--			if rot == 0 then
--				x, z = x1, z1
--			elseif rot == 1 then
--				x, z = schem.size.z - z1 - 1, x1
--			elseif rot == 2 then
--				x, z = schem.size.x - x1 - 1, schem.size.z - z1 - 1
--			elseif rot == 3 then
--				x, z = z1, schem.size.x - x1 - 1
--			end
--			local dz = pos.z - minp.z + z
--			local dx = pos.x - minp.x + x
--			if pos.x + x > minp.x and pos.x + x < maxp.x and pos.z + z > minp.z and pos.z + z < maxp.z then
--				local ivm = area:index(pos.x + x, pos.y, pos.z + z)
--				local isch = z1 * schem.size.y * schem.size.x + x1 + 1
--				for y = 0, schem.size.y - 1 do
--					local dy = pos.y - minp.y + y
--					if math.min(dx, csize.x - dx) + math.min(dy, csize.y - dy) + math.min(dz, csize.z - dz) > bevel then
--						if yslice[y] or 255 >= rand(255) then
--							local prob = schem.data[isch].prob or schem.data[isch].param1 or 255
--							if prob >= rand(255) and schem.data[isch].name ~= "air" then
--								data[ivm] = node[schem.data[isch].name]
--							end
--							local param2 = schem.data[isch].param2 or 0
--							p2data[ivm] = param2
--						end
--					end
--
--					ivm = ivm + area.ystride
--					isch = isch + schem.size.x
--				end
--			end
--		end
--	end
--end

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

local function surround(node, data, area, ivm)
	-- Check to make sure that a plant root is fully surrounded.
	-- This is due to the kludgy way you have to make water plants
	--  in minetest, to avoid bubbles.
	for x1 = -1,1,2 do
		local n = data[ivm+x1] 
		if n == node["default:river_water_source"] or n == node["default:water_source"] or n == node["air"] then
			return false
		end
	end
	for z1 = -area.zstride,area.zstride,2*area.zstride do
		local n = data[ivm+z1] 
		if n == node["default:river_water_source"] or n == node["default:water_source"] or n == node["air"] then
			return false
		end
	end

	return true
end

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
	--p2data = vm:get_param2_data()
	local heightmap = minetest.get_mapgen_object("heightmap")
	local biomemap = minetest.get_mapgen_object("biomemap")
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local csize = vector.add(vector.subtract(maxp, minp), 1)
	local noise_area = VoxelArea:new({MinEdge={x=0,y=0,z=0}, MaxEdge=vector.subtract(csize, 1)})

	-- use the same seed (based on perlin noise).
	math.randomseed(minetest.get_perlin(seed_noise):get2d({x=minp.x, y=minp.z}))

	local write = false
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
		write = true
		--------------------------------------------------------------
		-- fortress decoration non-loop -- only there to enable breaks
		-- Remove this loop to eliminate fortress decorations.
		--------------------------------------------------------------
		for deco_non_loop = 1, 1 do
			-- invisible maze
			-- hungry maze
			-- chests (w traps)
			-- step traps (math based)
			-- hidden doors/downs
			-- hot/ice floors
			--
			--local level = ceil(maxp.y / 3100)
			local n = 16
			local walls = {}
			local inner_floor = node['fun_caves:dungeon_floor_1']
			local outer_wall = node['fun_caves:dungeon_wall_2']
			local inner_wall = node['fun_caves:dungeon_wall_1']

			for y2 = 0, n-1 do
				--for y2 = 0, 0 do
				-- walls is zero-based.
				for i = 0, 2 * n * n - 1 do
					walls[i] = i
				end
				table.shuffle(walls)

				local dox, doz = rand(0, n-1), rand(0, n-1)
				for z = minp.z, maxp.z do
					for y = minp.y + y2 * 5, minp.y + y2 * 5 + 4 do
						local ivm = area:index(minp.x, y, z)
						for x = minp.x, maxp.x do
							if x == minp.x or z == minp.z or x == maxp.x or z == maxp.z then
								data[ivm] = outer_wall
							elseif (y - minp.y) % 5 == 0 then
								if floor((z - minp.z) / 5) == doz and floor((x - minp.x) / 5) == dox and (z - minp.z) % 5 ~= 0 and (x - minp.x) % 5 ~= 0 and y ~= minp.y then
									data[ivm] = node["air"]
								else
									data[ivm] = inner_floor
								end
							elseif (z - minp.z) % 5 == 0 or (x - minp.x) % 5 == 0 then
								--data[ivm] = fun_caves.DEBUG and node["default:glass"] or inner_wall
								data[ivm] = inner_wall
							else
								data[ivm] = node["air"]
							end
							ivm = ivm + 1
						end
					end
				end

				local set = unionfind(n * n)

				for m = 0, #walls do
					local c = walls[m]
					local a = floor(c / 2)
					local i = a % n
					local j = floor(a / n)
					local u = c % 2 == 0 and 1 or 0
					local v = c % 2 == 1 and 1 or 0
					local b = a + u + n * v
					if i < n - u and j < n - v and set:find(a) ~= set:find(b) then
						set:union(a, b)
						local x = (i + u) * 5 + minp.x
						local y = minp.y + y2 * 5
						local z = (j + v) * 5 + minp.z
						--if y > minp.y and rand(20) == 1 then
						--	for z1 = z + 1, z + 4 do
						--		ivm = area:index(x+1, y, z1)
						--		for x1 = x + 1, x + 4 do
						--			data[ivm] = node["air"]
						--			ivm = ivm + 1
						--		end
						--	end
						--end

						for z1 = z + (1-v), z + (1-v) * 4 do
							for y1 = y + 1, y + 4 do
								local ivm = area:index(x + (1-u), y1, z1)
								for x1 = x + (1-u), x + (1-u) * 4 do
									if x1 < maxp.x and z1 < maxp.z and x1 > minp.x and z1 > minp.z then
										data[ivm] = node["air"]
									end
									ivm = ivm + 1
								end
							end
						end
					end
				end
			end
		end
		-----------------------------------------------------
		-- end of fortress decoration non-loop
		-----------------------------------------------------
	else
		local cave_1 = minetest.get_perlin_map(cave_noise_1, csize):get3dMap_flat(minp)
		local cave_2 = minetest.get_perlin_map(cave_noise_2, csize):get3dMap_flat(minp)
		local cave_3 = minetest.get_perlin_map(cave_noise_3, {x=csize.x, y=csize.z}):get2dMap_flat({x=minp.x, y=minp.z})
		local biome_n = minetest.get_perlin_map(biome_noise, csize):get3dMap_flat(minp)
		local plant_n = minetest.get_perlin_map(plant_noise, {x=csize.x, y=csize.z}):get2dMap_flat({x=minp.x, y=minp.z})


		local index = 0
		local index3d = 0
		for z = minp.z, maxp.z do
			for x = minp.x, maxp.x do
				index = index + 1
				index3d = noise_area:index(x - minp.x, 0, z - minp.z)
				local ivm = area:index(x, minp.y, z)

				local height = heightmap[index]
				if height >= maxp.y - 1 and data[area:index(x, maxp.y, z)] ~= node['air'] then
					height = max_depth
					heightmap[index] = height
				elseif height <= minp.y then
					height = -max_depth
					heightmap[index] = height
				end

				local column = 0
				if underzone then
					if cave_3[index] < 30 then
						column = 1
					elseif cave_3[index] < 35 then
						column = 2
					end
				end

				for y = minp.y, maxp.y do
					-- Dis
					if underzone == 6 and y % 4960 < cave_3[index] + 160 and y % 4960 > cave_3[index] + 80 then
						if y < -29620 then
							data[ivm] = node["default:water_source"]
						else
							data[ivm] = node["air"]
						end
						write = true
					elseif underzone == 3 then
						if (x - minp.x) < 8 and (z - minp.z) < 8 then
							data[ivm] = node["default:steelblock"]
						elseif data[ivm] ~= node['air'] and y % 4960 < 160 and y % 4960 > 80 then
							data[ivm] = node["air"]
						end
						write = true
					-- Caina
					elseif column == 2 and underzone == 1 and (data[ivm] == node['default:stone'] or data[ivm] == node['default:desert_stone']) then
						if rand(70) == 1 then
							data[ivm] = node["fun_caves:thin_ice"]
						else
							data[ivm] = node["default:ice"]
						end
						write = true
					-- Phlegethos
					elseif column == 2 and (data[ivm] == node['default:stone'] or data[ivm] == node['default:desert_stone']) and rand(70) == 1 then
						data[ivm] = node["fun_caves:hot_stone"]
						write = true
					-- Dis
					elseif column == 1 and underzone ~= 3 and data[ivm] ~= node['air'] and y % 4960 < cave_3[index] + 160 and y % 4960 > cave_3[index] + 80 then
						if y < -29620 then
							data[ivm] = node["default:water_source"]
						else
							data[ivm] = node["air"]
						end
						write = true
					elseif column < 2 and underzone ~= 3 and data[ivm] ~= node['air'] and y < height - cave_3[index] and cave_1[index3d] * cave_2[index3d] > cave_width then
						if y < -29620 then
							data[ivm] = node["default:water_source"]
						else
							data[ivm] = node["air"]
						end
						write = true

						if y > 0 and cave_3[index] < 1 and y == height then
							-- Clear the air above a cave mouth.
							local ivm2 = ivm
							for y2 = y + 1, maxp.y + 8 do
								ivm2 = ivm2 + area.ystride
								if data[ivm2] ~= node["default:water_source"] then
									data[ivm2] = node["air"]
									write = true
								end
							end
						end
					end

					ivm = ivm + area.ystride
					index3d = index3d + csize.x
				end
			end
		end

		-- Air needs to be placed prior to decorations.
		local index = 0
		local index3d = 0
		for z = minp.z, maxp.z do
			for x = minp.x, maxp.x do
				index = index + 1
				index3d = noise_area:index(x - minp.x, 0, z - minp.z)
				local ivm = area:index(x, minp.y, z)

				local height = heightmap[index]

				for y = minp.y, maxp.y do
					if y <= height + deco_depth and (height < max_depth or y < 0) then
						----------------------------------------------------------
						-- cave decoration non-loop -- only there to enable breaks
						-- Remove this loop to eliminate cave decorations.
						----------------------------------------------------------
						for deco_non_loop = 1, 1 do
							if not (data[ivm] == node["air"] or data[ivm] == node["default:stone"]) then
								break
							end

							local biome_val = biome_n[index3d]
							local stone_type = node["default:stone"]
							local stone_depth = 1

							-- Compress biomes at the surface to avoid fluids.
							if y > fluid_compression then
								biome_val = biome_val / max(1, log(y - fluid_compression))
							end
							-------------------
							--biome_val = -0.75
							-------------------
							if underzone == 1 then
								stone_type = node["default:ice"]
								stone_depth = 2
							elseif underzone == 3 then
								stone_type = node["fun_caves:hot_brass"]
								stone_depth = 1
							elseif underzone == 6 then
								stone_type = node["default:dirt"]
								stone_depth = 2
							elseif underzone and y % 4960 <= 145 then
								stone_type = node["fun_caves:hot_cobble"]
							elseif underzone and y % 4960 > 145 then
								stone_type = node["fun_caves:black_sand"]
								stone_depth = 2
							elseif biome_val < -0.65 then
								stone_type = node["default:ice"]
								stone_depth = 2
							elseif biome_val < -0.6 then
								stone_type = node["fun_caves:thin_ice"]
								stone_depth = 2
							elseif biome_val < -0.5 then
								stone_type = node["fun_caves:stone_with_lichen"]
							elseif biome_val < -0.3 then
								stone_type = node["fun_caves:stone_with_moss"]
							elseif biome_val < -0.0 then
								stone_type = node["fun_caves:stone_with_lichen"]
							elseif biome_val < 0.2 then
								stone_type = node["fun_caves:stone_with_algae"]
							elseif y < 29620 then
							-- This is seperate to prevent the hot biomes spawning underwater.
								stone_type = node["default:dirt"]
								stone_depth = 2
							elseif biome_val < 0.35 then
								stone_type = node["fun_caves:stone_with_salt"]
								stone_depth = 2
							elseif biome_val < 0.5 then
								stone_type = node["default:sand"]
								stone_depth = 2
							elseif biome_val < 0.6 then
								stone_type = node["fun_caves:black_sand"]
								stone_depth = 2
							else
								stone_type = node["fun_caves:hot_cobble"]
							end
							--	"glow"

							local node_below
							if y > minp.y then
								node_below = data[ivm - area.ystride]
							end
							local node_above = data[ivm + area.ystride]

							if data[ivm] == node["default:stone"] then
								local air_above = false
								for i = 1, stone_depth do
									if data[ivm + area.ystride * i] == node["air"] or (y < 29620 and data[ivm + area.ystride * i] == node["default:water_source"]) then
										air_above = true
									end
								end

								if node_above == node["air"] and (stone_type == node["fun_caves:stone_with_algae"] or stone_type == node["fun_caves:stone_with_lichen"]) and rand(dirt_ratio) == 1 then
									data[ivm] = node["dirt"]
									write = true
									break
								end

								if air_above then
									if stone_type == node["fun_caves:stone_with_salt"] and rand(radioactive_ratio) == 1 then
										data[ivm] = node["fun_caves:radioactive_ore"]
										write = true
										break
									elseif stone_type == node["fun_caves:black_sand"] and rand(coalblock_ratio) == 1 then
										data[ivm] = node["default:coalblock"]
										break
									elseif node_above == node["air"] and stone_type == node["fun_caves:stone_with_moss"] and rand(fungal_stone_ratio) == 1 then
										data[ivm] = node["fun_caves:glowing_fungal_stone"]
										write = true
										break
									else
										data[ivm] = stone_type
										write = true
										break
									end
								end

								local air_below = false
								for i = 1, stone_depth do
									if data[ivm - area.ystride * i] == node["air"] then
										air_below = true
									end
								end

								if not air_above and stone_type == node["default:sand"] then
									data[ivm] = node["default:sandstone"]
									write = true
									break
								end

								if data[ivm] == node["default:stone"] and air_below then
									if stone_type == node["fun_caves:stone_with_salt"] and rand(radioactive_ratio) == 1 then
										data[ivm] = node["fun_caves:radioactive_ore"]
										write = true
										break
									elseif stone_type == node["fun_caves:black_sand"] and rand(coalblock_ratio) == 1 then
										data[ivm] = node["default:coalblock"]
										write = true
										break
									elseif node_below == node["air"] and (stone_type == node["fun_caves:stone_with_lichen"] or stone_type == node["fun_caves:stone_with_moss"]) and rand(fungal_stone_ratio) == 1 then
										data[ivm] = node["fun_caves:glowing_fungal_stone"]
										write = true
										break
									else
										data[ivm] = stone_type
										write = true
										break
									end
								end
							end

							-- Dis
							if underzone == 3 and data[ivm] == node['air'] and floor((x - minp.x) / 8) % 2 == 0 and floor((z - minp.z) / 8) % 2 == 0 and y % 4960 < 82 + dis_map[floor((x - minp.x) / 8)][floor((z - minp.z) / 8)] * 4 and y % 4960 > 80 then
								local dx = (x - minp.x) % 16
								local dy = y % 4960 - 80
								local dz = (z - minp.z) % 16
								if ((dx == 0 or dx == 7) and (dz % 3 ~= 2 or dy % 4 == 0)) or ((dz == 0 or dz == 7) and (dx % 3 ~= 2 or dy % 4 == 0)) then
									data[ivm] = node["fun_caves:hot_iron"]
								elseif dy %4 == 0 then
									data[ivm] = node["fun_caves:hot_brass"]
								end
								write = true
								break
							end

							if data[ivm] == node["air"] and y < maxp.y then
								-- hanging down
								if node_above == node["default:stone"] and rand(12) == 1 then
									if stone_type == node["default:ice"] then
										data[ivm] = node["fun_caves:icicle_down"]
										write = true
										break
									elseif stone_type == node["fun_caves:stone_with_algae"] then
										data[ivm] = node["fun_caves:stalactite_slimy"]
										write = true
										break
									elseif stone_type == node["fun_caves:stone_with_moss"] then
										data[ivm] = node["fun_caves:stalactite_mossy"]
										write = true
										break
									elseif stone_type == node["fun_caves:stone_with_lichen"] then
										data[ivm] = node["fun_caves:stalactite"]
										write = true
										break
									elseif stone_type == node["default:stone"] then
										data[ivm] = node["fun_caves:stalactite"]
										write = true
										break
									end
								end

								-- fluids
								if y > minp.y and (node_below == node["default:stone"] or node_below == node["fun_caves:hot_cobble"]) and rand(300) == 1 then
									data[ivm] = node["default:lava_source"]
									write = true
									break
								elseif node_below == node["fun_caves:stone_with_moss"] and rand(300) == 1 then
									data[ivm] = node["default:water_source"]
									write = true
									break

									-- standing up
								elseif node_below == node["default:ice"] and rand(12) == 1 then
									data[ivm] = node["fun_caves:icicle_up"]
									write = true
									break
								elseif node_below == node["fun_caves:stone_with_algae"] and rand(12) == 1 then
									data[ivm] = node["fun_caves:stalagmite_slimy"]
									write = true
									break
								elseif node_below == node["fun_caves:stone_with_moss"] and rand(12) == 1 then
									data[ivm] = node["fun_caves:stalagmite_mossy"]
									write = true
									break
								elseif node_below == node["fun_caves:stone_with_lichen"] and rand(12) == 1 then
									data[ivm] = node["fun_caves:stalagmite"]
									write = true
									break
								elseif node_below == node["default:stone"] and rand(12) == 1 then
									data[ivm] = node["fun_caves:stalagmite"]
									write = true
									break
								elseif node_below == node["fun_caves:hot_cobble"] and rand(50) == 1 then
									data[ivm] = node[fun_caves.hot_spikes[rand(#fun_caves.hot_spikes)]]
								elseif node_below == node["fun_caves:black_sand"] and rand(50) == 1 then
									data[ivm] = node["fun_caves:constant_flame"]
									write = true
									break

									-- vegetation
								elseif node_below == node["default:dirt"] and (stone_type == node["fun_caves:stone_with_lichen"] or stone_type == node["fun_caves:stone_with_algae"]) and biome_val >= -0.5 then
									if rand(10) == 1 then
										data[ivm] = node["flowers:mushroom_red"]
										write = true
										break
									elseif rand(10) == 1 then
										data[ivm] = node["flowers:mushroom_brown"]
										write = true
										break
									elseif node_above == node["air"] and rand(10) == 1 then
										data[ivm] = node["fun_caves:giant_mushroom_stem"]
										write = true
										break
									elseif rand(30) == 1 then
										local air_count = 0
										local j
										for i = 1, 12 do
											j = ivm + area.ystride * i
											if j <= #data and data[j] == node["air"] then
												air_count = air_count + 1
											end
										end
										if air_count > 5 then
											fun_caves.make_fungal_tree(data, area, ivm, rand(2, min(air_count, 12)))
										end
									end
								elseif node_below == node["fun_caves:giant_mushroom_stem"] and data[ivm - area.ystride * 2] == node["fun_caves:giant_mushroom_stem"] then
									data[ivm] = node["fun_caves:giant_mushroom_cap"]
									write = true
									break
								elseif node_below == node["fun_caves:giant_mushroom_stem"] then
									if node_above == node["air"] and rand(3) == 1 then
										data[ivm] = node["fun_caves:giant_mushroom_stem"]
										write = true
										break
									else
										data[ivm] = node["fun_caves:huge_mushroom_cap"]
										write = true
										break
									end
								end
							end
						end
						-----------------------------------------------------
						-- end of cave decoration non-loop
						-----------------------------------------------------
					elseif y < height then
						-- This just places non-abm dirt inside caves.
						-- Its value is questionable.
						if data[ivm] == node["air"] and (data[ivm - area.ystride] == node['default:stone'] or data[ivm - area.ystride] == node['default:sandstone']) then
							data[ivm - area.ystride] = node["fun_caves:dirt"]
							write = true
						end
					else
						local pn = plant_n[index]
						local biome
						if biomemap then
							biome = biome_ids[biomemap[index]]
						end
						-----------------------------------------------------------
						-- water decoration non-loop -- only there to enable breaks
						-- Remove this loop to eliminate water decorations.
						-----------------------------------------------------------
						for deco_non_loop = 1, 1 do
							if y < light_depth then
								break
							end

							local node_below = data[ivm - area.ystride]
							local node_above = data[ivm + area.ystride]

							if y < water_level and data[ivm] == node["default:sand"] and node_above == node["default:water_source"] and data[ivm + area.ystride * 2] == node["default:water_source"] and coral_biomes[biome] and pn < -0.1 and rand(5) == 1 and surround(node, data, area, ivm) then
								data[ivm] = node["fun_caves:staghorn_coral_water_sand"]
								write = true
								break
							elseif y < water_level and node_below == node["default:sand"] and node_above == node["default:water_source"] and data[ivm] == node["default:water_source"] and coral_biomes[biome] and pn < -0.1 and rand(5) < 3 then
								if rand(15) == 1 then
									data[ivm] = node["fun_caves:brain_coral"]
									write = true
									break
								elseif rand(15) == 1 then
									data[ivm] = node["fun_caves:dragon_eye"]
									write = true
									break
								else
									data[ivm] = node["fun_caves:pillar_coral"]
									write = true
									break
								end
							elseif x < maxp.x and y < maxp.y and z < maxp.z and x > minp.x and y > minp.y and z > minp.z and (node_above == node["default:water_source"] or node_above == node["default:river_water_source"]) and (data[ivm] == node["default:sand"] or data[ivm] == node["default:dirt"]) then
								-- Check the biomes and plant water plants, if called for.
								if not surround(node, data, area, ivm) then
									break
								end

								for i = 1, #fun_caves.water_plants do
									local desc = fun_caves.water_plants[i]

									if desc.content_id then
										if not node_match_cache[desc.content_id] then
											node_match_cache[desc.content_id] = {}
										end

										if not node_match_cache[desc.content_id][data[ivm]] then
											-- This is a great way to match all node type strings
											-- against a given node (or nodes). However, it's slow.
											-- To speed it up, we cache the results for each plant
											-- on each node, and avoid calling find_nodes every time.
											local posm, count = find_nodes_in_area({x=x, y=y, z=z}, {x=x, y=y, z=z}, desc.place_on)
											if #posm > 0 then
												node_match_cache[desc.content_id][data[ivm]] = "good" 
											else
												node_match_cache[desc.content_id][data[ivm]] = "bad" 
											end
										end

										if node_match_cache[desc.content_id][data[ivm]] == "good" and desc.fill_ratio and (not desc.biomes or (biome and desc.biomes and table.contains(desc.biomes, biome))) and rand() <= desc.fill_ratio then
											data[ivm] = desc.content_id
											write = true
											break
										end
									end
								end
							elseif y > minp.y and node_below == node["default:river_water_source"] and data[ivm] == node["air"] and water_lily_biomes[biome] and pn > 0.5 and rand(water_lily_ratio) == 1 then
								-- on top of the water
								-- I haven't figured out what the decoration manager is
								--  doing with the noise functions, but this works ok.
								data[ivm] = node["flowers:waterlily"]
								write = true
								break
							end
						end
						-----------------------------------------------------
						-- end of water decoration non-loop
						-----------------------------------------------------
					end

					ivm = ivm + area.ystride
					index3d = index3d + csize.x
				end
			end
		end
	end


	if write then
		vm:set_data(data)
		--vm:set_param2_data(p2data)
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


-- Inserting helps to ensure that fun_caves operates first.
table.insert(minetest.registered_on_generateds, 1, generate)
