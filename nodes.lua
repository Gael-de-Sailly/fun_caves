-- dirt, cave
local newnode = fun_caves.clone_node("default:dirt")
newnode.drop = "default:dirt"
newnode.groups.soil = 0
minetest.register_node("fun_caves:dirt", newnode)

-- dungeon floor, basic
local newnode = fun_caves.clone_node("default:stone")
newnode.description = "Dungeon Stone"
newnode.legacy_mineral = false
newnode.groups = {fortress = 1}
minetest.register_node("fun_caves:dungeon_floor_1", newnode)

-- dungeon walls, basic
local newnode = fun_caves.clone_node("default:sandstone")
newnode.description = "Dungeon Stone"
newnode.groups = {fortress = 1}
minetest.register_node("fun_caves:dungeon_wall_1", newnode)

-- dungeon walls, type 2
local newnode = fun_caves.clone_node("default:desert_stone")
newnode.description = "Dungeon Stone"
newnode.groups = {fortress = 1}
minetest.register_node("fun_caves:dungeon_wall_2", newnode)

-- ice -- add cold damage
minetest.add_group("default:ice", {surface_cold = 3})

-- ice, thin -- transparent
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
