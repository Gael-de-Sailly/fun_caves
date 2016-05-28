-- see also, fungal_tree.lua

-- player surface damage and hunger
local dps_delay = 3000000
local last_dps_check = 0
local cold_delay = 5
local hunger_delay = 60
local dps_count = hunger_delay
local get_us_time = minetest.get_us_time
local floor = math.floor
local abs = math.abs
local max = math.max
local rand = math.random
local mushrooms = {"flowers:mushroom_brown", "flowers:mushroom_red"}
local get_node_light = minetest.get_node_light
local remove_node = minetest.remove_node
local set_node = minetest.set_node
local get_node_or_nil = minetest.get_node_or_nil
local get_connected_players = minetest.get_connected_players
local find_nodes_in_area = minetest.find_nodes_in_area
local get_item_group = minetest.get_item_group

minetest.register_globalstep(function(dtime)
	local minp, maxp, counts
	local time = get_us_time()

	if last_dps_check and time - last_dps_check < dps_delay then
		return
	end

	local pos, factor, mob
	for _, mob in pairs(minetest.luaentities) do
		if not mob.initial_promotion then
			pos = mob.object:getpos()
			if mob.hp_max and mob.object and mob.health and mob.damage then
				factor = 1 + (max(abs(pos.x), abs(pos.y), abs(pos.z)) / 6200)
				if fun_caves.is_fortress(pos) then
					factor = factor * 1.5
				end
				mob.hp_max = floor(mob.hp_max * factor)
				mob.damage = floor(mob.damage * factor)
				--print("Promoting "..mob.name..": "..mob.hp_max.." at "..pos.x..","..pos.y..","..pos.z)
				mob.object:set_hp(mob.hp_max)
				mob.health = mob.hp_max
				mob.initial_promotion = true
				check_for_death(mob)
			end
		end
	end

	local players = get_connected_players()
	local player
	for i = 1, #players do
		player = players[i]
		minp = vector.subtract(player:getpos(), 0.5)
		maxp = vector.add(player:getpos(), 0.5)

		counts =  find_nodes_in_area(minp, maxp, {"group:surface_hot"})
		if #counts > 1 then
			player:set_hp(player:get_hp() - 1)
		end

		if dps_count % cold_delay == 0 then
			counts =  find_nodes_in_area(minp, maxp, {"group:surface_cold"})
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

	last_dps_check = get_us_time()
	dps_count = dps_count - 1
end)


-- Exploding fungal fruit
minetest.register_abm({
	nodenames = {"fun_caves:fungal_tree_fruit"},
	interval = 20 * fun_caves.time_factor,
	chance = 14,
	catch_up = false,
	action = function(pos, node)
		fun_caves.soft_boom(pos)
	end
})

-- Exploding fungal fruit -- in a fire
minetest.register_abm({
	nodenames = {"fun_caves:fungal_tree_fruit"},
	neighbors = {"fire:basic_flame"},
	interval = 10 * fun_caves.time_factor,
	chance = 5,
	catch_up = false,
	action = function(pos, node)
		fun_caves.soft_boom(pos)
	end
})

-- mushroom growth -- small into huge
minetest.register_abm({
	nodenames = mushrooms,
	interval = 200 * fun_caves.time_factor,
	chance = 25,
	action = function(pos, node)
		local pos_up = {x=pos.x,y=pos.y+1,z=pos.z}
		local node_up = get_node_or_nil(pos_up)
		if not node_up then
			return
		end
		if node_up.name ~= "air" then
			return
		end
		local node_under = get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
		if not node_under then
			return
		end
		if get_item_group(node_under.name, "soil") ~= 0 and
				(get_node_light(pos_up, nil) or 99) <= fun_caves.light_max then
			set_node(pos_up, {name = "fun_caves:huge_mushroom_cap"})
			set_node(pos, {name = "fun_caves:giant_mushroom_stem"})
		end
	end
})

