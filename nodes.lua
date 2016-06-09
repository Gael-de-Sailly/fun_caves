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

newnode = fun_caves.clone_node("default:dirt")
newnode.description = "Polluted Dirt"
newnode.tiles = {"default_dirt.png^[colorize:#100020:100"}
newnode.groups.soil = 0
minetest.register_node("fun_caves:polluted_dirt", newnode)

-- dungeon floor, basic
newnode = fun_caves.clone_node("default:stone")
newnode.description = "Dungeon Stone"
newnode.legacy_mineral = false
newnode.groups = {fortress = 1}
minetest.register_node("fun_caves:dungeon_floor_1", newnode)

-- dungeon walls, basic
newnode = fun_caves.clone_node("default:sandstone")
newnode.description = "Dungeon Stone"
newnode.groups = {fortress = 1}
minetest.register_node("fun_caves:dungeon_wall_1", newnode)

-- dungeon walls, type 2
newnode = fun_caves.clone_node("default:desert_stone")
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

newnode = fun_caves.clone_node("default:leaves")
newnode.description = "Blackened Leaves"
newnode.tiles = {"default_leaves.png^[colorize:#100020:200"}
newnode.special_tiles = {"default_leaves_simple.png^[colorize:#100020:200"}
newnode.groups = {snappy = 3, flammable = 2}
minetest.register_node("fun_caves:leaves_black", newnode)

newnode = fun_caves.clone_node("default:water_source")
newnode.description = "Poisonous Water"
newnode.groups.poison = 3
newnode.light_source = 6
newnode.liquid_alternative_flowing = "fun_caves:water_poison_flowing"
newnode.liquid_alternative_source = "fun_caves:water_poison_source"
newnode.post_effect_color = {a = 103, r = 108, g = 128, b = 64}
newnode.special_tiles[1].name = "fun_caves_water_poison_source_animated.png"
newnode.tiles[1].name = "fun_caves_water_poison_source_animated.png"
minetest.register_node("fun_caves:water_poison_source", newnode)

newnode = fun_caves.clone_node("default:water_flowing")
newnode.description = "Poisonous Water"
newnode.groups.poison = 3
newnode.light_source = 6
newnode.liquid_alternative_flowing = "fun_caves:water_poison_flowing"
newnode.liquid_alternative_source = "fun_caves:water_poison_source"
newnode.post_effect_color = {a = 103, r = 108, g = 128, b = 64}
newnode.special_tiles[1].name = "fun_caves_water_poison_flowing_animated.png"
newnode.tiles[1] = "fun_caves_water_poison.png"
minetest.register_node("fun_caves:water_poison_flowing", newnode)

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
