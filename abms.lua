-- see also, fungal_tree.lua

-- player surface damage and hunger
local dps_delay = 3000000
if fun_caves.DEBUG then
	local dps_delay = 1000000
end

local last_dps_check = 0
local cold_delay = 5
local monster_delay = 3
local hunger_delay = 60
local dps_count = hunger_delay
-- maximum number of mobs near player in fortresses
local fortress_mob_count = 5
local players_in_orbit = {}

local mushrooms = {"flowers:mushroom_brown", "flowers:mushroom_red"}
local hunger_mod = minetest.get_modpath("hunger")


-- fungal tree nodes
local fungal_tree_leaves = {}
for i = 1, 4 do
	fungal_tree_leaves[#fungal_tree_leaves+1] = "fun_caves:fungal_tree_leaves_"..i
end

local leaves = {}
for _, leaf in pairs(fungal_tree_leaves) do
	leaves[leaf] = true
end

-- hot spike parameters
local spike_air = {}
spike_air['default:lava_source'] = true
spike_air['default:lava_source'] = true
spike_air['default:lava_flowing'] = true

local spike_soil = {}
spike_soil['fun_caves:hot_cobble'] = true
spike_soil['fun_caves:black_sand'] = true


------------------------------------------------------------
-- all the fun_caves globalstep functions
------------------------------------------------------------
minetest.register_globalstep(function(dtime)
	local time = minetest.get_us_time()

	-- Execute only after an interval.
	if last_dps_check and time - last_dps_check < dps_delay then
		return
	end

	-- Promote mobs based on spawn position
	for _, mob in pairs(minetest.luaentities) do
		if not mob.initial_promotion then
			local pos = mob.object:getpos()
			if mob.hp_max and mob.object and mob.health and mob.damage then
				local factor = 1 + (math.max(math.abs(pos.x), math.abs(pos.y), math.abs(pos.z)) / 6200)
				if fun_caves.is_fortress(pos) then
					mob.started_in_fortress = true
					factor = factor * 1.5
				end
				mob.hp_max = math.floor(mob.hp_max * factor)
				mob.damage = math.floor(mob.damage * factor)
				if fun_caves.DEBUG then
					print("Promoting "..mob.name..": "..mob.hp_max.." at "..pos.x..","..pos.y..","..pos.z)
				end
				mob.object:set_hp(mob.hp_max)
				mob.health = mob.hp_max
				mob.initial_promotion = true
				check_for_death(mob)
			end
		end
	end

	-- Spawn mobs in fortresses -- only when a player is near
	local players = minetest.get_connected_players()
	for i = 1, #players do
		local player = players[i]
		local pos = player:getpos()

		-- How many mobs are up at the moment? This is a rough check.
		if fun_caves.fortress_spawns and #fun_caves.fortress_spawns > 0 and dps_count % monster_delay == 0 then
			local mob_count = 0
			for _, mob in pairs(minetest.luaentities) do
				if mob.health and mob.started_in_fortress then
					local dist = vector.subtract(pos, mob.object:getpos())
					local dist2 = math.max(math.abs(dist.x), math.abs(dist.y * 5), math.abs(dist.z))
					if dist2 < 30 then
						mob_count = mob_count + 1
					end
				end
			end

			-- If we need more, spawn them.
			if mob_count < fortress_mob_count then
				local floor_nodes, count = minetest.find_nodes_in_area_under_air({x=pos.x-30, y=pos.y-2, z=pos.z-30}, {x=pos.x+30, y=pos.y+2, z=pos.z+30}, {"group:fortress"})
				if #floor_nodes > 0 then
					local new_mob_pos = floor_nodes[math.random(#floor_nodes)]
					new_mob_pos.y = new_mob_pos.y + 2
					--------------------------------------
					-- Mobs are treated exacty the same. Spawn harder ones differently?
					--------------------------------------
					local name = fun_caves.fortress_spawns[math.random(#fun_caves.fortress_spawns)]
					local mob = minetest.add_entity(new_mob_pos, name)
					if mob then
						print("Fun Caves: Spawned "..name.." at ("..new_mob_pos.x..","..new_mob_pos.y..","..new_mob_pos.z..")")
					else
						print("Fun Caves: failed to spawn "..name)
					end
				end
			end
		end

		if pos.y >= 11168 and pos.y <= 15168 then
			if not players_in_orbit[player:get_player_name()] then
				player:set_physics_override({gravity=0.1})
				player:set_sky("#000000", "plain", {})
				players_in_orbit[player:get_player_name()] = true
			end
		elseif players_in_orbit[player:get_player_name()] then
			player:set_sky("#000000", "regular", {})
			minetest.after(20, function()
				player:set_physics_override({gravity=1})
			end)
			players_in_orbit[player:get_player_name()] = false
		end

		-- environmental damage
		if fun_caves.DEBUG and player:get_hp() < 20 then
			-- Regenerate the player while testing.
			print("HP: "..player:get_hp())
			player:set_hp(20)
			return
		else
			local minp = vector.subtract(pos, 0.5)
			local maxp = vector.add(pos, 0.5)

			-- ... from standing on or near hot objects.
			local counts =  minetest.find_nodes_in_area(minp, maxp, {"group:surface_hot"})
			if #counts > 1 then
				player:set_hp(player:get_hp() - 1)
			end

			-- ... from standing on or near poison.
			local counts =  minetest.find_nodes_in_area(minp, maxp, {"group:poison"})
			if #counts > 1 then
				player:set_hp(player:get_hp() - 1)
			end

			-- ... from standing on or near cold objects (less often).
			if dps_count % cold_delay == 0 then
				counts =  minetest.find_nodes_in_area(minp, maxp, {"group:surface_cold"})
				if #counts > 1 then
					player:set_hp(player:get_hp() - 1)
				end
			end

			-- ... from hunger (even less often).
			if dps_count % hunger_delay == 0 then
				if hunger_mod then
					hunger.update_hunger(player, hunger.players[player:get_player_name()].lvl - 4)
				else
					player:set_hp(player:get_hp() - 1)
				end
			end
		end
	end

	-- Set this outside of the player loop, to affect everyone.
	if dps_count % hunger_delay == 0 then
		dps_count = hunger_delay
	end

	last_dps_check = minetest.get_us_time()
	dps_count = dps_count - 1
end)


------------------------------------------------------------
-- destruction
------------------------------------------------------------

-- Exploding fungal fruit
minetest.register_abm({
	nodenames = {"fun_caves:fungal_tree_fruit"},
	interval = 20 * fun_caves.time_factor,
	chance = 15,
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

-- giant/huge mushroom "leaf decay"
-- This should be more efficient than the normal leaf decay,
-- since it only checks below the node.
minetest.register_abm({
	nodenames = {"fun_caves:giant_mushroom_cap", "fun_caves:huge_mushroom_cap"},
	interval = 5 * fun_caves.time_factor,
	chance = 5,
	action = function(pos, node)
		-- Check for stem under the cap.
		local node_under = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
		if not node_under or node_under.name ~= "fun_caves:giant_mushroom_stem" then
			minetest.set_node(pos, {name = "air"})
			return
		end
	end
})

-- Destroy mushroom caps in the light.
minetest.register_abm({
	nodenames = {"fun_caves:giant_mushroom_cap", "fun_caves:huge_mushroom_cap"},
	interval = 15 * fun_caves.time_factor,
	chance = 15,
	action = function(pos, node)
		if (minetest.get_node_light(pos, nil) or 99) >= fun_caves.light_max + 2 then
			minetest.set_node(pos, {name = "air"})
			return
		end
	end
})

------------------------------------------------------------
-- creation
------------------------------------------------------------

-- vacuum sucks
minetest.register_abm({
	nodenames = {"fun_caves:vacuum"},
	neighbors = {"air"},
	interval = fun_caves.time_factor,
	chance = 1,
	action = function(pos, node)
		if pos.y <= 11168 or pos.y >= 15168 then
			return
		end

		local p1 = vector.subtract(pos, 1)
		local p2 = vector.add(pos, 1)
		local positions =  minetest.find_nodes_in_area(p1, p2, {"air"})
		for _, p3 in pairs(positions) do
			local node2 = minetest.get_node_or_nil(p3)
			if node2 and node2.name == 'air' then
				minetest.set_node(p3, {name = 'fun_caves:vacuum'})
			end
		end
	end
})

-- fungal spread
minetest.register_abm({
	nodenames = fungal_tree_leaves,
	neighbors = {"air", "group:liquid"},
	interval = 5 * fun_caves.time_factor,
	chance = 10,
	catch_up = false,
	action = function(pos, node)
		if (minetest.get_node_light(pos, nil) or 99) >= fun_caves.light_max + 2 then
			minetest.remove_node(pos)
			return
		end

		local grow_pos = {x=pos.x, y=pos.y-1, z=pos.z}
		local grow_node = minetest.get_node_or_nil(grow_pos)
		if grow_node and grow_node.name == "air" then
			minetest.set_node(grow_pos, {name = node.name})
			return
		end

		grow_pos = {x=math.random(-1,1)+pos.x, y=math.random(-1,1)+pos.y, z=math.random(-1,1)+pos.z}
		grow_node = minetest.get_node_or_nil(grow_pos)
		if grow_node and grow_node.name == "air" and (minetest.get_node_light(grow_pos, nil) or 99) <= fun_caves.light_max then
			minetest.set_node(grow_pos, {name = node.name})
			return
		elseif grow_node and leaves[grow_node.name] and grow_node.name ~= node.name then
			minetest.set_node(grow_pos, {name = 'air'})
			return
		end

		if math.random(40) == 1 then
			minetest.set_node(pos, {name = "fun_caves:fungal_tree_fruit"})
			return
		end

		if math.random(100) == 1 then
			minetest.set_node(pos, {name = fungal_tree_leaves[math.random(#fungal_tree_leaves)]})
			return
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
		if not node_up or node_up.name ~= "air" then
			return
		end

		if (minetest.get_node_light(pos_up, nil) or 99) <= fun_caves.light_max then
			minetest.set_node(pos_up, {name = "fun_caves:huge_mushroom_cap"})
		end
	end
})

-- new fungi
minetest.register_abm({
	nodenames = {"default:dirt"},
	neighbors = {"air"},
	interval = 10 * fun_caves.time_factor,
	chance = 15,
	action = function(pos, node)
		if pos.y > 0 then
			return
		end

		local grow_pos = {x=pos.x, y=pos.y+1, z=pos.z}
		local grow_node = minetest.get_node_or_nil(grow_pos)
		if grow_node and grow_node.name == "air"
				and (minetest.get_node_light(grow_pos, nil) or 99) <= fun_caves.light_max then
			if math.random(4) == 1 then
				minetest.set_node(grow_pos, {name = fungal_tree_leaves[math.random(#fungal_tree_leaves)]})
			else
				minetest.set_node(grow_pos, {name = mushrooms[math.random(#mushrooms)]})
			end
		end
	end
})

-- mushroom growth -- small into huge
minetest.register_abm({
	nodenames = mushrooms,
	interval = 75 * fun_caves.time_factor,
	chance = 25,
	action = function(pos, node)
		-- Clumsy, but it's the best way to limit them to caves.
		if pos.y > 0 then
			return
		end

		local pos_up = {x=pos.x,y=pos.y+1,z=pos.z}
		local node_up = minetest.get_node_or_nil(pos_up)
		if not node_up or node_up.name ~= "air" then
			return
		end

		local node_under = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
		if not node_under
				or minetest.get_item_group(node_under.name, "soil") == 0
				or (minetest.get_node_light(pos_up, nil) or 99) > fun_caves.light_max then
			return
		end

		minetest.set_node(pos_up, {name = "fun_caves:huge_mushroom_cap"})
		minetest.set_node(pos, {name = "fun_caves:giant_mushroom_stem"})
	end
})

-- mushroom growth -- huge into giant
minetest.register_abm({
	nodenames = {"fun_caves:huge_mushroom_cap"},
	interval = 300 * fun_caves.time_factor,
	chance = 30,
	action = function(pos, node)
		local pos_up = {x=pos.x,y=pos.y+1,z=pos.z}
		local node_up = minetest.get_node_or_nil(pos_up)
		if not node_up or node_up.name ~= "air" then
			return
		end

		-- Check for soil.
		node_under = minetest.get_node_or_nil({x = pos.x, y = pos.y - 2, z = pos.z})
		if not node_under
				or minetest.get_item_group(node_under.name, "soil") == 0
				or (minetest.get_node_light(pos_up, nil) or 99) > fun_caves.light_max then
			return
		end

		minetest.set_node(pos_up, {name = "fun_caves:giant_mushroom_cap"})
		minetest.set_node(pos, {name = "fun_caves:giant_mushroom_stem"})
	end
})

-- Spike spread and death
minetest.register_abm({
	nodenames = fun_caves.hot_spikes,
	interval = 30 * fun_caves.time_factor,
	chance = 30,
	action = function(pos, node)
		if not fun_caves.hot_spike then
			return
		end
		local spike_num = fun_caves.hot_spike[node.name]
		if not spike_num then
			return
		end

		if spike_num < #fun_caves.hot_spikes then
			minetest.set_node(pos, {name=fun_caves.hot_spikes[spike_num+1]})
			return
		end

		local new_pos = {
			x = pos.x + math.random(-2, 2),
			y = pos.y + math.random(-1, 1),
			z = pos.z + math.random(-2, 2)
		}
		local new_node = minetest.get_node_or_nil(new_pos)
		if not (new_node and spike_air[new_node.name]) then
			return
		end

		local node_under = minetest.get_node_or_nil({x = new_pos.x, y = new_pos.y - 1, z = new_pos.z})
		if not (node_under and spike_soil[node_under.name]) then
			return
		end

		minetest.set_node(new_pos, {name = hot_spikes[1]})
	end
})


------------------------------------------------------------
-- meteors
------------------------------------------------------------

-- meteor strikes
minetest.register_abm({
	nodenames = {"default:dirt_with_grass", "default:dirt_with_dry_grass"},
	neighbors = {"air"},
	interval = 1000000 * fun_caves.time_factor,
	catch_up = false,
	chance = 30000,
	action = function(pos, node)
		local ps = {}
		local players = minetest.get_connected_players()
		for i = 1, #players do
			local pp = players[i]:getpos()
			if pp and pp.y > 0 then
				local sky = {}
				sky.bgcolor, sky.type, sky.textures = players[i]:get_sky()
				ps[#ps+1] = { p = players[i], sky = sky }
				players[i]:set_sky(0xffffff, "plain", {})
			end
		end

		minetest.set_node(pos, {name="fun_caves:meteorite_crater"})
		print('Fun Caves: meteorite impact '..pos.x..','..pos.y..','..pos.z)

		minetest.after(1, function()
			for i = 1, #ps do
				ps[i].p:set_sky(ps[i].sky.bgcolor, ps[i].sky.type, ps[i].sky.textures)
			end
		end)
	end
})

-- Remove old craters.
minetest.register_abm({
	nodenames = {"fun_caves:meteorite_crater"},
	interval = 100 * fun_caves.time_factor,
	chance = 10,
	action = function(pos, node)
		minetest.set_node(pos, {name="default:dirt"})
	end
})


------------------------------------------------------------
-- explosive functions
------------------------------------------------------------

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
	local def = cid_data[cid]
	if not def or minetest.is_protected(pos, "") then
		return
	end

	if def.on_blast then
		def.on_blast(vector.new(pos), 1)
		return
	end

	if def.snappy == nil and def.choppy == nil and def.fleshy == nil and def.name ~= "fire:basic_flame" then
		return
	end

	minetest.set_node(pos, {name="air"})
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
				(radius * radius) + math.random(-radius, radius) then
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
	dist = math.max(dist, 1)
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
		local dist = math.max(1, vector.distance(pos, obj_pos))

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

	local node = minetest.get_node_or_nil(pos)
	if not node then
		return
	end

	minetest.sound_play("tnt_explode", {pos=pos, gain=1.5, max_hear_distance=2*64})
	local radius = 5
	minetest.set_node(pos, {name="air"})
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
--		if minetest.get_node_light(pos, nil) >= fun_caves.light_max + 2 then
--			minetest.remove_node(pos)
--			return
--		end
--		local random = {
--			x = pos.x + math.random(-2, 2),
--			y = pos.y + math.random(-1, 1),
--			z = pos.z + math.random(-2, 2)
--		}
--		local random_node = minetest.get_node_or_nil(random)
--		if not random_node or random_node.name ~= "air" then
--			return
--		end
--		local node_under = minetest.get_node_or_nil({x = random.x,
--			y = random.y - 1, z = random.z})
--		if not node_under then
--			return
--		end
--
--		if (minetest.get_item_group(node_under.name, "soil") ~= 0 or
--				minetest.get_item_group(node_under.name, "tree") ~= 0) and
--				minetest.get_node_light(pos, 0.5) <= fun_caves.light_max and
--				minetest.get_node_light(random, 0.5) <= fun_caves.light_max then
--			minetest.set_node(random, {name = node.name})
--		end
--	end
--})
