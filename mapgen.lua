-- Much of this code is translated directly from the Minetest
-- cavegen.cpp, and is likewise distributed under the LGPL2.1


local DEBUG = false
-- Cave blend distance near YMIN, YMAX
local massive_cave_blend = 128
-- noise threshold for massive caves
local massive_cave_threshold = 0.6
-- mct: 1 = small rare caves, 0.5 1/3rd ground volume, 0 = 1/2 ground volume.

local seed_noise = {offset = 0, scale = 32768, seed = 5202, spread = {x = 80, y = 80, z = 80}, octaves = 2, persist = 0.4, lacunarity = 2}
local cave_noise_v6 = {offset = 6, scale = 6, seed = 34329, spread = {x = 250, y = 250, z = 250}, octaves = 3, persist = 0.5, lacunarity = 2}
local intersect_cave_noise_1 = {offset = 0, scale = 1, seed = -8402, spread = {x = 64, y = 64, z = 64}, octaves = 3, persist = 0.5, lacunarity = 2}
local intersect_cave_noise_2 = {offset = 0, scale = 1, seed = 3944, spread = {x = 64, y = 64, z = 64}, octaves = 3, persist = 0.5, lacunarity = 2}
local massive_cave_noise = {offset = 0, scale = 1, seed = 59033, spread = {x = 768, y = 256, z = 768}, octaves = 6, persist = 0.63, lacunarity = 2}
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

local function carveRoute(this, vec, f, randomize_xz)
	local startp = vector.new(this.orp)
	startp = vector.add(startp, this.of)

	local fp = vector.add(this.orp, vector.multiply(vec, f))
	fp.x = fp.x + 0.1 * math.random(-10, 10)
	fp.z = fp.z + 0.1 * math.random(-10, 10)
	local cp = vector.new(fp)

	local d0 = -this.rs/2
	local d1 = d0 + this.rs
	if (randomize_xz) then
		d0 = d0 + math.random(-1, 1)
		d1 = d1 + math.random(-1, 1)
	end

	for z0 = d0, d1 do
		local si = this.rs / 2 - math.max(0, math.abs(z0) - this.rs / 7 - 1)
		for x0 = -si - math.random(0,1), si - 1 + math.random(0,1) do
			local maxabsxz = math.max(math.abs(x0), math.abs(z0))
			local si2 = this.rs / 2 - math.max(0, maxabsxz - this.rs / 7 - 1)
			for y0 = -si2, si2 do
				if (this.large_cave_is_flat) then
					-- Make large caves not so tall
					if (this.rs > 7 and math.abs(y0) >= this.rs / 3) then
						--continue
					else
						local p = vector.new(cp.x + x0, cp.y + y0, cp.z + z0)
						p = vector.add(p, this.of)

						if not area:containsp(p) then
							--continue
						else
							local i = area:indexp(vector.round(p))
							local c = data[i]
							--if (not ndef.get(c).is_ground_content) then
							-- ** check for ground content? **
							local donotdig = false
							if c == node("default:desert_sand") then
								donotdig = true
							end

							if donotdig then
								--continue
							else
								if (this.large_cave) then
									local full_ymin = minp.y - 16
									local full_ymax = maxp.y + 16

									if this.flooded and not this.lava_cave then
										data[i] = (p.y <= this.water_level) and node("default:water_source") or node("air")
									elseif this.flooded then
										data[i] = (p.y < startp.y - 2) and node("default:lava_source") or node("air")
									else
										data[i] = node("air")
									end
								else
									if (c == node("ignore") or c == node("air")) then
										--continue
									else
										data[i] = node("air")
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

