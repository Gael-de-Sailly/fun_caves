-- search/replace -- lets mobs change the terrain
-- used for goblin traps and torch thieving
fun_caves.search_replace = function(pos, search_rate, replace_what, replace_with)
	if math.random(search_rate) == 1 then
		local p1 = vector.subtract(pos, 1)
		local p2 = vector.add(pos, 1)

		--look for nodes
		local nodelist = minetest.find_nodes_in_area(p1, p2, replace_what)

		if #nodelist > 0 then
			for _, new_pos in pairs(nodelist) do 
				minetest.set_node(new_pos, {name = replace_with})
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
local custom_delay = 2000000
fun_caves.custom_ready = function(self, delay)
	local time = minetest.get_us_time()
	if not delay then
		delay = custom_delay
	end
	if not self.custom_time or time - self.custom_time > delay then
		self.custom_time = time
		return true
	else
		return false
	end
end


-- Try to standardize creature stats based on (log of) mass.
local mob_stats = {

	{name = 'dmobs:badger', hp = 12, damage = 1, armor = 100},
	{name = 'dmobs:dragon', hp = 40, damage = 6, armor = 50},
	{name = 'dmobs:elephant', hp = 38, damage = 5, armor = 75},
	{name = 'dmobs:fox', hp = 8, damage = 1, armor = 100},
	{name = 'dmobs:hedgehog', hp = 2, damage = 1, armor = 100},
	{name = 'dmobs:ogre', hp = 26, damage = 3, armor = 75},
	{name = 'dmobs:orc', hp = 22, damage = 2, armor = 100},
	{name = 'dmobs:owl', hp = 6, damage = 1, armor = 100},
	{name = 'dmobs:panda', hp = 22, damage = 2, armor = 100},
	{name = 'kpgmobs:deer', hp = 20, damage = 2, armor = 100},
	{name = 'kpgmobs:horse2', hp = 30, damage = 3, armor = 100},
	{name = 'kpgmobs:horse3', hp = 30, damage = 3, armor = 100},
	{name = 'kpgmobs:horse', hp = 30, damage = 3, armor = 100},
	{name = 'kpgmobs:jeraf', hp = 32, damage = 3, armor = 100},
	{name = 'kpgmobs:medved', hp = 26, damage = 3, armor = 100},
	{name = 'kpgmobs:wolf', hp = 18, damage = 3, armor = 100},
	{name = 'mobs_animal:bee', hp = 1, damage = 1, armor = 200},
	{name = 'mobs_animal:bunny', hp = 2, damage = 1, armor = 100},
	{name = 'mobs_animal:chicken', hp = 8, damage = 1, armor = 150},
	{name = 'mobs_animal:cow', hp = 30, damage = 3, armor = 150},
	{name = 'mobs_animal:kitten', hp = 8, damage = 1, armor = 100},
	{name = 'mobs_animal:pumba', hp = 20, damage = 2, armor = 100},
	{name = 'mobs_animal:rat', hp = 2, damage = 1, armor = 100},
	{name = 'mobs_animal:sheep', hp = 18, damage = 1, armor = 150},
	{name = 'mobs_bat:bat', hp = 2, damage = 1, armor = 150},
	{name = 'mobs_birds:bird_lg', hp = 4, damage = 1, armor = 150},
	{name = 'mobs_birds:bird_sm', hp = 2, damage = 1, armor = 150},
	{name = 'mobs_birds:gull', hp = 4, damage = 1, armor = 150},
	{name = 'mobs_butterfly:butterfly', hp = 1, damage = 0, armor = 200},
	{name = 'mobs_creeper:creeper', hp = 14, damage = 2, armor = 150},
	{name = 'mobs_crocs:crocodile_float', hp = 26, damage = 3, armor = 75},
	{name = 'mobs_crocs:crocodile', hp = 26, damage = 3, armor = 75},
	{name = 'mobs_crocs:crocodile_swim', hp = 26, damage = 3, armor = 75},
	{name = 'mobs_fish:clownfish', hp = 2, damage = 0, armor = 100},
	{name = 'mobs_fish:tropical', hp = 2, damage = 0, armor = 100},
	{name = 'mobs_jellyfish:jellyfish', hp = 2, damage = 2, armor = 200},
	{name = 'mobs_monster:dirt_monster', hp = 20, damage = 2, armor = 100},
	{name = 'mobs_monster:dungeon_master', hp = 30, damage = 5, armor = 50},
	{name = 'mobs_monster:lava_flan', hp = 16, damage = 3, armor = 50},
	{name = 'mobs_monster:mese_monster', hp = 10, damage = 2, armor = 40},
	{name = 'mobs_monster:oerkki', hp = 16, damage = 2, armor = 100},
	{name = 'mobs_monster:sand_monster', hp = 20, damage = 2, armor = 200},
	{name = 'mobs_monster:spider', hp = 22, damage = 2, armor = 100},
	{name = 'mobs_monster:stone_monster', hp = 20, damage = 2, armor = 50},
	{name = 'mobs_monster:tree_monster', hp = 18, damage = 2, armor = 75},
	{name = 'mobs_sandworm:sandworm', hp = 42, damage = 7, armor = 100},
	{name = 'mobs_sharks:shark_lg', hp = 34, damage = 5, armor = 80},
	{name = 'mobs_sharks:shark_md', hp = 25, damage = 3, armor = 80},
	{name = 'mobs_sharks:shark_sm', hp = 16, damage = 2, armor = 80},
	--{name = 'mobs_slimes:green_big', hp = 16, damage = 3, armor = 100},
	--{name = 'mobs_slimes:green_medium', hp = 16, damage = 3, armor = 100},
	--{name = 'mobs_slimes:green_small', hp = 16, damage = 3, armor = 100},
	--{name = 'mobs_slimes:lava_big', hp = 16, damage = 3, armor = 100},
	--{name = 'mobs_slimes:lava_medium', hp = 16, damage = 3, armor = 100},
	--{name = 'mobs_slimes:lava_small', hp = 16, damage = 3, armor = 100},
	{name = 'mobs_turtles:seaturtle', hp = 18, damage = 2, armor = 75},
	{name = 'mobs_turtles:turtle', hp = 10, damage = 1, armor = 50},
	{name = 'mobs_yeti:yeti', hp = 22, damage = 2, armor = 100},
}
local colors = { 'black', 'blue', 'brown', 'cyan', 'dark_green', 'dark_grey', 'green', 'grey', 'magenta', 'orange', 'pink', 'red', 'violet', 'white', 'yellow',}
for _, color in pairs(colors) do
	mob_stats[#mob_stats+1] = {name = 'mobs_animal:sheep_'..color, hp = 18, damage = 1, armor = 150}
end
for _, mob in pairs(mob_stats) do
	if string.find(mob.name, 'mobs_monster') or string.find(mob.name, 'mobs_animal') then
		local i, j = string.find(mob.name, ':')
		local suff = string.sub(mob.name, i)
		mob_stats[#mob_stats+1] = {name = 'mobs'..suff, hp = mob.hp, damage = mob.damage, armor = mob.armor}
	end
end

for _, mob in pairs(mob_stats) do
	if minetest.registered_entities[mob.name] then
		minetest.registered_entities[mob.name].damage = mob.damage
		minetest.registered_entities[mob.name].hp_min = math.ceil(mob.hp * 0.5)
		minetest.registered_entities[mob.name].hp_max = math.ceil(mob.hp * 1.5)
		minetest.registered_entities[mob.name].armor = mob.armor
	end
end


if minetest.registered_entities["dmobs:fox"] then
	local function fire_walk(self)
		if not fun_caves.custom_ready(self, 1000000) then
			return
		end

		local pos = self.object:getpos()
		local p1 = vector.subtract(pos, 1)
		local p2 = vector.add(pos, 1)

		--look for nodes
		local nodelist = minetest.find_nodes_in_area(p1, p2, "air")
		for n in pairs(nodelist) do
			minetest.set_node(pos, {name='fire:basic_flame'})
		end
	end

	local m = table.copy(minetest.registered_entities["dmobs:fox"])
	m.name = 'fun_caves:fire_fox'
	m.damage = 3
	m.hp_min = 8
	m.hp_max = 24
	m.lava_damage = 0
	m.textures = { {"fun_caves_fire_fox_2.png"}, }
	m.base_texture = m.textures[1]
	m.do_custom = fire_walk

	minetest.registered_entities["fun_caves:fire_fox"] = m
	mobs.spawning_mobs["fun_caves:fire_fox"] = true

	--mobs:register_spawn("fun_caves:fire_fox", {'default:dirt_with_grass'}, 20, -1, 1000, 5, 31000)
end


mobs:register_mob("fun_caves:star", {
	description = "Star",
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	attacks_monsters = true,
	fly = true,
	fly_in = 'fun_caves:vacuum',
	reach = 2,
	damage = 2,
	hp_min = 10,
	hp_max = 20,
	armor = 100,
	collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	visual = "mesh",
	visual_size = {x = 5, y = 5},
	mesh = "star.x",
	drawtype = "front",
	textures = {
		{"fun_caves_albino.png"},
	},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_bee",
	},
	walk_velocity = 1,
	run_velocity = 3,
	jump = true,
	view_range = 15,
	floats = 0,
	--drops = {
	--	{name = "mobs:honey", chance = 2, min = 1, max = 2},
	--},
	water_damage = 0,
	lava_damage = 0,
	light_damage = 0,
	fall_damage = 0,
	lifetimer = 360,
	do_custom = function(self)
		if not fun_caves.custom_ready(self) then
			return
		end

		local pos = self.object:getpos()
		local node = minetest.get_node_or_nil(pos)
		if node and node.name then
			self.fly_in = node.name
		end
	end
})

mobs:spawn_specific("fun_caves:star", {'default:stone', 'fun_caves:asteroid_water'}, {'fun_caves:vacuum'}, -1, 20, nil, 300, 2, 11168, 15168, nil)

if minetest.registered_entities["mobs:bee"] then
	local function bee_summon(self)
		if self.state ~= 'attack' then
			return
		end

		local prob = 10
		if self.name == 'fun_caves:killer_bee_queen' then
			prob = 4
		end
		if math.random(prob) == 1 then
			local pos = self.object:getpos()
			local p1 = vector.subtract(pos, 1)
			local p2 = vector.add(pos, 1)

			--look for nodes
			local nodelist = minetest.find_nodes_in_area(p1, p2, "air")

			if #nodelist > 0 then
				for key,value in pairs(nodelist) do 
					minetest.add_entity(value, "fun_caves:killer_bee_drone")
					print("A bee summons reinforcement.")
					return  -- only one at a time
				end
			end
		end
	end

	local function bee_do(self)
		if not fun_caves.custom_ready(self) then
			return
		end

		local pos = self.object:getpos()
		pos.y = pos.y + 1

		if self.name == 'fun_caves:killer_bee' then
			fun_caves.search_replace(pos, 10, {'group:tree', 'fun_caves:glowing_fungal_wood',}, 'air')
		end
		fun_caves.search_replace(pos, 10, {"fun_caves:tree"}, "fun_caves:glowing_fungal_wood")
		fun_caves.search_replace(pos, 60, {"fun_caves:glowing_fungal_wood", 'fun_caves:sap'}, "air")

		bee_summon(self)

		fun_caves.surface_damage(self)
	end

	mobs:register_mob("fun_caves:killer_bee", {
		description = "Killer Bee",
		type = "monster",
		passive = false,
		attack_type = "dogfight",
		attacks_monsters = true,
		reach = 2,
		damage = 1,
		hp_min = 2,
		hp_max = 6,
		armor = 100,
		collisionbox = {-0.2, -0.01, -0.2, 0.2, 0.2, 0.2},
		visual = "mesh",
		mesh = "mobs_bee.x",
		drawtype = "front",
		textures = {
			{"mobs_bee.png"},
		},
		--textures = { {"fun_caves_killer_bee.png"}, }
		--visual_size = {x = 1.5, y = 1.5},
		makes_footstep_sound = false,
		sounds = {
			random = "mobs_bee",
		},
		walk_velocity = 1,
		run_velocity = 2,
		fall_speed = -3,
		jump = true,
		view_range = 15,
		floats = 0,
		drops = {
			{name = "mobs:honey", chance = 2, min = 1, max = 2},
		},
		water_damage = 1,
		lava_damage = 5,
		light_damage = 0,
		fall_damage = 0,
		--lifetimer = 360,
		follow = nil,
		animation = {
			speed_normal = 15,
			stand_start = 0,
			stand_end = 30,
			walk_start = 35,
			walk_end = 65,
		},
		do_custom = bee_do
	})


	mobs:register_spawn("fun_caves:killer_bee", {"fun_caves:tree", "fun_caves:ironwood", "fun_caves:diamondwood"}, 20, -1, 300, 5, 31000)
	mobs:register_spawn("fun_caves:killer_bee", {"fun_caves:glowing_fungal_wood"}, 20, -1, 100, 5, 31000)
	mobs:register_egg("fun_caves:killer_bee", "Killer Bee", "mobs_bee_inv.png", 1)


	local m = table.copy(minetest.registered_entities["fun_caves:killer_bee"])
	m.name = 'fun_caves:killer_bee_drone'
	m.damage = 3
	m.hp_min = 3
	m.hp_max = 9
	m.collisionbox = {-0.25, 0, -0.25, 0.25, 0.25, 0.25}
	m.visual_size = {x = 1.25, y = 1.25}

	minetest.registered_entities["fun_caves:killer_bee_drone"] = m
	mobs.spawning_mobs["fun_caves:killer_bee_drone"] = true

	mobs:register_spawn("fun_caves:killer_bee_drone", {"fun_caves:tree", "fun_caves:ironwood", "fun_caves:diamondwood"}, 20, -1, 1000, 5, 31000)

	m = table.copy(minetest.registered_entities["fun_caves:killer_bee"])
	m.name = 'fun_caves:killer_bee_queen'
	m.damage = 2
	m.hp_min = 4
	m.hp_max = 12
	m.collisionbox = {-0.3, 0, -0.3, 0.3, 0.3, 0.3}
	m.visual_size = {x = 1.5, y = 1.25}

	minetest.registered_entities["fun_caves:killer_bee_queen"] = m
	mobs.spawning_mobs["fun_caves:killer_bee_queen"] = true

	mobs:register_spawn("fun_caves:killer_bee_queen", {"fun_caves:tree", "fun_caves:ironwood", "fun_caves:diamondwood"}, 20, -1, 4000, 5, 31000)
end

if minetest.registered_entities["kpgmobs:wolf"] then
	local m = table.copy(minetest.registered_entities["kpgmobs:wolf"])
	m.name = 'fun_caves:white_wolf'
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

if minetest.registered_entities["dmobs:dragon"] then
	mobs:spawn_specific("dmobs:dragon", {"air"}, {"fun_caves:cloud", "fun_caves:storm_cloud"}, 20, 10, 300, 15000, 2, 4000, 31000)
end

if minetest.registered_entities["kpgmobs:medved"] then
	local m = table.copy(minetest.registered_entities["kpgmobs:medved"])
	m.name = 'fun_caves:moon_bear'
	m.textures = { {"fun_caves_moon_bear.png"}, }
	m.type = 'monster'
	m.base_texture = m.textures[1]

	minetest.registered_entities["fun_caves:moon_bear"] = m
	mobs.spawning_mobs["fun_caves:moon_bear"] = true

	mobs:register_spawn("fun_caves:moon_bear", {"default:dirt_with_snow", "fun_caves:cloud", "fun_caves:storm_cloud"}, 20, -1, 11000, 3, 31000, false)
	mobs:register_egg("fun_caves:moon_bear", "Moon Bear", "wool_white.png", 1)
end

if minetest.registered_entities["mobs_fish:clownfish"] then
	--local l_spawn_near		= {"default:sand","default:dirt","group:seaplants","group:seacoral"}
	mobs:spawn_specific("mobs_fish:clownfish", {"default:water_source", "default:water_flowing"}, {"default:sand","default:dirt", "fun_caves:cloud", "fun_caves:storm_cloud","group:seaplants","group:seacoral"}, 5, 20, 30, 10000, 1, 4000, 5000)
	mobs:spawn_specific("mobs_fish:tropical", {"default:water_source", "default:water_flowing"}, {"default:sand","default:dirt", "fun_caves:cloud", "fun_caves:storm_cloud","group:seaplants","group:seacoral"}, 5, 20, 30, 10000, 1, 4000, 5000)
	mobs:spawn_specific("mobs_fish:tropical", {"default:water_source", "default:water_flowing"}, nil, 5, 20, 30, 10000, 1, 8769, 8798)
end

if minetest.registered_entities["mobs_monster:spider"] then
	-- Deep spider
	local m = table.copy(minetest.registered_entities["mobs_monster:spider"])
	m.name = 'fun_caves:spider'
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
	m.name = 'fun_caves:spider_ice'
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
	m.name = 'fun_caves:dangler'
	m.docile_by_day = false
	m.attacks_monsters = true
	m.damage = 2
	m.hp_min = 9
	m.hp_max = 27
	m.armor = 100
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
	m.name = 'fun_caves:tarantula'
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
	m.name = 'fun_caves:tar_monster'
	m.damage = 2
	m.hp_min = 10
	m.hp_max = 30
	m.armor = 200
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
	m.name = 'fun_caves:sand_monster'
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
	mobs:spawn_specific("mobs_sharks:shark_sm", {"default:water_source"}, nil, 5, 20, 30, 60000, 1, 8769, 8798)
	mobs:spawn_specific("mobs_sharks:shark_md", {"default:water_source"}, nil, 5, 20, 30, 60000, 1, 8769, 8798)
	mobs:spawn_specific("mobs_sharks:shark_lg", {"default:water_source"}, nil, 5, 20, 30, 60000, 1, 8769, 8798)

	local m = table.copy(minetest.registered_entities["mobs_sharks:shark_lg"])
	local l_spawn_in		= {"default:water_flowing","default:water_source"}
	local l_spawn_near		= {"default:water_flowing","default:water_source","seawrecks:woodship","seawrecks:uboot"}

	m.name = 'fun_caves:shark_giant'
	m.damage = 7
	m.hp_min = 20
	m.hp_max = 60
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
dofile(fun_caves.path.."/goblin.lua")

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
