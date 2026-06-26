local modname = minetest.get_current_modname()

-- Create the master global table
resource_zones = {}

-- The Depleted Block (Shared placeholder for mined ores)
minetest.register_node(modname .. ":depleted_stone", {
    description = "Depleted Stone (Regenerating...)",
    tiles = {"default_stone.png^[colorize:#111111:150"}, 
    groups = {immortal = 1},
    diggable = false,
    pointable = true,
})

-- Master Ore Timer Function
function resource_zones.start_regen_timer(pos, original_ore_name, cooldown_seconds)
    minetest.set_node(pos, {name = modname .. ":depleted_stone"})
    
    local meta = minetest.get_meta(pos)
    meta:set_string("restores_to", original_ore_name)

    minetest.after(cooldown_seconds, function()
        if minetest.get_node(pos).name == modname .. ":depleted_stone" then
            minetest.set_node(pos, {name = original_ore_name})
            
            minetest.add_particlespawner({
                amount = 12, time = 0.2,
                minpos = {x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5},
                maxpos = {x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5},
                minvel = {x = -1, y = 1, z = -1}, maxvel = {x = 1, y = 3, z = 1},
                texture = "default_stone.png^[colorize:#ffffff:100", 
            })
        end
    end)
end

-- Master Crop Stage Loop Function (No globalsteps!)
-- Moves through stages sequentially based on the provided delay per stage
function resource_zones.start_crop_growth(pos, stages, current_index, delay_per_stage)
    if current_index > #stages then return end
    
    minetest.after(delay_per_stage, function()
        -- Ensure an admin or player didn't completely replace the plant block with something else
        local current_node = minetest.get_node(pos).name
        local expected_node = stages[current_index - 1] or "farming:wheat_8" -- fallback/safety check
        
        -- If the current block matches the stage it was supposed to be in, advance it
        if current_node == expected_node or string.find(current_node, "farming:") then
            local next_stage = stages[current_index]
            minetest.set_node(pos, {name = next_stage})
            
            -- Recurse to the next stage until fully grown
            resource_zones.start_crop_growth(pos, stages, current_index + 1, delay_per_stage)
        end
    end)
end

-- Load the secondary files safely
local path = minetest.get_modpath(modname)
dofile(path .. "/ores.lua")
dofile(path .. "/crops.lua")

-- CRASH SAFETY NET (LBM)
minetest.register_lbm({
    name = modname .. ":fix_stranded_placeholders",
    nodenames = {modname .. ":depleted_stone"},
    run_at_every_load = true,
    action = function(pos, node)
        local meta = minetest.get_meta(pos)
        local restore_target = meta:get_string("restores_to")
        
        if restore_target ~= "" then
            minetest.set_node(pos, {name = restore_target})
        end
    end
})
