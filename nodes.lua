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

local function teleporter(user, area, power)
	if not user then
		return
	end

	local name = user:get_player_name()
	local pos = user:getpos()

	if not fun_caves.db then
		fun_caves.db = {}
	end
	if not fun_caves.db.teleport_data then
		fun_caves.db.teleport_data = {}
	end
	if not fun_caves.db.teleport_data[name] then
		fun_caves.db.teleport_data[name] = {}
	end

	local out = io.open(fun_caves.world..'/fun_caves_data.txt','w')	
	if not (out and name) then
		return
	end

	if fun_caves.db.teleport_data[name].teleported_from then
		user:setpos(fun_caves.db.teleport_data[name].teleported_from)
		fun_caves.db.teleport_data[name].teleported_from = nil
	else
		local newpos
		if area == 'overworld' then
			newpos = {x=(math.random(2)*2-3)*(math.random(math.floor(map_max/6))+power*math.floor(map_max/6)), y=120, z=(math.random(2)*2-3)*(math.random(math.floor(map_max/6))+power*math.floor(map_max/6))}
		elseif area == 'hell' then
			newpos = {x=pos.x, y=fun_caves.underzones[({'Caina','Phlegethos','Dis','Minauros','Styx'})[power+1]].ceiling-30, z=pos.z}
		else
			return
		end

		user:setpos(newpos)
		print('Fun Caves: '..name..' teleported to ('..pos.x..','..pos.y..','..pos.z..')')
		fun_caves.db.teleport_data[name].teleported_from = pos
		out:write(minetest.serialize(fun_caves.db))
		user:set_physics_override({gravity=0.1})

		minetest.after(20, function()
			user:set_physics_override({gravity=1})
		end)
	end
end

minetest.register_craftitem("fun_caves:teleporter_iron_coral", {
	description = "Iron and Moonstone Teleporter",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"fun_caves_tesseract_iron_coral.png"},
	inventory_image = "fun_caves_tesseract_iron_coral.png",
	groups = {dig_immediate = 3},
	sounds = default.node_sound_stone_defaults(),
	on_use = function(itemstack, user, pointed_thing)
		teleporter(user, 'hell', 0)
	end,
})

minetest.register_craft({
	output = 'fun_caves:teleporter_iron_coral',
	recipe = {
		{'fun_caves:sky_iron', 'default:copper_ingot', 'fun_caves:sky_iron'},
		{'fun_caves:coral_gem', 'fun_caves:coral_gem', 'fun_caves:coral_gem'},
		{'fun_caves:sky_iron', 'default:obsidian_shard', 'fun_caves:sky_iron'},
	}
})

minetest.register_craftitem("fun_caves:coral_gem", {
	description = "Coral Gem",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"fun_caves_coral_gem.png"},
	inventory_image = "fun_caves_coral_gem.png",
	groups = {dig_immediate = 3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	type = "cooking",
	output = "fun_caves:coral_gem",
	recipe = "fun_caves:precious_coral",
	cooktime = 5,
})

minetest.register_craftitem("fun_caves:teleporter_iron_aquamarine", {
	description = "Iron and Aquamarine Teleporter",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"fun_caves_tesseract_iron_aqua.png"},
	inventory_image = "fun_caves_tesseract_iron_aqua.png",
	groups = {dig_immediate = 3},
	sounds = default.node_sound_stone_defaults(),
	on_use = function(itemstack, user, pointed_thing)
		teleporter(user, 'overworld', 0)
	end,
})

minetest.register_craft({
	output = 'fun_caves:teleporter_iron_aquamarine',
	recipe = {
		{'fun_caves:sky_iron', 'default:copper_ingot', 'fun_caves:sky_iron'},
		{'fun_caves:perfect_aquamarine', 'fun_caves:perfect_aquamarine', 'fun_caves:perfect_aquamarine'},
		{'fun_caves:sky_iron', 'default:obsidian_shard', 'fun_caves:sky_iron'},
	}
})

minetest.register_craftitem("fun_caves:meteorite", {
	description = "Iron Meteorite",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"fun_caves_meteorite.png"},
	inventory_image = "fun_caves_meteorite.png",
	groups = {dig_immediate = 3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craftitem("fun_caves:sky_iron", {
	description = "Sky Iron",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"default_steel_ingot.png"},
	inventory_image = "default_steel_ingot.png",
	groups = {dig_immediate = 3},
	sounds = default.node_sound_stone_defaults(),
})

local newnode = fun_caves.clone_node("default:stone_with_iron")
newnode.description = "Stone With Sky Iron"
newnode.drop = "fun_caves:sky_iron"
minetest.register_node("fun_caves:stone_with_sky_iron", newnode)

minetest.register_craftitem("fun_caves:meteoritic_iron_crucible", {
	description = "Crucible of Meteoritic Iron",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"crucible.png"},
	inventory_image = "crucible.png",
	groups = {dig_immediate = 3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'fun_caves:meteoritic_iron_crucible',
	recipe = {
		{'fun_caves:meteorite', 'fun_caves:meteorite', 'fun_caves:meteorite'},
		{'fun_caves:meteorite', 'fun_caves:meteorite', 'fun_caves:meteorite'},
		{'fun_caves:meteorite', 'fun_caves:crucible', 'fun_caves:meteorite'},
	}
})

minetest.register_craft({
	type = "cooking",
	output = "fun_caves:sky_iron",
	recipe = "fun_caves:meteoritic_iron_crucible",
	cooktime = 30,
})


minetest.register_craftitem("fun_caves:crucible", {
	description = "Crucible",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"crucible.png"},
	inventory_image = "crucible.png",
	groups = {dig_immediate = 3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'fun_caves:crucible',
	recipe = {
		{'default:clay', '', 'default:clay'},
		{'default:clay', '', 'default:clay'},
		{'', 'default:clay', ''},
	}
})

minetest.register_node("fun_caves:stone_with_aquamarines", {
	description = "Aquamarine Ore",
	tiles = {"default_stone.png^default_mineral_diamond.png"},
	groups = {cracky = 1},
	drop = "fun_caves:perfect_aquamarine",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "fun_caves:stone_with_aquamarines",
	wherein        = "default:stone",
	clust_scarcity = 17 * 17 * 17,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = -6000,
	y_max          = 31000,
})

minetest.register_craftitem("fun_caves:perfect_aquamarine", {
	description = "Perfect Aquamarine",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"default_diamond.png"},
	inventory_image = "default_diamond.png",
	groups = {dig_immediate = 3},
	sounds = default.node_sound_glass_defaults(),
})

local newnode = fun_caves.clone_node("default:dirt")
newnode.description = "Meteor Crater"
newnode.tiles = {"fun_caves_crater.png", "default_dirt.png", "default_dirt.png", "default_dirt.png", "default_dirt.png", "default_dirt.png"}
newnode.drop = "fun_caves:meteorite"
newnode.groups.soil = 0
minetest.register_node("fun_caves:meteorite_crater", newnode)
