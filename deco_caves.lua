local node = fun_caves.node
local min_surface = -80

function fun_caves.decorate_cave(data, area, minp, y, ivm, biome_val_in)
	local ivm_below = ivm - area.ystride
	local ivm_above = ivm + area.ystride
	local biome_val = biome_val_in

	-------------------
	local stone_type = node("default:stone")
	local stone_depth = 1
	local air_count = 0

	if y > -500 then
		biome_val = biome_val / math.max(1, math.log(500 + y))
	end
	-------------------
	--biome_val = 0.7
	-------------------
	if biome_val < -0.65 then
		stone_type = node("default:ice")
		stone_depth = 2
	elseif biome_val < -0.6 then
		stone_type = node("fun_caves:thinice")
		stone_depth = 2
	elseif biome_val < -0.5 then
		stone_type = node("fun_caves:stone_with_lichen")
	elseif biome_val < -0.3 then
		stone_type = node("fun_caves:stone_with_moss")
	elseif biome_val < -0.0 then
		stone_type = node("fun_caves:stone_with_lichen")
	elseif biome_val < 0.2 then
		stone_type = node("fun_caves:stone_with_algae")
	elseif biome_val < 0.35 then
		stone_type = node("fun_caves:stone_with_salt")
		stone_depth = 2
		if data[ivm] == node("default:stone") then
			return stone_type
		end
	elseif biome_val < 0.5 then
		stone_type = node("default:sand")
		stone_depth = 2
	elseif biome_val < 0.6 then
		stone_type = node("default:coalblock")
		stone_depth = 2
	else
		stone_type = node("fun_caves:hot_cobble")
	end
	--	"glow"

	local node_below
	if y > minp.y then
		node_below = data[ivm - area.ystride]
	end
	local node_above = data[ivm + area.ystride]

	local air_above = false
	for i = 1, stone_depth do
		if data[ivm + area.ystride * i] == node("air") then
			air_above = true
		end
	end

	if data[ivm] == node("default:stone") and (stone_type == node("fun_caves:stone_with_algae") or stone_type == node("fun_caves:stone_with_lichen")) and node_above == node("air") and math.random(3) == 1 then
		return node("dirt")
	end

	if data[ivm] == node("default:stone") and air_above then
		if stone_type == node("fun_caves:stone_with_salt") and math.random(500) == 1 then
			return node("fun_caves:radioactive_ore")
		else
			return stone_type
		end
	end

	local air_below = false
	for i = 1, stone_depth do
		if data[ivm - area.ystride * i] == node("air") then
			air_below = true
		end
	end

	if data[ivm] == node("default:stone") and air_below then
		if stone_type == node("fun_caves:stone_with_salt") and math.random(500) == 1 then
			return node("fun_caves:radioactive_ore")
		else
			return stone_type
		end
	end

	if node_below == node("air") and (data[ivm] == node("fun_caves:stone_with_lichen") or data[ivm] == node("fun_caves:stone_with_moss")) and math.random(50) == 1 then
		return node("fun_caves:glowing_fungal_stone")
	end
	if node_above == node("air") and data[ivm] == node("fun_caves:stone_with_moss") and math.random(50) == 1 then
		return node("fun_caves:glowing_fungal_stone")
	end

	if data[ivm] == node("air") then
		local sr = math.random(1000)

		-- hanging down
		if node_above == node("default:stone") and sr < 80 then
			if stone_type == node("default:ice") then
				return node("fun_caves:icicle_down")
			elseif stone_type == node("fun_caves:stone_with_algae") then
				return node("fun_caves:stalactite_slimy")
			elseif stone_type == node("fun_caves:stone_with_moss") then
				return node("fun_caves:stalactite_mossy")
			elseif stone_type == node("fun_caves:stone_with_lichen") then
				return node("fun_caves:stalactite")
			elseif stone_type == node("default:stone") then
				return node("fun_caves:stalactite")
			end
		end

		-- fluids
		--if y < min_surface and (node_below == node("default:stone") or node_below == node("fun_caves:hot_cobble")) and sr < 3 then
		if y > minp.y and (node_below == node("default:stone") or node_below == node("fun_caves:hot_cobble")) and sr < 3 then
			return node("default:lava_source")
		elseif node_below == node("fun_caves:stone_with_moss") and sr < 3 then
			return node("default:water_source")
		-- standing up
		elseif node_below == node("default:ice") and sr < 80 then
			return node("fun_caves:icicle_up")
		elseif node_below == node("fun_caves:stone_with_algae") and sr < 80 then
			return node("fun_caves:stalagmite_slimy")
		elseif node_below == node("fun_caves:stone_with_moss") and sr < 80 then
			return node("fun_caves:stalagmite_mossy")
		elseif node_below == node("fun_caves:stone_with_lichen") and sr < 80 then
			return node("fun_caves:stalagmite")
		elseif node_below == node("default:stone") and sr < 80 then
			return node("fun_caves:stalagmite")
		elseif node_below == node("fun_caves:hot_cobble") and sr < 80 then
			if sr < 20 then
				return node("fun_caves:hot_spike")
			else
				return node("fun_caves:hot_spike_"..math.ceil(sr / 20))
			end
		elseif node_below == node("default:coalblock") and sr < 20 then
			return node("fun_caves:constant_flame")
		-- vegetation
		elseif node_below == node("default:dirt") and (stone_type == node("fun_caves:stone_with_lichen") or stone_type == node("fun_caves:stone_with_algae")) and biome_val >= -0.5 then
			if sr < 110 then
				return node("flowers:mushroom_red")
			elseif sr < 220 then
				return node("flowers:mushroom_brown")
			elseif node_above == node("air") and sr < 330 then
				return node("fun_caves:giant_mushroom_stem")
			elseif sr < 360 then
				for i = 1, 12 do
					local j = ivm + area.ystride * i
					if j <= #data and data[j] == node("air") then
						air_count = air_count + 1
					end
				end
				if air_count > 5 then
					fun_caves.make_fungal_tree(data, area, ivm, math.random(2,math.min(air_count, 12)), node(fun_caves.fungal_tree_leaves[math.random(1,#fun_caves.fungal_tree_leaves)]), node("fun_caves:fungal_tree_fruit"))
					--node_below = node("dirt")
				end
			end
		elseif node_below == node("fun_caves:giant_mushroom_stem") and data[ivm - area.ystride * 2] == node("fun_caves:giant_mushroom_stem") then
			return node("fun_caves:giant_mushroom_cap")
		elseif node_below == node("fun_caves:giant_mushroom_stem") then
			if node_above == node("air") and math.random(3) == 1 then
				return node("fun_caves:giant_mushroom_stem")
			else
				return node("fun_caves:huge_mushroom_cap")
			end
		end

		if data[ivm] == node("air") then
			air_count = air_count + 1
		end
	end
end

--function original_fun_caves_decorate_cave(data, area)
--	local ivm_below = ivm - area.ystride
--	local ivm_above = ivm + area.ystride
--	local dy = y - minp.y
--
--	-------------------
--	local stone_type = node("default:stone")
--	local stone_depth = 1
--	local biome_val = biome_n[index3d]
--	if y > -500 then
--		biome_val = biome_val / math.max(1, math.log(500 + y))
--	end
--	-------------------
--	--biome_val = 0.7
--	-------------------
--	if biome_val < -0.6 then
--		if true then
--			stone_type = node("default:ice")
--			stone_depth = 2
--		else
--			stone_type = node("fun_caves:thinice")
--			stone_depth = 2
--		end
--	elseif biome_val < -0.5 then
--		stone_type = node("fun_caves:stone_with_lichen")
--	elseif biome_val < -0.3 then
--		stone_type = node("fun_caves:stone_with_moss")
--	elseif biome_val < -0.0 then
--		stone_type = node("fun_caves:stone_with_lichen")
--	elseif biome_val < 0.2 then
--		stone_type = node("fun_caves:stone_with_algae")
--	elseif biome_val < 0.35 then
--		stone_type = node("fun_caves:stone_with_salt")
--		stone_depth = 2
--		if data[ivm] == node("default:stone") then
--			data[ivm] = stone_type
--		end
--	elseif biome_val < 0.5 then
--		stone_type = node("default:sand")
--		stone_depth = 2
--	elseif biome_val < 0.6 then
--		stone_type = node("default:coalblock")
--		stone_depth = 2
--	else
--		stone_type = node("fun_caves:hot_cobble")
--	end
--	--	"glow"
--
--	if data[ivm] == node("air") then
--		-- Change stone per biome.
--		if data[ivm_below] == node("default:stone") or (stone_type == node("fun_caves:stone_with_salt") and data[ivm_below] ~= node("fun_caves:stone_with_salt") and data[ivm_below] ~= node("air")) then
--			data[ivm_below] = stone_type
--			if stone_type == node("fun_caves:stone_with_salt") and math.random(500) == 1 then
--				data[ivm_below - area.ystride] = node("fun_caves:radioactive_ore")
--			elseif stone_depth == 2 then
--				data[ivm_below - area.ystride] = stone_type
--			end
--		end
--		if data[ivm_above] == node("default:stone") or (stone_type == node("fun_caves:stone_with_salt") and data[ivm_above] ~= node("fun_caves:stone_with_salt") and data[ivm_above] ~= node("air")) then
--			data[ivm_above] = stone_type
--			if stone_type == node("fun_caves:stone_with_salt") and math.random(500) == 1 then
--				data[ivm_above - area.ystride] = node("fun_caves:radioactive_ore")
--			elseif stone_depth == 2 then
--				data[ivm_above + area.ystride] = stone_type
--			end
--		end
--
--		if (data[ivm_above] == node("fun_caves:stone_with_lichen") or data[ivm_above] == node("fun_caves:stone_with_moss")) and math.random(1,50) == 1 then
--			data[ivm_above] = node("fun_caves:glowing_fungal_stone")
--		end
--
--		if data[ivm] == node("air") then
--			local sr = math.random(1,1000)
--
--			-- fluids
--			if (data[ivm_below] == node("default:stone") or data[ivm_below] == node("fun_caves:hot_cobble")) and sr < 3 then
--				data[ivm] = node("default:lava_source")
--			elseif data[ivm_below] == node("fun_caves:stone_with_moss") and sr < 3 then
--				data[ivm] = node("default:water_source")
--				-- hanging down
--			elseif data[ivm_above] == node("default:ice") and sr < 80 then
--				data[ivm] = node("fun_caves:icicle_down")
--			elseif (data[ivm_above] == node("fun_caves:stone_with_lichen") or data[ivm_above] == node("fun_caves:stone_with_moss") or data[ivm_above] == node("fun_caves:stone_with_algae") or data[ivm_above] == node("default:stone")) and sr < 80 then
--				if data[ivm_above] == node("fun_caves:stone_with_algae") then
--					data[ivm] = node("fun_caves:stalactite_slimy")
--				elseif data[ivm_above] == node("fun_caves:stone_with_moss") then
--					data[ivm] = node("fun_caves:stalactite_mossy")
--				else
--					data[ivm] = node("fun_caves:stalactite")
--				end
--				-- standing up
--			elseif data[ivm_below] == node("fun_caves:hot_cobble") and sr < 20 then
--				if sr < 10 then
--					data[ivm] = node("fun_caves:hot_spike")
--				else
--					data[ivm] = node("fun_caves:hot_spike_"..(math.ceil(sr / 3) - 2))
--				end
--			elseif data[ivm_below] == node("default:coalblock") and sr < 20 then
--				data[ivm] = node("fun_caves:constant_flame")
--			elseif data[ivm_below] == node("default:ice") and sr < 80 then
--				data[ivm] = node("fun_caves:icicle_up")
--			elseif (data[ivm_below] == node("fun_caves:stone_with_lichen") or data[ivm_below] == node("fun_caves:stone_with_algae") or data[ivm_below] == node("default:stone") or data[ivm_below] == node("fun_caves:stone_with_moss")) and sr < 80 then
--				if data[ivm_below] == node("fun_caves:stone_with_algae") then
--					data[ivm] = node("fun_caves:stalagmite_slimy")
--				elseif data[ivm_below] == node("fun_caves:stone_with_moss") then
--					data[ivm] = node("fun_caves:stalagmite_mossy")
--				elseif data[ivm_below] == node("fun_caves:stone_with_lichen") or data[ivm_above] == node("default:stone") then
--					data[ivm] = node("fun_caves:stalagmite")
--				end
--			elseif data[ivm_below] == node("fun_caves:stone_with_moss") and sr < 90 then
--				data[ivm_below] = node("fun_caves:glowing_fungal_stone")
--				-- vegetation
--			elseif (data[ivm_below] == node("fun_caves:stone_with_lichen") or data[ivm_below] == node("fun_caves:stone_with_algae")) and biome_val >= -0.5 then
--				if sr < 110 then
--					data[ivm] = node("flowers:mushroom_red")
--				elseif sr < 140 then
--					data[ivm] = node("flowers:mushroom_brown")
--				elseif air_count > 1 and sr < 160 then
--					data[ivm_above] = node("fun_caves:huge_mushroom_cap")
--					data[ivm] = node("fun_caves:giant_mushroom_stem")
--				elseif air_count > 2 and sr < 170 then
--					data[ivm + 2 * area.ystride] = node("fun_caves:giant_mushroom_cap")
--					data[ivm_above] = node("fun_caves:giant_mushroom_stem")
--					data[ivm] = node("fun_caves:giant_mushroom_stem")
--				elseif air_count > 5 and sr < 180 then
--					fun_caves.make_fungal_tree(data, area, ivm, math.random(2,math.min(air_count, 12)), node(fun_caves.fungal_tree_leaves[math.random(1,#fun_caves.fungal_tree_leaves)]), node("fun_caves:fungal_tree_fruit"))
--					data[ivm_below] = node("dirt")
--				elseif sr < 300 then
--					data[ivm_below] = node("dirt")
--				end
--				if data[ivm] ~= node("air") then
--					data[ivm_below] = node("dirt")
--				end
--			end
--		end
--
--		if data[ivm] == node("air") then
--			air_count = air_count + 1
--		end
--	end
--end
