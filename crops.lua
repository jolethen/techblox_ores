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
    groups = {snappy = 3, flammable = 2, attached_node = 1, plant = 1, cant_to_protect = 1},
    drop = "", 
    on_dig = function(pos, node, digger)
        -- Do nothing, completely indestructible / non-harvestable early stage
    end,
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
    groups = {snappy = 3, flammable = 2, attached_node = 1, plant = 1, cant_to_protect = 1},
    drop = "",
    on_dig = function(pos, node, digger) end,
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
    groups = {snappy = 3, flammable = 2, attached_node = 1, plant = 1, cant_to_protect = 1},
    drop = "",
    on_dig = function(pos, node, digger) end,
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
    groups = {snappy = 3, flammable = 2, attached_node = 1, plant = 1, cant_to_protect = 1},
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    },
    drop = "",

    -- CRITICAL BYPASS: Custom on_dig cuts past core protection checks
    on_dig = function(pos, node, digger)
        if not digger or not digger:is_player() then return end
        
        local player_name = digger:get_player_name()

        -- 1. Award items directly (2 Barley, 1 Seed)
        local inv = digger:get_inventory()
        local barley_item = minetest.registered_items["farming:barley"] and "farming:barley 2" or "farming:seed_barley 2"
        local seed_item = minetest.registered_items["farming:seed_barley"] and "farming:seed_barley 1" or "farming:barley_seed 1"

        local drop_barley = inv:add_item("main", barley_item)
        local drop_seed = inv:add_item("main", seed_item)
        
        if not drop_barley:is_empty() then minetest.add_item(pos, drop_barley) end
        if not drop_seed:is_empty() then minetest.add_item(pos, drop_seed) end

        -- =========================================================================
        -- SERVER METRIC HOOK: Track who harvested this crop for Weekly Quests
        -- =========================================================================
        if weeklyquests and weeklyquests.add_progress then
            -- Pass the player name, action tracking key, and increment amount
            weeklyquests.add_progress(player_name, "harvest_mmo_barley", 1)
        end
        -- =========================================================================

        -- 2. Handle tool wear for things like swords/shears (snappy group)
        local tool = digger:get_wielded_item()
        local tp = tool:get_tool_capabilities()
        if tp and tp.groupcaps and tp.groupcaps.snappy then
            local wear = tp.groupcaps.snappy.uses and (65535 / tp.groupcaps.snappy.uses) or 0
            tool:add_wear(wear)
            digger:set_wielded_item(tool)
        end

        -- 3. Transition states array
        local stages = {
            modname .. ":mmo_barley_1", 
            modname .. ":mmo_barley_3", 
            modname .. ":mmo_barley_5", 
            modname .. ":mmo_barley_8"  
        }

        local delay_per_stage = 450

        -- Reset instantly to Stage 1
        minetest.set_node(pos, {name = modname .. ":mmo_barley_1"})

        -- Kick off background growth cycle loop
        if resource_zones and resource_zones.start_crop_growth then
            resource_zones.start_crop_growth(pos, stages, 2, delay_per_stage)
        else
            -- Fallback safety check if master script is broken
            minetest.set_node(pos, {name = modname .. ":mmo_barley_8"})
        end
    end,
})
