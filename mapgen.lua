local DEBUG = false

local cave_noise_1 = {offset = 0, scale = 1, seed = 3901, spread = {x = 40, y = 10, z = 40}, octaves = 3, persist = 1, lacunarity = 2}
local cave_noise_2 = {offset = 0, scale = 1, seed = -8402, spread = {x = 40, y = 20, z = 40}, octaves = 3, persist = 1, lacunarity = 2}
local seed_noise = {offset = 0, scale = 32768, seed = 5202, spread = {x = 80, y = 80, z = 80}, octaves = 2, persist = 0.4, lacunarity = 2}
local biome_noise = {offset = 0.0, scale = 1.0, spread = {x = 400, y = 400, z = 400}, seed = 903, octaves = 3, persist = 0.5, lacunarity = 2.0}
local biome_blend = {offset = 0.0, scale = 0.1, spread = {x = 8, y = 8, z = 8}, seed = 4023, octaves = 2, persist = 1.0, lacunarity = 2.0}


local node = fun_caves.node

local data = {}
local p2data = {}  -- vm rotation data buffer
local lightmap = {}
local vm, emin, emax, area, csize
local div_sz_x, div_sz_z, minp, maxp, terrain, cave

if fun_caves.world then
	fun_caves.biomes = {}
	local biomes = fun_caves.biomes
	local biome_names = {}
	biome_names["common"] = {}
	biome_names["uncommon"] = {}
	do
		local biome_terrain_scale = {}
		biome_terrain_scale["coniferous_forest"] = 0.75
		biome_terrain_scale["rainforest"] = 0.33
		biome_terrain_scale["underground"] = 1.5

		local tree_biomes = {}
		tree_biomes["deciduous_forest"] = {"deciduous_trees"}
		tree_biomes["coniferous_forest"] = {"conifer_trees"}
		tree_biomes["taiga"] = {"conifer_trees"}
		tree_biomes["rainforest"] = {"jungle_trees"}
		tree_biomes["rainforest_swamp"] = {"jungle_trees"}
		tree_biomes["coniferous_forest"] = {"conifer_trees"}
		tree_biomes["savanna"] = {"acacia_trees"}

		for i, obiome in pairs(minetest.registered_biomes) do
			local biome = table.copy(obiome)
			biome.special_tree_prob = 2
			if biome.name == "savanna" then
				biome.special_tree_prob = 30
			end
			local rarity = "common"
			biome.terrain_scale = biome_terrain_scale[biome] or 0.5
			if string.find(biome.name, "ocean") then
				biome.terrain_scale = 1
				rarity = "uncommon"
			end
			if string.find(biome.name, "swamp") then
				biome.terrain_scale = 0.25
				rarity = "uncommon"
			end
			if string.find(biome.name, "beach") then
				biome.terrain_scale = 0.25
				rarity = "uncommon"
			end
			if string.find(biome.name, "^underground$") then
				biome.node_top = "default:stone"
				rarity = "uncommon"
			end
			biome.special_trees = tree_biomes[biome.name]
			biomes[biome.name] = biome
			biome_names[rarity][#biome_names[rarity]+1] = biome.name
		end
	end
	biomes["control"] = {}
end

if false then
	local cave_stones = {
		"fun_caves:stone_with_moss",
		"fun_caves:stone_with_lichen",
		"fun_caves:stone_with_algae",
		"fun_caves:stone_with_salt",
	}
	local mushroom_stones = {}
	mushroom_stones[node("default:stone")] = true
	mushroom_stones[node("fun_caves:stone_with_algae")] = true
	mushroom_stones[node("fun_caves:stone_with_lichen")] = true
end

local function place_schematic(pos, schem, center)
	local rot = math.random(4) - 1
	local yslice = {}
	if schem.yslice_prob then
		for _, ys in pairs(schem.yslice_prob) do
			yslice[ys.ypos] = ys.prob
		end
	end

	if center then
		pos.x = pos.x - math.floor(schem.size.x / 2)
		pos.z = pos.z - math.floor(schem.size.z / 2)
	end

	for z1 = 0, schem.size.z - 1 do
		for x1 = 0, schem.size.x - 1 do
			local x, z
			if rot == 0 then
				x, z = x1, z1
			elseif rot == 1 then
				x, z = schem.size.z - z1 - 1, x1
			elseif rot == 2 then
				x, z = schem.size.x - x1 - 1, schem.size.z - z1 - 1
			elseif rot == 3 then
				x, z = z1, schem.size.x - x1 - 1
			end
			local dz = pos.z - minp.z + z
			local dx = pos.x - minp.x + x
			if pos.x + x > minp.x and pos.x + x < maxp.x and pos.z + z > minp.z and pos.z + z < maxp.z then
				local ivm = area:index(pos.x + x, pos.y, pos.z + z)
				local isch = z1 * schem.size.y * schem.size.x + x1 + 1
				for y = 0, schem.size.y - 1 do
					local dy = pos.y - minp.y + y
					if math.min(dx, csize.x - dx) + math.min(dy, csize.y - dy) + math.min(dz, csize.z - dz) > bevel then
						if yslice[y] or 255 >= math.random(255) then
							local prob = schem.data[isch].prob or schem.data[isch].param1 or 255
							if prob >= math.random(255) and schem.data[isch].name ~= "air" then
								data[ivm] = node(schem.data[isch].name)
							end
							local param2 = schem.data[isch].param2 or 0
							p2data[ivm] = param2
						end
					end

					ivm = ivm + area.ystride
					isch = isch + schem.size.x
				end
			end
		end
	end
end

local function get_decoration(biome)
	for i, deco in pairs(fun_caves.decorations) do
		if not deco.biomes or deco.biomes[biome] then
			local range = 1000
			if deco.deco_type == "simple" then
				if deco.fill_ratio and math.random(range) - 1 < deco.fill_ratio * 1000 then
					return deco.decoration
				end
			else
				-- nop
			end
		end
	end
end


local function rangelim(x, y, z)
	return math.max(math.min(x, z), y)
end

local function getBiome(x, z)
	return nil
end


function fun_caves.generate(p_minp, p_maxp, seed)
	minp, maxp = p_minp, p_maxp
	vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	vm:get_data(data)
	--p2data = vm:get_param2_data()
	area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	csize = vector.add(vector.subtract(maxp, minp), 1)

	-- Deal with memory issues. This, of course, is supposed to be automatic.
	local mem = math.floor(collectgarbage("count")/1024)
	if mem > 400 then
		print("Fun Caves: Manually collecting garbage...")
		collectgarbage("collect")
	end

	-- use the same seed (based on perlin noise).
	math.randomseed(minetest.get_perlin(seed_noise):get2d({x=minp.x, y=minp.z}))

	-- Keep this first after seeding!
	local px = math.floor((minp.x + 32) / csize.x)
	local pz = math.floor((minp.z + 32) / csize.z)

	local cave_1 = minetest.get_perlin_map(cave_noise_1, csize):get3dMap_flat(minp)
	local cave_2 = minetest.get_perlin_map(cave_noise_2, csize):get3dMap_flat(minp)
	local biome_n = minetest.get_perlin_map(biome_noise, {x=csize.x, y=csize.z}):get2dMap_flat({x=minp.x, y=minp.z})
	local biome_bn = minetest.get_perlin_map(biome_blend, {x=csize.x, y=csize.z}):get2dMap_flat({x=minp.x, y=minp.z})

	local biome_avg = 0
	local biome_ct = 0
	local index = 0
	local index3d = 0
	for z = minp.z, maxp.z do
		local dz = z - minp.z
		for x = minp.x, maxp.x do
			index = index + 1
			local dx = x - minp.x
			index3d = dz * csize.y * csize.x + dx + 1
			local ivm = area:index(x, minp.y, z)

			for y = minp.y, maxp.y do
				local dy = y - minp.y

				local n1 = cave_2[index3d]
				local n2 = cave_1[index3d]

				if n1 * n2 > 0.05 then
					data[ivm] = node("air")
				else
					data[ivm] = node("default:stone")
				end

				local biome_val = biome_n[index] + biome_bn[index]
				biome_avg = biome_avg + biome_val
				biome_ct = biome_ct + 1

				ivm = ivm + area.ystride
				index3d = index3d + csize.x
			end
		end
	end

	vm:set_data(data)
	biome_avg = biome_avg / biome_ct
	fun_caves.set_ores(biome_avg)
	minetest.generate_ores(vm, minp, maxp)
	vm:get_data(data)

	local index = 0
	local index3d = 0
	for z = minp.z, maxp.z do
		local dz = z - minp.z
		for x = minp.x, maxp.x do
			index = index + 1
			local dx = x - minp.x
			index3d = (dz + 1) * csize.y * csize.x + dx
			local air_count = 0
			local ivm = area:index(x, maxp.y, z)

			for y = maxp.y, minp.y, -1 do
				local ivm_below = ivm - area.ystride
				local ivm_above = ivm + area.ystride
				local dy = y - minp.y

				if data[ivm] == node("air") then
					-------------------
					local stone_type = node("default:stone")
					local stone_depth = 1
					local biome_val = biome_n[index] + biome_bn[index]
					if biome_val < -0.8 then
						if true then
							stone_type = node("default:ice")
							stone_depth = 2
						else
							stone_type = node("fun_caves:thinice")
							stone_depth = 2
						end
					elseif biome_val < -0.7 then
						stone_type = node("fun_caves:stone_with_lichen")
					elseif biome_val < -0.4 then
						stone_type = node("fun_caves:stone_with_moss")
					elseif biome_val < 0.1 then
						stone_type = node("fun_caves:stone_with_lichen")
					elseif biome_val < 0.4 then
						stone_type = node("fun_caves:stone_with_algae")
					elseif biome_val < 0.55 then
						stone_type = node("fun_caves:stone_with_salt")
						stone_depth = 2
					elseif biome_val < 0.7 then
						stone_type = node("default:sand")
						stone_depth = 2
					elseif biome_val < 0.8 then
						stone_type = node("default:coalblock")
						stone_depth = 2
					else
						stone_type = node("fun_caves:hot_cobble")
					end
					--	"glow"

					-- Change stone per biome.
					if data[ivm_below] == node("default:stone") then
						data[ivm_below] = stone_type
						if stone_depth == 2 then
							data[ivm_below - area.ystride] = stone_type
						end
					end
					if data[ivm_above] == node("default:stone") then
						data[ivm_above] = stone_type
						if stone_depth == 2 then
							data[ivm_above + area.ystride] = stone_type
						end
					end

					if (data[ivm_above] == node("fun_caves:stone_with_lichen") or data[ivm_above] == node("fun_caves:stone_with_moss")) and math.random(1,20) == 1 then
						data[ivm_above] = node("fun_caves:glowing_fungal_stone")
					end

					if data[ivm] == node("air") then
						local sr = math.random(1,1000)

						-- fluids
						if (data[ivm_below] == node("default:stone") or data[ivm_below] == node("fun_caves:hot_cobble")) and sr < 20 then
								data[ivm] = node("default:lava_source")
						elseif data[ivm_below] == node("fun_caves:stone_with_moss") and sr < 5 then
								data[ivm] = node("default:water_source")
						-- hanging down
						elseif data[ivm_above] == node("default:ice") and sr < 80 then
							data[ivm] = node("fun_caves:icicle_down")
						elseif (data[ivm_above] == node("fun_caves:stone_with_lichen") or data[ivm_above] == node("fun_caves:stone_with_moss") or data[ivm_above] == node("fun_caves:stone_with_algae") or data[ivm_above] == node("default:stone")) and sr < 80 then
							if data[ivm_above] == node("fun_caves:stone_with_algae") then
								data[ivm] = node("fun_caves:stalactite_slimy")
							elseif data[ivm_above] == node("fun_caves:stone_with_moss") then
								data[ivm] = node("fun_caves:stalactite_mossy")
							else
								data[ivm] = node("fun_caves:stalactite")
							end
						-- standing up
						elseif data[ivm_below] == node("fun_caves:hot_cobble") and sr < 20 then
							if sr < 10 then
								data[ivm] = node("fun_caves:hot_spike")
							else
								data[ivm] = node("fun_caves:hot_spike_"..(math.ceil(sr / 3) - 2))
							end
						elseif data[ivm_below] == node("default:coalblock") and sr < 20 then
							data[ivm] = node("fun_caves:constant_flame")
						elseif data[ivm_below] == node("default:ice") and sr < 80 then
							data[ivm] = node("fun_caves:icicle_up")
						elseif (data[ivm_below] == node("fun_caves:stone_with_lichen") or data[ivm_below] == node("fun_caves:stone_with_algae") or data[ivm_below] == node("default:stone") or data[ivm_below] == node("fun_caves:stone_with_moss")) and sr < 80 then
							if data[ivm_below] == node("fun_caves:stone_with_algae") then
								data[ivm] = node("fun_caves:stalagmite_slimy")
							elseif data[ivm_below] == node("fun_caves:stone_with_moss") then
								data[ivm] = node("fun_caves:stalagmite_mossy")
							elseif data[ivm_below] == node("fun_caves:stone_with_lichen") or data[ivm_above] == node("default:stone") then
								data[ivm] = node("fun_caves:stalagmite")
							end
						-- vegetation
						elseif (data[ivm_below] == node("fun_caves:stone_with_lichen") or data[ivm_below] == node("fun_caves:stone_with_algae")) and biome_val >= -0.7 then
							if sr < 110 then
								data[ivm] = node("flowers:mushroom_red")
							elseif sr < 140 then
								data[ivm] = node("flowers:mushroom_brown")
							elseif air_count > 1 and sr < 160 then
								data[ivm_above] = node("fun_caves:huge_mushroom_cap")
								data[ivm] = node("fun_caves:giant_mushroom_stem")
							elseif air_count > 2 and sr < 170 then
								data[ivm + 2 * area.ystride] = node("fun_caves:giant_mushroom_cap")
								data[ivm_above] = node("fun_caves:giant_mushroom_stem")
								data[ivm] = node("fun_caves:giant_mushroom_stem")
							elseif air_count > 5 and sr < 180 then
								fun_caves.make_fungal_tree(data, area, ivm, math.random(2,math.min(air_count, 12)), node(fun_caves.fungal_tree_leaves[math.random(1,#fun_caves.fungal_tree_leaves)]), node("fun_caves:fungal_tree_fruit"))
								data[ivm_below] = node("dirt")
							elseif sr < 300 then
								data[ivm_below] = node("dirt")
							end
							if data[ivm] ~= node("air") then
								data[ivm_below] = node("dirt")
							end
						end
					end

					if data[ivm] == node("air") then
						air_count = air_count + 1
					end
				end

				ivm = ivm - area.ystride
				index3d = index3d - csize.x
			end
		end
	end


	vm:set_data(data)
	--vm:set_param2_data(p2data)
	if DEBUG then
		vm:set_lighting({day = 15, night = 15})
	else
		vm:set_lighting({day = 0, night = 0})
		vm:calc_lighting()
	end
	vm:update_liquids()
	vm:write_to_map()

	vm, area, lightmap, terrain, cave = nil, nil, nil, nil, nil
end

function fun_caves.respawn(player)
	local pos = {x=0,y=0,z=0}
	local cave_1 = minetest.get_perlin(cave_noise_1):get3d(pos)
	local cave_2 = minetest.get_perlin(cave_noise_2):get3d(pos)
	local biome_n = minetest.get_perlin(biome_noise):get2d({x=pos.x, y=pos.z})
	local biome_bn = minetest.get_perlin(biome_blend):get2d({x=pos.x, y=pos.z})
	local biome = biome_n + biome_bn

	while biome < -0.3 or biome > 0.3 do
		pos.x = pos.x + math.random(20) - 10
		pos.z = pos.z + math.random(20) - 10

		biome_n = minetest.get_perlin(biome_noise):get2d({x=pos.x, y=pos.z})
		biome_bn = minetest.get_perlin(biome_blend):get2d({x=pos.x, y=pos.z})
		biome = biome_n + biome_bn
	end

	while cave_1 * cave_2 <= 0.05 do
		pos.y = pos.y + 1
		cave_1 = minetest.get_perlin(cave_noise_1):get3d(pos)
		cave_2 = minetest.get_perlin(cave_noise_2):get3d(pos)
	end

	pos.y = pos.y + 1
	player:setpos(pos)
	return true -- Disable default player spawner
end
