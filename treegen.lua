local rand = math.random
local min = math.min
local max = math.max
local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local max_depth = 31000


local newnode = fun_caves.clone_node("default:tree")
newnode.description = "Bark"
newnode.tiles = {"default_tree.png"}
newnode.is_ground_content = false
minetest.register_node("fun_caves:bark", newnode)

newnode = fun_caves.clone_node("default:tree")
newnode.description = "Giant Wood"
newnode.tiles = {"fun_caves_tree.png"}
newnode.is_ground_content = false
minetest.register_node("fun_caves:tree", newnode)

minetest.register_craft({
	output = 'default:wood 4',
	recipe = {
		{'fun_caves:tree'},
	}
})

minetest.register_node("fun_caves:ironwood", {
	description = "Ironwood",
	tiles = {"fun_caves_tree.png^[colorize:#B7410E:80"},
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, level=1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("fun_caves:diamondwood", {
	description = "Diamondwood",
	tiles = {"fun_caves_tree.png^[colorize:#5D8AA8:80"},
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, level=2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("fun_caves:petrified_wood", {
	description = "Petrified Wood",
	tiles = {"ores_petrified_wood.png"},
	groups = {cracky = 3, stone = 1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("fun_caves:leaves", {
	description = "Leaves",
	visual_scale = 1.3,
	tiles = {"default_leaves.png^[noalpha"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy = 3, flammable = 2},
	drop = {
		max_items = 1,
		items = {
			{
				items = {'default:sapling'},
				rarity = 20,
			},
			{
				items = {'default:leaves'},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

newnode = fun_caves.clone_node("default:water_source")
newnode.description = "Water"
newnode.liquid_range = 0
newnode.liquid_viscosity = 7
newnode.liquid_renewable = false
newnode.liquid_alternative_flowing = "fun_caves:weightless_water"
newnode.liquid_alternative_source = "fun_caves:weightless_water"
minetest.register_node("fun_caves:weightless_water", newnode)

bucket.liquids['fun_caves:weightless_water'] = {
	source = 'fun_caves:weightless_water',
	flowing = 'fun_caves:weightless_water',
	itemname = 'bucket:bucket_water',
}

newnode = fun_caves.clone_node("fun_caves:weightless_water")
newnode.description = "Sap"
newnode.tiles[1].name =  "fun_caves_sap_source_animated.png"
newnode.special_tiles[1].name =  "fun_caves_sap_source_animated.png"
newnode.inventory_image = minetest.inventorycube("default_water.png^[colorize:#FF7E00:B0")
newnode.liquid_alternative_flowing = "fun_caves:sap"
newnode.liquid_alternative_source = "fun_caves:sap"
newnode.post_effect_color = {a = 120, r = 255, g = 191, b = 0}
minetest.register_node("fun_caves:sap", newnode)

bucket.register_liquid(
	"fun_caves:sap",
	"fun_caves:sap",
	"fun_caves:bucket_sap",
	"fun_caves_bucket_sap.png",
	"Bucket of Sap",
	{}
)

minetest.register_node("fun_caves:syrup", {
	description = "Syrup",
	drawtype = "plantlike",
	tiles = {"fun_caves_syrup.png"},
	inventory_image  = "fun_caves_syrup.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.25, 0.25}
	},
	groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
	on_use = minetest.item_eat(2, "vessels:glass_bottle"),
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_craftitem("fun_caves:charcoal", {
	description = "Charcoal Briquette",
	inventory_image = "default_coal_lump.png",
	groups = {coal = 1}
})

minetest.register_craft({
	type = "fuel",
	recipe = "fun_caves:charcoal",
	burntime = 50,
})

minetest.register_craft({
	type = "cooking",
	output = "default:sand",
	recipe = "fun_caves:bark",
})

minetest.register_craft({
	type = "cooking",
	output = "default:iron_lump",
	recipe = "fun_caves:ironwood",
})

minetest.register_craft({
	type = "cooking",
	output = "default:diamond",
	recipe = "fun_caves:diamondwood",
})

minetest.register_craft({
	type = "cooking",
	output = "fun_caves:charcoal",
	recipe = "group:tree",
})

minetest.register_craft({
	output = 'default:torch 4',
	recipe = {
		{'fun_caves:charcoal'},
		{'group:stick'},
	}
})

minetest.register_craft({
	output = 'fun_caves:syrup',
	type = "shapeless",
	recipe = {
		'vessels:glass_bottle',
		'fun_caves:bucket_sap',
	},
	replacements = {{'fun_caves:bucket_sap', 'bucket:bucket_empty'},},
})


--minetest.register_craft( {
--	output = "vessels:glass_bottle 10",
--	recipe = {
--		{ "fun_caves:amber", "", "fun_caves:amber" },
--		{ "fun_caves:amber", "", "fun_caves:amber" },
--		{ "", "fun_caves:amber", "" }
--	}
--})


local tree_noise_1 = {offset = 0, scale = 1, seed = 7227, spread = {x = 10, y = 10, z = 10}, octaves = 3, persist = 1, lacunarity = 2}
local wood_noise = {offset = 0, scale = 1, seed = -4640, spread = {x = 32, y = 32, z = 32}, octaves = 4, persist = 0.7, lacunarity = 2}


fun_caves.treegen = function(minp, maxp, data, p2data, area, node)
	local tree_n = minetest.get_perlin(tree_noise_1):get2d({x=floor((minp.x + 32) / 160) * 80, y=floor((minp.z + 32) / 160) * 80})
	if minp.y < -112 or minp.y > 208 or (not fun_caves.DEBUG and tree_n < 0.5) then
		return
	end

	local csize = vector.add(vector.subtract(maxp, minp), 1)
	local map_max = {x = csize.x, y = csize.y + 2, z = csize.z}
	local map_min = {x = minp.x, y = minp.y - 1, z = minp.z}

	local wood_1 = minetest.get_perlin_map(wood_noise, map_max):get3dMap_flat(map_min)

	local write = false

	local index = 0
	local index3d = 0
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			local dx = (x + 32) % 160 - 80
			local dz = (z + 32) % 160 - 80
			local r2 = 70 + floor(dx / 4) % 3 * 6 + floor(dz / 4) % 3 * 6

			index = index + 1
			index3d = (z - minp.z) * (csize.y + 2) * csize.x + (x - minp.x) + 1
			local ivm = area:index(x, minp.y - 1, z)

			for y = minp.y - 1, maxp.y + 1 do
				local dy = y - minp.y
				local r = 20
				if abs(y - 50) > 130 then
					r = max(0, r - floor((abs(y - 50) - 130) / 2))
				end

				local distance = floor(math.sqrt(dx ^ 2 + dz ^ 2))
				if distance < r then
					if distance % 8 == 7 and wood_1[index3d] < 0.3 then
						data[ivm] = node['fun_caves:petrified_wood']
					elseif wood_1[index3d] < -0.98 then
						data[ivm] = node['fun_caves:weightless_water']
					elseif wood_1[index3d] < -0.8 then
						data[ivm] = node['air']
					elseif wood_1[index3d] < -0.05 then
						data[ivm] = node['fun_caves:tree']
					elseif wood_1[index3d] < 0.05 then
						data[ivm] = node['air']
					elseif wood_1[index3d] < 0.6 then
						data[ivm] = node['fun_caves:tree']
					elseif wood_1[index3d] < 0.97 then
						data[ivm] = node['fun_caves:ironwood']
					else
						data[ivm] = node['fun_caves:diamondwood']
					end

					if data[ivm] ~= node['air'] and data[ivm] ~= node['fun_caves:weightless_water'] and rand(500) == 1 then
						data[ivm] = node['fun_caves:sap']
					end
					write = true
				elseif y < 222 and y > -132 and floor(dx ^ 2 + dz ^ 2) < (r + 2) ^ 2 then
					data[ivm] = node['fun_caves:bark']
					write = true

				-- foliage
				elseif y < 272 and y > 112 and floor(dx ^ 2 + dz ^ 2 + (y - 192) ^ 2) < r2 ^ 2 and y % 10 == 0 and (floor(dx / 4) % 3 == 0 or floor(dz / 4) % 3 == 0) then
					if data[ivm] == node['air'] then
						data[ivm] = node['fun_caves:bark']
						write = true
					end
				elseif y < 275 and y > 115 and floor(dx ^ 2 + dz ^ 2 + (y - 192) ^ 2) < r2 ^ 2 and (y + 3) % 10 < 7 and (floor((dx + 3) / 4) % 3 < 2 or floor((dz + 3) / 4) % 3 < 2) then
					local r = abs(((y + 3) % 10) - 3)
					if (r < 2 or rand(r) == 1) and data[ivm] == node['air'] then
						data[ivm] = node['fun_caves:leaves']
						write = true
					end
				end

				ivm = ivm + area.ystride
				index3d = index3d + csize.x
			end
		end
	end

	return write
end
