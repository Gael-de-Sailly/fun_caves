local get_node_or_nil = minetest.get_node_or_nil
local get_item_group = minetest.get_item_group

local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, name)
	local node = get_node_or_nil(pos)
	if node and get_item_group(node.name, "fortress") ~= 0 then
		return true
	end
	return old_is_protected(pos, name)
end

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

minetest.register_node('fun_caves:sticks_default', {
	description = 'Sticks',
	drawtype = 'allfaces_optional',
	waving = 1,
	visual_scale = 1.3,
	tiles = {'mymonths_sticks.png'},
	paramtype = 'light',
	is_ground_content = false,
	drop = 'default:stick 2',
	groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
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
