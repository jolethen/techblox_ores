local modname = minetest.get_current_modname()

-- 1. REGISTER THE MMO BARLEY NODE (Fully Grown Stage)
minetest.register_node(modname .. ":mmo_barley", {
    description = "Public Resource Barley (Regenerating)",
    drawtype = "plantlike",
    -- Set to stage 8 texture directly
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

    -- Harvest only possible at full stage 8 maturity
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if digger and digger:is_player() then
            local inv = digger:get_inventory()
            
            local barley_item = minetest.registered_items["farming:barley"] and "farming:barley 2" or "farming:barley_item 2"
            local seed_item = "farming:seed_barley 1" or "farming:barley_seed 1"

            -- Gives 2 Barley and 1 Seed directly to inventory
            local drop_barley = inv:add_item("main", barley_item)
            local drop_seed = inv:add_item("main", seed_item)
            
            if not drop_barley:is_empty() then minetest.add_item(pos, drop_barley) end
            if not drop_seed:is_empty() then minetest.add_item(pos, drop_seed) end
        end

        -- Sequential steps: starts at 1, ticks to 3, ticks to 5, then hits your master block
        local stages = {
            "farming:barley_1",  
            "farming:barley_3",  
            "farming:barley_5",  
            modname .. ":mmo_barley"  
        }

        -- 30 seconds / 3 shifts = 10 second delay between growth loops
        local delay_per_stage = 10 

        -- Immediately reset to the ground stage 1 on harvest
        minetest.set_node(pos, {name = "farming:barley_1"})

        -- Fire up the sequential loop starting at step 2 (farming:barley_3)
        resource_zones.start_crop_growth(pos, stages, 2, delay_per_stage)
    end,
})
