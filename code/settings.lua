--------------------------------------------------------------
--                     settings.lua                         --
--------------------------------------------------------------
--                                                          --
-- Merely loads the settingtypes.txt into game_doc          --
--------------------------------------------------------------
game_doc.settings = {}

-- Enable/Disable the hidden entries system
local hidden_enable = minetest.settings:get("game_doc_hidden_enable")
if hidden_enable == nil then
    game_doc.settings.hidden_enable = false
else
    if hidden_enable == "Enabled" then
        game_doc.settings.hidden_enable = true
        game_doc.player_data = {}
    else
        game_doc.settings.hidden_enable = false
    end
end

-- All entires and categories are hidden by default
local hidden_default = minetest.settings:get("game_doc_hidden_default")
if hidden_default == nil then
    game_doc.settings.hidden_default = false
else
    if hidden_default == "Enabled" then
        game_doc.settings.hidden_enable = true
    else
        game_doc.settings.hidden_enable = false
    end
end