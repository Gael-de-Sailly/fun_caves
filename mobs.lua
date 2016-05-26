
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

fun_caves.surface_damage = function(self, cold_natured)
	if not self.fun_caves_damage_timer then
		self.fun_caves_damage_timer = 0
	end

	self.fun_caves_damage_timer = self.fun_caves_damage_timer + 1
	if self.fun_caves_damage_timer > 30 then
		self.fun_caves_damage_timer = 0
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
	end
end


local path = minetest.get_modpath(minetest.get_current_modname())
dofile(path .. "/danglers.lua")
dofile(path .. "/spider.lua")
dofile(path .. "/tarantula.lua")
dofile(path .. "/spider_ice.lua")
--dofile(path .. "/dirt_monster.lua")
dofile(path .. "/sand_monster.lua")
dofile(path .. "/tar_monster.lua")

if minetest.registered_entities["mobs_monster:dirt_monster"] then
	-- check this
	mobs:register_spawn("mobs_monster:dirt_monster", {"default:dirt"}, 7, 0, 7000, 1, -50, false)
end
if minetest.registered_entities["mobs_slimes:green_big"] then
	mobs:spawn_specific("mobs_slimes:green_big",
	{"fun_caves:stone_with_moss", "fun_caves:stone_with_algae"},
	{"air"},
	4, 20, 30, 30000, 1, -31000, 31000
	)
	mobs:spawn_specific("mobs_slimes:green_medium",
	{"fun_caves:stone_with_moss", "fun_caves:stone_with_algae"},
	{"air"},
	4, 20, 30, 30000, 2, -31000, 31000
	)
	mobs:spawn_specific("mobs_slimes:green_small",
	{"default:dirt_with_grass", "default:junglegrass", "default:mossycobble", "ethereal:green_dirt_top"},
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


fun_caves.goblin_spawn_frequency = 150
fun_caves.goblin_trap_freq = 500
fun_caves.goblin_torch_freq = 10

fun_caves.goblin_drops = { "default:pick_steel",  "default:sword_steel", "default:shovel_steel", "farming:bread", "bucket:bucket_water", "default:pick_stone", "default:sword_stone" }
--{"group:stone"} = { "default:stone", "default:mossycobble", "default:sandstone", "default:desert_stone", "default:stone_with_coal", "default:stone_with_iron", "default:stone_with_copper", "default:stone_with_gold", "default:stone_with_diamond" }

dofile(path.."/goblin_cobbler.lua")
dofile(path.."/goblin_digger.lua")
dofile(path.."/goblin_coal.lua")
dofile(path.."/goblin_ice.lua")
dofile(path.."/goblin_copper.lua")
dofile(path.."/goblin_iron.lua")
dofile(path.."/goblin_gold.lua")
dofile(path.."/goblin_diamond.lua")
dofile(path.."/goblin_king.lua")
