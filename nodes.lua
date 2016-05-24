local light_max = 13

minetest.add_group("default:ice", {surface_cold = 3})

--thin (transparent) ice
minetest.register_node("fun_caves:thin_ice", {
	description = "Thin Ice",
	tiles = {"caverealms_thin_ice.png"},
	is_ground_content = true,
	groups = {cracky=3},
	sounds = default.node_sound_glass_defaults(),
	use_texture_alpha = true,
	light_source = 1,
	drawtype = "glasslike",
	sunlight_propagates = true,
	freezemelt = "default:water_source",
	paramtype = "light",
})

minetest.register_node("fun_caves:huge_mushroom_cap", {
	description = "Huge Mushroom Cap",
	tiles = {"vmg_mushroom_giant_cap.png", "vmg_mushroom_giant_under.png", "vmg_mushroom_giant_cap.png"},
	is_ground_content = false,
	paramtype = "light",
	drawtype = "nodebox",
	node_box = { type = "fixed", 
		fixed = {
			{-0.5, -0.5, -0.33, 0.5, -0.33, 0.33}, 
			{-0.33, -0.5, 0.33, 0.33, -0.33, 0.5}, 
			{-0.33, -0.5, -0.33, 0.33, -0.33, -0.5}, 
			{-0.33, -0.33, -0.33, 0.33, -0.17, 0.33}, 
		} },
	light_source = 11,
	groups = {fleshy=1, dig_immediate=3, flammable=2, plant=1, leafdecay=1},
})

minetest.register_node("fun_caves:giant_mushroom_cap", {
	description = "Giant Mushroom Cap",
	tiles = {"vmg_mushroom_giant_cap.png", "vmg_mushroom_giant_under.png", "vmg_mushroom_giant_cap.png"},
	is_ground_content = false,
	paramtype = "light",
	drawtype = "nodebox",
	node_box = { type = "fixed", 
		fixed = {
			{-0.4, -0.5, -0.4, 0.4, 0.0, 0.4},
			{-0.75, -0.5, -0.4, -0.4, -0.25, 0.4},
			{0.4, -0.5, -0.4, 0.75, -0.25, 0.4},
			{-0.4, -0.5, -0.75, 0.4, -0.25, -0.4},
			{-0.4, -0.5, 0.4, 0.4, -0.25, 0.75},
		} },
	light_source = 14,
	groups = {fleshy=1, dig_immediate=3, flammable=2, plant=1, leafdecay=1},
})

minetest.register_node("fun_caves:giant_mushroom_stem", {
	description = "Giant Mushroom Stem",
	tiles = {"vmg_mushroom_giant_stem.png", "vmg_mushroom_giant_stem.png", "vmg_mushroom_giant_stem.png"},
	is_ground_content = false,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2, plant=1},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	drawtype = "nodebox",
	node_box = { type = "fixed", fixed = { {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}, }},
})

-- Mushroom stems can be used as wood, ala Journey to the Center of the Earth.
minetest.register_craft({
	output = "default:wood",
	recipe = {
		{"fun_caves:giant_mushroom_stem"}
	}
})

minetest.register_craft({
	output = "mobs:leather",
	recipe = {
		{"fun_caves:giant_mushroom_cap"}
	}
})

minetest.register_craft({
	output = "dye:red",
	recipe = {
		{"flowers:mushroom_red"}
	}
})

--minetest.register_craft({
--	output = "dye:yellow",
--	recipe = {
--		{"flowers:mushroom_brown"}
--	}
--})

-- Caps can be cooked and eaten.
minetest.register_node("fun_caves:mushroom_steak", {
	description = "Mushroom Steak",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"vmg_mushroom_steak.png"},
	inventory_image = "vmg_mushroom_steak.png",
	on_use = minetest.item_eat(4),
	groups = {dig_immediate = 3, attached_node = 1},
})

minetest.register_craft({
	type = "cooking",
	output = "fun_caves:mushroom_steak",
	recipe = "fun_caves:huge_mushroom_cap",
	cooktime = 2,
})

minetest.register_craft({
	type = "cooking",
	output = "fun_caves:mushroom_steak 2",
	recipe = "fun_caves:giant_mushroom_cap",
	cooktime = 2,
})

-- Glowing fungal stone provides an eerie light.
minetest.register_node("fun_caves:glowing_fungal_stone", {
	description = "Glowing Fungal Stone",
	tiles = {"default_stone.png^vmg_glowing_fungal.png",},
	is_ground_content = true,
	light_source = 6,
	groups = {cracky=3, stone=1},
	drop = {items={ {items={"default:cobble"},}, {items={"fun_caves:glowing_fungus",},},},},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("fun_caves:glowing_fungus", {
	description = "Glowing Fungus",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"vmg_glowing_fungus.png"},
	inventory_image = "vmg_glowing_fungus.png",
	groups = {dig_immediate = 3, attached_node = 1},
})

-- The fungus can be made into juice and then into glowing glass.
minetest.register_node("fun_caves:moon_juice", {
	description = "Moon Juice",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"vmg_moon_juice.png"},
	inventory_image = "vmg_moon_juice.png",
	groups = {dig_immediate = 3, attached_node = 1},
	sounds = default.node_sound_glass_defaults(),
})

