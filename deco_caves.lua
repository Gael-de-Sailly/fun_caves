-- black (oily) sand
local newnode = fun_caves.clone_node("default:sand")
newnode.description = "Black Sand"
newnode.tiles = {"fun_caves_black_sand.png"}
newnode.groups['falling_node'] = 0
minetest.register_node("fun_caves:black_sand", newnode)

-- cobble, hot - cobble with lava instead of mortar XD
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

-- dirt, glowing
newnode = fun_caves.clone_node("default:dirt")
newnode.description = "Glowing Dirt"
newnode.light_source = default.LIGHT_MAX
newnode.soil = {
	base = "fun_caves:glowing_dirt",
	dry = "fun_caves:glowing_soil",
	wet = "fun_caves:glowing_soil_wet"
}
minetest.register_node("fun_caves:glowing_dirt", newnode)

-- Dirt can become soil.
newnode = fun_caves.clone_node("farming:soil")
newnode.description = "Glowing Soil"
newnode.light_source = default.LIGHT_MAX
newnode.soil = {
	base = "fun_caves:glowing_dirt",
	dry = "fun_caves:glowing_soil",
	wet = "fun_caves:glowing_soil_wet"
}
minetest.register_node("fun_caves:glowing_dirt", newnode)

-- Dirt to soil to wet soil...
newnode = fun_caves.clone_node("farming:soil_wet")
newnode.description = "Wet Glowing Soil"
newnode.light_source = default.LIGHT_MAX
newnode.soil = {
	base = "fun_caves:glowing_dirt",
	dry = "fun_caves:glowing_soil",
	wet = "fun_caves:glowing_soil_wet"
}
minetest.register_node("fun_caves:glowing_dirt", newnode)

-- flame, constant -- does not expire
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

-- Glowing fungal stone provides an eerie light.
minetest.register_node("fun_caves:glowing_fungal_stone", {
	description = "Glowing Fungal Stone",
	tiles = {"default_stone.png^vmg_glowing_fungal.png",},
	is_ground_content = true,
	light_source = fun_caves.light_max - 4,
	groups = {cracky=3, stone=1},
	drop = {items={ {items={"default:cobble"},}, {items={"fun_caves:glowing_fungus",},},},},
	sounds = default.node_sound_stone_defaults(),
})

-- Glowing fungus grows underground.
minetest.register_node("fun_caves:glowing_fungus", {
	description = "Glowing Fungus",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"vmg_glowing_fungus.png"},
	inventory_image = "vmg_glowing_fungus.png",
	groups = {dig_immediate = 3},
})

-- moon glass (glows)
local newnode = fun_caves.clone_node("default:glass")
newnode.light_source = default.LIGHT_MAX
minetest.register_node("fun_caves:moon_glass", newnode)

-- Moon juice is extracted from glowing fungus, to make glowing materials.
minetest.register_node("fun_caves:moon_juice", {
	description = "Moon Juice",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"vmg_moon_juice.png"},
	inventory_image = "vmg_moon_juice.png",
	--groups = {dig_immediate = 3, attached_node = 1},
	groups = {dig_immediate = 3},
	sounds = default.node_sound_glass_defaults(),
})

-- mushroom cap, giant
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
	light_source = fun_caves.light_max,
	groups = {fleshy=1, dig_immediate=3, flammable=2, plant=1},
})

-- mushroom cap, huge
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
	light_source = fun_caves.light_max,
	groups = {fleshy=1, dig_immediate=3, flammable=2, plant=1},
})

-- mushroom stem, giant or huge
minetest.register_node("fun_caves:giant_mushroom_stem", {
	description = "Giant Mushroom Stem",
	tiles = {"vmg_mushroom_giant_stem.png", "vmg_mushroom_giant_stem.png", "vmg_mushroom_giant_stem.png"},
	is_ground_content = false,
	groups = {choppy=2, oddly_breakable_by_hand=1, flammable=2,  plant=1}, 
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	drawtype = "nodebox",
	node_box = { type = "fixed", fixed = { {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}, }},
})

