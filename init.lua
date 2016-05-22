fun_caves = {}
fun_caves.version = "1.0"
fun_caves.path = minetest.get_modpath(minetest.get_current_modname())
fun_caves.world = false
fun_caves.time_factor = 10
fun_caves.node_match_cache = {}


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

function fun_caves.node(name)
	if not fun_caves.node_cache then
		fun_caves.node_cache = {}
	end

	if not fun_caves.node_cache[name] then
		fun_caves.node_cache[name] = minetest.get_content_id(name)
		if name ~= "ignore" and fun_caves.node_cache[name] == 127 then
			print("*** Failure to find node: "..name)
		end
	end

	return fun_caves.node_cache[name]
end


dofile(fun_caves.path .. "/nodes.lua")
dofile(fun_caves.path .. "/deco.lua")
dofile(fun_caves.path .. "/fungal_tree.lua")
dofile(fun_caves.path .. "/mapgen.lua")
dofile(fun_caves.path .. "/mobs.lua")


-- Inserting helps to ensure that fun_caves operates first.
table.insert(minetest.registered_on_generateds, 1, fun_caves.generate)
