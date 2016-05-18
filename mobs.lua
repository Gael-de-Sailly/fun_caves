
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


dofile(fun_caves.path .. "/mobs_crafts.lua")
dofile(fun_caves.path .. "/danglers.lua")
dofile(fun_caves.path .. "/spider.lua")
dofile(fun_caves.path .. "/spider_ice.lua")
dofile(fun_caves.path .. "/dirt_monster.lua")
dofile(fun_caves.path .. "/stone_monster.lua")
dofile(fun_caves.path .. "/lava_flan.lua")
--dofile(fun_caves.path .. "/dungeon_master.lua")
--dofile(fun_caves.path .. "/mese_monster.lua")
dofile(fun_caves.path .. "/sand_monster.lua")

fun_caves.goblin_spawn_frequency = 150

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
