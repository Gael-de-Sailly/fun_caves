local light_depth = -13
local water_level = 1

local water_lily_biomes = {}
for _, i in pairs({"rainforest_swamp", "rainforest", "savanna_swamp", "savanna",  "deciduous_forest_swamp", "deciduous_forest", "desertstone_grassland", }) do
	water_lily_biomes[i] = true
end
local coral_biomes = {}
for _, i in pairs({"desert_ocean", "savanna_ocean", "rainforest_ocean", }) do
	coral_biomes[i] = true
end

plant_noise = {offset = 0.0, scale = 1.0, spread = {x = 200, y = 200, z = 200}, seed = 33, octaves = 3, persist = 0.7, lacunarity = 2.0}

local function surround(node, data, area, ivm)
	-- Check to make sure that a plant root is fully surrounded.
	-- This is due to the kludgy way you have to make water plants
	--  in minetest, to avoid bubbles.
	for x1 = -1,1,2 do
		local n = data[ivm+x1] 
		if n == node("default:river_water_source") or n == node("default:water_source") or n == node("air") then
			return false
		end
	end
	for z1 = -area.zstride,area.zstride,2*area.zstride do
		n = data[ivm+z1] 
		if n == node("default:river_water_source") or n == node("default:water_source") or n == node("air") then
			return false
		end
	end

	return true
end

local node_match_cache = {}

function fun_caves.decorate_water(node, data, area, minp, maxp, pos, ivm, biome_in, pn)
	if pos.y < light_depth then
		return
	end

	local biome = biome_in

	local node_below = data[ivm - area.ystride]
	local node_above = data[ivm + area.ystride]

	local inside = false
	if pos.x < maxp.x and pos.y < maxp.y and pos.z < maxp.z and pos.x > minp.x and pos.y > minp.y and pos.z > minp.z then
		inside = true
	end

	if pos.y < water_level and data[ivm] == node("default:sand") and node_above == node("default:water_source") and data[ivm + area.ystride * 2] == node("default:water_source") and coral_biomes[biome] and pn < -0.1 and math.random(5) == 1 and surround(node, data, area, ivm) then
		return node("fun_caves:staghorn_coral_water_sand")
	elseif pos.y < water_level and node_below == node("default:sand") and node_above == node("default:water_source") and data[ivm] == node("default:water_source") and coral_biomes[biome] and pn < -0.1 and math.random(5) < 3 then
		local sr = math.random(65)
		if sr < 4 then
			return node("fun_caves:brain_coral")
		elseif sr < 6 then
			return node("fun_caves:dragon_eye")
		elseif sr < 65 then
			return node("fun_caves:pillar_coral")
		end
	elseif inside and (node_above == node("default:water_source") or node_above == node("default:river_water_source")) and (data[ivm] == node("default:sand") or data[ivm] == node("default:dirt")) then
		-- Check the biomes and plant water plants, if called for.
		if not surround(node, data, area, ivm) then
			return
		end

		for _, desc in pairs(fun_caves.water_plants) do
			if desc.content_id then
				if not node_match_cache[desc.content_id] then
					node_match_cache[desc.content_id] = {}
				end

				if not node_match_cache[desc.content_id][data[ivm]] then
					-- This is a great way to match all node type strings
					-- against a given node (or nodes). However, it's slow.
					-- To speed it up, we cache the results for each plant
					-- on each node, and avoid calling find_nodes every time.
					local posm, count = minetest.find_nodes_in_area(pos, pos, desc.place_on)
					if #posm > 0 then
						node_match_cache[desc.content_id][data[ivm]] = "good" 
					else
						node_match_cache[desc.content_id][data[ivm]] = "bad" 
					end
				end

				if node_match_cache[desc.content_id][data[ivm]] == "good" and desc.fill_ratio and (not desc.biomes or (biome and desc.biomes and table.contains(desc.biomes, biome))) and math.random() <= desc.fill_ratio then
					return desc.content_id
				end
			end
		end
	elseif pos.y > minp.y and node_below == node("default:river_water_source") and data[ivm] == node("air") and water_lily_biomes[biome] and pn > 0.5 and math.random(15) == 1 then
		-- on top of the water
		-- I haven't figured out what the decoration manager is
		--  doing with the noise functions, but this works ok.
		return node("flowers:waterlily")
	end
end
