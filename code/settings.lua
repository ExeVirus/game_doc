---------------------------------------------------------------
--                     settings.lua                          --
---------------------------------------------------------------
--                                                           --
--      Merely loads the settingtypes.txt into game_doc      --
--      Make edits in settingstypes.txt or main menu         --
---------------------------------------------------------------
game_doc.settings = {}


---------------------Helper Functions--------------------------

-----------------------------
-- handleBooleanEnum()
--
-- Expects the settingtypes value to be an enum of "Enabled" or "Disabled"
-- settingtypes_name: the settingtypes.txt and main menu name
-- setting_name: the internal game_doc.settings name
-- default: 'true' or 'false' when setting is 'nil'
local function handleBooleanEnum(settingtypes_name, setting_name, default)
    local setting_value = minetest.settings:get(settingtypes_name)
    if setting_value == nil then
        game_doc.settings[setting_name] = default
    else
        if setting_value == "Enabled" then
            game_doc.settings[setting_name] = true
        else
            game_doc.settings[setting_name] = false
        end
    end
end

local function handleStandardVariable(settingtypes_name, setting_name, default)
    game_doc.settings[setting_name] = minetest.settings:get(settingtypes_name) or default
end

---------------------------------------------------------------
-------------------------Main Settings-------------------------
---------------------------------------------------------------

-- Enable/Disable the hidden entries system
handleBooleanEnum("game_doc_hidden_enable", "hidden_enable", false)

-- All entires and categories are hidden by default
handleBooleanEnum("game_doc_hidden_default", "hidden_default", false)

-- Enable Chat command /game_doc (to show main formspec)
handleBooleanEnum("game_doc_enable_chat_command", "enable_chat_command", true)

---------------------------------------------------------------
-----------------------Graphical Settings----------------------
---------------------------------------------------------------

               --Dimensions--

-- Full Width of all game_doc formspecs
handleStandardVariable("game_doc_width", "width", 20.0)

-- Full height of all game_doc formspecs
handleStandardVariable("game_doc_height", "height", 20.0)

-- The margin between boxes and borders
handleStandardVariable("game_doc_edge_size", "edge_size", 0.2)

-- The header text area size (height)
handleStandardVariable("game_doc_entry_header_size", "header_size", 2.0)

-- The button widths
handleStandardVariable("game_doc_button_width", "button_width", 5.0)

-- The button heights
handleStandardVariable("game_doc_button_height", "button_height", 1.6)

                   --Colors--

-- Formspec Background Color
handleStandardVariable("game_doc_bgcolor", "bgcolor", "#111E")

-- Formspec heading Color
handleStandardVariable("game_doc_heading_color", "heading_color", "#FFF")

               --Text Specific--

-- Main Formspec Name
handleStandardVariable("game_doc_main_name", "main_name", "Game Guide")

-- Main Formspec Heading Font-Size
handleStandardVariable("game_doc_main_font_size", "main_font_size", 32)

               -- Markdown2Formspec
game_doc.md2f_settings = {
    background_color = "#bababa25",
    font_color = "#FFF",
    heading_1_color = "#AFA",
    heading_2_color = "#FAA",
    heading_3_color = "#AAF",
    heading_4_color = "#FFA",
    heading_5_color = "#AFF",
    heading_6_color = "#FAF",
    heading_1_size = "26",
    heading_2_size = "24",
    heading_3_size = "22",
    heading_4_size = "20",
    heading_5_size = "18",
    heading_6_size = "16",
    code_block_mono_color = "#6F6",
    code_block_font_size = 14,
    mono_color = "#6F6",
    block_quote_color = "#FFA",
}