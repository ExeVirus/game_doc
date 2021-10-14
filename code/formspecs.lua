--------------------------------------------------------------
--                     formspecs.lua                        --
--------------------------------------------------------------
--                                                          --
-- This file provides the 3 public modder-facing functions  --
-- for generating game_doc formspecs. These are:            --
--                                                          --
-- <> game_doc.main_form()                                  --
-- <> game_doc.category_form()                              --
-- <> game_doc.entry_form()                                 --
--                                                          --
-- Use the above functions to show the stadard game_doc     --
-- formspecs. There is a fourth, private function which     --
-- provides the help formspec found in the main form.       --
--                                                          --
-- This file also provides the functions for receiving and  --
-- responding to the submission of these formspecs after    --
-- these functions are defined.                             --
--------------------------------------------------------------

-- Common functions for the three formspecs
game_doc.header = function()
    return table.concat(
        {
            "formspec_version[4]\n",
            "size[" , game_doc.settings.width , "," , game_doc.settings.height , "]\n",
            "position[0.5,0.5]\n",
            "bgcolor[".. game_doc.settings.bgcolor .."]\n",
        },"")
end

--Overridable button functions for i3 support
game_doc.help_button = function(x,y,w,h,i3)
    if i3 then
        return table.concat({
            "image_button[",x,",",y,";",w,",",h,";game_doc_help.png;gmdc_help;;;false;game_doc_help_pressed.png]"
        })
    else
        return table.concat({"button[",x,",",y,";",w,",",h,";gmdc_help;Help]\n"})
    end
end

game_doc.back_button = function(x,y,w,h,i3)
    if i3 then
        return table.concat({"image_button[",x,",",y,";",w,",",h,";game_doc_back.png;gmdc_back;;;false;game_doc_back_pressed.png]"})
    else
        return table.concat({"button[",x,",",y,";",w,",",h,";gmdc_back;Back]\n"})
    end
end

game_doc.select_button = function(x,y,w,h,i3)
    if i3 then
        return table.concat({"image_button[",x,",",y,";",w,",",h,";game_doc_select.png;gmdc_select;;;false;game_doc_select_pressed.png]"})
    else
        return table.concat({"button[",x,",",y,";",w,",",h,";gmdc_select;Select]\n"})
    end
end

-- Function for hiding spaces to fix reorder issues
local function move_spaces(s)
    local new_table = {}
    for i=1,#s do
        local _s = s[i]
        new_table[i] = _s:match("%s*(.*)").._s:match("%s*")
    end
    return new_table
end

------------------------------
-- main_form
--
-- Reuses a pre-calculated main form when possible.
-- This is generated after mod loading. If you
-- add entries during runtime, this ready made form
-- will be invalidated, and be recalculated once.
-- Handy, right?
--
-- If you don't provide a player_name or an invalid name,
-- the default hidden values are shown. I.e. fresh player settings
--
game_doc.main_form = function(player_name)
    --different if using the hidden system
    if game_doc.settings.hidden_enable then

    else
        -- reuse a ready made form when possible
        if game_doc.ready_main_form == nil then
            
            ----local vars for calculation----
            local edge = game_doc.settings.edge_size
            local w = game_doc.settings.width
            local h = game_doc.settings.height
            local button_w = game_doc.settings.button_width
            local button_h = game_doc.settings.button_height
            local taw = w - edge * 2 --text_area_width
            local hsize = game_doc.settings.header_size
            local hcolor = game_doc.settings.heading_color
            local hfsize = game_doc.settings.main_font_size
            local mname = game_doc.settings.main_name
            local non_list_height = hsize+edge*2+button_h

            if game_doc.category_list == nil then
                -- Get list of categories
                local category_list = {}
                for k in pairs(game_doc.doc_data) do table.insert(category_list, k) end
                table.sort(category_list)
                game_doc.category_list = category_list
                game_doc.category_comma_list = table.concat(move_spaces(category_list), ",")
            end

            game_doc.ready_main_form = table.concat({
                game_doc.header(),
                "hypertext[0,0;",w,",",h,";;<style color=",hcolor," size=",hfsize,"><b><center>",mname,"</center></b></style>]\n",
                game_doc.help_button(edge, edge+hsize, button_w, button_h, game_doc.i3),
                game_doc.select_button(taw-button_w, edge+hsize, button_w, button_h, game_doc.i3),
                "box[",edge,",",non_list_height,";",taw,",",h-non_list_height-edge,";#bababa25]\n",
                "textlist[",edge,",",non_list_height,";",taw,",",h-non_list_height-edge,";gmdc_list;",game_doc.category_comma_list,";;true]\n",
            },"")
        end
        return game_doc.ready_main_form
    end