-- mushroom growth -- huge into giant
minetest.register_abm({
	nodenames = {"fun_caves:huge_mushroom_cap"},
	interval = 500 * fun_caves.time_factor,
	chance = 30,
	action = function(pos, node)
		if get_node_light(pos, nil) >= default.LIGHT_MAX - 2 then
			set_node(pos, {name = "air"})
			return
		end
		local pos_up = {x=pos.x,y=pos.y+1,z=pos.z}
		local node_up = get_node_or_nil(pos_up)
		if not node_up then
			return
		end
		if node_up.name ~= "air" then
			return
		end
		local node_under = get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
		if not node_under or node_under.name ~= "fun_caves:giant_mushroom_stem" then
			return
		end
		node_under = get_node_or_nil({x = pos.x, y = pos.y - 2, z = pos.z})
		if not node_under then
			return
		end
		if get_item_group(node_under.name, "soil") ~= 0 and
				(get_node_light(pos_up, nil) or 99) <= fun_caves.light_max then
			set_node(pos_up, {name = "fun_caves:giant_mushroom_cap"})
			set_node(pos, {name = "fun_caves:giant_mushroom_stem"})
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
		local node_up = get_node_or_nil(pos_up)
		if not node_up then
			return
		end
		if node_up.name ~= "air" then
			return
		end
		if (get_node_light(pos_up, nil) or 99) <= fun_caves.light_max then
			set_node(pos_up, {name = "fun_caves:huge_mushroom_cap"})
		end
	end
})