local newnode = fun_caves.clone_node("default:glass")
newnode.light_source = default.LIGHT_MAX
minetest.register_node("fun_caves:moon_glass", newnode)

minetest.register_craft({
	output = "fun_caves:moon_juice",
	recipe = {
		{"fun_caves:glowing_fungus", "fun_caves:glowing_fungus", "fun_caves:glowing_fungus"},
		{"fun_caves:glowing_fungus", "fun_caves:glowing_fungus", "fun_caves:glowing_fungus"},
		{"fun_caves:glowing_fungus", "vessels:glass_bottle", "fun_caves:glowing_fungus"},
	},
})

minetest.register_craft({
	output = "fun_caves:moon_glass",
	type = "shapeless",
	recipe = {
		"fun_caves:moon_juice",
		"fun_caves:moon_juice",
		"default:glass",
	},
})

-- What's a cave without speleothems?
local spel = {
	{type1="stalactite", type2="stalagmite", tile="default_stone.png"},
	{type1="stalactite_slimy", type2="stalagmite_slimy", tile="default_stone.png^fun_caves_algae.png"},
	{type1="stalactite_mossy", type2="stalagmite_mossy", tile="default_stone.png^fun_caves_moss.png"},
	{type1="icicle_down", type2="icicle_up", desc="Icicle", tile="caverealms_thin_ice.png", drop="default:ice"},
}

for _, desc in pairs(spel) do
	minetest.register_node("fun_caves:"..desc.type1, {
		description = (desc.desc or "Stalactite"),
		tiles = {desc.tile},
		is_ground_content = true,
		walkable = false,
		paramtype = "light",
		drop = (desc.drop or "fun_caves:stalactite"),
		drawtype = "nodebox",
		node_box = { type = "fixed", 
			fixed = {
				{-0.07, 0.0, -0.07, 0.07, 0.5, 0.07}, 
				{-0.04, -0.25, -0.04, 0.04, 0.0, 0.04}, 
				{-0.02, -0.5, -0.02, 0.02, 0.25, 0.02}, 
			} },
		groups = {rock=1, cracky=3},
		sounds = default.node_sound_stone_defaults(),
	})

	minetest.register_node("fun_caves:"..desc.type2, {
		description = (desc.desc or "Stalagmite"),
		tiles = {desc.tile},
		is_ground_content = true,
		walkable = false,
		paramtype = "light",
		drop = "fun_caves:stalagmite",
		drawtype = "nodebox",
		node_box = { type = "fixed", 
			fixed = {
				{-0.07, -0.5, -0.07, 0.07, 0.0, 0.07}, 
				{-0.04, 0.0, -0.04, 0.04, 0.25, 0.04}, 
				{-0.02, 0.25, -0.02, 0.02, 0.5, 0.02}, 
			} },
		groups = {rock=1, cracky=3},
		sounds = default.node_sound_stone_defaults(),
	})
end

-- They can be made into cobblestone, to get them out of inventory.
minetest.register_craft({
	output = "default:cobble",
	recipe = {
		{"", "", ""},
		{"fun_caves:stalactite", "fun_caves:stalactite", ""},
		{"fun_caves:stalactite", "fun_caves:stalactite", ""},
	},
})

minetest.register_craft({
	output = "default:cobble",
	recipe = {
		{"", "", ""},
		{"fun_caves:stalagmite", "fun_caves:stalagmite", ""},
		{"fun_caves:stalagmite", "fun_caves:stalagmite", ""},
	},
})

newnode = fun_caves.clone_node("default:dirt")
newnode.description = "Glowing Dirt"
newnode.light_source = default.LIGHT_MAX
newnode.soil = {
	base = "fun_caves:glowing_dirt",
	dry = "fun_caves:glowing_soil",
	wet = "fun_caves:glowing_soil_wet"
}
minetest.register_node("fun_caves:glowing_dirt", newnode)

newnode = fun_caves.clone_node("farming:soil")
newnode.description = "Glowing Soil"
newnode.light_source = default.LIGHT_MAX
newnode.soil = {
	base = "fun_caves:glowing_dirt",
	dry = "fun_caves:glowing_soil",
	wet = "fun_caves:glowing_soil_wet"
}
minetest.register_node("fun_caves:glowing_dirt", newnode)

