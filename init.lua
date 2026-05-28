local modname = minetest.get_current_modname()

-- Explicitly create the global table so other scripts can access the function
resource_zones = {}

-- 1. THE DEPLETED PLACEHOLDER BLOCK
minetest.register_node(modname .. ":depleted_stone", {
    description = "Depleted Stone (Regenerating...)",
    tiles = {"default_stone.png^[colorize:#111111:150"}, 
    groups = {immortal = 1},
    diggable = false,
    pointable = true,
})

-- 2. THE REGENERATION TIMER FUNCTION
function resource_zones.start_regen_timer(pos, original_ore_name, cooldown_seconds)
    -- Instantly swap the dug block to the depleted placeholder
    minetest.set_node(pos, {name = modname .. ":depleted_stone"})
    
    -- Store what the block used to be inside its metadata (Crash Safety)
    local meta = minetest.get_meta(pos)
    meta:set_string("restores_to", original_ore_name)

    -- Start the background countdown
    minetest.after(cooldown_seconds, function()
        -- Only replace if it hasn't been modified/broken by an admin in the meantime
        if minetest.get_node(pos).name == modname .. ":depleted_stone" then
            -- Swap it back to the original ore block
            minetest.set_node(pos, {name = original_ore_name})
            
            -- Add a quick burst of particles when it spawns back
            minetest.add_particlespawner({
                amount = 12,
                time = 0.2,
                minpos = {x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5},
                maxpos = {x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5},
                minvel = {x = -1, y = 1, z = -1},
                maxvel = {x = 1, y = 3, z = 1},
                texture = "default_stone.png^[colorize:#ffffff:100", 
            })
        end
    end)
end

-- 3. CRASH SAFETY NET (LBM)
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
