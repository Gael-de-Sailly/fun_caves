---------------------------------------------------------------
-- GOBLINS
---------------------------------------------------------------

local spawn_frequency = 150  -- 150
local dig_freq = 5  -- 5
local trap_freq = 25  -- 25
local torch_freq = 2  -- 2

--fun_caves.goblin_drops = { "default:pick_steel",  "default:sword_steel", "default:shovel_steel", "farming:bread", "bucket:bucket_water", "default:pick_stone", "default:sword_stone" }
--{"group:stone"} = { "default:stone", "default:mossycobble", "default:sandstone", "default:desert_stone", "default:stone_with_coal", "default:stone_with_iron", "default:stone_with_copper", "default:stone_with_gold", "default:stone_with_diamond" }

local diggable = {"group:cracky", "group:snappy", "group:crumbly"}
local traps = {
	'fun_caves:mossycobble_trap',
	'fun_caves:stone_with_coal_trap',
	'fun_caves:stone_with_copper_trap',
	'fun_caves:stone_with_diamond_trap',
	'fun_caves:stone_with_gold_trap',
	'fun_caves:stone_with_iron_trap',
}


local function goblin_do(self)
	if not fun_caves.custom_ready(self) then
		return
	end

	local pos = self.object:getpos()
	pos.y = pos.y + 0.5

	-- dig
	if self.name == 'fun_caves:goblin_digger' then
		fun_caves.search_replace(pos, 1, diggable, 'air')
	else
		fun_caves.search_replace(pos, dig_freq, diggable, 'air')
	end

	-- steal torches
	fun_caves.search_replace(self.object:getpos(), torch_freq, {"default:torch"}, "air")

	pos.y = pos.y - 0.5

	-- place a mossycobble
	local cobbling = trap_freq
	if self.name == 'fun_caves:goblin_cobbler' then
		cobbling = torch_freq
	end
	fun_caves.search_replace(pos, cobbling, {"group:stone", "default:sandstone"}, "default:mossycobble")

	-- place a trap
	local trap = 'fun_caves:mossycobble_trap'
	if self.name == 'fun_caves:goblin_ice' then
		trap = 'fun_caves:stone_with_ice_trap'
		fun_caves.search_replace(pos, trap_freq, {"default:ice"}, trap)
	else
		if self.name == 'fun_caves:goblin_coal' then
			trap = 'fun_caves:stone_with_coal_trap'
		elseif self.name == 'fun_caves:goblin_copper' then
			trap = 'fun_caves:stone_with_copper_trap'
		elseif self.name == 'fun_caves:goblin_diamond' then
			trap = 'fun_caves:stone_with_diamond_trap'
		elseif self.name == 'fun_caves:goblin_gold' then
			trap = 'fun_caves:stone_with_gold_trap'
		elseif self.name == 'fun_caves:goblin_iron' then
			trap = 'fun_caves:stone_with_iron_trap'
		elseif self.name == 'fun_caves:goblin_king' then
			trap = traps[math.random(#traps)]
		end
		if self.name == 'fun_caves:goblin_king' then
			print(trap)
		end
		fun_caves.search_replace(pos, trap_freq, {"group:stone", "default:sandstone"}, trap)
	end

	fun_caves.surface_damage(self)
end


--local function goblin_right_click(self, clicker)
--	local item = clicker:get_wielded_item()
--	local name = clicker:get_player_name()
--
--	-- feed to heal goblin
--	if item:get_name() == "default:apple"
--		or item:get_name() == "farming:bread" then
--
--		local hp = self.object:get_hp()
--		-- return if full health
--		if hp >= self.hp_max then
--			minetest.chat_send_player(name, "goblin at full health.")
--			return
--		end
--		hp = hp + 4
--		if hp > self.hp_max then hp = self.hp_max end
--		self.object:set_hp(hp)
--		-- take item
--		if not minetest.setting_getbool("creative_mode") then
--			item:take_item()
--			clicker:set_wielded_item(item)
--		end
--
--		-- right clicking with gold lump drops random item from fun_caves.goblin_drops
--	elseif item:get_name() == "default:gold_lump" then
--		if not minetest.setting_getbool("creative_mode") then
--			item:take_item()
--			clicker:set_wielded_item(item)
--		end
--		local pos = self.object:getpos()
--		pos.y = pos.y + 0.5
--		minetest.add_item(pos, {name = fun_caves.goblin_drops[math.random(1, #fun_caves.goblin_drops)]})
--
--	else
--		-- if owner switch between follow and stand
--		if self.owner and self.owner == clicker:get_player_name() then
--			if self.order == "follow" then
--				self.order = "stand"
--			else
--				self.order = "follow"
--			end
--			--			else
--			--				self.owner = clicker:get_player_name()
--		end
--	end
--
--	mobs:capture_mob(self, clicker, 0, 5, 80, false, nil)
--end


local drops = {
	digger = {
		{name = "default:mossycobble", chance = 1, min = 1, max = 3},
	},
	cobbler = {
		{name = "fun_caves:glowing_fungus", chance = 1, min = 2, max = 5},
	},
	coal = {
		{name = "default:coal_lump", chance = 1, min = 1, max = 3},
	},
	copper = {
		{name = "default:copper_lump", chance = 1, min = 1, max = 3},
	},
	diamond = {
		{name = "default:diamond", chance = 5, min = 1, max = 3},
	},
	gold = {
		{name = "default:gold_lump", chance = 1, min = 1, max = 3},
	},
	ice = {
		{name = "default:coal_lump", chance = 1, min = 1, max = 3},
	},
	iron = {
		{name = "default:iron_lump", chance = 1, min = 1, max = 3},
	},
	king = {
		{name = "default:mese_crystal", chance = 1, min = 1, max = 3},
	},
}
for name, drop in pairs(drops) do
	if name == 'digger' or name == 'cobbler' or name == 'coal' or name == 'ice' then
		drop[#drop+1] = {name = "default:pick_stone", chance = 3, min = 1, max = 3}
		drop[#drop+1] = {name = "default:sword_stone", chance = 5, min = 1, max = 1}
	elseif name == 'copper' or name == 'iron' then
		drop[#drop+1] = {name = "default:pick_steel", chance = 3, min = 1, max = 3}
		drop[#drop+1] = {name = "default:sword_steel", chance = 5, min = 1, max = 1}
	elseif name == 'diamond' or name == 'gold' then
		drop[#drop+1] = {name = "default:pick_diamond", chance = 3, min = 1, max = 3}
		drop[#drop+1] = {name = "default:sword_diamond", chance = 5, min = 1, max = 1}
	elseif name == 'king' then
		drop[#drop+1] = {name = "default:pick_mese", chance = 3, min = 1, max = 3}
		drop[#drop+1] = {name = "default:sword_mese", chance = 5, min = 1, max = 1}
	end

	drop[#drop+1] = {name = "fun_caves:mushroom_steak", chance = 2, min = 1, max = 2}
	drop[#drop+1] = {name = "default:torch", chance = 3, min = 1, max = 10}
end


mobs:register_mob("fun_caves:goblin_digger", {
	description = "Digger Goblin",
	type = "monster",
	passive = false,
	damage = 1,
	attack_type = "dogfight",
	attacks_monsters = true,
	hp_min = 5,
	hp_max = 10,
	armor = 100,
	fear_height = 4,
	collisionbox = {-0.35,-1,-0.35, 0.35,-.1,0.35},
	visual = "mesh",
	mesh = "goblins_goblin.b3d",
	drawtype = "front",
	textures = {
		{"goblins_goblin_digger.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		random = "goblins_goblin_ambient",
		warcry = "goblins_goblin_attack",
		attack = "goblins_goblin_attack",
		damage = "goblins_goblin_damage",
		death = "goblins_goblin_death",
		distance = 15,
	},
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	drops = drops['digger'],
	water_damage = 1,
	lava_damage = 2,
	light_damage = 0,
	--lifetimer = 360,
	follow = {"default:diamond"},
	view_range = 10,
	owner = "",
	order = "follow",
	animation = {
		speed_normal = 30,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 200,
		punch_end = 219,
	},
	on_rightclick = nil,
	do_custom = goblin_do,
})

mobs:register_egg("fun_caves:goblin_digger", "Goblin Egg (digger)", "default_mossycobble.png", 1)
mobs:register_spawn("fun_caves:goblin_digger", {"group:stone"}, 100, 0, 20 * spawn_frequency, 3, -51)
mobs:register_spawn("fun_caves:goblin_digger", {"default:mossycobble"}, 100, 0, spawn_frequency, 3, -51)


local m = table.copy(minetest.registered_entities["fun_caves:goblin_digger"])
m.name = 'fun_caves:goblin_cobbler'
m.textures = { {"goblins_goblin_cobble1.png"}, {"goblins_goblin_cobble2.png"}, }
m.base_texture = m.textures[1]
m.drops = drops['cobbler']
minetest.registered_entities["fun_caves:goblin_cobbler"] = m
mobs.spawning_mobs["fun_caves:goblin_cobbler"] = true

mobs:register_spawn("fun_caves:goblin_cobbler", {"group:stone"}, 100, 0, 10 * spawn_frequency, 3, -51)
mobs:register_spawn("fun_caves:goblin_cobbler", {"default:mossycobble"}, 100, 0, spawn_frequency, 3, -51)
mobs:register_egg("fun_caves:goblin_cobbler", "Goblin Egg (cobbler)", "default_mossycobble.png", 1)


local m = table.copy(minetest.registered_entities["fun_caves:goblin_digger"])
m.name = 'fun_caves:goblin_coal'
m.textures = { {"goblins_goblin_coal1.png"}, {"goblins_goblin_coal2.png"}, }
m.base_texture = m.textures[1]
m.drops = drops['coal']
minetest.registered_entities["fun_caves:goblin_coal"] = m
mobs.spawning_mobs["fun_caves:goblin_coal"] = true

mobs:register_spawn("fun_caves:goblin_coal", {'default:coalblock', "default:stone_with_coal"}, 100, 0, spawn_frequency, 3, -51)
mobs:register_spawn("fun_caves:goblin_coal", {"default:mossycobble"}, 100, 0, spawn_frequency, 3, -51)
mobs:register_egg("fun_caves:goblin_coal", "Goblin Egg (coal)", "default_mossycobble.png", 1)


local m = table.copy(minetest.registered_entities["fun_caves:goblin_digger"])
m.name = 'fun_caves:goblin_copper'
m.hp_min = 7
m.hp_max = 15
m.armor = 75
m.textures = { {"goblins_goblin_copper1.png"}, {"goblins_goblin_copper2.png"}, }
m.base_texture = m.textures[1]
m.drops = drops['copper']
minetest.registered_entities["fun_caves:goblin_copper"] = m
mobs.spawning_mobs["fun_caves:goblin_copper"] = true

mobs:register_spawn("fun_caves:goblin_copper", {"default:stone_with_copper"}, 100, 0, spawn_frequency, 3, -51)
mobs:register_spawn("fun_caves:goblin_copper", {"default:mossycobble"}, 100, 0, 2 * spawn_frequency, 3, -51)
mobs:register_egg("fun_caves:goblin_copper", "Goblin Egg (copper)", "default_mossycobble.png", 1)


local m = table.copy(minetest.registered_entities["fun_caves:goblin_digger"])
m.name = 'fun_caves:goblin_diamond'
m.damage = 3
m.hp_min = 7
m.hp_max = 15
m.armor = 50
m.textures = { {"goblins_goblin_diamond1.png"}, {"goblins_goblin_diamond2.png"}, }
m.base_texture = m.textures[1]
m.drops = drops['diamond']
minetest.registered_entities["fun_caves:goblin_diamond"] = m
mobs.spawning_mobs["fun_caves:goblin_diamond"] = true

mobs:register_spawn("fun_caves:goblin_diamond", {"default:stone_with_diamond"}, 100, 0, spawn_frequency, 3, -51)
mobs:register_spawn("fun_caves:goblin_diamond", {"default:mossycobble"}, 100, 0, 2 * spawn_frequency, 3, -51)
mobs:register_egg("fun_caves:goblin_diamond", "Goblin Egg (diamond)", "default_mossycobble.png", 1)


local m = table.copy(minetest.registered_entities["fun_caves:goblin_digger"])
m.name = 'fun_caves:goblin_gold'
m.damage = 3
m.hp_min = 7
m.hp_max = 15
m.armor = 75
m.textures = { {"goblins_goblin_gold1.png"}, {"goblins_goblin_gold2.png"}, }
m.base_texture = m.textures[1]
m.drops = drops['gold']
minetest.registered_entities["fun_caves:goblin_gold"] = m
mobs.spawning_mobs["fun_caves:goblin_gold"] = true

mobs:register_spawn("fun_caves:goblin_gold", {"default:stone_with_gold"}, 100, 0, spawn_frequency, 3, -51)
mobs:register_spawn("fun_caves:goblin_gold", {"default:mossycobble"}, 100, 0, 2 * spawn_frequency, 3, -51)
mobs:register_egg("fun_caves:goblin_gold", "Goblin Egg (gold)", "default_mossycobble.png", 1)


local m = table.copy(minetest.registered_entities["fun_caves:goblin_digger"])
m.name = 'fun_caves:goblin_ice'
m.textures = { {"fun_caves_goblin_ice2.png"}, }
m.base_texture = m.textures[1]
m.drops = drops['ice']
minetest.registered_entities["fun_caves:goblin_ice"] = m
mobs.spawning_mobs["fun_caves:goblin_ice"] = true

mobs:register_spawn("fun_caves:goblin_ice", {"default:ice"}, 100, 0, 10 * spawn_frequency, 3, -51)
mobs:register_egg("fun_caves:goblin_ice", "Goblin Egg (ice)", "default_mossycobble.png", 1)


local m = table.copy(minetest.registered_entities["fun_caves:goblin_digger"])
m.name = 'fun_caves:goblin_iron'
m.damage = 3
m.hp_min = 7
m.hp_max = 15
m.armor = 75
m.textures = { {"goblins_goblin_iron1.png"}, {"goblins_goblin_iron2.png"}, }
m.base_texture = m.textures[1]
m.drops = drops['iron']
minetest.registered_entities["fun_caves:goblin_iron"] = m
mobs.spawning_mobs["fun_caves:goblin_iron"] = true

mobs:register_spawn("fun_caves:goblin_iron", {"default:stone_with_iron"}, 100, 0, spawn_frequency, 3, -51)
mobs:register_spawn("fun_caves:goblin_iron", {"default:mossycobble"}, 100, 0, 2 * spawn_frequency, 3, -51)
mobs:register_egg("fun_caves:goblin_iron", "Goblin Egg (iron)", "default_mossycobble.png", 1)


local m = table.copy(minetest.registered_entities["fun_caves:goblin_digger"])
m.name = 'fun_caves:goblin_king'
m.damage = 3
m.hp_min = 10
m.hp_max = 20
m.armor = 50
m.textures = { {"goblins_goblin_king.png"}, }
m.base_texture = m.textures[1]
m.drops = drops['king']
minetest.registered_entities["fun_caves:goblin_king"] = m
mobs.spawning_mobs["fun_caves:goblin_king"] = true

mobs:register_spawn("fun_caves:goblin_king", {"default:stone_with_mese"}, 100, 0, spawn_frequency, 3, -51)
mobs:register_spawn("fun_caves:goblin_king", {"default:mossycobble"}, 100, 0, 3 * spawn_frequency, 3, -51)
mobs:register_egg("fun_caves:goblin_king", "Goblin Egg (king)", "default_mossycobble.png", 1)


---------------------------------------------------------------
-- Traps
---------------------------------------------------------------

minetest.register_node("fun_caves:mossycobble_trap", {
	description = "Messy Gobblestone",
	tiles = {"default_mossycobble.png"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
	sounds = default.node_sound_stone_defaults(),
	paramtype = "light",
	light_source =  4,
})

--[[ too bad we can't keep track of what physics are set too by other mods...]]
minetest.register_abm({
	nodenames = {"fun_caves:mossycobble_trap"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, 0.95)) do -- IDKWTF this is but it works
				if object:is_player() then
					object:set_physics_override({speed = 0.1})
					minetest.after(1, function() -- this effect is temporary
						object:set_physics_override({speed = 1})  -- we'll just set it to 1 and be done.
					end)
				end
		end
	end})

minetest.register_craft({
	type = "cooking",
	output = "default:stone",
	recipe = "fun_caves:mossycobble_trap",
})

minetest.register_node("fun_caves:stone_with_coal_trap", {
	description = "Coal Trap",
	tiles = {"default_cobble.png^default_mineral_coal.png"},
	groups = {cracky = 3},
	--drop = 'default:coal_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_abm({
	nodenames = {"fun_caves:stone_with_coal_trap"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, 2)) do
			if object:is_player() then
				minetest.set_node(pos, {name="fire:basic_flame"})
				if object:get_hp() > 0 then
					object:set_hp(object:get_hp()-2)
				end
			end
		end
	end
})

minetest.register_node("fun_caves:stone_with_diamond_trap", {
	description = "Diamond Trap",
	tiles = {"default_cobble.png^default_mineral_diamond.png"},
	groups = {cracky = 3},
	--drop = 'default:diamond',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

local singleplayer = minetest.is_singleplayer()
local setting = minetest.setting_getbool("enable_tnt")
if (not singleplayer and setting ~= true) or (singleplayer and setting == false) then
	-- wimpier trap for non-tnt settings
	minetest.register_abm({
		nodenames = {"fun_caves:stone_with_diamond_trap"},
		interval = 1,
		chance = 1,
		action = function(pos, node, active_object_count, active_object_count_wider)
			for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, 3)) do
				if object:is_player() then
					minetest.set_node(pos, {name="default:lava_source"})
					if object:get_hp() > 0 then
						object:set_hp(object:get_hp()-2)
						minetest.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5, max_hear_distance = 10})
					end
				end
			end
		end})
else
	-- 5... 4... 3... 2... 1...
	minetest.register_abm({
		nodenames = {"fun_caves:stone_with_diamond_trap"},
		interval = 1,
		chance = 1,
		action = function(pos, node, active_object_count, active_object_count_wider)
			for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, 3)) do
				if object:is_player() then
					minetest.set_node(pos, {name="tnt:tnt_burning"})
					minetest.get_node_timer(pos):start(5)
					minetest.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5, max_hear_distance = 10})
				end
			end
		end})
end

newnode = fun_caves.clone_node("default:lava_source")
newnode.description = "Molten Gold Source"
newnode.wield_image = "goblins_molten_gold.png"
newnode.tiles[1].name = "goblins_molten_gold_source_animated.png"
newnode.special_tiles[1].name = "goblins_molten_gold_source_animated.png"
newnode.liquid_alternative_flowing = "fun_caves:molten_gold_flowing"
newnode.liquid_alternative_source = "fun_caves:molten_gold_source"
newnode.liquid_renewable = false
newnode.post_effect_color = {a=192, r=255, g=64, b=0}
minetest.register_node("fun_caves:molten_gold_source", newnode)

newnode = fun_caves.clone_node("default:lava_flowing")
newnode.description = "Flowing Molten Gold"
newnode.wield_image = "goblins_molten_gold.png"
newnode.tiles = {"goblins_molten_gold.png"}
newnode.special_tiles[1].name = "goblins_molten_gold_flowing_animated.png"
newnode.liquid_alternative_flowing = "fun_caves:molten_gold_flowing"
newnode.liquid_alternative_source = "fun_caves:molten_gold_source"
newnode.liquid_renewable = false
newnode.post_effect_color = {a=192, r=255, g=64, b=0}
minetest.register_node("fun_caves:molten_gold_flowing", newnode)

minetest.register_node("fun_caves:stone_with_gold_trap", {
	description = "Gold Trap",
	tiles = {"default_cobble.png^default_mineral_gold.png"},
	groups = {cracky = 3},
	--drop = 'default:gold_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_abm({
	nodenames = {"fun_caves:stone_with_gold_trap"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, 2)) do
			if object:is_player() then
				minetest.set_node(pos, {name="fun_caves:molten_gold_source"})
				if object:get_hp() > 0 then
					object:set_hp(object:get_hp()-2)
					minetest.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5, max_hear_distance = 10})
				 end
			end
		end
	end})

minetest.register_node("fun_caves:ice_trap", {
	description = "Ice Trap",
	tiles = {"default_ice.png^default_mineral_coal.png"},
	groups = {cracky = 3},
	drop = 'default:ice',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_abm({
	nodenames = {"fun_caves:ice_trap"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, 2)) do
			if object:is_player() then
				minetest.set_node(pos, {name="fire:basic_flame"})
				if object:get_hp() > 0 then
					object:set_hp(object:get_hp()-2)
				end
			end
		end
	end
})

minetest.register_node("fun_caves:stone_with_iron_trap", {
	description = "Iron Trap",
	tiles = {"default_cobble.png^default_mineral_iron.png"},
	groups = {cracky = 3},
	--drop = 'default:iron_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

-- summon a metallic goblin?
-- pit of iron razors?
minetest.register_abm({
	nodenames = {"fun_caves:stone_with_iron_trap"},
	interval = 2,
	chance = 2,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, 2)) do
			if object:is_player() then
				if object:get_hp() > 0 then
					object:set_hp(object:get_hp()-1)
					minetest.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5, max_hear_distance = 10})
				 end
			end
		end
	end})

minetest.register_node("fun_caves:stone_with_copper_trap", {
	description = "Copper Trap",
	tiles = {"default_cobble.png^default_mineral_copper.png"},
	groups = {cracky = 3},
	--drop = 'default:copper_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

local function lightning_effects(pos, radius)
	minetest.add_particlespawner({
		amount = 30,
		time = 1,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x=-10, y=-10, z=-10},
		maxvel = {x=10,  y=10,  z=10},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 3,
		minsize = 16,
		maxsize = 32,
		texture = "goblins_lightning.png",
	})
end

--[[ based on dwarves cactus]]
minetest.register_abm({
	nodenames = {"fun_caves:stone_with_copper_trap"},
	interval = 1,
	chance = 2,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, 3)) do
			if object:is_player() then
				if object:get_hp() > 0 then
					object:set_hp(object:get_hp()-1)
					-- sprite
					lightning_effects(pos, 3)
					minetest.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5, max_hear_distance = 10})
				 end
			end
		end
	end})
