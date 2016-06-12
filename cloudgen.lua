dofile(fun_caves.path .. "/deco_clouds.lua")


local rand = math.random
local min = math.min
local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local max_depth = 31000


local cloud_noise_1 = {offset = 10, scale = 10, seed = 4877, spread = {x = 120, y = 120, z = 120}, octaves = 3, persist = 1, lacunarity = 2}
local cloud_noise_2 = {offset = 0, scale = 1, seed = 5748, spread = {x = 40, y = 10, z = 40}, octaves = 3, persist = 1, lacunarity = 2}
local plant_noise = {offset = 0.0, scale = 1.0, spread = {x = 200, y = 200, z = 200}, seed = -2525, octaves = 3, persist = 0.7, lacunarity = 2.0}
local biome_noise = {offset = 0.0, scale = 1.0, spread = {x = 400, y = 400, z = 400}, seed = -1471, octaves = 3, persist = 0.5, lacunarity = 2.0}

fun_caves.cloudgen = function(minp, maxp, data, p2data, area, node)
	local clouds = ceil(minp.y / floor(max_depth / 7))
	if abs(clouds * floor(max_depth / 7) - minp.y) > 80 then
		return
	end

	local csize = vector.add(vector.subtract(maxp, minp), 1)
	local map_max = {x = csize.x, y = csize.y, z = csize.z}
	local map_min = {x = minp.x, y = minp.y, z = minp.z}

	local cloud_1 = minetest.get_perlin_map(cloud_noise_1, {x=csize.x, y=csize.z}):get2dMap_flat({x=minp.x, y=minp.z})
	local cloud_2 = minetest.get_perlin_map(cloud_noise_2, map_max):get3dMap_flat(map_min)
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

			local cloud
			if biome_n[index] < 0 then
				cloud = 'storm_cloud'
			else
				cloud = 'cloud'
			end

			cloud_1[index] = floor(cloud_1[index] + 0.5)
			if cloud_1[index] > 0 then
				for y = minp.y, maxp.y do
					local dy = y - minp.y
					if dy > 32 and cloud_1[index] > 15 and dy < 47 then
						if dy < 47 - (cloud_1[index] - 15) then
							data[ivm] = node['fun_caves:'..cloud]
						else
							data[ivm] = node['default:water_source']
							write = true
						end
					elseif (dy <= 32 or cloud_1[index] <= 15) and dy >= 32 - cloud_1[index] and dy <= 32 + cloud_1[index] then
						data[ivm] = node['fun_caves:'..cloud]
						write = true
					elseif data[ivm - area.ystride] == node['fun_caves:'..cloud] and data[ivm] == node['air'] then
						if rand(30) == 1 and plant_n[index] > 0.5 then
							data[ivm] = node['fun_caves:moon_weed']
							write = true
						elseif rand(60) == 1 and plant_n[index] > 0.5 then
							fun_caves.place_schematic(minp, maxp, data, p2data, area, node, {x=x,y=y-1,z=z}, fun_caves.schematics['lumin_tree'], true)
							write = true
						elseif rand(10) == 1 then
							data[ivm] = node['default:grass_'..rand(4)]
							write = true
						end
					elseif data[ivm] == node['air'] and (dy < 29 - cloud_1[index] or dy > 35 + cloud_1[index]) and cloud_2[index3d] > abs((dy - 40) / 20) then
						data[ivm] = node['fun_caves:wispy_cloud']
						write = true
					end

					ivm = ivm + area.ystride
					index3d = index3d + csize.x
				end
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
			if biome_n[index] < 0 then
				cloud = 'storm_cloud'
			else
				cloud = 'cloud'
			end

			cloud_1[index] = floor(cloud_1[index] + 0.5)
			if cloud_1[index] > 0 then
				for y = minp.y, maxp.y do
					local dy = y - minp.y
					if data[ivm] == node['fun_caves:'..cloud] and data[ivm + area.ystride] == node['default:water_source'] and rand(30) == 1 and fun_caves.surround(node, data, area, ivm) then
						data[ivm] = node['fun_caves:water_plant_1_water_'..cloud]
					end

					ivm = ivm + area.ystride
				end
			end
		end
	end

	return write
end
