local max_depth = 31000


newnode = fun_caves.clone_node("default:water_source")
newnode.description = "Water"
newnode.liquid_range = 0
newnode.liquid_viscosity = 1
newnode.liquid_renewable = false
newnode.liquid_renewable = false
newnode.liquid_alternative_flowing = "fun_caves:asteroid_water"
newnode.liquid_alternative_source = "fun_caves:asteroid_water"
newnode.drowning = 0
newnode.light_source = 2
newnode.sunlight_propagates = true
newnode.post_effect_color = {a = 50, r = 30, g = 60, b = 90},
minetest.register_node("fun_caves:asteroid_water", newnode)

--bucket.liquids['fun_caves:asteroid_water'] = {
--	source = 'fun_caves:asteroid_water',
--	flowing = 'fun_caves:asteroid_water',
--	itemname = 'bucket:bucket_water',
--}

minetest.register_node("fun_caves:vacuum", {
	description = "Vacuum",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drawtype = "glasslike",
	sunlight_propagates = true,
	drowning = 1,
	post_effect_color = {a = 20, r = 220, g = 200, b = 200},
	tiles = {'fun_caves_blank.png'},
	alpha = 0.1,
	paramtype = "light",
})


local asteroid_noise_1 = {offset = 0, scale = 1, seed = -7620, spread = {x = 40, y = 40, z = 40}, octaves = 3, persist = 1, lacunarity = 2}
local plant_noise = {offset = 0.0, scale = 1.0, spread = {x = 200, y = 200, z = 200}, seed = -2525, octaves = 3, persist = 0.7, lacunarity = 2.0}
local biome_noise = {offset = 0.0, scale = 1.0, spread = {x = 400, y = 400, z = 400}, seed = -1471, octaves = 3, persist = 0.5, lacunarity = 2.0}

fun_caves.asteroids = function(minp, maxp, data, p2data, area, node)
	if minp.y < 11168 or minp.y > 15168 then
		return
	end

	math.randomseed(minetest.get_us_time())
	local density = 4 + math.abs(minp.y - 13168) / 500
	local empty = false
	if math.random(math.floor(density)) ~= 1 then
		empty = true
		--return
	end

	local csize = vector.add(vector.subtract(maxp, minp), 1)
	local map_max = {x = csize.x, y = csize.y, z = csize.z}
	local map_min = {x = minp.x, y = minp.y, z = minp.z}

	local asteroid_1 = minetest.get_perlin_map(asteroid_noise_1, map_max):get3dMap_flat(map_min)

	local write = false

	local index = 0
	local index3d = 0
	for z = minp.z, maxp.z do
		local dz = z - minp.z
		for x = minp.x, maxp.x do
			local dx = x - minp.x
			index = index + 1
			index3d = (z - minp.z) * (csize.y) * csize.x + (x - minp.x) + 1
			local ivm = area:index(x, minp.y, z)

			for y = minp.y, maxp.y do
				local dy = y - minp.y
				if empty then
					data[ivm] = node['fun_caves:vacuum']
					write = true
				else
				local dist2 = (40 - dy) ^ 2 + (40 - dx) ^ 2 + (40 - dz) ^ 2
				if dist2 < (40 - math.abs(asteroid_1[index3d]) * 30) ^ 2 then
					data[ivm] = node['default:stone']
					write = true
				elseif dist2 < 35 ^ 2 then
					data[ivm] = node['fun_caves:asteroid_water']
					write = true
				else
					data[ivm] = node['fun_caves:vacuum']
					write = true
				end
				end

				ivm = ivm + area.ystride
				index3d = index3d + csize.x
			end
		end
	end

	return write
end
