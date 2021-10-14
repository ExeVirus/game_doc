--------------------------------------------------------------
--                     add_entries.lua                      --
--------------------------------------------------------------
--                                                          --
-- This file provides the 3 public modder-facing functions  --
-- for addding entries to game_doc. These are:              --
--                                                          --
-- <> game_doc.add_direct_entry()                           --
-- <> game_doc.add_file_entry()                             --
-- <> game_doc.add_folder_entries()                         --
--                                                          --
-- Use the above functions to register your in-game docs,   --
-- quests, dialog, etc.                                     --
--------------------------------------------------------------

-------------------------------
-- add_direct_entry()
-- category_name: "string" representing the human readable name of the category
-- entry_name: "string" representing the human readable name of the entry
-- hypertext_element: "hypertext[]" element for the entry
-- hidden: default false (based on settings), true will hide from players until
--         shown via hidden_modifications.lua functions >> optional
game_doc.add_direct_entry = function(category_name, entry_name, hypertext_element, hidden)
    --safety check
    if category_name == nil or entry_name == nil or hypertext_element == nil then
        minetest.log("warning", "game_doc.add_direct_entry(): someone tried to add an invalid entry")
        return
    end

    -- handle enabled or disabled hidden system
    if game_doc.settings.hidden_enable then
        --get hide value 
        local hide = hidden or game_doc.settings.hidden_default
        --create category if needed
        if type(game_doc.doc_data[category_name]) ~= "table" then
            game_doc.doc_data[category_name] = { hidden = game_doc.settings.hidden_default, entries = {}}
        end
        --add the entry
        game_doc.doc_data[category_name].entries[entry_name] = { hypertext = hypertext_element, hidden = hide }
    else
        if type(game_doc.doc_data[category_name]) ~= "table" then
            game_doc.doc_data[category_name] = {entries = {}}
            -- Added a new category, invalidate the main form
            if game_doc.mods_loaded == true then
                game_doc.ready_main_form = nil
            end
        end
        --add the entry
        game_doc.doc_data[category_name].entries[entry_name] = { hypertext = hypertext_element }
        -- Added a new entry, invalidate the category form
        if game_doc.mods_loaded == true then
            game_doc.ready_forms[category_name] = nil
        end
    end
end

-------------------------------
-- add_file_entry()
-- category_name: "string" representing the human readable name of the category
-- entry_name: "string" representing the human readable name of the entry
-- markdown_file: file_path to markdown file to load
-- hidden: default false (based on settings), true will hide from players until
--         shown via hidden_modifications.lua functions >> optional
game_doc.add_file_entry = function(category_name, entry_name, markdown_file, hidden)
    --safety check
    if category_name == nil or entry_name == nil or markdown_file == nil then
        minetest.log("warning", "game_doc.add_file_entry(): someone tried to add an invalid entry")
        return
    end

    local x = game_doc.settings.edge_size
    local y = game_doc.settings.edge_size * 2 + game_doc.settings.header_size + game_doc.settings.button_height
    local w = game_doc.settings.width - game_doc.settings.edge_size * 2
    local h = game_doc.settings.height - game_doc.settings.edge_size * 3 - game_doc.settings.header_size - game_doc.settings.button_height

    --load hypertext via markdown2formspec
    game_doc.add_direct_entry(
        category_name,
        entry_name,
        md2f.md2ff(x,y,w,h,markdown_file,entry_name,game_doc.md2f_settings),
        hidden
    )
end


-------------------------------
-- add_folder_entries()
-- category_name: "string" representing the human readable name of the category
-- folder_locaion: file_path to markdown files to load, extension should be ".md"
-- hide_category: default false (based on settings)    >> optional
-- hide_elements: default false (based on settings), true will hide from players until
--         shown via hidden_modifications.lua functions    >> optional
game_doc.add_folder_entries = function(category_name, folder_location, hide_category, hide_elements)
    --safety check
    if category_name == nil or folder_location == nil then
        minetest.log("warning", "game_doc.add_folder_entries(): someone tried to add an invalid entry")
        return
    end

    ------Handle category------
    -- handle enabled or disabled hidden system
    if game_doc.settings.hidden_enable then
        --get hide value 
        local hide = hide_category or game_doc.settings.hidden_default
        --create category if needed
        if type(game_doc.doc_data[category_name]) ~= "table" then
            game_doc.doc_data[category_name] = { hidden = hide }
        else 
            game_doc.doc_data[category_name].hidden = hide --override it
        end
    end

    local filelist = minetest.get_dir_list(folder_location, false) --get all filenames, ignore subdirectories

    for _, filename in pairs(filelist) do --for each file
        local extension = string.sub(filename, -2)
        if(extension == "md") then --md = markdown
            local entry_name = string.sub(filename, 1, -4)
            game_doc.add_file_entry(category_name, entry_name, folder_location.."/"..filename, (hide_elements or game_doc.settings.hidden_default))
        end
    end
end
