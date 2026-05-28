local modname = minetest.get_current_modname()

-- Register a dedicated MMO Wheat node for public zones
minetest.register_node(modname .. ":mmo_wheat", {
    description = "Public Resource Wheat (Regenerating)",
    -- Uses the visual model and texture of fully grown vanilla wheat
    drawtype = "plantlike",
    tiles = {"farming_wheat_8.png"},
    inventory_image = "farming_wheat.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    buildable_to = true,
    groups = {snappy = 3, flammable = 2, attached_node = 1},
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    },

    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        -- Give standard drops to the player
        if digger and digger:is_player() then
            local inv = digger:get_inventory()
            local drop_wheat = inv:add_item("main", "farming:wheat 1")
            local drop_seed = inv:add_item("main", "farming:seed_wheat 1")
            
            if not drop_wheat:is_empty() then minetest.add_item(pos, drop_wheat) end
            if not drop_seed:is_empty() then minetest.add_item(pos, drop_seed) end
        end

        -- Define the visual growth stages it will cycle through
        local stages = {
            "farming:wheat_2",  
            "farming:wheat_4",  
            "farming:wheat_6",  
            modname .. ":mmo_wheat"  -- Cycles back to this custom block at the end!
        }

        -- 1 hour total (3600 seconds) / 4 stages = 900 seconds per stage
        local delay_per_stage = 900 

        -- Reset the block to stage 1 instantly
        minetest.set_node(pos, {name = "farming:seed_wheat"})

        -- Begin the growth chain reaction
        resource_zones.start_crop_growth(pos, stages, 1, delay_per_stage)
    end,
})
