
minetest.register_node("fun_caves:pillar_coral", {
	description = "Pillar Coral",
	tiles = {"fun_caves_pillar_coral.png"},
	paramtype = "light",
	light_source = 2,
	groups = {cracky = 3, stone=1},
	sounds = default.node_sound_stone_defaults(),
})


minetest.register_node("fun_caves:brain_coral", {
	description = "Brain Coral",
	tiles = {"fun_caves_brain_coral.png"},
	light_source = 4,
	groups = {cracky = 3, stone=1,},
	sounds = default.node_sound_stone_defaults(),
})


minetest.register_node("fun_caves:dragon_eye", {
	description = "Dragon Eye",
	tiles = {"fun_caves_dragon_eye.png"},
	light_source = 4,
	groups = {cracky = 3, stone=1,},
	sounds = default.node_sound_stone_defaults(),
})


minetest.register_node("fun_caves:staghorn_coral", {
	description = "Staghorn Coral",
	drawtype = "plantlike",
	tiles = {"fun_caves_staghorn_coral.png"},
	waving = false,
	sunlight_propagates = true,
	paramtype = "light",
	light_source = 2,
	walkable = false,
	groups = {cracky = 3, stone=1, attached_node=1, sea=1},
	sounds = default.node_sound_stone_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
	},
})

function fun_caves.sea_plants()
	if y >= light_depth and (data[index_3d] == node["sand"] or data[index_3d] == node["dirt"]) and (data[index_3d_above] == node["water_source"] or data[index_3d_above] == node["river_water_source"]) then
		-- Check the biomes and plant water plants, if called for.
		biome = valc.biome_ids[biomemap[index_2d]]
		if y < water_level and data[index_3d_above + ystride] == node["water_source"] and table.contains(coral_biomes, biome) and n21[index_2d] < -0.1 and math_random(1,3) ~= 1 then
			sr = math_random(1,100)
			if sr < 4 then
				data[index_3d_above] = node["brain_coral"]
			elseif sr < 6 then
				data[index_3d_above] = node["dragon_eye"]
			elseif sr < 35 then
				data[index_3d_above] = node["staghorn_coral"]
			elseif sr < 100 then
				data[index_3d_above] = node["pillar_coral"]
			end
		elseif surround then
			for _, desc in pairs(valc.water_plants) do
				placeable = false

				if not node_match_cache[desc] then
					node_match_cache[desc] = {}
				end

				if node_match_cache[desc][data[index_3d]] then
					placeable = node_match_cache[desc][data[index_3d]]
				else
					-- This is a great way to match all node type strings
					-- against a given node (or nodes). However, it's slow.
					-- To speed it up, we cache the results for each plant
					-- on each node, and avoid calling find_nodes every time.
					pos, count = minetest.find_nodes_in_area({x=x,y=y,z=z}, {x=x,y=y,z=z}, desc.place_on)
					if #pos > 0 then
						placeable = true
					end
					node_match_cache[desc][data[index_3d]] = placeable 
				end

				if placeable and desc.fill_ratio and desc.content_id then
					biome = valc.biome_ids[biomemap[index_2d]]

					if not desc.biomes or (biome and desc.biomes and table.contains(desc.biomes, biome)) then
						if math_random() <= desc.fill_ratio then
							data[index_3d] = desc.content_id
							write = true
						end
					end
				end
			end
		end
	end
end
