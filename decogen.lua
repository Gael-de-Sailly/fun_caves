local deco_depth = -30  -- place cave stuff this far beneath the surface
local light_depth = -13  -- depth above which to place corals/sea plants
local water_level = 1
local fluid_compression = -200  -- the depth to start planting lava/water
local water_lily_ratio = 15  -- place this many water for every lily
local max_depth = 31000


local water_lily_biomes = {}
for _, i in pairs({"rainforest_swamp", "rainforest", "savanna_swamp", "savanna",  "deciduous_forest_swamp", "deciduous_forest", "desertstone_grassland", }) do
	water_lily_biomes[i] = true
end
local coral_biomes = {}
for _, i in pairs({"desert_ocean", "savanna_ocean", "rainforest_ocean", }) do
	coral_biomes[i] = true
end


local rand = math.random
local max = math.max
local min = math.min
local log = math.log
local floor = math.floor
local find_nodes_in_area = minetest.find_nodes_in_area
local csize
local node_match_cache = {}


local biome_noise = {offset = 0.0, scale = 1.0, spread = {x = 400, y = 400, z = 400}, seed = 903, octaves = 3, persist = 0.5, lacunarity = 2.0}
local plant_noise = {offset = 0.0, scale = 1.0, spread = {x = 200, y = 200, z = 200}, seed = 33, octaves = 3, persist = 0.7, lacunarity = 2.0}