newnode = fun_caves.clone_node("farming:soil_wet")
newnode.description = "Wet Glowing Soil"
newnode.light_source = default.LIGHT_MAX
newnode.soil = {
	base = "fun_caves:glowing_dirt",
	dry = "fun_caves:glowing_soil",
	wet = "fun_caves:glowing_soil_wet"
}
minetest.register_node("fun_caves:glowing_dirt", newnode)

minetest.register_craft({
	output = "fun_caves:glowing_dirt",
	type = "shapeless",
	recipe = {
		"fun_caves:moon_juice",
		"default:dirt",
	},
})

--thin (transparent) ice
minetest.register_node("fun_caves:thin_ice", {
	description = "Thin Ice",
	tiles = {"caverealms_thin_ice.png"},
	is_ground_content = true,
	groups = {cracky=3},
	sounds = default.node_sound_glass_defaults(),
	use_texture_alpha = true,
	drawtype = "glasslike",
	sunlight_propagates = true,
	freezemelt = "default:water_source",
	paramtype = "light",
})

newnode = fun_caves.clone_node("default:stone")
newnode.description = "Cave Stone With Moss"
newnode.tiles = {"default_stone.png^fun_caves_moss.png"}
newnode.groups = {stone=1, crumbly=3}
newnode.sounds = default.node_sound_dirt_defaults({
	footstep = {name="default_grass_footstep", gain=0.25},
})
minetest.register_node("fun_caves:stone_with_moss", newnode)

newnode = fun_caves.clone_node("default:stone")
newnode.description = "Cave Stone With Lichen"
newnode.tiles = {"default_stone.png^fun_caves_lichen.png"}
newnode.groups = {stone=1, crumbly=3}
newnode.sounds = default.node_sound_dirt_defaults({
	footstep = {name="default_grass_footstep", gain=0.25},
})
minetest.register_node("fun_caves:stone_with_lichen", newnode)

newnode = fun_caves.clone_node("default:stone")
newnode.description = "Cave Stone With Algae"
newnode.tiles = {"default_stone.png^fun_caves_algae.png"}
newnode.groups = {stone=1, crumbly=3}
newnode.sounds = default.node_sound_dirt_defaults({
	footstep = {name="default_grass_footstep", gain=0.25},
})
minetest.register_node("fun_caves:stone_with_algae", newnode)

minetest.register_node("fun_caves:stone_with_salt", {
	description = "Cave Stone with Salt",
	tiles = {"caverealms_salty2.png"},
	paramtype = "light",
	use_texture_alpha = true,
	drawtype = "glasslike",
	sunlight_propagates = false,
	is_ground_content = true,
	groups = {stone=1, crumbly=3},
	sounds = default.node_sound_glass_defaults(),
})
newnode = fun_caves.clone_node("fun_caves:stone_with_salt")
newnode.description = "Salt With Radioactive Ore"
newnode.tiles = {"caverealms_salty2.png^[colorize:#004000:250"}
newnode.light_source = 4
minetest.register_node("fun_caves:radioactive_ore", newnode)


--Glow Obsidian
minetest.register_node("fun_caves:glow_obsidian", {
	description = "Glowing Obsidian",
	tiles = {"caverealms_glow_obsidian.png"},
	is_ground_content = true,
	groups = {stone=2, crumbly=1},
	--light_source = 7,
	sounds = default.node_sound_stone_defaults({
		footstep = {name="default_stone_footstep", gain=0.25},
	}),
})

--Glow Obsidian 2 - has traces of lava
minetest.register_node("fun_caves:glow_obsidian_2", {
	description = "Hot Glow Obsidian",
	tiles = {"caverealms_glow_obsidian2.png"},
	is_ground_content = true,
	groups = {stone=2, crumbly=1, surface_hot=3, igniter=1},
	damage_per_second = 1,
	--light_source = 9,
	sounds = default.node_sound_stone_defaults({
		footstep = {name="default_stone_footstep", gain=0.25},
	}),
})


--minetest.register_node("fun_caves:bright_air", {
--	drawtype = "glasslike",
--	tiles = {"technic_light.png"},
--	paramtype = "light",
--	groups = {not_in_creative_inventory=1},
--	drop = "",
--	walkable = false,
--	buildable_to = true,
--	sunlight_propagates = true,
--	light_source = LIGHT_MAX,
--	pointable = false,
--})

--define special flame so that it does not expire
minetest.register_node("fun_caves:constant_flame", {
	description = "Fire",
	drawtype = "plantlike",
	tiles = {{
		name="fire_basic_flame_animated.png",
		animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},
	}},
	inventory_image = "fire_basic_flame.png",
	light_source = 14,
	groups = {igniter=2,dig_immediate=3,hot=3, not_in_creative_inventory=1},
	drop = '',
	walkable = false,
	buildable_to = true,
	damage_per_second = 4,
})

