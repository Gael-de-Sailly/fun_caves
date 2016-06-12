
local newnode = fun_caves.clone_node("default:dirt")
newnode.description = "Cloud"
newnode.tiles = {'fun_caves_storm_cloud.png'}
newnode.sunlight_propagates = true
minetest.register_node("fun_caves:cloud", newnode)