end

------------------------------
-- category_form
--
-- Reuses a pre-calculated form when possible.
-- This is generated after mod loading. If you
-- add entries during runtime, this ready made form
-- will be invalidated, and be recalculated once.
-- Handy, right?
--
-- If you don't provide a player_name or an invalid name,
-- the default hidden values are shown. I.e. fresh player settings
--
game_doc.category_form = function(category_name, player_name)
    if game_doc.doc_data[category_name] ~= nil then
        --different if using the hidden system
        if game_doc.settings.hidden_enable then

        else
            -- reuse a ready made form when possible
            if game_doc.ready_forms[category_name] == nil then
                
                ----local vars for calculation----
                local edge = game_doc.settings.edge_size
                local w = game_doc.settings.width
                local h = game_doc.settings.height
                local button_w = game_doc.settings.button_width
                local button_h = game_doc.settings.button_height
                local taw = w - edge * 2 --text_area_width
                local hsize = game_doc.settings.header_size
                local hcolor = game_doc.settings.heading_color
                local hfsize = game_doc.settings.main_font_size
                local non_list_height = hsize+edge*2+button_h

                if game_doc.category_list == nil then
                    -- Get list of categories
                    local category_list = {}
                    for k in pairs(game_doc.doc_data) do table.insert(category_list, k) end
                    table.sort(category_list)
                    game_doc.category_list = category_list 
                    game_doc.category_comma_list = table.concat(category_list, ",")
                end

                -- Get list of entries
                if game_doc.entry_lists == nil then game_doc.entry_lists = {} end
                if game_doc.entry_lists[category_name] == nil then
                    game_doc.entry_lists[category_name] = {}
                    local entry_list = {}
                    for k in pairs(game_doc.doc_data[category_name].entries) do table.insert(entry_list, k) end
                    table.sort(entry_list)
                    game_doc.entry_lists[category_name].entry_list = entry_list
                    game_doc.entry_lists[category_name].entry_comma_list = table.concat(move_spaces(entry_list), ",")
                end

                game_doc.ready_forms[category_name] = table.concat({
                    game_doc.header(),
                    "hypertext[0,0;",w,",",h,";;<style color=",hcolor," size=",hfsize,"><b><center>",category_name,"</center></b></style>]\n",
                    game_doc.back_button(edge, edge+hsize, button_w, button_h, game_doc.i3),
                    game_doc.select_button(taw-button_w, edge+hsize, button_w, button_h, game_doc.i3),
                    "box[",edge,",",non_list_height,";",taw,",",h-non_list_height-edge,";#bababa25]\n",
                    "textlist[",edge,",",non_list_height,";",taw,",",h-non_list_height,";gmdc_list;",game_doc.entry_lists[category_name].entry_comma_list,";;true]\n",
                },"")
            end
            return game_doc.ready_forms[category_name]
        end
    else --error
        return table.concat({
            game_doc.header(),
            "label[0,0;Error: category: ", category_name, " does not exist.\n",
        },"")
    end
end

------------------------------
-- entry_form
--
-- Doesn't display if the player should not be able to see it
--
game_doc.entry_form = function(category_name, entry_name, player_name)
    --verify it exists
    if game_doc.doc_data[category_name] ~= nil and game_doc.doc_data[category_name].entries[entry_name] ~= nil then
        --different if using the hidden system
        if game_doc.settings.hidden_enable then
            --verify they are able to see the category and entry
            if game_doc.doc_data[category_name].hidden == false and game_doc.doc_data[category_name].entries[entry_name].hidden == false then
                
            else
                return table.concat({
                    game_doc.header(),
                    "label[0,0;Error: player: ", player_name, " is unable to view this hidden entry.\n",
                },"")
            end
        else
            ----local vars for calculation----
            local edge = game_doc.settings.edge_size
            local w = game_doc.settings.width
            local h = game_doc.settings.height
            local button_w = game_doc.settings.button_width
            local button_h = game_doc.settings.button_height
            local taw = w - edge * 2 --text_area_width
            local hsize = game_doc.settings.header_size
            local hcolor = game_doc.settings.heading_color
            local hfsize = game_doc.settings.main_font_size

            return table.concat({
                game_doc.header(),
                "hypertext[0,0;",w,",",h,";;<style color=",hcolor," size=",hfsize,"><b><center>",entry_name,"</center></b></style>]\n",
                game_doc.back_button(edge, edge+hsize, button_w, button_h, game_doc.i3),
                game_doc.doc_data[category_name].entries[entry_name].hypertext,
            },"")
        end
    else --error
        return table.concat({
            game_doc.header(),
            "label[0,0;Error: category: ", category_name, ", entry: ", entry_name," does not exist.\n",
        },"")
    end
