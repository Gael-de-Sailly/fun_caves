-- search/replace -- lets mobs change the terrain
-- used for goblin traps and torch thieving
fun_caves.search_replace = function(pos, search_rate, replace_what, replace_with)
	if math.random(1, search_rate) == 1 then
		local p1 = vector.subtract(pos, 1)
		local p2 = vector.add(pos, 1)

		--look for nodes
		local nodelist = minetest.find_nodes_in_area(p1, p2, replace_what)

		if #nodelist > 0 then
			for key,value in pairs(nodelist) do 
				minetest.set_node(value, {name = replace_with})
				return  -- only one at a time
			end
		end
	end
end

function fun_caves.climb(self)
	if self.state == "stand" and math.random() < 0.2 then
		if self.fall_speed == 2 then
			self.fall_speed = -2
		else
			self.fall_speed = 2
		end
	elseif self.state == "attack" and self.fall_speed ~= -2 then
		self.fall_speed = -2
	end
end

-- causes mobs to take damage from hot/cold surfaces
fun_caves.surface_damage = function(self, cold_natured)
	--if not self.fun_caves_damage_timer then
	--	self.fun_caves_damage_timer = 0
	--end

	--self.fun_caves_damage_timer = self.fun_caves_damage_timer + 1
	--if self.fun_caves_damage_timer > 30 then
	--	self.fun_caves_damage_timer = 0
		local pos = self.object:getpos()
		local minp = vector.subtract(pos, 1.5)
		local maxp = vector.add(pos, 1.5)
		local counts = 0
		if self.lava_damage > 0 then
			counts =  minetest.find_nodes_in_area(minp, maxp, {"group:surface_hot"})
			if #counts > 0 then
				self.health = self.health - self.lava_damage
				effect(pos, 5, "fire_basic_flame.png")
			end
		end

		if not cold_natured then
			counts =  minetest.find_nodes_in_area(minp, maxp, {"group:surface_cold"})
			if #counts > 0 then
				self.health = self.health - 1
			end
		end

		check_for_death(self)
	--end
end

-- executed in a mob's do_custom() to regulate their actions
-- if false, do nothing
local custom_delay = 1000000
fun_caves.custom_ready = function(self)
	local time = minetest.get_us_time()
	if not self.custom_time or time - self.custom_time > custom_delay then
		self.custom_time = time
		return true
	else
		return false
	end
end


if minetest.registered_entities["kpgmobs:wolf"] then
	local m = table.copy(minetest.registered_entities["kpgmobs:wolf"])
	m.textures = { {"fun_caves_white_wolf.png"}, }
	m.base_texture = m.textures[1]

	minetest.registered_entities["fun_caves:white_wolf"] = m
	mobs.spawning_mobs["fun_caves:white_wolf"] = true

	mobs:register_spawn("fun_caves:white_wolf", {"default:dirt_with_snow", "fun_caves:cloud", "fun_caves:storm_cloud"}, 20, -1, 11000, 3, 31000)
	mobs:register_egg("fun_caves:white_wolf", "White Wolf", "wool_white.png", 1)
end

if minetest.registered_entities["kpgmobs:horse2"] then
	mobs:register_spawn("kpgmobs:horse2", {"fun_caves:cloud", "fun_caves:storm_cloud"}, 20, 8, 11000, 1, 31000)
end

if minetest.registered_entities["mobs_fish:clownfish"] then
	--local l_spawn_near		= {"default:sand","default:dirt","group:seaplants","group:seacoral"}
	mobs:spawn_specific("mobs_fish:clownfish", {"default:water_source", "default:water_flowing"}, {"default:sand","default:dirt", "fun_caves:cloud", "fun_caves:storm_cloud","group:seaplants","group:seacoral"}, 5, 20, 30, 10000, 1, 4000, 31000)
	mobs:spawn_specific("mobs_fish:tropical", {"default:water_source", "default:water_flowing"}, {"default:sand","default:dirt", "fun_caves:cloud", "fun_caves:storm_cloud","group:seaplants","group:seacoral"}, 5, 20, 30, 10000, 1, 4000, 31000)
