local modname = minetest.get_current_modname()

-- Configuration table for all renewable ores
local renewable_ores = {
    coal = {
        description = "Renewable Coal Ore",
        texture = "default_mineral_coal.png",
        drop_item = "default:coal_lump",
        cooldown = 2,
    },
    iron = {
        description = "Renewable Iron Ore",
        texture = "default_mineral_iron.png",
        drop_item = "default:iron_lump",
        cooldown = 10,
    },
    earth = {
        description = "Renewable Earth Rune Ore",
        -- FIXED: Explicitly telling the server to fetch this texture from the magic_materials mod assets
        texture = "magic_materials_earth_rune_ore.png^[combine:16x16:0,0=magic_materials_earth_rune_ore.png",
        drop_item = "magic_materials:earth_rune",
        cooldown = 15,
    },
    light = {
        description = "Renewable Light Rune Ore",
        -- FIXED: Explicitly telling the server to fetch this texture from the magic_materials mod assets
        texture = "magic_materials_light_rune_ore.png^[combine:16x16:0,0=magic_materials_light_rune_ore.png",
        drop_item = "magic_materials:light_rune",
        cooldown = 10,
    },
}

-- Loop through the table to register nodes dynamically
for id, data in pairs(renewable_ores) do
    local node_name = modname .. ":renewable_" .. id

    minetest.register_node(node_name, {
        description = data.description,
        tiles = {"default_stone.png^" .. data.texture},
        groups = {cracky = 3, cant_to_protect = 1},
        -- Leave drop empty so if anything weird happens, no extra items spawn naturally
        drop = "", 

        -- CRITICAL BYPASS: Custom on_dig avoids minetest.node_dig (which protection mods hook into)
        on_dig = function(pos, node, digger)
            if not digger or not digger:is_player() then return end
            
            -- 1. Award the item directly
            local inv = digger:get_inventory()
            local leftover = inv:add_item("main", data.drop_item .. " 1")
            if not leftover:is_empty() then
                minetest.add_item(pos, leftover)
            end
            
            -- 2. Handle tool wear out manually (since we bypassed default core routines)
            local tool = digger:get_wielded_item()
            local tp = tool:get_tool_capabilities()
            -- Apply standard durability wear if the player is using a valid mining tool
            if tp and tp.groupcaps and tp.groupcaps.cracky then
                local wear = tp.groupcaps.cracky.uses and (65535 / tp.groupcaps.cracky.uses) or 0
                tool:add_wear(wear)
                digger:set_wielded_item(tool)
            end

            -- 3. Instantly kick off your regeneration timer system
            if resource_zones and resource_zones.start_regen_timer then
                resource_zones.start_regen_timer(pos, node_name, data.cooldown)
            else
                -- Emergency manual switch to air if init.lua table is somehow uninitialized
                minetest.remove_node(pos)
            end
        end,
    })
end