end

------------------------------
-- help_form
--
-- Merely explains how to use this game_doc documentation
--
game_doc.help_form = function()
    local x = game_doc.settings.edge_size
    local y = game_doc.settings.edge_size + game_doc.settings.header_size
    local w = game_doc.settings.width - game_doc.settings.edge_size * 2
    local h = game_doc.settings.height - game_doc.settings.edge_size * 2 - game_doc.settings.header_size
    local edge = game_doc.settings.edge_size
    local button_w = game_doc.settings.button_width
    local button_h = game_doc.settings.button_height
    local hsize = game_doc.settings.header_size
    return table.concat({
        game_doc.header(),
        game_doc.back_button(edge, edge+hsize, button_w, button_h, game_doc.i3),
        md2f.md2f(x,y+edge+button_h,w,h-edge*2-button_h,
        --begin markdown for help file
[[# **Game Guide Help**
This game guide is built to provide you with all the knowledge needed to enjoy every part of this game: from building, to mining, farming, fighting, flying, tinkering, and more.
#### Categories and Entries
The guide is broken into *Categories* and *Entires*. *Categories* are shown on the main
page, and once you **select** one or double click/tap that option in the list,
you will be greeted with that Category's page of *Entries*.

You then do the same on the entry page, and now you can read all about that exact topic.]]
        --end markdown for help file
        ,"game_doc_help",
        game_doc.md2f_settings),
    },"")
end


------------------------------
-- on_recieve
--
-- Handles the above 4 formspec submissions
--
minetest.register_on_player_receive_fields(
function(player, formname, fields)
    --Early fail for efficiency
    if formname:sub(1,4) == "gmdc" then
        local player_name = player:get_player_name()
        minetest.log(dump(fields))

        ---------------Main Form---------------
        if formname == "gmdc_main" then
            --reused local function 
            local function show_category(player_name)
                local index = game_doc.player_data[player_name].selected_category or nil
                if index == nil then return end
                if game_doc.settings.hidden_enable then

                else
                    game_doc.player_data[player_name].selected_category = game_doc.category_list[index]
                    minetest.show_formspec(player_name,"gmdc_category",game_doc.category_form(game_doc.category_list[index], player_name))
                end
            end

            --handle help
            if fields.gmdc_help then
                minetest.show_formspec(player_name,"gmdc_help", game_doc.help_form())
            --handle select
            elseif fields.gmdc_select then
                show_category(player_name)
            --handle text_list
            elseif fields.gmdc_list then
                local type, index = fields.gmdc_list:sub(1,3), tonumber(fields.gmdc_list:sub(5))
                if type == "CHG" then
                    game_doc.player_data[player_name].selected_category = index
                elseif type == "DCL" then
                    game_doc.player_data[player_name].selected_category = index
                    show_category(player_name)
                end
            end

        ---------------Category Form---------------
        elseif formname == "gmdc_category" then
            --reused local function 
            local function show_entry(player_name)
                local index = game_doc.player_data[player_name].selected_entry or nil
                if index == nil then return end
                if game_doc.settings.hidden_enable then

                else
                    local category = game_doc.player_data[player_name].selected_category
                    local entry = game_doc.entry_lists[category].entry_list[index]
                    minetest.show_formspec(player_name,"gmdc_entry",game_doc.entry_form(category, entry, player_name))
                end
            end
            --handle back
            if fields.gmdc_back then
                game_doc.player_data[player_name].selected_category = nil
                minetest.show_formspec(player_name,"gmdc_main", game_doc.main_form(player_name))
            --handle select
            elseif fields.gmdc_select then
                show_entry(player_name)
            --handle text_list
            elseif fields.gmdc_list then
                local type, index = fields.gmdc_list:sub(1,3), tonumber(fields.gmdc_list:sub(5))
                if type == "CHG" then
                    game_doc.player_data[player_name].selected_entry = index
                elseif type == "DCL" then
                    game_doc.player_data[player_name].selected_entry = index
                    show_entry(player_name)
                end
            end
        ---------------Entry Form---------------
        elseif formname == "gmdc_entry" then
            --handle back
            if fields.gmdc_back then
                game_doc.player_data[player_name].selected_entry = nil
                minetest.show_formspec(player_name,"gmdc_category", game_doc.category_form(game_doc.player_data[player_name].selected_category,player_name))
            end
        
        ---------------Help Form---------------
        elseif formname == "gmdc_help" then
            if fields.gmdc_help_back then
                game_doc.player_data[player_name].selected_category = nil
                minetest.show_formspec(player_name,"gmdc_main", game_doc.main_form(player_name))
            end
        end
    end
end)