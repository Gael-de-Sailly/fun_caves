-- Much of this code is translated directly from the Minetest
-- cavegen.cpp, and is likewise distributed under the LGPL2.1


local node = fun_caves.node

local data = {}
local p2data = {}  -- vm rotation data buffer
local lightmap = {}
local vm, emin, emax, a, csize, heightmap, biomemap
local div_sz_x, div_sz_z, minp, maxp, terrain, cave

local terrain_noise = {offset = 0,
scale = 20, seed = 8829, spread = {x = 40, y = 40, z = 40},
octaves = 6, persist = 0.4, lacunarity = 2}

local cave_noise = {offset = 0, scale = 1,
seed = -3977, spread = {x = 30, y = 30, z = 30}, octaves = 3,
persist = 0.8, lacunarity = 2}

local seed_noise = {offset = 0, scale = 32768,
seed = 5202, spread = {x = 80, y = 80, z = 80}, octaves = 2,
persist = 0.4, lacunarity = 2}

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
				local ivm = a:index(pos.x + x, pos.y, pos.z + z)
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

					ivm = ivm + a.ystride
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


local np_cave = {offset = 6, scale = 6, seed = 34329, spread = {x = 250, y = 250, z = 250}, octaves = 3, persist = 0.5, lacunarity = 2}

local function rangelim(x, y, z)
	return math.max(math.min(x, z), y)
end

local function carveRoute(this, vec, f, randomize_xz, tunnel_above_ground)
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
			if (tunnel_above_ground) then
				--continue
			else
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

							if not a:containsp(p) then
								--continue
							else
								local i = a:indexp(vector.round(p))
								local c = data[i]
								--if (not ndef.get(c).is_ground_content) then
								-- ** check for ground content? **
								if false then
									--continue
								else
									if (this.large_cave) then
										local full_ymin = minp.y - 16
										local full_ymax = maxp.y + 16

										if (this.flooded and full_ymin < this.water_level and full_ymax > this.water_level) then
											data[i] = (p.y <= this.water_level) and node("default:water_source") or node("air")
										elseif (this.flooded and full_ymax < this.water_level) then
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
end

local function makeTunnel(this, dirswitch)
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

	-- Do not make caves that are entirely above ground, to fix
	-- shadow bugs caused by overgenerated large caves.
	-- It is only necessary to check the startpoint and endpoint.
	local orpi = vector.new(this.orp.x, this.orp.y, this.orp.z)
	local veci = vector.new(vec.x, vec.y, vec.z)
	local h1
	local h2

	local p1 = vector.add(orpi, veci, this.of, this.rs / 2)
	if (p1.z >= minp.z and p1.z <= maxp.z and
			p1.x >= minp.x and p1.x <= maxp.x) then
		local index1 = (p1.z - minp.z) * a.ystride + (p1.x - minp.x)
		--h1 = mg.heightmap[index1]
		h1 = this.water_level
	else
		h1 = this.water_level -- If not in heightmap
	end

	local p2 = vector.add(orpi, this.of, this.rs / 2)
	if (p2.z >= minp.z and p2.z <= maxp.z and
			p2.x >= minp.x and p2.x <= maxp.x) then
		local index2 = (p2.z - minp.z) * a.ystride + (p2.x - minp.x)
		--h2 = mg.heightmap[index2]
		h2 = this.water_level
	else
		h2 = this.water_level
	end

	-- If startpoint and endpoint are above ground,
	-- disable placing of nodes in carveRoute while
	-- still running all pseudorandom calls to ensure
	-- caves consistent with existing worlds.
	local tunnel_above_ground = p1.y > h1 and p2.y > h2

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
		carveRoute(this, vec, f, randomize_xz, tunnel_above_ground)
	end

	this.orp = rp
end

local function makeCave(this, max_stone_height)
	this.max_stone_y = max_stone_height
	this.main_direction = vector.new(0, 0, 0)
	--print(dump(this))

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
		makeTunnel(this, j % this.dswitchint == 0)
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

local function generateCaves(max_stone_y)
	local cave_amount = minetest.get_perlin(np_cave):get2d({x=minp.x, y=minp.y})
	local volume_nodes = (maxp.x - minp.x + 1) * (maxp.y - minp.y + 1) * 16
	cave_amount = math.max(0.0, cave_amount)
	local caves_count = cave_amount * volume_nodes / 50000
	local bruises_count = 1

	if (math.random(1, 6) == 1) then
		bruises_count = math.random(0, math.random(0, 2))
	end

	if (getBiome(minp.x, minp.z) == "desert") then
		caves_count = caves_count / 3
		bruises_count = caves_count / 3
	end

	for i = 0, caves_count + bruises_count do
		local large_cave = (i >= caves_count)
		local cave = CaveV6(large_cave)

		--print(dump(cave))
		makeCave(cave, max_stone_y)
	end
end


function fun_caves.generate(p_minp, p_maxp, seed)
	minp, maxp = p_minp, p_maxp
	vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	vm:get_data(data)
	--p2data = vm:get_param2_data()
	a = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
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

	generateCaves(1)

	--local index = 0
	--local index3d = 0
	--for z = minp.z, maxp.z do
	--	local dz = z - minp.z
	--	for x = minp.x, maxp.x do
	--		index = index + 1
	--		local dx = x - minp.x
	--		index3d = dz * csize.y * csize.x + dx + 1
	--		local ivm = a:index(x, minp.y, z)

	--		for y = minp.y, maxp.y do
	--			local dy = y - minp.y

	--			ivm = ivm + a.ystride
	--			index3d = index3d + csize.x
	--		end
	--	end
	--end


	vm:set_data(data)
	--minetest.generate_ores(vm, minp, maxp)
	--minetest.generate_decorations(vm, minp, maxp)
	--vm:set_param2_data(p2data)
	vm:set_lighting({day = 0, night = 0})
	vm:calc_lighting()
	vm:update_liquids()
	vm:write_to_map()

	vm, a, lightmap, heightmap, biomemap, terrain, cave = nil, nil, nil, nil, nil, nil, nil
end