-- mushroom spread -- spores produce small mushrooms
minetest.register_abm({
	nodenames = {"fun_caves:giant_mushroom_cap", "fun_caves:huge_mushroom_cap"},
	interval = 15 * fun_caves.time_factor,
	chance = 10,
	action = function(pos, node)
		if get_node_light(pos, nil) >= default.LIGHT_MAX - 2 then
			set_node(pos, {name = "air"})
			return
		end
		local pos_down = pos
		pos_down.y = pos_down.y - 1
		local pos1, count = find_nodes_in_area_under_air(vector.subtract(pos_down, 4), vector.add(pos_down, 4), {"group:soil"})
		if #pos1 < 1 then
			return
		end
		local random = pos1[rand(1, #pos1)]
		random.y = random.y + 1
		if (get_node_light(random, nil) or 99) <= fun_caves.light_max then
			set_node(random, {name = mushrooms[rand(#mushrooms)]})
		end
	end
})

-- new mushrooms
minetest.register_abm({
	nodenames = {"default:dirt"},
	neighbors = {"air"},
	interval = 20 * fun_caves.time_factor,
	chance = 25,
	action = function(pos, node)
		if pos.y > 0 then
			return
		end

		local grow_pos = {x=pos.x, y=pos.y+1, z=pos.z}
		local grow_node = get_node_or_nil(grow_pos)
		if grow_node and grow_node.name == "air" then
			if (get_node_light(grow_pos, nil) or 99) <= fun_caves.light_max then
				set_node(grow_pos, {name = mushrooms[rand(#mushrooms)]})
				return
			end
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
			set_node(pos, {name=hot_spikes[spike_num+1]})
			return
		end

		local random = {
			x = pos.x + rand(-2, 2),
			y = pos.y + rand(-1, 1),
			z = pos.z + rand(-2, 2)
		}
		local random_node = get_node_or_nil(random)
		if not random_node or (random_node.name ~= "air" and random_node.name ~= "default:lava_source" and random_node.name ~= "default:lava_flowing") then
			return
		end
		local node_under = get_node_or_nil({x = random.x,
			y = random.y - 1, z = random.z})
		if not node_under then
			return
		end

		--print("node_under ("..random.x..","..(random.y-1)..","..random.z.."): "..node_under.name)
		if node_under.name == "fun_caves:hot_cobble" or node_under.name == "fun_caves:black_sand" then
			--print("setting ("..random.x..","..random.y..","..random.z.."): "..node_under.name)
			set_node(random, {name = hot_spikes[1]})
		end
	end
})


-- All of this is copied from TNT, but modified to leave stone intact.

-- Fill a list with data for content IDs, after all nodes are registered
local cid_data = {}
minetest.after(0, function()
	for name, def in pairs(minetest.registered_nodes) do
		cid_data[minetest.get_content_id(name)] = {
			name = name,
			--drops = def.drops,
			flammable = def.groups.flammable,
			choppy = def.groups.choppy,
			fleshy = def.groups.fleshy,
			snappy = def.groups.snappy,
			on_blast = def.on_blast,
		}
	end
end)

local function add_effects(pos, radius)
	minetest.add_particlespawner({
		amount = 128,
		time = 1,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x=-20, y=-20, z=-20},
		maxvel = {x=20,  y=20,  z=20},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 3,
		minsize = 8,
		maxsize = 16,
		texture = "tnt_smoke.png",
	})
end

local function destroy(pos, cid)
	if minetest.is_protected(pos, "") then
		return
	end
	local def = cid_data[cid]
	if def and def.on_blast then
		def.on_blast(vector.new(pos), 1)
		return
	end
	if def.snappy == nil and def.choppy == nil and def.fleshy == nil and def.name ~= "fire:basic_flame" then
		return
	end
	local new = "air"
	--if rand(1,2) == 1 then
	if true then
		local node_under = get_node_or_nil({x = pos.x,
			y = pos.y - 1, z = pos.z})
		if node_under and node_under.name ~= "air" then
			--new = node.name
		end
	end
	set_node(pos, {name=new})
end

local function explode(pos, radius)
	local pos = vector.round(pos)
	local vm = VoxelManip()
	local p1 = vector.subtract(pos, radius)
	local p2 = vector.add(pos, radius)
	local minp, maxp = vm:read_from_map(p1, p2)
	local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()

	local drops = {}
	local p = {}

	local c_air = minetest.get_content_id("air")

	for z = -radius, radius do
	for y = -radius, 4*radius do
	local vi = a:index(pos.x + (-radius), pos.y + y, pos.z + z)
	for x = -radius, radius do
		if (x * x) + (y * y / 4) + (z * z) <=
				(radius * radius) + rand(-radius, radius) then
			local cid = data[vi]
			p.x = pos.x + x
			p.y = pos.y + y
			p.z = pos.z + z
			if cid ~= c_air then
				destroy(p, cid)
			end
		end
		vi = vi + 1
	end
	end
	end
end

local function calc_velocity(pos1, pos2, old_vel, power)
	local vel = vector.direction(pos1, pos2)
	vel = vector.normalize(vel)
	vel = vector.multiply(vel, power)

	-- Divide by distance
	local dist = vector.distance(pos1, pos2)
	dist = max(dist, 1)
	vel = vector.divide(vel, dist)

	-- Add old velocity
	vel = vector.add(vel, old_vel)
	return vel
end

local function entity_physics(pos, radius)
	-- Make the damage radius larger than the destruction radius
	radius = radius * 2
	local objs = minetest.get_objects_inside_radius(pos, radius)
	for _, obj in pairs(objs) do
		local obj_pos = obj:getpos()
		local obj_vel = obj:getvelocity()
		local dist = max(1, vector.distance(pos, obj_pos))

		if obj_vel ~= nil then
			obj:setvelocity(calc_velocity(pos, obj_pos,
					obj_vel, radius * 10))
		end

		local damage = (4 / dist) * radius
		obj:set_hp(obj:get_hp() - damage)
	end
end

fun_caves.soft_boom = function(pos)
	if not pos then
		return
	end

	local node = get_node_or_nil(pos)
	if not node then
		return
	end

	minetest.sound_play("tnt_explode", {pos=pos, gain=1.5, max_hear_distance=2*64})
	local radius = 5
	set_node(pos, {name="air"})
	explode(pos, radius)
	entity_physics(pos, radius)
	add_effects(pos, radius)
end

--local function burn(pos)
--	minetest.get_node_timer(pos):start(1)
--end


-----------------------------------------------
-- testing only -- remove before distribution
-----------------------------------------------
-- Mushroom spread and death
--minetest.register_abm({
--	nodenames = mushrooms,
--	interval = 1 * fun_caves.time_factor,
--	chance = 50,
--	action = function(pos, node)
--		if get_node_light(pos, nil) >= default.LIGHT_MAX - 2 then
--			remove_node(pos)
--			return
--		end
--		local random = {
--			x = pos.x + rand(-2, 2),
--			y = pos.y + rand(-1, 1),
--			z = pos.z + rand(-2, 2)
--		}
--		local random_node = get_node_or_nil(random)
--		if not random_node or random_node.name ~= "air" then
--			return
--		end
--		local node_under = get_node_or_nil({x = random.x,
--			y = random.y - 1, z = random.z})
--		if not node_under then
--			return
--		end
--
--		if (get_item_group(node_under.name, "soil") ~= 0 or
--				get_item_group(node_under.name, "tree") ~= 0) and
--				get_node_light(pos, 0.5) <= fun_caves.light_max and
--				get_node_light(random, 0.5) <= fun_caves.light_max then
--			set_node(random, {name = node.name})
--		end
--	end
--})