end

if minetest.registered_entities["mobs_monster:spider"] then
	-- Deep spider
	local m = table.copy(minetest.registered_entities["mobs_monster:spider"])
	m.docile_by_day = false
	m.drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 3},
		{name = "wool:black", chance = 1, min = 1, max = 3},
	}
	m.water_damage = 0
	m.do_custom = function(self)
		if not fun_caves.custom_ready(self) then
			return
		end

		fun_caves.surface_damage(self)
	end

	minetest.registered_entities["fun_caves:spider"] = m
	mobs.spawning_mobs["fun_caves:spider"] = true

	mobs:register_spawn("fun_caves:spider", {"fun_caves:stone_with_moss", "fun_caves:stone_with_lichen", "fun_caves:stone_with_algae"}, 14, 0, 2000, 2, -51)

	mobs:register_egg("fun_caves:spider", "Deep Spider", "mobs_cobweb.png", 1)


	-- ice spider
	m = table.copy(minetest.registered_entities["mobs_monster:spider"])
	m.docile_by_day = false
	m.textures = { {"fun_caves_spider_ice.png"}, }
	m.base_texture = m.textures[1]
	m.drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 3},
		{name = "wool:white", chance = 1, min = 1, max = 3},
	}
	m.water_damage = 0
	m.do_custom = function(self)
		if not fun_caves.custom_ready(self) then
			return
		end

		fun_caves.surface_damage(self, true)
	end

	minetest.registered_entities["fun_caves:spider_ice"] = m
	mobs.spawning_mobs["fun_caves:spider_ice"] = true

	mobs:register_spawn("fun_caves:spider_ice", {"default:ice"}, 14, 0, 1000, 2, 31000)

	mobs:register_egg("fun_caves:spider_ice", "Ice Spider", "mobs_cobweb.png", 1)


	-- dangling spiders
	m = table.copy(minetest.registered_entities["mobs_monster:spider"])
	m.docile_by_day = false
	m.attacks_monsters = true
	m.damage = 1
	m.hp_min = 10
	m.hp_max = 20
	m.water_damage = 0
	m.fall_damage = 0
	m.collisionbox = {-0.32, -0.0, -0.25, 0.25, 0.25, 0.25}
	m.visual_size = {x = 1.5, y = 1.5}
	m.drops = {
		{name = "mobs:meat_raw", chance = 2, min = 1, max = 1},
		{name = "farming:cotton", chance = 2, min = 1, max = 2},
	}
	m.do_custom = function(self)
		if not fun_caves.custom_ready(self) then
			return
		end

		fun_caves.climb(self)
		fun_caves.search_replace(self.object:getpos(), 100, {"air"}, "mobs:cobweb")

		fun_caves.surface_damage(self)
	end

	minetest.registered_entities["fun_caves:dangler"] = m
	mobs.spawning_mobs["fun_caves:dangler"] = true

	mobs:register_spawn("fun_caves:dangler", {"fun_caves:stone_with_moss", "fun_caves:stone_with_lichen", "fun_caves:stone_with_algae"}, 14, 0, 1000, 3, -51)

	mobs:register_egg("fun_caves:dangler", "Dangling Spider", "mobs_cobweb.png", 1)


	-- tarantula
	m = table.copy(minetest.registered_entities["mobs_monster:spider"])
	m.type = "animal"
	m.reach = 1
	m.damage = 1
	m.hp_min = 1
	m.hp_max = 2
	m.collisionbox = {-0.15, -0.01, -0.15, 0.15, 0.1, 0.15}
	m.textures = { {"fun_caves_tarantula.png"}, }
	m.base_texture = m.textures[1]
	m.visual_size = {x = 1, y = 1}
	m.sounds = {}
	m.run_velocity = 2
	m.jump = false
	m.drops = { {name = "mobs:meat_raw", chance = 1, min = 1, max = 1}, }
	m.do_custom = function(self)
		if not self.fun_caves_damage_timer then
			self.fun_caves_damage_timer = 0
		end

		fun_caves.surface_damage(self)
	end
	minetest.registered_entities["fun_caves:tarantula"] = m
	mobs.spawning_mobs["fun_caves:tarantula"] = true

	mobs:register_spawn("fun_caves:tarantula", {"default:desert_sand", "default:dirt_with_dry_grass"}, 99, 0, 3000, 2, 31000)

	mobs:register_egg("fun_caves:tarantula", "Tarantula", "mobs_cobweb.png", 1)


	minetest.register_abm({
		nodenames = {"mobs:cobweb"},
		interval = 500,
		chance = 50,
		action = function(pos, node)
			minetest.set_node(pos, {name = "air"})
		end
	})
