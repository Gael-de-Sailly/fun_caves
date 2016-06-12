fun_caves.water_plants = {}
local function register_water_plant(desc)
	fun_caves.water_plants[#fun_caves.water_plants+1] = desc
end


minetest.register_node("fun_caves:pillar_coral", {
	description = "Pillar Coral",
	tiles = {"fun_caves_pillar_coral.png"},
	paramtype = "light",
	light_source = 2,
	groups = {cracky = 3, stone=1},
	sounds = default.node_sound_stone_defaults(),
})


minetest.register_node("fun_caves:brain_coral", {
	description = "Brain Coral",
	tiles = {"fun_caves_brain_coral.png"},
	light_source = 4,
	groups = {cracky = 3, stone=1,},
	sounds = default.node_sound_stone_defaults(),
})


minetest.register_node("fun_caves:dragon_eye", {
	description = "Dragon Eye",
	tiles = {"fun_caves_dragon_eye.png"},
	light_source = 4,
	groups = {cracky = 3, stone=1,},
	sounds = default.node_sound_stone_defaults(),
})


fun_caves.plantlist = {
	{name="staghorn_coral",
	 desc="Staghorn Coral",
	 water=true,
	 light_source=1,
	 coral=true,
	 sounds = default.node_sound_stone_defaults(),
	},

	{name="precious_coral",
	 desc="Precious Coral",
	 water=true,
	 light_source=1,
	 coral=true,
	 sounds = default.node_sound_stone_defaults(),
	},

	{name="water_plant_1",
	 desc="Water Plant",
	 water=true,
	},

	{name="bird_of_paradise",
	 desc="Bird of Paradise",
	 light=true,
	 groups={flower=1},
	},

	{name="gerbera",
	 desc="Gerbera",
	 light=true,
	 groups={flower=1, color_pink=1},
	},

	{name="hibiscus",
	 desc="Hibiscus",
	 wave=true,
	 groups={flower=1, color_white=1},
	},

	{name="orchid",
	 desc="Orchid",
	 wave=true,
	 light=true,
	 groups={flower=1, color_white=1},
	},
}


for _, plant in ipairs(fun_caves.plantlist) do
	if plant.coral then
		groups = {cracky=3, stone=1, attached_node=1}
	else
		groups = {snappy=3,flammable=2,flora=1,attached_node=1}
	end
	if plant.groups then
		for k,v in pairs(plant.groups) do
			groups[k] = v
		end
	end

	minetest.register_node("fun_caves:"..plant.name, {
		description = plant.desc,
		drawtype = "plantlike",
		tiles = {"fun_caves_"..plant.name..".png"},
		waving = plant.wave,
		sunlight_propagates = plant.light,
		paramtype = "light",
		walkable = false,
		groups = groups,
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		},
	})

	if plant.water then
		local def = {
			description = plant.desc,
			drawtype = "nodebox",
			node_box = {type='fixed', fixed={{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}, {-0.5, 0.5, -0.001, 0.5, 1.5, 0.001}, {-0.001, 0.5, -0.5, 0.001, 1.5, 0.5}}},
			drop = {max_items=2, items={{items={"fun_caves:"..plant.name}, rarity=1}, {items={"default:sand"}, rarity=1}}},
			tiles = { "default_sand.png", "fun_caves_"..plant.name..".png",},
			--tiles = { "default_dirt.png", "fun_caves_"..plant.name..".png",},
			sunlight_propagates = plant.light,
			--light_source = 14,
			paramtype = "light",
			light_source = plant.light_source,
			walkable = false,
			groups = groups,
			selection_box = {
				type = "fixed",
				fixed = {-0.5, 0.5, -0.5, 0.5, 11/16, 0.5},
			},
			sounds = plant.sounds or default.node_sound_leaves_defaults(),
		}
		minetest.register_node("fun_caves:"..plant.name.."_water_sand", def)
		def2 = table.copy(def)
		def2.tiles = { "default_dirt.png", "fun_caves_"..plant.name..".png",}
		def2.drop = {max_items=2, items={{items={"fun_caves:"..plant.name}, rarity=1}, {items={"default:dirt"}, rarity=1}}}
		minetest.register_node("fun_caves:"..plant.name.."_water_soil", def2)
		def2 = table.copy(def)
		def2.tiles = { "fun_caves_cloud.png", "fun_caves_"..plant.name..".png",}
		def2.drop = {max_items=2, items={{items={"fun_caves:"..plant.name}, rarity=1}, {items={"fun_caves:cloud"}, rarity=1}}}
		minetest.register_node("fun_caves:"..plant.name.."_water_cloud", def2)
		def2 = table.copy(def)
		def2.tiles = { "fun_caves_storm_cloud.png", "fun_caves_"..plant.name..".png",}
		def2.drop = {max_items=2, items={{items={"fun_caves:"..plant.name}, rarity=1}, {items={"fun_caves:storm_cloud"}, rarity=1}}}
		minetest.register_node("fun_caves:"..plant.name.."_water_storm_cloud", def2)
	end
