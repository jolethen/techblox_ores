local modname = minetest.get_current_modname()

-- 1. REGISTER STAGE 1 (Seedling)
minetest.register_node(modname .. ":mmo_barley_1", {
    description = "MMO Barley (Stage 1)",
    drawtype = "plantlike",
    tiles = {"x_farming_barley_1.png"},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    buildable_to = true,
    groups = {snappy = 3, flammable = 2, attached_node = 1, plant = 1},
    drop = "", -- Drops nothing if broken early
})

-- 2. REGISTER STAGE 3 (Sprout)
minetest.register_node(modname .. ":mmo_barley_3", {
    description = "MMO Barley (Stage 3)",
    drawtype = "plantlike",
    tiles = {"x_farming_barley_3.png"},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    buildable_to = true,
    groups = {snappy = 3, flammable = 2, attached_node = 1, plant = 1},
    drop = "",
})

-- 3. REGISTER STAGE 5 (Growing)
minetest.register_node(modname .. ":mmo_barley_5", {
    description = "MMO Barley (Stage 5)",
    drawtype = "plantlike",
    tiles = {"x_farming_barley_5.png"},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    buildable_to = true,
    groups = {snappy = 3, flammable = 2, attached_node = 1, plant = 1},
    drop = "",
})

-- 4. REGISTER STAGE 8 (Fully Grown & Harvestable)
minetest.register_node(modname .. ":mmo_barley_8", {
    description = "Public Resource Barley (Fully Grown)",
    drawtype = "plantlike",
    tiles = {"x_farming_barley_8.png"},
    inventory_image = "x_farming_barley_8.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    buildable_to = true,
    groups = {snappy = 3, flammable = 2, attached_node = 1, plant = 1},
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    },

    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if digger and digger:is_player() then
            local inv = digger:get_inventory()
            
            local barley_item = minetest.registered_items["farming:barley"] and "farming:barley 2" or "farming:seed_barley 2"
            local seed_item = minetest.registered_items["farming:seed_barley"] and "farming:seed_barley 1" or "farming:barley_seed 1"

            local drop_barley = inv:add_item("main", barley_item)
            local drop_seed = inv:add_item("main", seed_item)
            
            if not drop_barley:is_empty() then minetest.add_item(pos, drop_barley) end
            if not drop_seed:is_empty() then minetest.add_item(pos, drop_seed) end
        end

        -- FIX: The sequential list of states matching the order they happen in-world
        local stages = {
            modname .. ":mmo_barley_1", -- Index 1 (Placed instantly)
            modname .. ":mmo_barley_3", -- Index 2 (Next state)
            modname .. ":mmo_barley_5", -- Index 3 (Next state)
            modname .. ":mmo_barley_8"  -- Index 4 (Final state)
        }

        -- 30 seconds total / 3 shifts = 10 seconds per shift
        local delay_per_stage = 10

        -- Reset instantly to Stage 1
        minetest.set_node(pos, {name = modname .. ":mmo_barley_1"})

        -- Move to Index 2 (mmo_barley_3). init.lua will check if Index 1 is currently there. (Passes!)
        resource_zones.start_crop_growth(pos, stages, 2, delay_per_stage)
    end,
})