end

if minetest.registered_entities["mobs_monster:sand_monster"] then
	local m = table.copy(minetest.registered_entities["mobs_monster:sand_monster"])
	m.damage = 2
	m.hp_min = 15
	m.hp_max = 40
	m.textures = { {"fun_caves_tar_monster.png"}, }
	m.base_texture = m.textures[1]
	m.drops = { {name = "default:coal_lump", chance = 1, min = 3, max = 5}, }
	m.water_damage = 1
	m.lava_damage = 2
	m.light_damage = 1

	minetest.registered_entities["fun_caves:tar_monster"] = m
	mobs.spawning_mobs["fun_caves:tar_monster"] = true

	mobs:register_spawn("fun_caves:tar_monster", {"fun_caves:black_sand"}, 20, 0, 4000, 1, 31000)

	mobs:register_egg("fun_caves:tar_monster", "Tar Monster", "fun_caves_black_sand.png", 1)


	m = table.copy(minetest.registered_entities["mobs_monster:sand_monster"])
	m.textures = { {"fun_caves_sand_monster.png"}, }
	m.base_texture = m.textures[1]
	m.drops = { {name = "default:sand", chance = 1, min = 3, max = 5}, }

	minetest.registered_entities["fun_caves:sand_monster"] = m
	mobs.spawning_mobs["fun_caves:sand_monster"] = true

	mobs:register_spawn("fun_caves:sand_monster", {"default:sand"}, 20, 0, 4000, 3, -50)

	mobs:register_egg("fun_caves:sand_monster", "Deep Sand Monster", "default_sand.png", 1)
end

-- Change the original, rather than making a copy.
if minetest.registered_entities["dmobs:elephant"] then
	local m = minetest.registered_entities["dmobs:elephant"]
	m.type = "monster"
	m.reach = 3
	m.damage = 3
end

if minetest.registered_entities["mobs_monster:dirt_monster"] then
	-- check this
	mobs:register_spawn("mobs_monster:dirt_monster", {"default:dirt"}, 7, 0, 4000, 1, -50)
	mobs:register_spawn("mobs_monster:dirt_monster", {"default:dirt_with_dry_grass"}, 7, 0, 7000, 1, 31000, false)
end

if minetest.registered_entities["mobs_slimes:green_big"] then
	mobs:spawn_specific("mobs_slimes:green_big",
	{"fun_caves:stone_with_moss", "fun_caves:stone_with_algae", 'fun_caves:polluted_dirt'},
	{"air"},
	4, 20, 30, 30000, 1, -31000, 31000
	)
	mobs:spawn_specific("mobs_slimes:green_medium",
	{"fun_caves:stone_with_moss", "fun_caves:stone_with_algae", 'fun_caves:polluted_dirt'},
	{"air"},
	4, 20, 30, 30000, 2, -31000, 31000
	)
	mobs:spawn_specific("mobs_slimes:green_small",
	{"default:dirt_with_grass", "default:junglegrass", "default:mossycobble", "ethereal:green_dirt_top", 'fun_caves:polluted_dirt'},
	{"air"},
	4, 20, 30, 30000, 3, -31000, 31000
	)
