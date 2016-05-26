local min_surface = -80

function fun_caves.decorate_cave(node, data, area, minp, y, ivm, biome_val_in)
	if not (data[ivm] == node("air") or data[ivm] == node("default:stone")) then
		return
	end

	local ivm_below = ivm - area.ystride
	local ivm_above = ivm + area.ystride
	local biome_val = biome_val_in

	-------------------
	local stone_type = node("default:stone")
	local stone_depth = 1

	if y > -200 then
		biome_val = biome_val / math.max(1, math.log(200 + y))
	end
	-------------------
	--biome_val = 0.55
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
	elseif biome_val < 0.5 then
		stone_type = node("default:sand")
		stone_depth = 2
	elseif biome_val < 0.6 then
		stone_type = node("fun_caves:black_sand")
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

	if data[ivm] == node("default:stone") then
		local air_above = false
		for i = 1, stone_depth do
			if data[ivm + area.ystride * i] == node("air") then
				air_above = true
			end
		end

		if node_above == node("air") and (stone_type == node("fun_caves:stone_with_algae") or stone_type == node("fun_caves:stone_with_lichen")) and math.random(10) == 1 then
			return node("dirt")
		end

		if air_above then
			if stone_type == node("fun_caves:stone_with_salt") and math.random(500) == 1 then
				return node("fun_caves:radioactive_ore")
			elseif stone_type == node("fun_caves:black_sand") and math.random(100) == 1 then
				return node("default:coalblock")
			elseif node_above == node("air") and stone_type == node("fun_caves:stone_with_moss") and math.random(50) == 1 then
				return node("fun_caves:glowing_fungal_stone")
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
			elseif stone_type == node("fun_caves:black_sand") and math.random(100) == 1 then
				return node("default:coalblock")
			elseif node_below == node("air") and (stone_type == node("fun_caves:stone_with_lichen") or stone_type == node("fun_caves:stone_with_moss")) and math.random(50) == 1 then
				return node("fun_caves:glowing_fungal_stone")
			else
				return stone_type
			end
		end
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
			if sr <= 20 then
				return node("fun_caves:hot_spike")
			else
				return node("fun_caves:hot_spike_"..math.ceil(sr / 20))
			end
		elseif node_below == node("fun_caves:black_sand") and sr < 20 then
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
				local air_count = 0
				local j
				for i = 1, 12 do
					j = ivm + area.ystride * i
					if j <= #data and data[j] == node("air") then
						air_count = air_count + 1
					end
				end
				if air_count > 5 then
					fun_caves.make_fungal_tree(data, area, ivm, math.random(2,math.min(air_count, 12)))
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
	end
end
