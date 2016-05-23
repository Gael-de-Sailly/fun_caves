local DEBUG = false

local cave_noise_1 = {offset = 0, scale = 1, seed = 3901, spread = {x = 40, y = 10, z = 40}, octaves = 3, persist = 1, lacunarity = 2}
local cave_noise_2 = {offset = 0, scale = 1, seed = -8402, spread = {x = 40, y = 20, z = 40}, octaves = 3, persist = 1, lacunarity = 2}
local cave_noise_3 = {offset = 15, scale = 10, seed = 3721, spread = {x = 40, y = 40, z = 40}, octaves = 3, persist = 1, lacunarity = 2}
local seed_noise = {offset = 0, scale = 32768, seed = 5202, spread = {x = 80, y = 80, z = 80}, octaves = 2, persist = 0.4, lacunarity = 2}
local biome_noise = {offset = 0.0, scale = 1.0, spread = {x = 400, y = 400, z = 400}, seed = 903, octaves = 3, persist = 0.5, lacunarity = 2.0}


local node = fun_caves.node
local min_surface = -80

local data = {}
--local p2data = {}  -- vm rotation data buffer
local vm, emin, emax, area, noise_area, csize, minp, maxp

-- Create a table of biome ids, so I can use the biomemap.
if not fun_caves.biome_ids then
	fun_caves.biome_ids = {}
	for name, desc in pairs(minetest.registered_biomes) do
		local i = minetest.get_biome_id(desc.name)
		fun_caves.biome_ids[i] = desc.name
	end
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


local function detect_bull(heightmap, csize)
	local probably = false

	if minp.y >= 8 + csize.y / 2 then
		return false
	end

	if maxp.y <= 8 - csize.y / 2 then
		probably = true
	end

	local j = -31000
	local k = 0
	local cutoff = (csize.x * csize.z) * 0.1
	for i = 1, #heightmap do
		if j == heightmap[i] then
			k = k + 1
			if k > cutoff then
				--print("maxp.y: "..maxp.y..", minp.y: "..minp.y..", heightmap stuck at: "..heightmap[i])
				return true
			elseif not probably and i > 2 * cutoff then
				--print("maxp.y: "..maxp.y..", minp.y: "..minp.y..", guessing good heightmap")
				return false
			end
		else
			k = 0
		end
		j = heightmap[i]
	end
end


function fun_caves.generate(p_minp, p_maxp, seed)
	minp, maxp = p_minp, p_maxp
	vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	vm:get_data(data)
	--p2data = vm:get_param2_data()
	local heightmap = minetest.get_mapgen_object("heightmap")
	local biomemap = minetest.get_mapgen_object("biomemap")
	area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	csize = vector.add(vector.subtract(maxp, minp), 1)
	noise_area = VoxelArea:new({MinEdge={x=0,y=0,z=0}, MaxEdge=vector.subtract(csize, 1)})

	-- There's a bug in the heightmap from valleys_c. Check for it.
	local bullshit_heightmap = detect_bull(heightmap, csize)
	local write = false

	-- Deal with memory issues. This, of course, is supposed to be automatic.
	local mem = math.floor(collectgarbage("count")/1024)
	if mem > 200 then
		print("Fun Caves: Manually collecting garbage...")
		collectgarbage("collect")
	end

	-- use the same seed (based on perlin noise).
	math.randomseed(minetest.get_perlin(seed_noise):get2d({x=minp.x, y=minp.z}))

	local cave_1 = minetest.get_perlin_map(cave_noise_1, csize):get3dMap_flat(minp)
	local cave_2 = minetest.get_perlin_map(cave_noise_2, csize):get3dMap_flat(minp)
	local cave_3 = minetest.get_perlin_map(cave_noise_3, {x=csize.x, y=csize.z}):get2dMap_flat({x=minp.x, y=minp.z})
	local biome_n = minetest.get_perlin_map(biome_noise, csize):get3dMap_flat(minp)

	local index = 0
	local index3d = 0
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			index = index + 1

			if bullshit_heightmap and maxp.y > 0 then
				-- nop
			else
				write = true
				index3d = noise_area:index(x - minp.x, 0, z - minp.z)
				local ivm = area:index(x, minp.y, z)

				for y = minp.y, maxp.y do
					if (bullshit_heightmap or y < heightmap[index] - cave_3[index]) and cave_1[index3d] * cave_2[index3d] > 0.05 then
						data[ivm] = node("air")

						if y > 0 and cave_3[index] < 1 and heightmap[index] == y then
							-- Clear the air above a cave mouth.
							local ivm2 = ivm
							for y2 = y + 1, maxp.y + 8 do
								ivm2 = ivm2 + area.ystride
								if data[ivm2] ~= node("default:water_source") then
									data[ivm2] = node("air")
								end
							end
						end
					end

					ivm = ivm + area.ystride
					index3d = index3d + csize.x
				end
			end
		end
	end

	-- Air needs to be placed prior to decorations.
	local index = 0
	local index3d = 0
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			index = index + 1
			if bullshit_heightmap and maxp.y > 0 then
				-- nop
			else
				local pn = minetest.get_perlin(plant_noise):get2d({x=x, y=z})
				local biome = fun_caves.biome_ids[biomemap[index]]
				index3d = noise_area:index(x - minp.x, 0, z - minp.z)
				local ivm = area:index(x, minp.y, z)
				write = true

				for y = minp.y, maxp.y do
					if bullshit_heightmap or y <= heightmap[index] - 20 then
						data[ivm] = fun_caves.decorate_cave(data, area, minp, y, ivm, biome_n[index3d]) or data[ivm]
					elseif y < heightmap[index] and not bullshit_heightmap then
						if data[ivm] == node("air") and data[ivm - area.ystride] ~= node('air') then
							data[ivm - area.ystride] = node("dirt")
						end
					else
						data[ivm] = fun_caves.decorate_water(data, area, minp, maxp, {x=x,y=y,z=z}, ivm, biome, pn) or data[ivm]
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
		if DEBUG then
			vm:set_lighting({day = 15, night = 15})
		else
			vm:calc_lighting({x=minp.x,y=emin.y,z=minp.z},maxp)
		end
		vm:update_liquids()
		vm:write_to_map()
	end

	vm, area, noise_area = nil, nil, nil
end