end

if minetest.registered_entities["mobs_creeper:creeper"] then
	mobs:spawn_specific("mobs_creeper:creeper",
	{"fun_caves:stone_with_moss"},
	{"air"},
	-1, 20, 30, 20000, 1, -31000, 31000
	)
end

if minetest.registered_entities["mobs_sharks:shark_lg"] then
	local m = table.copy(minetest.registered_entities["mobs_sharks:shark_lg"])
	local l_spawn_in		= {"default:water_flowing","default:water_source"}
	local l_spawn_near		= {"default:water_flowing","default:water_source","seawrecks:woodship","seawrecks:uboot"}

	m.damage = 15
	m.hp_min = 40
	m.hp_max = 50
	m.visual_size = {x=3, y=3}
	m.collisionbox = {-2, -1.5, -2, 2, 1.5, 2}
	m.textures = {"fun_caves_albino.png"}
	m.base_texture = m.textures[1]

	minetest.registered_entities["fun_caves:shark_giant"] = m
	mobs.spawning_mobs["fun_caves:shark_giant"] = true

	mobs:spawn_specific("fun_caves:shark_giant", l_spawn_in, l_spawn_near, -1, 20, 30, 60000, 1, -31000, -29620)
	mobs:register_egg("fun_caves:shark_md", "Shark (giant)", "mob_shark_shark_item.png", 0)
end

dofile(fun_caves.path.."/zombie.lua")


fun_caves.goblin_spawn_frequency = 150
fun_caves.goblin_trap_freq = 25
fun_caves.goblin_torch_freq = 2

fun_caves.goblin_drops = { "default:pick_steel",  "default:sword_steel", "default:shovel_steel", "farming:bread", "bucket:bucket_water", "default:pick_stone", "default:sword_stone" }
--{"group:stone"} = { "default:stone", "default:mossycobble", "default:sandstone", "default:desert_stone", "default:stone_with_coal", "default:stone_with_iron", "default:stone_with_copper", "default:stone_with_gold", "default:stone_with_diamond" }

dofile(fun_caves.path.."/goblin_cobbler.lua")
dofile(fun_caves.path.."/goblin_digger.lua")
dofile(fun_caves.path.."/goblin_coal.lua")
dofile(fun_caves.path.."/goblin_ice.lua")
dofile(fun_caves.path.."/goblin_copper.lua")
dofile(fun_caves.path.."/goblin_iron.lua")
dofile(fun_caves.path.."/goblin_gold.lua")
dofile(fun_caves.path.."/goblin_diamond.lua")
dofile(fun_caves.path.."/goblin_king.lua")

fun_caves.fortress_spawns = {}
local t_mobs = {
	"mobs_monster:dungeon_master",
	"mobs_monster:lava_flan",
	"mobs_monster:mese_monster",
	"mobs_monster:oerkki",
	"mobs_monster:stone_monster",
	"fun_caves:spider",
	"mobs_slimes:green_big",
	"mobs_slimes:green_medium",
	"mobs_slimes:green_small",
	"fun_caves:goblin_cobble",
	"fun_caves:goblin_copper",
	"fun_caves:goblin_coal",
	"fun_caves:goblin_ice",
	"fun_caves:goblin_iron",
	"fun_caves:goblin_gold",
	"fun_caves:goblin_diamond",
	"fun_caves:goblin_king",
	"fun_caves:zombie",
	"fun_caves:zombie",
	"dmobs:orc",
	"dmobs:orc",
	"dmobs:orc",
	"dmobs:ogre",
	"dmobs:ogre",
	"dmobs:dragon",
}
for _, mob in pairs(t_mobs) do
	if minetest.registered_entities[mob] then
		fun_caves.fortress_spawns[#fun_caves.fortress_spawns+1] = mob
	end
end
