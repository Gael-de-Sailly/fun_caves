-- player surface damage and hunger
local dps_delay = 3000000
local last_dps_check = 0
local cold_delay = 5
local hunger_delay = 60
local dps_count = hunger_delay
minetest.register_globalstep(function(dtime)
	local minp, maxp, counts
	local time = minetest.get_us_time()

	if last_dps_check and time - last_dps_check < dps_delay then
		return
	end

	local pos
	for k, v in pairs(minetest.luaentities) do
		if not v.fortress_check then
			pos = v.object:getpos()
			if fun_caves.is_fortress(pos) and v.hp_max and v.object and v.health and v.damage then
				local factor = 1.5 + (pos.y / -3100)
				v.hp_max = math.floor(v.hp_max * factor)
				v.damage = math.floor(v.damage * factor)
				print("Promoting "..v.name..": "..v.hp_max.." at "..pos.x..","..pos.y..","..pos.z)
				v.object:set_hp(v.hp_max)
				v.health = v.hp_max
				v.fortress_check = true
				check_for_death(v)
				--print(dump(v.damage))
			end
		end
	end

	for id, player in pairs(minetest.get_connected_players()) do
		minp = vector.subtract(player:getpos(), 0.5)
		maxp = vector.add(player:getpos(), 0.5)

		counts =  minetest.find_nodes_in_area(minp, maxp, {"group:surface_hot"})
		if #counts > 1 then
			player:set_hp(player:get_hp() - 1)
		end

		if dps_count % cold_delay == 0 then
			counts =  minetest.find_nodes_in_area(minp, maxp, {"group:surface_cold"})
			if #counts > 1 then
				player:set_hp(player:get_hp() - 1)
			end
		end

		-- hunger
		if dps_count % hunger_delay == 0 then
			player:set_hp(player:get_hp() - 1)
			dps_count = hunger_delay
		end
	end

	last_dps_check = minetest.get_us_time()
	dps_count = dps_count - 1
end)


-- mushroom growth -- small into huge
minetest.register_abm({
	nodenames = {"flowers:mushroom_brown", "flowers:mushroom_red"},
	interval = 200 * fun_caves.time_factor,
	chance = 25,
	action = function(pos, node)
		local pos_up = {x=pos.x,y=pos.y+1,z=pos.z}
		local node_up = minetest.get_node_or_nil(pos_up)
		if not node_up then
			return
		end
		if node_up.name ~= "air" then
			return
		end
		local node_under = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
		if not node_under then
			return
		end
		if minetest.get_item_group(node_under.name, "soil") ~= 0 and
				minetest.get_node_light(pos_up, nil) <= fun_caves.light_max then
			minetest.set_node(pos_up, {name = "fun_caves:huge_mushroom_cap"})
			minetest.set_node(pos, {name = "fun_caves:giant_mushroom_stem"})
		end
	end
})

-- mushroom growth -- huge into giant
minetest.register_abm({
	nodenames = {"fun_caves:huge_mushroom_cap"},
	interval = 500 * fun_caves.time_factor,
	chance = 30,
	action = function(pos, node)
		if minetest.get_node_light(pos, nil) >= default.LIGHT_MAX - 2 then
			minetest.set_node(pos, {name = "air"})
			return
		end
		local pos_up = {x=pos.x,y=pos.y+1,z=pos.z}
		local node_up = minetest.get_node_or_nil(pos_up)
		if not node_up then
			return
		end
		if node_up.name ~= "air" then
			return
		end
		local node_under = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
		if not node_under or node_under.name ~= "fun_caves:giant_mushroom_stem" then
			return
		end
		node_under = minetest.get_node_or_nil({x = pos.x, y = pos.y - 2, z = pos.z})
		if not node_under then
			return
		end
		if minetest.get_item_group(node_under.name, "soil") ~= 0 and
				minetest.get_node_light(pos_up, nil) <= fun_caves.light_max then
			minetest.set_node(pos_up, {name = "fun_caves:giant_mushroom_cap"})
			minetest.set_node(pos, {name = "fun_caves:giant_mushroom_stem"})
		end
	end
})