--Hot Cobble - cobble with lava instead of mortar XD
minetest.register_node("fun_caves:hot_cobble", {
	description = "Hot Cobble",
	tiles = {"caverealms_hot_cobble.png"},
	is_ground_content = true,
	groups = {crumbly=2, surface_hot=3},
	--light_source = 2,
	damage_per_second = 1,
	sounds = default.node_sound_stone_defaults({
		footstep = {name="default_stone_footstep", gain=0.25},
	}),
})

local last_dps_check = 0
minetest.register_globalstep(function(dtime)
	last_dps_check = last_dps_check + 1
	if last_dps_check > 20000 then
		last_dps_check = 0
	end

	if last_dps_check % 20 == 0 then
		for id, player in pairs(minetest.get_connected_players()) do
			local minp = vector.subtract(player:getpos(), 0.5)
			local maxp = vector.add(player:getpos(), 0.5)

			local counts =  minetest.find_nodes_in_area(minp, maxp, {"group:surface_hot"})
			if #counts > 1 then
				player:set_hp(player:get_hp() - 1)
			end

			if last_dps_check % 200 == 0 then
				local counts =  minetest.find_nodes_in_area(minp, maxp, {"group:surface_cold"})
				if #counts > 1 then
					player:set_hp(player:get_hp() - 1)
				end
			end

			-- hunger
			if last_dps_check % 2000 == 0 then
				player:set_hp(player:get_hp() - 1)
			end
		end
	end
end)

-- mushroom growth
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
				minetest.get_node_light(pos_up, nil) <= light_max then
			minetest.set_node(pos_up, {name = "fun_caves:huge_mushroom_cap"})
			minetest.set_node(pos, {name = "fun_caves:giant_mushroom_stem"})
		end
	end
})

-- mushroom growth
minetest.register_abm({
	nodenames = {"fun_caves:huge_mushroom_cap"},
	interval = 500 * fun_caves.time_factor,
	chance = 30,
	action = function(pos, node)
		if minetest.get_node_light(pos, nil) >= 14 then
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
				minetest.get_node_light(pos_up, nil) <= light_max then
			minetest.set_node(pos_up, {name = "fun_caves:giant_mushroom_cap"})
			minetest.set_node(pos, {name = "fun_caves:giant_mushroom_stem"})
		end
	end
})

-- mushroom growth
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
		if minetest.get_node_light(pos_up, nil) <= light_max then
			minetest.set_node(pos_up, {name = "fun_caves:huge_mushroom_cap"})
		end
	end
})

-- mushroom spread
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
		if minetest.get_node_light(random, nil) <= light_max then
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
		if minetest.get_node_light(pos, nil) == 15 then
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
				minetest.get_node_light(pos, 0.5) <= light_max and
				minetest.get_node_light(random, 0.5) <= light_max then
			minetest.set_node(random, {name = node.name})
		end
	end
})

minetest.register_craft({
	output = 'default:paper 6',
	recipe = {
		{'fun_caves:giant_mushroom_stem', 'fun_caves:giant_mushroom_stem', 'fun_caves:giant_mushroom_stem'},
	}
})

--stone spike
local spike_size = { 1.0, 1.2, 1.4, 1.6, 1.7 }
local hot_spikes = {}

for i in ipairs(spike_size) do
	if i == 1 then
		nodename = "fun_caves:hot_spike"
	else
		nodename = "fun_caves:hot_spike_"..i
	end

	hot_spikes[#hot_spikes+1] = nodename

	vs = spike_size[i]

	minetest.register_node(nodename, {
		description = "Stone Spike",
		tiles = {"fun_caves_hot_spike.png"},
		inventory_image = "fun_caves_hot_spike.png",
		wield_image = "fun_caves_hot_spike.png",
		is_ground_content = true,
		groups = {cracky=3, oddly_breakable_by_hand=1, hot=3},
		damage_per_second = 1,
		sounds = default.node_sound_stone_defaults(),
		paramtype = "light",
		drawtype = "plantlike",
		walkable = false,
		light_source = i * 2,
		buildable_to = true,
		visual_scale = vs,
		selection_box = {
			type = "fixed",
			fixed = {-0.5*vs, -0.5*vs, -0.5*vs, 0.5*vs, -5/16*vs, 0.5*vs},
		}
	})
end

-- Spike spread and death
minetest.register_abm({
	nodenames = hot_spikes,
	--neighbors = {"default:lava_source", "default:lava_flowing"},
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

		print("node_under ("..random.x..","..(random.y-1)..","..random.z.."): "..node_under.name)
		if node_under.name == "fun_caves:hot_cobble" or node_under.name == "default:coalblock" then
			print("setting ("..random.x..","..random.y..","..random.z.."): "..node_under.name)
			minetest.set_node(random, {name = hot_spikes[1]})
		end
	end
})

