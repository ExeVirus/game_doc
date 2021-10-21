--------------------------------------------------------------
--                  player_management.lua                   --
--------------------------------------------------------------
--                                                          --
-- This file manages the somewhat complex process of        --
-- managing player hidden values via mod storage.           --
-- For example:                                             --
--                                                          --
-- When a category is hidden by default, and a player has   --
-- somehow unlocked that category or entry, they will have  --
-- an entry in their player table specifying as such.       --
--                                                          --
-- For this table, categories are stored in one list, and   --
-- Entires are stored in a separate table that uses the     --
-- category as a key, to speed up the formspec display at   --
-- runtime.                                                 --
--                                                          --
-- Nothing happens in this file if the hidden system is     --
-- disabled, as it's un-needed to track per-player data.    --
--                                                          --
-- Persistence is handled by storing each player's data     --
-- by name in the world folder under "game_doc/<name>.json" --
--                                                          --
-- Note: if you have a player reveal a hidden entry, and    --
-- then you remove that entry for some reason, they will    --
-- have a memory leak here where we track that hidden value --
-- but it's no longer needed. This is done so if that entry --
-- returned, the old player value will be remembered.       --
--------------------------------------------------------------

-- Reused Variables
local world_path = minetest.get_worldpath()

--------------------------
--
-- load_from_json(file_name)
--
-- Loads a table from a .json file (if present) in the world
-- folder
--
game_doc.load_from_json = function(file_name) 
    local data = nil
    local f = io.open(world_path .. "/game_doc/" .. file_name .. ".json", "rb")
    if f ~= nil then
        local file_contents = f:read("*all")
        data = minetest.parse_json(file_contents)
        f:close()
    end
    return data
end

--------------------------
--
-- save_to_json(file_name, table)
--
-- Save a provided table to a .json file in the world
-- folder
--
game_doc.save_to_json = function(file_name, table)
    local f = io.open(world_path .. "/game_doc/" .. file_name .. ".json", "wb")
    if f ~= nil and type(table) == "table" then
        f:write(minetest.write_json(table))
        f:close()
    else
        minetest.log("warning", "Unable to save json in world folder (game_doc.save_json() in player_management.lua")
    end
end

-- At load time we have to do several steps
minetest.register_on_mods_loaded(
function()
    --Generate the default hidden table
    game_doc.build_hidden_defaults()
    --Load the old defaults table if applicable
    local old_table = game_doc.load_from_json("hidden.defaults")

    if old_table then
        --Get a diff between the old table and the current
        local diff = game_doc.hidden_table_diff(old_table) --diff only contains a list of categories that are changed, and a list of entries that are changed

        if diff then
            -- Adjust *every* player file
            game_doc.fix_all_players_defaults(diff)
        end
    end

    --Save the new defaults
    game_doc.save_to_json("hidden.defaults", game_doc.hidden_default)
end
)

--------------------------
--
-- build_hidden_defaults()
--
-- Generates the default hidden values for
-- all categories and entries
--
game_doc.build_hidden_defaults = function()
    game_doc.hidden_default = {}
    local hd = game_doc.hidden_default
    hd.shown_categories = {} --for formspec display
    hd.categories = {} --for modifications and saving
    hd.entry_table = {}
    for k,v in pairs(game_doc.doc_data) do
        hd.categories[k] = v.hidden
        if not v.hidden then
            table.insert(hd.shown_categories,k)
        end
        hd.entry_table[k] = {}
        local category = hd.categories[k]
        category.entries = {}
        category.shown_entries = {}
        for _k, _v in pairs(v.entries) do
            category.entries[k] = v.hidden
            if not _v.hidden then
                table.insert(category.shown_entries,_k)
            end
        end
        table.sort(category.shown_entries)
    end
    table.sort(hd.shown_categories)
end

--------------------------
--
-- on_joinplayer()
--
-- handles creating and loading a player's stored data
--
minetest.register_on_joinplayer(
function(player, last_login)
    local player_name = player:get_player_name()
    game_doc.load_player_data(player_name)
end)

--------------------------
--
-- load_player_data()
--
-- loads a player's data IF it isn't already loaded
--
game_doc.load_player_data = function(player_name) 
    if game_doc.player_data[player_name] == nil then
        local loaded_data = game_doc.load_from_json(player_name)
        game_doc.setup_player_hidden_values(player_name, loaded_data) -- default + player diff (if not nil)
    end
end

--------------------------
--
-- save_player_data()
--
-- loads a player's data IF it isn't already loaded
--
game_doc.save_player_data = function(player_name) 
    if game_doc.player_data[player_name] ~= nil then
        local to_save = {
            categories = table.copy(game_doc.player_data[player_name].categories),
            entry_table = table.copy(game_doc.player_data[player_name].entry_table),
        }
        -- diff away the defaults
        game_doc.subtract_defaults(to_save)

        -- save the diff'd data
        game_doc.save_to_json(player_name, to_save)
    end
end

--------------------------
--
-- on_leaveplayer()
--
-- handles setting player's data to nil
-- (frees the memory)
--
minetest.register_on_leaveplayer(
function(player, timed_out)
    local player_name = player:get_player_name()
    game_doc.player_data[player_name] = nil
end)

--------------------------
--
-- handle_modification(player_name,category,entry,show/hide) {true/false}
--
-- handles changes to hidden values for a player's categories or entry
--
game_doc.handle_modification = function (player_name, category, entry, show)
    if category == nil then
        return --Can't change what doesn't exist
    else if entry == nil then
        --This is a category change

        --Ensure the player data is loaded

        local player_data = game_doc.player_data[player_name]

        -- Ignore "modifications" that don't affect anything
        if player_data.categories[category] then
            if not show then
                return --it's already hidden, so nothing needs to be done
            end
        else
            if show then
                return --It's already shown, so nothing needs to be done
            end
        end

        --Update the runtime lists
        if show then
            player_data.categories[category] = ~show
            table.insert(player_data.shown_categories, category)
            table.sort(player_data.shown_categories)
        else
            player_data.categories[category] = ~show
            for i=1,#player_data.shown_categories,1 do
                if player_data.shown_categories[i] == category then
                    table.remove(player_data.shown_categories, i)
                    break
                end
            end
        end
        --overwrite the player's saved values 
        game_doc.save_player_data(player_name)
    else --Handle an entry change


        --overwrite the player's saved values 
        game_doc.save_player_data(player_name)
    end
end


