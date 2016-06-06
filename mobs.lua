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


dofile(fun_caves.path .. "/danglers.lua")
dofile(fun_caves.path .. "/spider.lua")
dofile(fun_caves.path .. "/tarantula.lua")
dofile(fun_caves.path .. "/spider_ice.lua")
dofile(fun_caves.path .. "/sand_monster.lua")
dofile(fun_caves.path .. "/tar_monster.lua")

if minetest.registered_entities["mobs_monster:dirt_monster"] then
	-- check this
	mobs:register_spawn("mobs_monster:dirt_monster", {"default:dirt"}, 7, 0, 4000, 1, -50)
	mobs:register_spawn("mobs_monster:dirt_monster", {"default:dirt_with_dry_grass"}, 7, 0, 7000, 1, 31000, false)
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
}
for _, mob in pairs(t_mobs) do
	if minetest.registered_entities[mob] then
		fun_caves.fortress_spawns[#fun_caves.fortress_spawns+1] = mob
	end
end
