local modname = minetest.get_current_modname()

-- 1. UNBREAKABLE ZONE WALL
minetest.register_node(modname .. ":mine_wall", {
    description = "Indestructible Mine Structure Brick",
    tiles = {"default_desert_stone_brick.png^[colorize:#000000:40"}, 
    groups = {immortal = 1}, 
    diggable = false,
})

-- 2. THE DEPLETED PLACEHOLDER BLOCK
minetest.register_node(modname .. ":depleted_stone", {
    description = "Depleted Stone (Regenerating...)",
    tiles = {"default_stone.png^[colorize:#111111:150"}, 
    groups = {immortal = 1},
    diggable = false,
    pointable = true,
})

-- 3. THE REGENERATION TIMER FUNCTION
-- This can be called by any ore script on your server
function resource_zones.start_regen_timer(pos, original_ore_name, cooldown_seconds)
    -- 1. Instantly swap the dug block to the depleted placeholder
    minetest.set_node(pos, {name = modname .. ":depleted_stone"})
    
    -- 2. Store what the block *used* to be inside its metadata (Crash Safety)
    local meta = minetest.get_meta(pos)
    meta:set_string("restores_to", original_ore_name)

    -- 3. Start the background countdown
    minetest.after(cooldown_seconds, function()
        -- Only replace if it hasn't been modified by an admin/worldedit in the meantime
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
                texture = "default_stone.png^[colorize:#ffffff:100", -- White flash particles
            })
        end
    end)
end

-- 4. CRASH SAFETY NET (LBM)
-- If the server restarts, this fixes any "stuck" placeholders instantly on chunk load
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
