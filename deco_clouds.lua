
local newnode = fun_caves.clone_node("default:dirt")
newnode.description = "Cloud"
newnode.tiles = {'fun_caves_cloud.png'}
newnode.sunlight_propagates = true
minetest.register_node("fun_caves:cloud", newnode)

newnode = fun_caves.clone_node("default:dirt")
newnode.description = "Storm Cloud"
newnode.tiles = {'fun_caves_storm_cloud.png'}
--newnode.sunlight_propagates = true
minetest.register_node("fun_caves:storm_cloud", newnode)

newnode = fun_caves.clone_node("default:dirt")
newnode.description = "Wispy Cloud"
newnode.tiles = {'fun_caves_wisp.png'}
newnode.sunlight_propagates = true
newnode.use_texture_alpha = true
newnode.walkable = false
newnode.buildable_to = true
newnode.pointable = false
minetest.register_node("fun_caves:wispy_cloud", newnode)

minetest.register_node("fun_caves:moon_weed", {
	description = "Moon Weed",
	drawtype = "plantlike",
	tiles = {"fun_caves_moon_weed.png"},
	inventory_image = "fun_caves_moon_weed.png",
	waving = false,
	sunlight_propagates = true,
	paramtype = "light",
	light_source = 8,
	walkable = false,
	groups = {snappy=3,flammable=2,flora=1,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
	},
})

minetest.register_node("fun_caves:leaves_lumin", {
	description = "Leaves",
	drawtype = "allfaces_optional",
	waving = 1,
	visual_scale = 1.3,
	tiles = {"default_leaves.png^[colorize:#FFDF00:150"},
	special_tiles = {"default_leaves_simple.png^[colorize:#FFDF00:150"},
	paramtype = "light",
	is_ground_content = false,
	light_source = 8,
	groups = {snappy = 3, leafdecay = 4, flammable = 2, leaves = 1},
	drop = {
		max_items = 1,
		items = {
			--{
			--	-- player will get sapling with 1/20 chance
			--	items = {'default:sapling'},
			--	rarity = 20,
			--},
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {'fun_caves:leaves_lumin'},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),

	after_place_node = default.after_place_leaves,
})

minetest.register_node("fun_caves:lumin_tree", {
	description = "Lumin Tree",
	tiles = {
		"default_tree_top.png", "default_tree_top.png", "fun_caves_lumin_tree.png"
	},
	paramtype = "light",
	drawtype = "nodebox",
	node_box = {
		type = "fixed", 
		fixed = { {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}, }
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),

	on_place = minetest.rotate_node
})
