-------------------
-- Fungal Tree   --
-------------------

local rand = math.random
local max = math.max

local colors = {}
colors["^[colorize:#FF00FF:60"] = "dye:violet"
colors["^[colorize:#0000FF:60"] = "dye:blue"
colors["^[colorize:#FF4500:80"] = "dye:green"
colors[""] = "dye:white"
local fungal_tree_leaves = {}

local newnode = fun_caves.clone_node("farming:straw")
newnode.description = "Dry Fiber"
minetest.register_node("fun_caves:dry_fiber", newnode)


minetest.register_node("fun_caves:fungal_tree_fruit", {
	description = "Fungal tree fruit",
	drawtype = "plantlike",
	visual_scale = 0.75,
	tiles = {"fun_caves_fungal_tree_fruit.png"},
	--inventory_image = ".png",
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 6,
	walkable = false,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0, 0.2}
	},
	groups = {fleshy = 3, dig_immediate = 3, flammable = 2},
	--on_use = minetest.item_eat(2),
	sounds = default.node_sound_leaves_defaults(),
	on_timer = fun_caves.soft_boom,
	on_punch = fun_caves.soft_boom,
})

local fruit = minetest.get_content_id("fun_caves:fungal_tree_fruit")

function fun_caves.make_fungal_tree(data, area, ivm, height)
	local leaf = minetest.get_content_id(fungal_tree_leaves[rand(#fungal_tree_leaves)])
	for y = 0, height do
		local radius = 1
		if y > 1 and y < height - 2 then
			radius = 2
		end
		for z = -radius,radius do
			for x = -radius,radius do
				local sr = rand(1,100)
				local i = ivm + z*area.zstride + y*area.ystride + x
				if x == 0 and y == 0 and z == 0 then
					data[i] = leaf
				elseif sr == 1 then
					data[i] = fruit
				elseif sr < 50 then
					data[i] = leaf
				end
			end
		end
	end
end

-- multicolored growths
local count = 0
for color, dye in pairs(colors) do
	count = count + 1
	local name = "fun_caves:fungal_tree_leaves_"..count
	fungal_tree_leaves[#fungal_tree_leaves+1] = name

	minetest.register_node(name, {
		description = "Fungal tree growths",
		drawtype = "allfaces_optional",
		waving = 1,
		visual_scale = 1.3,
		tiles = {"fun_caves_fungal_tree_leaves.png"..color},
		paramtype = "light",
		is_ground_content = false,
		groups = {snappy=3, flammable=3, plant=1},
		drop = {
			max_items = 1,
			items = {
				--{items = {"fun_caves:"..tree.name.."_sapling"}, rarity = tree.drop_rarity },
				{items = {name} }
			}
		},
		sounds = default.node_sound_leaves_defaults(),
		after_place_node = default.after_place_leaves,
	})

	minetest.register_craft({
		type = "cooking",
		output = "fun_caves:dry_fiber",
		recipe = name,
		cooktime = 2,
	})

	if dye then
		minetest.register_craft({
			output = dye,
			recipe = {
				{name}
			}
		})
	end
end

minetest.register_craft({
	output = "dye:yellow",
	recipe = {
		{"flowers:mushroom_brown"}
	}
})