-- Air needs to be placed prior to decorations.
fun_caves.decogen = function(minp, maxp, data, p2data, area, node, heightmap, biome_ids, underzone, dis_map)
	csize = vector.add(vector.subtract(maxp, minp), 1)
	local biomemap = minetest.get_mapgen_object("biomemap")
	local map_max = {x = csize.x, y = csize.y + 2, z = csize.z}
	local map_min = {x = minp.x, y = minp.y - 1, z = minp.z}
	--local noise_area = VoxelArea:new({MinEdge={x=0,y=-1,z=0}, MaxEdge={x=csize.x,y=csize.y+1,z=csize.z}})

	local biome_n = minetest.get_perlin_map(biome_noise, map_max):get3dMap_flat(map_min)
	local plant_n = minetest.get_perlin_map(plant_noise, {x=csize.x, y=csize.z}):get2dMap_flat({x=minp.x, y=minp.z})

	local dis_map = {}
	if underzone and underzone.name == 'Dis' then
		for i = 0, 10, 2 do
			dis_map[i] = {}
			for j = 0, 10, 2 do
				dis_map[i][j] = rand(6)
				if dis_map[i][j] == 6 then
					dis_map[i][j] = 5 + rand(10)
				end
			end
		end
	end

	local undersea = fun_caves.underzones['Styx'].sealevel

	local write = false
	local write_p2 = false

	local index = 0
	local index3d = 0
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			index = index + 1
			--index3d = noise_area:index(x - minp.x, -1, z - minp.z)
			index3d = (z - minp.z) * (csize.y + 2) * csize.x + (x - minp.x) + 1
			local ivm = area:index(x, minp.y, z)

			local height = heightmap[index]

			for y = minp.y-1, maxp.y+1 do
				if y <= height + deco_depth and (height < max_depth or y < 0) then
					----------------------------------------------------------
					-- cave decoration non-loop -- only there to enable breaks
					-- Remove this loop to eliminate cave decorations.
					----------------------------------------------------------
					for deco_non_loop = 1, 1 do
						if not (data[ivm] == node["air"] or data[ivm] == node["default:stone"]) then
							break
						end

						local biome
						--if underzone and y < (underzone.ceiling + underzone.floor) / 2 then
						if underzone then
							biome = underzone
						else
							local biome_val = biome_n[index3d]

							-- Compress biomes at the surface to avoid fluids.
							if y > fluid_compression then
								biome_val = biome_val / max(1, log(y - fluid_compression))
							end

							for _, bi in pairs(fun_caves.cave_biomes) do
								if biome_val >= bi.biome_val_low and biome_val < bi.biome_val_high then
									biome = bi
								end
							end
							--biome = fun_caves.cave_biomes['salt']

							if not biome then
								print(("* Error in biome selection: %s"):format(biome_val))
							end

							if not biome or (y < undersea and not biome.underwater) then
								biome = fun_caves.cave_biomes['algae']
							end
						end


						local node_below
						if y > minp.y then
							node_below = data[ivm - area.ystride]
						end
						local node_above = data[ivm + area.ystride]

						if underzone and underzone.lake and y < underzone.floor + underzone.lake_level and data[ivm] == node['air'] then
							data[ivm] = node[underzone.lake]
							write = true
							break
						end

						if data[ivm] == node["default:stone"] then
							if node_above == node["air"] and biome and biome.dirt and rand(biome.dirt_chance) == 1 then
								data[ivm] = node[biome.dirt]
								write = true
								break
							end

							local air_above = false
							for i = 1, biome.stone_depth do
								if data[ivm + area.ystride * i] == node["air"] or (y < undersea and data[ivm + area.ystride * i] == node["default:water_source"]) then
									air_above = true
								end
							end

							if air_above then
								if biome and biome.deco and rand(biome.deco_chance) == 1 then
									data[ivm] = node[biome.deco]
									write = true
									break
								else
									data[ivm] = node[biome.floor_node]
									write = true
									break
								end
							end

							local air_below = false
							for i = 1, biome.stone_depth do
								if data[ivm - area.ystride * i] == node["air"] then
									air_below = true
								end
							end

							if not air_above and biome.floor_node == "default:sand" then
								data[ivm] = node["default:sandstone"]
								write = true
								break
							end

							if air_below then
								if biome and biome.deco and rand(biome.deco_chance) == 1 then
									data[ivm] = node[biome.deco]
									write = true
									break
								else
									data[ivm] = node[biome.ceiling_node]
									write = true
									break
								end
							end
						end

						-- smallest city generator ever
						if underzone and underzone.name == 'Dis' and data[ivm] == node['air'] and floor((x - minp.x) / 8) % 2 == 0 and floor((z - minp.z) / 8) % 2 == 0 and y - underzone.floor < dis_map[floor((x - minp.x) / 8)][floor((z - minp.z) / 8)] * 4 + 1 and y - underzone.floor >= 0 then
							local dx = (x - minp.x) % 16
							local dy = y - underzone.floor + 1
							local dz = (z - minp.z) % 16
							if dx == 1 and dz == 1 then
								data[ivm] = node["default:ladder_steel"]
								p2data[ivm] = 3
								write_p2 = true
							elseif ((dx == 0 or dx == 7) and (dz % 3 ~= 2 or dy % 4 == 0)) or ((dz == 0 or dz == 7) and (dx % 3 ~= 2 or dy % 4 == 0)) then
								data[ivm] = node["fun_caves:hot_iron"]
							elseif dy % 4 == 0 then
								data[ivm] = node["fun_caves:hot_brass"]
							end
							write = true
							break
						end

						if data[ivm] == node["air"] and y < maxp.y then
							-- hanging down
							--  stone hasn't yet been changed
							if biome and biome.stalactite and node_above == node["default:stone"] and rand(biome.stalactite_chance) == 1 then
								data[ivm] = node[biome.stalactite]
								write = true
								break
							end

							-- fluids
							if y > minp.y and biome and biome.fluid and node_below == node[biome.floor_node] and rand(biome.fluid_chance) == 1 then
								data[ivm] = node[biome.fluid]
								write = true
								break

								-- standing up
							elseif node_below == node[biome.floor_node] and biome and biome.stalagmite and rand(biome.stalagmite_chance) == 1 then
								if type(biome.stalagmite) == 'table' then
									data[ivm] = node[biome.stalagmite[rand(#biome.stalagmite)]]
								else
									data[ivm] = node[biome.stalagmite]
								end
								write = true
								break

								-- vegetation
							elseif node_below == node["fun_caves:polluted_dirt"] then
								if rand(10) == 1 then
									data[ivm] = node["default:dry_shrub"]
									write = true
									break
								elseif rand(50) == 1 then
									local air_count = 0
									local j
									for i = 1, 9 do
										j = ivm + area.ystride * i
										if j <= #data and data[j] == node["air"] then
											air_count = air_count + 1
										end
									end
									if air_count > 6 then
										fun_caves.place_schematic(minp, maxp, data, p2data, area, node, {x=x,y=y,z=z}, fun_caves.schematics['decaying_tree'], true)
									end
								end
							elseif node_below == node["default:dirt"] and biome and biome.fungi then
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
				elseif y < height and data[ivm] == node["air"] and (data[ivm - area.ystride] == node['default:stone'] or data[ivm - area.ystride] == node['default:sandstone']) then
					-- This just places non-abm dirt inside caves.
					-- Its value is questionable.
						data[ivm - area.ystride] = node["fun_caves:dirt"]
						write = true
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

						if y < water_level and data[ivm] == node["default:sand"] and node_above == node["default:water_source"] and data[ivm + area.ystride * 2] == node["default:water_source"] and coral_biomes[biome] and pn < -0.1 and rand(5) == 1 and fun_caves.surround(node, data, area, ivm) then
							if rand(100) == 1 then
								data[ivm] = node["fun_caves:precious_coral_water_sand"]
							else
								data[ivm] = node["fun_caves:staghorn_coral_water_sand"]
							end
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
							if not fun_caves.surround(node, data, area, ivm) then
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

	return write, write_p2
end
