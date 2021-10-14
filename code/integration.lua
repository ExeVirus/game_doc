--------------------------------------------------------------
--                     integration.lua                      --
--------------------------------------------------------------
--                                                          --
-- This file will optionally register game_doc with i3,     --
-- and provide a chat command to access the main game_doc   --
-- formspec.                                                --
--------------------------------------------------------------

-- Chat Command Integration (disabled if i3 is present)
if game_doc.settings.enable_chat_command and not rawget(_G, "i3") then
    minetest.register_chatcommand("doc", {
        privs = {
            interact = true,
        },
        func = function(player_name, _)
            --game_doc.player_data[player_name].selected_category = 1
            minetest.show_formspec(player_name,"gmdc_main",game_doc.main_form(player_name))
        end,
    })
end

-- i3 Integration

-- The following is essentially a bunch of overrides on the default guide formspecs
-- so that it fits very nicely into i3's world
if rawget(_G, "i3") then
    game_doc.i3 = true

    -- Override the header and other values, as everything will flow through i3
    game_doc.header = function() return "" end
    game_doc.settings.edge_size = 0.1
    game_doc.settings.width = 10.23
    game_doc.settings.height = 12
    game_doc.settings.button_width = 0.6
    game_doc.settings.button_height = 0.6
    game_doc.settings.header_size = 0
    game_doc.settings.main_font_size = 26
    game_doc.settings.heading_color = "#FFF"
    game_doc.current_form = "main"
    game_doc.md2f_settings.background_color = "#bababa25"
    
    --Register our new "Game Guide" Tab
    i3.new_tab {
        name = "guide",
        description = "Game Guide",
    
        -- Determine if the tab is visible by a player, `false` or `nil` hide the tab
        access = function() return true end,
    
        formspec = function(player, data, fs) end,
    
        -----------------------
        -- fields()
        --
        -- player: player objectRef
        -- data: internal i3 data
        -- fields: fields received by i3
        --
        -- This function is where all the magical integration happens
        -- Long story short, the tab.formspec function gets called 
        -- with set_fs, which is the final bit of this function. 
        -- In order to support multiple pages, we have to override that 
        -- formspec function to write out the correct player formspec
        -- 
        -- The correct formspec can be the help page, main page, 
        -- category page, or entry page. What page is shown depends
        -- on what fields are received.
        --
        -- The flow of the function is as follows
        -- 1. Handle Fields
        -- 2. Override tab[our_index].formspec
        -- 3. Show/Update formspec

        fields = function(player, data, fields)
            local player_name = player:get_player_name()
            -----------------Handle Main Form Fields------------------
            if game_doc.player_data[player_name].current_form == "main" then
                --Parse and process actual fields
                if fields.gmdc_help then
                    game_doc.player_data[player_name].current_form = "help"
                elseif fields.gmdc_select then
                    game_doc.player_data[player_name].current_form = "category"
                elseif fields.gmdc_list then
                    local type, index = fields.gmdc_list:sub(1,3), tonumber(fields.gmdc_list:sub(5))
                    if type == "CHG" then
                        game_doc.player_data[player_name].category_index = index
                    elseif type == "DCL" then
                        game_doc.player_data[player_name].category_index = index
                        game_doc.player_data[player_name].current_form = "category"
                    end
                end
            -----------------Handle Category Form Fields------------------
            elseif game_doc.player_data[player_name].current_form == "category" then
                if fields.gmdc_back then
                    game_doc.player_data[player_name].category_index = nil
                    game_doc.player_data[player_name].current_form = "main"
                elseif fields.gmdc_select then
                    game_doc.player_data[player_name].current_form = "entry"
                elseif fields.gmdc_list then
                    local type, index = fields.gmdc_list:sub(1,3), tonumber(fields.gmdc_list:sub(5))
                    if type == "CHG" then
                        game_doc.player_data[player_name].selected_entry = index
                    elseif type == "DCL" then
                        game_doc.player_data[player_name].selected_entry = index
                        game_doc.player_data[player_name].current_form = "entry"
                    end
                end
            -----------------Handle Entry Form Fields------------------
            elseif game_doc.player_data[player_name].current_form == "entry" then
                if fields.gmdc_back then
                    game_doc.player_data[player_name].selected_entry = nil
                    game_doc.player_data[player_name].current_form = "category"
                end
            -----------------Handle Help Form Fields------------------
            elseif game_doc.player_data[player_name].current_form == "help" then
                if fields.gmdc_back then
                    game_doc.player_data[player_name].category_index = nil
                    game_doc.player_data[player_name].current_form = "main"
                end
            else --hasn't been set yet
                game_doc.player_data[player_name].current_form = "main"
            end
            
            -----Override Formspec for tab-----
            local tabs = i3.get_tabs()
            local index = nil
            for i=1,#tabs,1 do
                if tabs[i].name == "guide" then
                    index = i
                end
            end
            if index ~= nil then
                -------------Handle displaying correct formspec-------------
                local _fs = "" --variable to store the formspec to be shown
                if game_doc.player_data[player_name].current_form == "help" then
                    _fs = game_doc.help_form(player_name)
                elseif game_doc.player_data[player_name].current_form == "category" then
                    -- Get the selected category name
                    local index = game_doc.player_data[player_name].category_index or nil
                    if index == nil then 
                        _fs = game_doc.main_form(player_name)
                        game_doc.player_data[player_name].current_form = "main"
                    else
                        if game_doc.settings.hidden_enable then
        
                        else
                            game_doc.player_data[player_name].selected_category = game_doc.category_list[index]
                            _fs = game_doc.category_form(game_doc.player_data[player_name].selected_category, player_name)
                        end
                    end
                elseif game_doc.player_data[player_name].current_form == "entry" then
                    -- Get the selected entry name
                    local index = game_doc.player_data[player_name].selected_entry or nil
                    if index == nil then
                        _fs = game_doc.category_form(game_doc.player_data[player_name].selected_category, player_name)
                        game_doc.player_data[player_name].current_form = "category"
                    else
                        if game_doc.settings.hidden_enable then
        
                        else
                            local category = game_doc.player_data[player_name].selected_category
                            local entry = game_doc.entry_lists[category].entry_list[index]
                            _fs = game_doc.entry_form(category, entry, player_name)
                        end
                    end
                else --main
                    _fs = game_doc.main_form(player_name)
                end
                tabs[index].formspec = function(player, data, fs)
                    fs(_fs)
                end
            else
                tabs[index].formspec = function(player, data, fs)
                    fs("label[1,1,game_doc error in integration.lua]")
                end
            end
            -----Display Formspec-----
            i3.set_fs(player)
        end,
    }
end