end


local function register_flower(name, seed, biomes)
	local param = {
		deco_type = "simple",
		place_on = {"default:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = -0.02,
			scale = 0.03,
			spread = {x = 200, y = 200, z = 200},
			seed = seed,
			octaves = 3,
			persist = 0.6
		},
		biomes = biomes,
		y_min = 6,
		y_max = 31000,
		decoration = "fun_caves:"..name,
	}

	-- Let rainforest plants show up more often.
	local key1 = table.contains(biomes, "rainforest")
	local key2 = table.contains(biomes, "desertstone_grassland")
	if key1 or key2 then
		if key1 then
			table.remove(param.biomes, key1)
		else
			table.remove(param.biomes, key2)
		end
		if #param.biomes > 0 then
			minetest.register_decoration(param)
		end

		local param2 = table.copy(param)
		param2.biomes = {"rainforest", "desertstone_grassland", }
		param2.noise_params.seed = param2.noise_params.seed + 20
		param2.noise_params.offset = param2.noise_params.offset + 0.01
		minetest.register_decoration(param2)
	else
		minetest.register_decoration(param)
	end
end

register_flower("bird_of_paradise", 8402, {"rainforest", "desertstone_grassland", })
register_flower("orchid", 3944, {"sandstone_grassland", "tundra", "taiga", "stone_grassland", "coniferous_forest", "deciduous_forest", "savanna", "rainforest", "rainforest_swamp", "desertstone_grassland", })
register_flower("hibiscus", 7831, {"sandstone_grassland", "deciduous_forest", "savanna", "rainforest", "rainforest_swamp", "desertstone_grassland", })
--register_flower("calla_lily", 7985, {"sandstone_grassland", "stone_grassland", "deciduous_forest", "rainforest", "desertstone_grassland", })
register_flower("gerbera", 1976, {"savanna", "rainforest", "desertstone_grassland", })

do
	-- Water Plant
	local water_plant_1_def_sand = {
		fill_ratio = 0.05,
		place_on = {"group:sand"},
		decoration = {"fun_caves:water_plant_1_water_sand"},
		--biomes = {"sandstone_grassland", "stone_grassland", "coniferous_forest", "deciduous_forest", "desert", "savanna", "rainforest", "rainforest_swamp", },
		biomes = {"sandstone_grassland", "stone_grassland", "coniferous_forest", "deciduous_forest", "savanna", "rainforest", "rainforest_swamp","sandstone_grassland_ocean", "stone_grassland_ocean", "coniferous_forest_ocean", "deciduous_forest_ocean", "desert_ocean", "savanna_ocean", "desertstone_grassland", },
		y_max = 60,
	}
	local water_plant_1_def_soil = table.copy(water_plant_1_def_sand)
	water_plant_1_def_soil.place_on = {"group:soil"}
	water_plant_1_def_soil.decoration = {"fun_caves:water_plant_1_water_soil",}
	local water_plant_1_def_cloud = table.copy(water_plant_1_def_sand)
	water_plant_1_def_cloud.place_on = {"group:cloud"}
	water_plant_1_def_cloud.decoration = {"fun_caves:water_plant_1_water_cloud",}
	local water_plant_1_def_storm_cloud = table.copy(water_plant_1_def_sand)
	water_plant_1_def_storm_cloud.place_on = {"group:cloud"}
	water_plant_1_def_storm_cloud.decoration = {"fun_caves:water_plant_1_water_storm_cloud",}

	register_water_plant(water_plant_1_def_sand)
	register_water_plant(water_plant_1_def_soil)
	register_water_plant(water_plant_1_def_cloud)
	register_water_plant(water_plant_1_def_storm_cloud)
end


-- Get the content ids for all registered water plants.
for _, desc in pairs(fun_caves.water_plants) do
	if type(desc.decoration) == 'string' then
		desc.content_id = minetest.get_content_id(desc.decoration)
	elseif type(desc.decoration) == 'table' then
		desc.content_id = minetest.get_content_id(desc.decoration[1])
	end
end
