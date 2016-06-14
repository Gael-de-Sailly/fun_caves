local cave_width = 0.05  -- figurative width
local max_depth = 31000


local cave_noise_1 = {offset = 0, scale = 1, seed = 3901, spread = {x = 40, y = 10, z = 40}, octaves = 3, persist = 1, lacunarity = 2}
local cave_noise_2 = {offset = 0, scale = 1, seed = -8402, spread = {x = 40, y = 20, z = 40}, octaves = 3, persist = 1, lacunarity = 2}
local cave_noise_3 = {offset = 15, scale = 10, seed = 3721, spread = {x = 40, y = 40, z = 40}, octaves = 3, persist = 1, lacunarity = 2}


fun_caves.cavegen = function(minp, maxp, data, area, node, heightmap, underzone)
	local csize = vector.add(vector.subtract(maxp, minp), 1)
	local map_max = {x = csize.x, y = csize.y + 2, z = csize.z}
	local map_min = {x = minp.x, y = minp.y - 1, z = minp.z}
	--local noise_area = VoxelArea:new({MinEdge=map_min, MaxEdge={x=maxp.x,y=maxp.y+1,z=maxp.z}})

	local cave_1 = minetest.get_perlin_map(cave_noise_1, map_max):get3dMap_flat(map_min)
	local cave_2 = minetest.get_perlin_map(cave_noise_2, map_max):get3dMap_flat(map_min)
	local cave_3 = minetest.get_perlin_map(cave_noise_3, {x=csize.x, y=csize.z}):get2dMap_flat({x=minp.x, y=minp.z})

	local write = false

	local index = 0
	local index3d = 0
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			index = index + 1
			--index3d = noise_area:index(x, minp.y-1, z)
			index3d = (z - minp.z) * (csize.y + 2) * csize.x + (x - minp.x) + 1
			local ivm = area:index(x, minp.y-1, z)

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

			for y = minp.y-1, maxp.y+1 do
				if underzone and underzone.regular_columns and (x - minp.x) < 8 and (z - minp.z) < 8 then
					data[ivm] = node[underzone.column_node]
					write = true
				elseif underzone and underzone.column_node and not underzone.regular_columns and column == 2 then
					if underzone.column_node_rare and math.random(70) == 1 then
						data[ivm] = node[underzone.column_node_rare]
					else
						data[ivm] = node[underzone.column_node]
					end
					write = true
				elseif underzone and (y < underzone.ceiling - (underzone.vary and cave_3[index] or 0) and y > underzone.floor + (underzone.vary and cave_3[index] or 0)) then
					if underzone.sealevel and y <= underzone.sealevel then
						data[ivm] = node["default:water_source"]
					else
						data[ivm] = node["air"]
					end
					write = true
				elseif underzone and (y < underzone.ceiling + 10 - (underzone.vary and cave_3[index] or 0) and y > underzone.floor - 10 + (underzone.vary and cave_3[index] or 0)) then
					-- nop
				elseif ((y <= maxp.y and y >= minp.y) or (data[ivm] == node['default:stone'])) and y < height - cave_3[index] and cave_1[index3d] * cave_2[index3d] > cave_width then
					if y <= fun_caves.underzones['Styx'].sealevel then
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

	return write
end
