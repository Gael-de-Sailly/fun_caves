dofile(fun_caves.path .. "/deco_clouds.lua")


local rand = math.random
local min = math.min
local floor = math.floor
local ceil = math.ceil
local abs = math.ceil
local map_max = 31000


local cloud_noise_1 = {offset = 10, scale = 10, seed = 3721, spread = {x = 120, y = 120, z = 120}, octaves = 3, persist = 1, lacunarity = 2}

fun_caves.cloudgen = function(minp, maxp, data, area, node)
	local clouds = ceil(minp.y / floor(map_max / 7))
	if abs(clouds * floor(map_max / 7) - minp.y) > 80 then
		return
	end

	local csize = vector.add(vector.subtract(maxp, minp), 1)

	local cloud_1 = minetest.get_perlin_map(cloud_noise_1, {x=csize.x, y=csize.z}):get2dMap_flat({x=minp.x, y=minp.z})

	local write = false

	local index = 0
	local index3d = 0
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			index = index + 1
			--index3d = noise_area:index(x, minp.y-1, z)
			index3d = (z - minp.z) * (csize.y + 2) * csize.x + (x - minp.x) + 1
			--local height = cloud_1[index] + minp.y + 32
			local ivm = area:index(x, minp.y-1, z)

			if cloud_1[index] > 0 then
				for y = minp.y, maxp.y do
					local dy = y - minp.y
					if dy > 32 and cloud_1[index] > 15 then
						if dy < 47 then
							if dy < 47 - (cloud_1[index] - 15) then
								data[ivm] = node['fun_caves:cloud']
							else
								data[ivm] = node['default:water_source']
							end
							write = true
						end
					elseif dy >= 32 - cloud_1[index] and dy <= 32 + cloud_1[index] then
						data[ivm] = node['fun_caves:cloud']
						write = true
					end

					ivm = ivm + area.ystride
					index3d = index3d + csize.x
				end
			end
		end
	end

	return write
end
