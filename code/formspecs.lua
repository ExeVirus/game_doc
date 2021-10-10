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
-- formspecs.                                               --
--------------------------------------------------------------

-- Common header for the three formspecs
local function header()
    return table.concat(
        {
            "formspec_version[4]\n",
            "size[" , game_doc.settings.width , "," , game_doc.settings.height , "]\n",
            "position[0.5,0.5]\n",
            "bgcolor[".. game_doc.settings.bgcolor .."]\n",
        },"")
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

            -- Get list of categories
            local category_list = {}
            for k in pairs(game_doc.doc_data) do table.insert(category_list, k) end
            table.sort(category_list)
            category_list = table.concat(category_list, ",")

            game_doc.ready_main_form = table.concat({
                header(),
                "hypertext[0,0;",w,",",h,";;<style color=",hcolor," size=",hfsize,"><b><center>",mname,"</center></b></style>]\n",
                "button[",edge,",",edge+hsize,";",button_w,",",button_h,";gdmc_help;Help]\n",
                "button_exit[",(taw/2)-button_w/2,",",edge+hsize,";",button_w,",",button_h,";gdmc_quit;Quit]\n",
                "button[",taw-button_w,",",edge+hsize,";",button_w,",",button_h,";gdmc_select;Select]\n",
                "textlist[",edge,",",non_list_height,";",taw,",",h-non_list_height,";gmdc_list;",category_list,";1;false]\n",
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

                -- Get list of categories
                local entry_list = {}
                for k in pairs(game_doc.doc_data[category_name].entries) do table.insert(entry_list, k) end
                table.sort(entry_list)
                entry_list = table.concat(entry_list, ",")

                game_doc.ready_forms[category_name] = table.concat({
                    header(),
                    "hypertext[0,0;",w,",",h,";;<style color=",hcolor," size=",hfsize,"><b><center>",category_name,"</center></b></style>]\n",
                    "button[",edge,",",edge+hsize,";",button_w,",",button_h,";gdmc_back;Back]\n",
                    "button_exit[",(taw/2)-button_w/2,",",edge+hsize,";",button_w,",",button_h,";gdmc_quit;Quit]\n",
                    "button[",taw-button_w,",",edge+hsize,";",button_w,",",button_h,";gdmc_select;Select]\n",
                    "textlist[",edge,",",non_list_height,";",taw,",",h-non_list_height,";gmdc_list;",entry_list,";1;false]\n",
                },"")
            end
            return game_doc.ready_forms[category_name]
        end
    else --error
        return table.concat({
            header(),
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
                    header(),
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

            return table.concat({
                header(),
                "button[",edge,",",edge,";",button_w,",",button_h,";gdmc_back;Back]\n",
                "button_exit[",(taw/2)-button_w/2,",",edge,";",button_w,",",button_h,";gdmc_quit;Quit]\n",
                game_doc.doc_data[category_name].entries[entry_name].hypertext,
            },"")
        end
    else --error
        return table.concat({
            header(),
            "label[0,0;Error: category: ", category_name, ", entry: ", entry_name," does not exist.\n",
        },"")
    end
end