-- mushroom growth -- caps regenerate in time
minetest.register_abm({
	nodenames = {"fun_caves:giant_mushroom_stem"},
	interval = 15 * fun_caves.time_factor,
	chance = 10,
	action = function(pos, node)
		local pos_up = {x=pos.x,y=pos.y+1,z=pos.z}
		local node_up = minetest.get_node_or_nil(pos_up)
		if not node_up then
			return
		end
		if node_up.name ~= "air" then
			return
		end
		if minetest.get_node_light(pos_up, nil) <= fun_caves.light_max then
			minetest.set_node(pos_up, {name = "fun_caves:huge_mushroom_cap"})
		end
	end
})

-- mushroom spread -- spores produce small mushrooms
minetest.register_abm({
	nodenames = {"fun_caves:giant_mushroom_cap", "fun_caves:huge_mushroom_cap"},
	interval = 15 * fun_caves.time_factor,
	chance = 10,
	action = function(pos, node)
		if minetest.get_node_light(pos, nil) >= 14 then
			minetest.set_node(pos, {name = "air"})
			return
		end
		local pos_down = pos
		pos_down.y = pos_down.y - 1
		local pos1, count = minetest.find_nodes_in_area_under_air(vector.subtract(pos_down, 4), vector.add(pos_down, 4), {"group:soil"})
		if #pos1 < 1 then
			return
		end
		local random = pos1[math.random(1, #pos1)]
		random.y = random.y + 1
		local mushroom_type
		if math.random(1,2) == 1 then
			mushroom_type = "flowers:mushroom_red"
		else
			mushroom_type = "flowers:mushroom_brown"
		end
		if minetest.get_node_light(random, nil) <= fun_caves.light_max then
			minetest.set_node(random, {name = mushroom_type})
		end
	end
})

-- Mushroom spread and death
minetest.register_abm({
	nodenames = {"flowers:mushroom_brown", "flowers:mushroom_red"},
	interval = 15 * fun_caves.time_factor,
	chance = 10,
	action = function(pos, node)
		if minetest.get_node_light(pos, nil) >= default.LIGHT_MAX - 2 then
			minetest.remove_node(pos)
			return
		end
		local random = {
			x = pos.x + math.random(-2, 2),
			y = pos.y + math.random(-1, 1),
			z = pos.z + math.random(-2, 2)
		}
		local random_node = minetest.get_node_or_nil(random)
		if not random_node or random_node.name ~= "air" then
			return
		end
		local node_under = minetest.get_node_or_nil({x = random.x,
			y = random.y - 1, z = random.z})
		if not node_under then
			return
		end

		if (minetest.get_item_group(node_under.name, "soil") ~= 0 or
				minetest.get_item_group(node_under.name, "tree") ~= 0) and
				minetest.get_node_light(pos, 0.5) <= fun_caves.light_max and
				minetest.get_node_light(random, 0.5) <= fun_caves.light_max then
			minetest.set_node(random, {name = node.name})
		end
	end
})

-- Spike spread and death
minetest.register_abm({
	nodenames = fun_caves.hot_spikes,
	interval = 30 * fun_caves.time_factor,
	chance = 10,
	action = function(pos, node)
		local spike_num
		for i = 1, #hot_spikes do
			if hot_spikes[i] == node.name then
				spike_num = i
			end
		end
		if not spike_num then
			return
		end

		if spike_num < #hot_spikes then
			minetest.set_node(pos, {name=hot_spikes[spike_num+1]})
			return
		end

		local random = {
			x = pos.x + math.random(-2, 2),
			y = pos.y + math.random(-1, 1),
			z = pos.z + math.random(-2, 2)
		}
		local random_node = minetest.get_node_or_nil(random)
		if not random_node or (random_node.name ~= "air" and random_node.name ~= "default:lava_source" and random_node.name ~= "default:lava_flowing") then
			return
		end
		local node_under = minetest.get_node_or_nil({x = random.x,
			y = random.y - 1, z = random.z})
		if not node_under then
			return
		end

		--print("node_under ("..random.x..","..(random.y-1)..","..random.z.."): "..node_under.name)
		if node_under.name == "fun_caves:hot_cobble" or node_under.name == "default:coalblock" then
			--print("setting ("..random.x..","..random.y..","..random.z.."): "..node_under.name)
			minetest.set_node(random, {name = hot_spikes[1]})
		end
	end
})