-- obsidian, glowing
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

-- obsidian, glowing, 2 - has traces of lava
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

-- salt
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

-- salt, radioactive ore
newnode.description = "Salt With Radioactive Ore"
newnode.tiles = {"caverealms_salty2.png^[colorize:#004000:250"}
newnode.light_source = 4
minetest.register_node("fun_caves:radioactive_ore", newnode)

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

-- spikes, hot -- silicon-based life
local spike_size = { 1.0, 1.2, 1.4, 1.6, 1.7 }
fun_caves.hot_spikes = {}

for i in ipairs(spike_size) do
	if i == 1 then
		nodename = "fun_caves:hot_spike"
	else
		nodename = "fun_caves:hot_spike_"..i
	end

	fun_caves.hot_spikes[#fun_caves.hot_spikes+1] = nodename

	vs = spike_size[i]

	minetest.register_node(nodename, {
		description = "Stone Spike",
		tiles = {"fun_caves_hot_spike.png"},
		inventory_image = "fun_caves_hot_spike.png",
		wield_image = "fun_caves_hot_spike.png",
		is_ground_content = true,
		groups = {cracky=3, oddly_breakable_by_hand=1, surface_hot=3},
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

fun_caves.hot_spike = {}
for i = 1, #fun_caves.hot_spikes do
	fun_caves.hot_spike[fun_caves.hot_spikes[i]] = i
end

-- stone with algae
newnode = fun_caves.clone_node("default:stone")
newnode.description = "Cave Stone With Algae"
newnode.tiles = {"default_stone.png^fun_caves_algae.png"}
newnode.groups = {stone=1, crumbly=3}
newnode.sounds = default.node_sound_dirt_defaults({
	footstep = {name="default_grass_footstep", gain=0.25},
})
minetest.register_node("fun_caves:stone_with_algae", newnode)

-- stone with lichen
newnode = fun_caves.clone_node("default:stone")
newnode.description = "Cave Stone With Lichen"
newnode.tiles = {"default_stone.png^fun_caves_lichen.png"}
newnode.groups = {stone=1, crumbly=3}
newnode.sounds = default.node_sound_dirt_defaults({
	footstep = {name="default_grass_footstep", gain=0.25},
})
minetest.register_node("fun_caves:stone_with_lichen", newnode)

-- stone with moss
newnode = fun_caves.clone_node("default:stone")
newnode.description = "Cave Stone With Moss"
newnode.tiles = {"default_stone.png^fun_caves_moss.png"}
newnode.groups = {stone=1, crumbly=3}
newnode.sounds = default.node_sound_dirt_defaults({
	footstep = {name="default_grass_footstep", gain=0.25},
})
minetest.register_node("fun_caves:stone_with_moss", newnode)


------------------------------------
-- recipes
------------------------------------

-- Mushroom stems can be used as wood and leather,
-- ala Journey to the Center of the Earth.
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

minetest.register_craft({
	output = 'default:paper 6',
	recipe = {
		{'fun_caves:giant_mushroom_stem', 'fun_caves:giant_mushroom_stem', 'fun_caves:giant_mushroom_stem'},
	}
})

-- Caps can be cooked and eaten.
minetest.register_node("fun_caves:mushroom_steak", {
	description = "Mushroom Steak",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"vmg_mushroom_steak.png"},
	inventory_image = "vmg_mushroom_steak.png",
	on_use = minetest.item_eat(4),
	--groups = {dig_immediate = 3, attached_node = 1},
	groups = {dig_immediate = 3},
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

-- moon juice from fungus
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

minetest.register_craft({
	output = "fun_caves:glowing_dirt",
	type = "shapeless",
	recipe = {
		"fun_caves:moon_juice",
		"default:dirt",
	},
})

-- Speleothems can be made into cobblestone, to get them out of inventory.
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