local function makeV6Tunnel(this, dirswitch)
	if dirswitch and not this.large_cave then
		this.main_direction = vector.new(
			((math.random() * 20) - 10) / 10,
			((math.random() * 20) - 10) / 30,
			((math.random() * 20) - 10) / 10
		)
		this.main_direction = vector.multiply(this.main_direction, math.random(0, 10) / 10)
	end

	-- Randomize size
	local min_d = this.min_tunnel_diameter
	local max_d = this.max_tunnel_diameter
	this.rs = math.random(min_d, max_d)
	local rs_part_max_length_rs = this.rs * this.part_max_length_rs

	local maxlen
	if this.large_cave then
		maxlen = vector.new(
			rs_part_max_length_rs,
			rs_part_max_length_rs / 2,
			rs_part_max_length_rs
		)
	else
		maxlen = vector.new(
			rs_part_max_length_rs,
			math.random(1, rs_part_max_length_rs),
			rs_part_max_length_rs
		)
	end

	local vec = vector.new(
		(math.random() * maxlen.x) - maxlen.x / 2,
		(math.random() * maxlen.y) - maxlen.y / 2,
		(math.random() * maxlen.z) - maxlen.z / 2
	)

	-- Jump downward sometimes
	if not this.large_cave and math.random(0, 12) == 0 then
		vec = vector.new(
			(math.random() * maxlen.x) - maxlen.x / 2,
			(math.random() * (maxlen.y * 2)) - maxlen.y,
			(math.random() * maxlen.z) - maxlen.z / 2
		)
	end

	vec = vector.add(vec, this.main_direction)

	local rp = vector.add(this.orp, vec)
	if (rp.x < 0) then
		rp.x = 0
	elseif (rp.x >= this.ar.x) then
		rp.x = this.ar.x - 1
	end

	if (rp.y < this.route_y_min) then
		rp.y = this.route_y_min
	elseif (rp.y >= this.route_y_max) then
		rp.y = this.route_y_max - 1
	end

	if (rp.z < 0) then
		rp.z = 0
	elseif (rp.z >= this.ar.z) then
		rp.z = this.ar.z - 1
	end

	vec = vector.subtract(rp, this.orp)

	local veclen = vector.length(vec)
	-- As odd as it sounds, veclen is *exactly* 0.0 sometimes, causing a FPE
	if (veclen < 0.05) then
		veclen = 1.0
	end

	-- Every second section is rough
	local randomize_xz = (math.random(1, 2) == 1)

	-- Carve routes
	for f = 0, 1, 1.0 / veclen do
		--print(dump(vec))
		carveRoute(this, vec, f, randomize_xz)
	end

	this.orp = rp
end

local function makeV6Cave(this)
	this.max_stone_y = 32000
	this.main_direction = vector.new(0, 0, 0)

	-- Allowed route area size in nodes
	this.ar = vector.add(vector.subtract(maxp, minp), 1)
	-- Area starting point in nodes
	this.of = minp

	-- Allow a bit more
	--(this should be more than the maximum radius of the tunnel)
	local max_spread_amount = 16
	local insure = 10
	local more = math.max(max_spread_amount - this.max_tunnel_diameter / 2 - insure, 1)
	this.ar = vector.add(this.ar, vector.multiply(vector.new(1,0,1), (more * 2)))
	this.of = vector.subtract(this.of, vector.multiply(vector.new(1,0,1), more))

	this.route_y_min = 0
	-- Allow half a diameter + 7 over stone surface
	this.route_y_max = -this.of.y + this.max_stone_y + this.max_tunnel_diameter / 2 + 7

	-- Limit maximum to area
	this.route_y_max = rangelim(this.route_y_max, 0, this.ar.y - 1)

	if this.large_cave then
		local min = 0
		if minp.y < this.water_level and maxp.y > this.water_level then
			min = this.water_level - this.max_tunnel_diameter/3 - this.of.y
			this.route_y_max = this.water_level + this.max_tunnel_diameter/3 - this.of.y
		end
		this.route_y_min = math.random(min, min + this.max_tunnel_diameter)
		this.route_y_min = rangelim(this.route_y_min, 0, this.route_y_max)
	end

	local route_start_y_min = this.route_y_min
	local route_start_y_max = this.route_y_max

	route_start_y_min = rangelim(route_start_y_min, 0, this.ar.y-1)
	route_start_y_max = rangelim(route_start_y_max, route_start_y_min, this.ar.y-1)

	-- Randomize starting position
	this.orp = vector.new(
		(math.random() * this.ar.x) + 0.5,
		(math.random(route_start_y_min, route_start_y_max)) + 0.5,
		(math.random() * this.ar.z) + 0.5
	)

	-- Generate some tunnel starting from orp
	for j = 0, this.tunnel_routepoints do
		--print(dump(this.orp))
		makeV6Tunnel(this, j % this.dswitchint == 0)
	end
end

local function CaveV6(is_large_cave)
	local this = {}
	this.water_level    = 1
	this.large_cave     = is_large_cave

	this.min_tunnel_diameter = 2
	this.max_tunnel_diameter = math.random(2, 6)
	this.dswitchint          = math.random(1, 14)
	this.flooded             = true
	this.lava_cave           = false

	if math.random(2) == 1 then
		this.lava_cave = true
	end

	if this.large_cave then
		this.part_max_length_rs  = math.random(2,4)
		this.tunnel_routepoints  = math.random(5, math.random(15,30))
		this.min_tunnel_diameter = 5
		this.max_tunnel_diameter = math.random(7, math.random(8,24))
	else
		this.part_max_length_rs = math.random(2,9)
		this.tunnel_routepoints = math.random(10, math.random(15,30))
	end

	this.large_cave_is_flat = (math.random(0,1) == 0)
	return this
