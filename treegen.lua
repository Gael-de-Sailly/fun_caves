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

local tree_noise_1 = {offset = 0, scale = 1, seed = 7227, spread = {x = 10, y = 10, z = 10}, octaves = 3, persist = 1, lacunarity = 2}
local limb_noise_1 = {offset = 0, scale = 1, seed = 3901, spread = {x = 80, y = 3, z = 80}, octaves = 3, persist = 1, lacunarity = 2}

fun_caves.treegen = function(minp, maxp, data, p2data, area, node)
	local tree_n = minetest.get_perlin(tree_noise_1):get2d({x=floor((minp.x + 32) / 160) * 80, y=floor((minp.z + 32) / 160) * 80})
	if minp.y < -112 or minp.y > 208 or tree_n < 0.5 then
		return
	end

	local csize = vector.add(vector.subtract(maxp, minp), 1)
	local map_max = {x = csize.x, y = csize.y, z = csize.z}
	local map_min = {x = minp.x, y = minp.y, z = minp.z}

	local limb_1 = minetest.get_perlin_map(limb_noise_1, map_max):get3dMap_flat(map_min)

	local write = false

	local index = 0
	local index3d = 0
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			local dx = (x + 32) % 160 - 80
			local dz = (z + 32) % 160 - 80
			local r2 = 70 + floor(dx / 4) % 3 * 6 + floor(dz / 4) % 3 * 6

			index = index + 1
			index3d = (z - minp.z) * (csize.y) * csize.x + (x - minp.x) + 1
			local ivm = area:index(x, minp.y, z)

			for y = minp.y, maxp.y do
				local dy = y - minp.y
				local r = 20
				if abs(y - 80) > 100 then
					r = max(0, r - floor((abs(y - 80) - 100) / 2))
				end

				if floor(dx ^ 2 + dz ^ 2) < r ^ 2 then
					data[ivm] = node['fun_caves:tree']
					write = true
				elseif y < 222 and y > -102 and floor(dx ^ 2 + dz ^ 2) < (r + 2) ^ 2 then
					data[ivm] = node['fun_caves:bark']
					write = true
				elseif y < 272 and y > 112 and floor(dx ^ 2 + dz ^ 2 + (y - 192) ^ 2) < r2 ^ 2 and y % 10 == 0 and (floor(dx / 4) % 3 == 0 or floor(dz / 4) % 3 == 0) then
					if data[ivm] == node['air'] then
						data[ivm] = node['fun_caves:tree']
						write = true
					end
				elseif y < 272 and y > 112 and floor(dx ^ 2 + dz ^ 2 + (y - 192) ^ 2) < r2 ^ 2 and (y + 3) % 10 < 7 and (floor((dx + 3) / 4) % 3 < 2 or floor((dz + 3) / 4) % 3 < 2) then
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
