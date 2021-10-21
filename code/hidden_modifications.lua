--------------------------------------------------------------
--                 hidden_modifications.lua                 --
--------------------------------------------------------------
--                                                          --
-- This file provides the 4 public modder-facing functions  --
-- for hidden entries and categories. These are:            --
--                                                          --
-- <> game_doc.hide_category()                              --
-- <> game_doc.show_category()                              --
-- <> game_doc.hide_entry()                                 --
-- <> game_doc.show_entry()                                 --
--                                                          --
-- Use the above functions to edit hidden-ness of game_doc. --
--------------------------------------------------------------

--------------------------
--
-- hide_category(player_name,category)
--
-- Frontend to the handle_modification()
--
game_doc.hide_category = function(player_name, category)
    game_doc.handle_modification(player_name,category,nil,false)
end

--------------------------
--
-- show_category(player_name,category)
--
-- Frontend to the handle_modification()
--
game_doc.show_category = function(player_name, category)
    game_doc.handle_modification(player_name,category,nil,true)
end

--------------------------
--
-- hide_entry(player_name,category,entry)
--
-- Frontend to the handle_modification()
--
game_doc.hide_entry = function(player_name, category, entry)
    game_doc.handle_modification(player_name,category,entry,false)
end

--------------------------
--
-- show_entry(player_name,category,entry)
--
-- Frontend to the handle_modification()
--
game_doc.show_entry = function(player_name, category, entry)
    game_doc.handle_modification(player_name,category,entry,true)
end