local modname = minetest.get_current_modname()

-- RENEWABLE COAL ORE (2 Second Cooldown)
minetest.register_node(modname .. ":renewable_coal", {
    description = "Renewable Coal Ore",
    tiles = {"default_stone.png^default_mineral_coal.png"},
    groups = {cracky = 3},
    drop = "", 

    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if digger and digger:is_player() then
            local inv = digger:get_inventory()
            local leftover = inv:add_item("main", "default:coal_lump 1")
            if not leftover:is_empty() then
                minetest.add_item(pos, leftover)
            end
        end
        resource_zones.start_regen_timer(pos, modname .. ":renewable_coal", 2)
    end,
})

-- RENEWABLE IRON ORE (10 Second Cooldown)
minetest.register_node(modname .. ":renewable_iron", {
    description = "Renewable Iron Ore",
    tiles = {"default_stone.png^default_mineral_iron.png"},
    groups = {cracky = 3},
    drop = "", 

    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if digger and digger:is_player() then
            local inv = digger:get_inventory()
            local leftover = inv:add_item("main", "default:iron_lump 1")
            if not leftover:is_empty() then
                minetest.add_item(pos, leftover)
            end
        end
        resource_zones.start_regen_timer(pos, modname .. ":renewable_iron", 10)
    end,
})
