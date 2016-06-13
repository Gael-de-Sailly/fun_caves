local rand = math.random
local min = math.min
local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local max_depth = 31000


local newnode = fun_caves.clone_node("default:dirt")
newnode.description = "Air"
newnode.tiles = {'fun_caves_blank.png'}
newnode.sunlight_propagates = true
newnode.use_texture_alpha = true
newnode.light_source = 14
newnode.walkable = false
newnode.buildable_to = true
newnode.pointable = false
minetest.register_node("fun_caves:airy", newnode)

local terrain_noise_1 = {offset = 10, scale = 10, seed = 4877, spread = {x = 120, y = 120, z = 120}, octaves = 3, persist = 1, lacunarity = 2}
local plant_noise = {offset = 0.0, scale = 1.0, spread = {x = 200, y = 200, z = 200}, seed = -2525, octaves = 3, persist = 0.7, lacunarity = 2.0}
local biome_noise = {offset = 0.0, scale = 1.0, spread = {x = 400, y = 400, z = 400}, seed = -1471, octaves = 3, persist = 0.5, lacunarity = 2.0}

fun_caves.skysea = function(minp, maxp, data, p2data, area, node)
	if minp.y ~= 8768 then
		return
	end

	local csize = vector.add(vector.subtract(maxp, minp), 1)
	local map_max = {x = csize.x, y = csize.y, z = csize.z}
	local map_min = {x = minp.x, y = minp.y, z = minp.z}

	local terrain_1 = minetest.get_perlin_map(terrain_noise_1, {x=csize.x, y=csize.z}):get2dMap_flat({x=minp.x, y=minp.z})
	local plant_n = minetest.get_perlin_map(plant_noise, {x=csize.x, y=csize.z}):get2dMap_flat({x=minp.x, y=minp.z})
	local biome_n = minetest.get_perlin_map(biome_noise, {x=csize.x, y=csize.z}):get2dMap_flat({x=minp.x, y=minp.z})

	local write = false

	local index = 0
	local index3d = 0
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			index = index + 1
			index3d = (z - minp.z) * (csize.y) * csize.x + (x - minp.x) + 1
			local ivm = area:index(x, minp.y, z)

			terrain_1[index] = floor(terrain_1[index] + 0.5)
			for y = minp.y, maxp.y do
				local dy = y - minp.y
				if dy == 0 then
					data[ivm] = node['fun_caves:airy']
					write = true
				elseif dy == 32 and terrain_1[index] > 9 then
					data[ivm] = node['default:wood']
					write = true
				elseif dy < 33 then
					data[ivm] = node['default:water_source']
					write = true
				elseif dy == 33 and terrain_1[index] > 10 then
					data[ivm] = node['default:wood']
					write = true
				elseif dy > 33 and dy == terrain_1[index] + 22 then
					data[ivm] = node['default:dirt_with_grass']
					write = true
				elseif dy > 33 and dy < terrain_1[index] + 22 then
					data[ivm] = node['default:dirt']
					write = true
				end

				ivm = ivm + area.ystride
				index3d = index3d + csize.x
			end
		end
	end

	local index = 0
	local index3d = 0
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			index = index + 1
			local ivm = area:index(x, minp.y, z)

			local cloud
			--if biome_n[index] < 0 then

			terrain_1[index] = floor(terrain_1[index] + 0.5)
			if terrain_1[index] > 0 then
				for y = minp.y, maxp.y do
					local dy = y - minp.y
					if data[ivm] == node['air'] and data[ivm - area.ystride] == node['default:dirt_with_grass'] then
					end

					ivm = ivm + area.ystride
				end
			end
		end
	end

	return write
end
