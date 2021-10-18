--------------------------------------------------------------
--                    direct_access.lua                     --
--------------------------------------------------------------
--                                                          --
-- This file provides the 2 public modder-facing functions  --
-- for accessing game_doc data. These are:                  --
--                                                          --
-- <> game_doc.get_doc_data()                               --
-- <> game_doc.get_hidden_data(player_name)                 --
--                                                          --
-- Use the above functions to access and possibly make      --
-- changes to the backend data in game_doc                  --
--------------------------------------------------------------

game_doc.get_doc_data = function()
    return game_doc.doc_data
end

game_doc.get_hidden_data = function(player_name)
    return game_doc.player_data[player_name] --can be nil
end

-- Simple, right? 