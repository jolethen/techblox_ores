local modname = minetest.get_current_modname()

-- RENEWABLE COAL ORE (2 Second Cooldown)
minetest.register_node(modname .. ":renewable_coal", {
    description = "Renewable Coal Ore",
    tiles = {"default_stone.png^default_mineral_coal.png"},
    -- Added cant_to_protect = 1 to allow harvesting in protected areas
    groups = {cracky = 3, cant_to_protect = 1},
    drop = "", 

    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if digger and digger:is_player() then
            local inv = digger:get_inventory()
            local leftover = inv:add_item("main", "default:coal_lump 1")
            if not leftover:is_empty() then
                minetest.add_item(pos, leftover)
            end
        end
        
        -- Start timer with a safety fallback check
        if resource_zones and resource_zones.start_regen_timer then
            resource_zones.start_regen_timer(pos, modname .. ":renewable_coal", 2)
        end
    end,
})

-- RENEWABLE IRON ORE (10 Second Cooldown)
minetest.register_node(modname .. ":renewable_iron", {
    description = "Renewable Iron Ore",
    tiles = {"default_stone.png^default_mineral_iron.png"},
    -- Added cant_to_protect = 1 to allow harvesting in protected areas
    groups = {cracky = 3, cant_to_protect = 1},
    drop = "", 

    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if digger and digger:is_player() then
            local inv = digger:get_inventory()
            local leftover = inv:add_item("main", "default:iron_lump 1")
            if not leftover:is_empty() then
                minetest.add_item(pos, leftover)
            end
        end
        
        -- Start timer with a safety fallback check
        if resource_zones and resource_zones.start_regen_timer then
            resource_zones.start_regen_timer(pos, modname .. ":renewable_iron", 10)
        end
    end,
})
