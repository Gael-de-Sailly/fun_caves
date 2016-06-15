fun_caves = {}
fun_caves.version = "1.0"
fun_caves.time_factor = 10  -- affects growth abms
fun_caves.light_max = 8  -- light intensity for mushroom growth
fun_caves.path = minetest.get_modpath(minetest.get_current_modname())
fun_caves.world = minetest.get_worldpath()
fun_caves.DEBUG = false  -- for maintenance only



local inp = io.open(fun_caves.world..'/fun_caves_data.txt','r')
if inp then
	local d = inp:read('*a')
	fun_caves.db = minetest.deserialize(d)
else
	fun_caves.db = {}
end


minetest.register_on_mapgen_init(function(mgparams)
	minetest.set_mapgen_params({flags="nocaves,nodungeons"})
end)


-- Check if the table contains an element.
function table.contains(table, element)
  for key, value in pairs(table) do
    if value == element then
			if key then
				return key
			else
				return true
			end
    end
  end
  return false
end

-- Modify a node to add a group
function minetest.add_group(node, groups)
	local def = minetest.registered_items[node]
	if not def then
		return false
	end
	local def_groups = def.groups or {}
	for group, value in pairs(groups) do
		if value ~= 0 then
			def_groups[group] = value
		else
			def_groups[group] = nil
		end
	end
	minetest.override_item(node, {groups = def_groups})
	return true
end

function fun_caves.clone_node(name)
	local node = minetest.registered_nodes[name]
	local node2 = table.copy(node)
	return node2
end


dofile(fun_caves.path .. "/abms.lua")
dofile(fun_caves.path .. "/unionfind.lua")
dofile(fun_caves.path .. "/nodes.lua")
dofile(fun_caves.path .. "/deco.lua")
dofile(fun_caves.path .. "/fungal_tree.lua")
dofile(fun_caves.path .. "/mapgen.lua")

if mobs and mobs.mod == "redo" then
	dofile(fun_caves.path .. "/mobs.lua")
end