end

local function getBiome(x, z)
	return nil
end

local function generateV6Caves()
	local cave_amount = minetest.get_perlin(cave_noise_v6):get2d({x=minp.x, y=minp.y})
	local volume_nodes = (maxp.x - minp.x + 1) * (maxp.y - minp.y + 1) * 16
	cave_amount = math.max(0.0, cave_amount)
	local caves_count = cave_amount * volume_nodes / 50000
	local bruises_count = 1

	if (math.random(1, 6) == 1) then
		bruises_count = math.random(0, math.random(0, 2))
	end

	for i = 0, caves_count + bruises_count do
		local large_cave = (i >= caves_count)
		local cave = CaveV6(large_cave)

		makeV6Cave(cave)
	end
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

	-- Fill with stone.
	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			local ivm = area:index(minp.x, y, z)
			for x = minp.x, maxp.x do
				data[ivm] = node("default:stone")
				ivm = ivm + 1
			end
		end
	end

	local made_a_big_one = false
	local massive_cave = minetest.get_perlin_map(massive_cave_noise, csize):get3dMap_flat(minp)
	local cave_1 = minetest.get_perlin_map(intersect_cave_noise_1, csize):get3dMap_flat(minp)
	local cave_2 = minetest.get_perlin_map(intersect_cave_noise_2, csize):get3dMap_flat(minp)
	local biome_n = minetest.get_perlin_map(biome_noise, {x=csize.x, y=csize.z}):get2dMap_flat({x=minp.x, y=minp.z})
	local biome_bn = minetest.get_perlin_map(biome_blend, {x=csize.x, y=csize.z}):get2dMap_flat({x=minp.x, y=minp.z})

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

				if massive_cave[index3d] > massive_cave_threshold then
					data[ivm] = node("air")
					made_a_big_one = true
				else
					local n1 = (math.abs(cave_1[index3d]) < 0.08)
					local n2 = (math.abs(cave_2[index3d]) < 0.08)

					if n1 and n2 then
						local sr = 1000
						if data[ivm] == node("default:stone") then
							sr = math.random(1000)
						end

						--if sr == 1 then
						--	data[ivm] = node("default:lava_source")
						--elseif sr == 2 then
						--	data[ivm] = node("default:water_source")
						--else
							data[ivm] = node("air")
						--end
					end
				end

				ivm = ivm + area.ystride
				index3d = index3d + csize.x
			end
		end
	end

	if made_a_big_one then
		--print("massive cave at "..minp.x..","..minp.y..","..minp.z)
	else
		generateV6Caves()
	end

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
					elseif biome_val < -0.3 then
						stone_type = node("fun_caves:stone_with_moss")
					elseif biome_val < 0.2 then
						stone_type = node("fun_caves:stone_with_lichen")
					elseif biome_val < 0.5 then
						stone_type = node("fun_caves:stone_with_algae")
					elseif biome_val < 0.6 then
						stone_type = node("fun_caves:stone_with_salt")
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
						if (not made_a_big_one) and data[ivm_below] == node("default:stone") and sr < 10 then
								data[ivm] = node("default:lava_source")
						elseif (not made_a_big_one) and data[ivm_below] == node("fun_caves:stone_with_moss") and sr < 10 then
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
							elseif made_a_big_one and air_count > 5 and sr < 180 then
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
	minetest.generate_ores(vm, minp, maxp)
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
	local massive_cave = minetest.get_perlin(massive_cave_noise):get3d(pos)
	local biome_n = minetest.get_perlin(biome_noise):get2d({x=pos.x, y=pos.z})
	local biome_bn = minetest.get_perlin(biome_blend):get2d({x=pos.x, y=pos.z})
	local biome = biome_n + biome_bn

	while biome < 0.3 or biome > 0.5 do
		pos.x = pos.x + math.random(20) - 10
		pos.z = pos.z + math.random(20) - 10

		biome_n = minetest.get_perlin(biome_noise):get2d({x=pos.x, y=pos.z})
		biome_bn = minetest.get_perlin(biome_blend):get2d({x=pos.x, y=pos.z})
		biome = biome_n + biome_bn
	end

	while massive_cave <= massive_cave_threshold do
		pos.y = pos.y + 80
		massive_cave = minetest.get_perlin(massive_cave_noise):get3d(pos)
	end

	while massive_cave > massive_cave_threshold do
		pos.y = pos.y - 1
		massive_cave = minetest.get_perlin(massive_cave_noise):get3d(pos)
	end

	pos.y = pos.y + 1
	player:setpos(pos)
	return true -- Disable default player spawner
end
